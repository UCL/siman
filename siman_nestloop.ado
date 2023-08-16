*! version 1.8   14aug2023
* version 1.8.1 16aug2023	  IW changed how main graph is written, so that stagger works; correct looping over PMs and targets; general tidying up and clarifying; correct use of true
* version 1.8   14aug2023	  IW extended lines to include last scenario; reduced default PMs; range correctly allows for all methods
* version 1.7.3    01aug2023  IW added legendoff option; made name() work
*  version 1.7.2   22may2023  IW fixes
*  version 1.7.1 13mar2023    EMZ added error message
*  version 1.7   11aug2022    EMZ fixed bug to allow name() in call  
*  version 1.6   11july2022   EMZ renamed created variables to have _ infront
*  version 1.5   19may2022    EMZ added error message
*  version 1.4   31mar2022    EMZ minor updates
*  version 1.3   10jan2022    EMZ updates from IW testing.
*  version 1.2   06Dec2021    Numeric dgm variable labels to 2d.p. in graph. dgm() in nestloop to take the order specified in dgmorder() so that 
*                             siman_setup does not need to be re-run if the user would like to change the order of the dgms.
*  version 1.1   02Dec2021    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Ian White's nplot.ado

capture program drop siman_nestloop
program define siman_nestloop, rclass
version 15

* siman_nestloop [performancemeasures] [if] [, *]
// PARSE
syntax [anything] [if], ///
	[DGMOrder(string) ///
	STAGger(real 0) Connect(string) noREFline /// control main graph
	FRACLegend(real 0.3) FRACGap(real 0) /// control sizing
	LEGENDGap(real 3) LEGENDColor(string) /// control descriptor graph
	LEGENDPattern(string) LEGENDSize(string) LEGENDSTYle(string) LEGENDWidth(string) /// control descriptor graph
	debug pause legendoff /// undocumented
	LColor(string) LPattern(string) LSTYle(string) LWidth(string) /// twoway options for main graph
	name(string) * /// twoway options for overall graph
	] 

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* Check DGMs are in the dataset, if not produce an error message
if "`dgm'"=="" {
	di as error "dgm variable is missing: can not run nested loop plot."
	exit 498
	}
	
* If only 1 dgm in the dataset, produce error message as nothing will be graphed
if `ndgm'==1 {
	di as error "Only 1 dgm in the dataset, nothing to graph."
	exit 498
}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman analyse first before siman nestloop."
	exit 498
	}

* check performance measures
qui levelsof _perfmeascode, local(allpms) clean 
local wrongpms : list anything - allpms
if !mi("`wrongpms'") {
	di as error "Performance measures wrongly specified: `wrongpms'"
	exit 498
}	
if "`anything'"=="" {
	if !mi("`true'") {
		local pmdefault bias empse cover
	}
	else {
		local pmdefault mean empse relerror
		local missedmessage " and no true value"
	}
	di as text "Performance measures not specified`missedmessage': defaulting to `pmdefault'"
	local anything `pmdefault'
}
else if "`anything'"=="all" local anything `allpms'
local pmlist `anything'
local npms : word count `pmlist'

* parse name
if !mi(`"`name'"') {
	gettoken name nameopts : name, parse(",")
}
else {
	local name simannestloop
	local nameopts , replace
}

* graph option parsing
if `fraclegend'<=0 | `fraclegend'>=1 {
	di as error "fraclegend() must be >0 and <1"
	exit 498
}
if `fracgap'<0 | `fracgap'>=1 {
	di as error "fracgap() must be >=0 and <1"
	exit 498
}
if mi("`connect'") local connect J // could be L
if mi("`legendcolor'") local legendcolor gs4
if mi("`legendpattern'") local legendpattern solid
if mi("`legendsize'") local legendsize vsmall

*** END OF PARSING ***

preserve

* keep performance measures only
qui drop if `rep'>0

* Need data in wide format (with method/perf measures wide) which siman reshape does not offer, so do below.  Start with reshaping to long-long format if not already in this format
* If data is not in long-long format, then reshape
if `nformat'!=1 {
	qui siman reshape, longlong
	foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
	}
}

* If user has specified an order for dgm, use this order (so that siman_setup doesn't need to be re-run).  Take out -ve signs if there are any.
if !mi("`dgmorder'") {
	local ndgmorder: word count `dgmorder'
	qui tokenize `dgmorder'
	forvalues d = 1/`ndgmorder' {
		local dgmassigned = 0
		if  substr("``d''",1,1)=="-" {
			local e = substr("``d''", 2,strlen("``d''"))
			if `d'==1 local dgmnew `e'
			else local dgmnew `dgmnew' `e'
			local dgmassigned = 1
		}
		if `dgmassigned'!=1 {
			if `d'==1 local dgmnew ``d''
			else local dgmnew `dgmnew' ``d''
		}
	}
	local dgm = `"`dgmnew'"'
}

* if the user has not specified 'if' in the siman nestloop syntax, but there is one from siman analyse then use that 'if'
if ("`if'"=="" & "`ifanalyse'"!="") local ifnestloop = `"`ifanalyse'"'
else local ifnestloop = `"`if'"'
tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifnestloop' 
qui sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman nestloop.  If you have not specified an 'if' in siman nestloop, but you specified one in siman setup/analyse, then that 'if' will have been applied to siman nestloop." 
	exit 498
	}
qui keep if `touseif'

* create a variable `scenario' that uniquely identifies each of the dgm combinations
tempvar scenario
* option to order dgms and the direction of each dgm (e.g. lowest to highest etc)	
if !mi("`dgmorder'") {
    qui gsort `dgmorder', gen(`scenario')
}
else qui gsort `dgm', gen(`scenario')
summ `scenario', meanonly
local nscenarios = r(max)
if upper("`connect'") != "L" {
	tempvar new
	qui expand 2 if `scenario'==`nscenarios', gen(`new')
	qui replace `scenario'=`scenario'+1 if `new'
	drop `new'
	qui replace `scenario' = `scenario'-0.5
}
label var `scenario' "Scenario"

* take out underscores at the end of variable names if there are any
foreach u of var * {
	if  substr("`u'",strlen("`u'"),1)=="_" {
		local U = substr("`u'", 1, index("`u'","_") - 1)
			if "`U'" != "" {
			capture rename `u' `U' 
			if _rc di as txt "problem with `u'"
		} 
	}
}
* and update macros
if  substr("`estimate'",strlen("`estimate'"),1)=="_" local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
if  substr("`se'",strlen("`se'"),1)=="_" local se = substr("`se'", 1, index("`se'","_") - 1)
if  substr("`df'",strlen("`df'"),1)=="_" local df = substr("`df'", 1, index("`df'","_") - 1)
if  substr("`ci'",strlen("`ci'"),1)=="_" local ci = substr("`ci'", 1, index("`ci'","_") - 1)
if  substr("`p'",strlen("`p'"),1)=="_" local p = substr("`p'", 1, index("`p'","_") - 1)
if  substr("`true'",strlen("`true'"),1)=="_" local true = substr("`true'", 1, index("`true'","_") - 1)

* drop variables that we're not going to use
qui drop `se' `df' `ci' `p' 

* Process methods
* Take out underscores at the end of method value labels if there are any.  
* Need to tokenize the method variable again as might have changed in a previous reshape.
					
qui levelsof `method', local(methodlist)
local nmethods = r(r)
qui tokenize `"`methodlist'"'

cap quietly label drop `method'
local labelchange = 0

forvalues m = 1/`nmethods' {
	if  substr("``m''",strlen("``m''"),1)=="_" {
		local label`m' = substr("``m''", 1, index("``m''","_") - 1)
		local metlabel`m' = "``m''"
		local labelchange = 1
			if `m'==1 {
				local labelvalues `m' "`label`m''" 
				local metlist `metlabel`m''
				}
			else if `m'>1 {
				local labelvalues `labelvalues' `m' "`label`m''" 
				local metlist `metlist' `metlabel`m''
				}
	}
	else {
	local metlabel`m' = "``m''"
	if `m'==1 local metlist `metlabel`m''
	else if `m'>=2 local metlist `metlist' `metlabel`m''
	}
}	
if `labelchange'==1 {
	label define methodlab `labelvalues'
	label values `method' methodlab
	}
	
local valmethod = "`metlist'"

forvalues i=1/`nmethods' {
	local m`i' = "``i''"
}

************************
* DRAW NESTED LOOP GRAPH
************************

if `nmethods'==1 & `stagger'>0 {
	di as error "Stagger(`stagger') ignored: only one method"
	local stagger 0
}

* If true has been entered as a single number, create a variable to be used in the graphs
capture confirm number `true'
if !_rc {
	qui gen true = `true'
	local true "true"
}

qui levelsof `target'
local ntargets = r(r)
local ngraphs = `ntargets'*`npms'
if `ngraphs'>1 di as text "Drawing `ngraphs' graphs (`ntargets' targets * `npms' performance measures)..."
else di as text "Drawing graph..."

* resolve varlists in descriptors: can in principle allow continuous descriptors
local ndescriptors 0
local descriptors2
foreach descriptor of local dgm {
	local cts = substr("`descriptor'",1,2)=="c." 
	if `cts' local descriptor = substr("`descriptor'",3,.)
	local cts2 = cond(`cts',"c.","")
	foreach desc2 of varlist `descriptor' {
		local descriptors2 `descriptors2' `cts2'`desc2'
	}
	local ++ndescriptors 
}

*sort data ready for graphs
qui sort `scenario'

local nmethodlabelsplus1 = `nmethods' + 1

* set up staggered versions of `scenario' 
if `stagger'>0  {
	local k 0
	foreach thismethod of local methodlist {
		local ++k
		gen `scenario'_`thismethod' = `scenario' + `stagger'*(2*`k'-1-`nmethods')/(`nmethods'-1)
	}
}

* sort out targets
if mi("`target'") {
	local target _null
}
qui levelsof `target', local(targetlist)

foreach thispm of local pmlist { // loop over PMs
	foreach thistarget of local targetlist { // loop over targets

		* range of upper part
		local min .
		local max .
		foreach thismethod of local methodlist {
			summ `estimate' if `target'=="`thistarget'" & `method'=="`thismethod'" & _perfmeascode=="`thispm'", meanonly
			local min=min(`min',r(min))
			local max=max(`max',r(max))
		}
		if "`thispm'" =="mean" { // add true as another method
			summ `true' if `target'=="`thistarget'", meanonly
			local min=min(`min',r(min))
			local max=max(`max',r(max))
			local methodlist2 `true'
		}
		if `max'<=`min' {
			di as text "Warning: `thispm' does not vary for `target' `thistarget'"
			local min = `min'-1
			local max = `max'+1
		}
		
		* CREATE GRAPH COMMAND FOR DESCRIPTOR LINES 
		if "`legendoff'" == "" {
			* main graph goes from y = `min' to `max'
			* `fraclegend' defines fraction of graph given to legend
			* `fracgap' defines fraction of graph given to gap
			* legends go from y = `lmin' to `lmax'
			local fracsum = `fraclegend' + `fracgap'
			local lmin = (`min'-`fracsum'*`max') / (1-`fracsum')
			local lmax = `min' - `fracgap'*(`max'-`lmin')
			local step = (`lmax'-`lmin') / ((`legendgap'+1)*`ndescriptors')
			* if !mi("`debug'") di as text "Descriptor graph: lmax=`lmax', lmin=`lmin', step=`step'"
			local j 0
			local descriptor_labels_cmd
			local factorlist
			foreach var of local descriptors2 {
				if substr("`var'",1,2)=="c." {
					di as error "Sorry, this program does not yet handle continuous variables"
					exit 498
				}
				summ `var' `if', meanonly
				if r(max)==r(min) {
					if !mi("`debug'") di as text "Warning: no variation for descriptor `var'"
					continue
				}
				local ++j
				tempvar S`var' // this is the variable containing the y-axis position for descriptor `var'
				qui gen `S`var'' = ( (`var'-r(min)) / (r(max)-r(min)) + (`legendgap'+1)*(`j'-1)) * `step' + `lmin' `if'
				label var `S`var'' "y-value for descriptor `var'"
				local Svarname_ypos = ( (`legendgap'+1)*(`j' - 1)+2.2 ) * `step' + `lmin'
				local factorlist `factorlist' `S`var''
				local varlabel : variable label `var'
				if mi("`varlabel'") local varlabel `var'
				* get levels
				local levels
				local levelsnoquote
				forvalues i=1/`=_N' {
					if `var'==`var'[_n-1] continue
					* format values if necessary
					local format : format `var'
					if mi("`format'") local level = `var'[`i']
					else local level = string(`var'[`i'],"`format'")
					* label value if necessary
					local level : label (`var') `level' // use label if one exists
					* round numeric variables to 2 d.p. for display on graph only
					cap local level = round(`level', 0.01)
					local level `""`level'""' // add quotes
					* is it old or new?
					local oldlevel : list level in levels
					if !`oldlevel' {
						if !mi(`"`levels'"') {
							local levels `"`levels',"'
							local levelsnoquote `"`levelsnoquote',"'
						}
						local levels `"`levels' `level'"'
						local levelnoquote `level'
						local levelsnoquote `levelsnoquote' `levelnoquote'
					}
				}
				local levels`j' `levels'
				local nextlegendcolor : word `j' of `legendcolor'
				if !mi("`nextlegendcolor'") local thislegendcolor `nextlegendcolor' // keeps previous color if msg
				local descriptor_labels_cmd `descriptor_labels_cmd' ///
					text(`Svarname_ypos' 1 `"`varlabel' (`levelsnoquote')"', ///
					place(e) col(`thislegendcolor') size(`legendsize') justification(left)) 
				local order `order' `j'
			}
			local descriptor_graph_cmd ///
				(line `factorlist' `scenario' `if', c(`connect' ...) ///
				lcol(`legendcolor' ...)	lpattern(`legendpattern' ...) lwidth(`legendwidth' ...) ///
				lstyle(`legendstyle' ...) )
		}
		
		// create main graph command
		local k 0
		local main_graph_cmd
		local legend
		foreach thismethod in `methodlist' `methodlist2' {
			local ++k
			local istruevar = `k'==`nmethods'+1
			if `stagger'>0 local xvar `scenario'_`thismethod'
			else local xvar `scenario'
			if `istruevar' local thisgraphcmd line `true' `scenario' if `target'=="`thistarget'" & ///
				_perfmeascode=="`thispm'", c(`connect')
			else local thisgraphcmd line `estimate' `xvar' if `target'=="`thistarget'" & ///
				`method'=="`thismethod'" & _perfmeascode=="`thispm'", c(`connect')
			foreach thing in lcolor lpattern lstyle lwidth {
				local this : word `k' of ``thing''
				if !mi("`this'") local thisgraphcmd `thisgraphcmd' `thing'(`this')
			}
			local main_graph_cmd `main_graph_cmd' (`thisgraphcmd')
			if `istruevar' local legend `legend' `k' `"True"'
			else local legend `legend' `k' `"Method: `m`k''"'
		}
		* reference lines
		if "`refline'"!="norefline" {
			if "`thispm'"=="cover" local ref 95
			else if inlist("`thispm'", "bias", "relprec", "relerror") local ref 0
			else local ref
			if !mi("`ref'") local yline yline(`ref',lcol(gs12))
		}

		// draw main graph
		if "`target'"!="_null" {
			local note note(`target'=`thistarget')
			local targetname _`thistarget'
		}
		if !mi("`debug'") & `ngraphs'>1 di as text "Drawing graph for `target'=`thistarget', PM=`thispm'..."
		local graph_cmd graph twoway 										///
			`main_graph_cmd'														///
			`descriptor_graph_cmd'											///
			,																///
			legend(order(`legend'))											///
			ytitle("`thispm'") 												///
			xla(1/`nscenarios') yla(,nogrid) 								///
			`descriptor_labels_cmd'											///
			name(`name'`targetname'_`thispm' `nameopts')						///
			`note' `yline'													///
			`options'
		global F9 `graph_cmd'
		if !mi("`debug'") di as text `"Graph command is: "' as input `"`graph_cmd'"'
		if !mi("`pause'") pause
		`graph_cmd'
		
	} // end of loop over targets

} // end of main loop of PMs

qui drop `scenario'
restore

end
