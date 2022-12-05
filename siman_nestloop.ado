*! version 1.7   11aug2022
*  version 1.7   11aug2022    EMZ fixed bug to allow name() in call  
*  version 1.6   11july2022   EMZ renamed created variables to have _ infront
*  version 1.5   19may2022    EMZ added error message
*  version 1.4   31mar2022    EMZ minor updates
*  version 1.3   10jan2022    EMZ updates from IW testing.
*  version 1.2   06Dec2021    Numeric dgm variable labels to 2d.p. in graph. dgm() in nestloop to take the order specified in dgmorder() so that 
*                             siman_setup does not need to be re-run if the user would like to change the order of the dgms.
*  version 1.1   02Dec2021    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Ian White's nplot.ado
/* From IW's nplot.ado comments:
"We recommend to sort the simulation dataset in such a way 
that the simulation parameter with the largest influence 
on the criterion of interest is considered first, and so forth."
*/
* File to produce the nested loop plot

capture program drop siman_nestloop
program define siman_nestloop, rclass
version 15

* siman_nestloop [performancemeasures] [if] [, *]
// PARSE
syntax [anything] [if], ///
	[DGMOrder(string) ///
	Connect(string) /// control main graph and descriptor graph
	STAGger(real 0) /// control main graph
	FRACLegend(real 0.3) FRACGap(real 0) /// control sizing
	LEGENDGap(real 3) LEGENDColor(string) /// control descriptor graph
	LEGENDPattern(string) LEGENDSize(string) LEGENDSTYle(string) LEGENDWidth(string) /// control descriptor graph
	debug /// undocumented
	LColor(passthru) LPattern(passthru) LSTYle(passthru) LWidth(passthru) * /// ordinary twoway options
	] 


foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
	
}

* Check DGMs are in the dataset, if not produce an error message
if "`dgm'"=="" {
	di as error "DGM is missing from the dataset, can not run nested loop plot."
	exit 498
	}
	
* If only 1 dgm in the dataset, produce error message as nothing will be graphed
if `ndgm'==1 {
	di as error "Only 1 dgm in the dataset, nothing to graph."
	exit 498
}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman_nestloop."
	exit 498
	}

* if performance measures are not specified, run graphs for all of them
if "`anything'"=="" {
	qui levelsof _perfmeascode, local(lablevelscode)
		foreach lablevelc of local lablevelscode {
			local varlist `varlist' *`lablevelc'
		}
}
else foreach thing of local anything {
	local varelement = "*`thing'"
	local varlist `varlist' `varelement'
	}

preserve

* keep performance measures only
qui drop if `rep'>0

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

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
	di as error "The 'if' option can not be applied to 'rep' in siman_nestloop."  
	exit 498
	}
qui keep if `touseif'

* create a variable that uniquely identifies each of the dgm combinations
cap confirm variable exact _scenario
if !_rc {
	di as error "The variable _scenario already exists in the dataset.  Please rename your _scenario variable and run the siman suite again."
	exit 498
	}

* option to order dgms and the direction of each dgm (e.g. lowest to highest etc)	
if !mi("`dgmorder'") {
    qui gsort `dgmorder', gen(_scenario)
}
else qui gsort `theta' `dgm', gen(_scenario)

* add in to existing macros
local scenario "_scenario"
local dgm `scenario' `dgm'
local varlist `varlist' `scenario'

* Define descriptors as DGM	
local descriptors = `"`dgm'"'

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
		
if  substr("`estimate'",strlen("`estimate'"),1)=="_" local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
if  substr("`se'",strlen("`se'"),1)=="_" local se = substr("`se'", 1, index("`se'","_") - 1)
if  substr("`df'",strlen("`df'"),1)=="_" local df = substr("`df'", 1, index("`df'","_") - 1)
if  substr("`ci'",strlen("`ci'"),1)=="_" local ci = substr("`ci'", 1, index("`ci'","_") - 1)
if  substr("`p'",strlen("`p'"),1)=="_" local p = substr("`p'", 1, index("`p'","_") - 1)
if  substr("`true'",strlen("`true'"),1)=="_" local true = substr("`true'", 1, index("`true'","_") - 1)

* drop variables that we're not going to use
qui drop `se' `df' `ci' `p' 

* reshape to wide method format

* defining true value based on whether it contains 1 or >1 values
if "`ntruevalue'"=="single" local optionlist `estimate'  
else if "`ntruevalue'"=="multiple" local optionlist `estimate' `true' 

	* Take out underscores at the end of method value labels if there are any.  
	* Need to tokenize the method variable again as might have changed in a previous reshape.
					
		qui tab `method'
		local nmethodlabels = `r(r)'
	
		qui levels `method', local(mlevels)
		qui tokenize `"`mlevels'"'
	
        cap quietly label drop `method'
		local labelchange = 0

		forvalues m = 1/`nmethodlabels' {
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
		
			forvalues i=1/`nmethodlabels' {
				local m`i' = "``i''"
				}

	
		* check if method elements are numeric (e.g. 1 2) or string (e.g. A B) for reshape
		local string = 0
		capture confirm numeric variable `method'
		if _rc local string = 1
		
		* take out true from option list if included for the reshape, otherwise will be included in the optionlist as well as i() and reshape won't work
		local optionreshape `optionlist'
		local exclude "`true'"
		local optionreshape: list optionreshape - exclude
	
		if `string' == 0 {
			qui reshape wide "`optionreshape'", i(`dgm' `target' _perfmeascode) j(`method' "`valmethod'") 
		}
		else if `string' == 1 {
			qui reshape wide "`optionreshape'", i(`dgm' `target' _perfmeascode) j(`method' "`valmethod'") string
		}

		foreach option in `optionreshape' {
			forvalues j = 1/`nmethodlabels' {
				local `option'stubreshape`j' = "`option'`m`j''"
					if `j'==1 local optionlist2 ``option'stubreshape`j''
					else if `j'>=2 local optionlist2 `optionlist2' ``option'stubreshape`j''
					}
		}
	
		qui reshape wide `optionlist2', i(`rep' `dgm' `target') j(_perfmeascode) string	
		
	
* for nested loop graph (IW's code)		
*************************************

if `fraclegend'<=0 | `fraclegend'>=1 {
	di as error "fraclegend() must be >0 and <1"
	exit 498
}
if `fracgap'<0 | `fracgap'>=1 {
	di as error "fracgap() must be >=0 and <1"
	exit 498
}

if mi("`connect'") local connect J // could be l
if mi("`legendcolor'") local legendcolor gs4
if mi("`legendpattern'") local legendpattern solid
if mi("`legendsize'") local legendsize vsmall

local nvars : word count `varlist'
local xvar :  word `nvars' of `varlist'
local yvars : list varlist - xvar
local nyvars = `nvars' - 1
if `nyvars'==1 & `stagger'>0 {
	di as error "Stagger(`stagger') ignored: only one yvar"
	local stagger 0
}

* If true has been enetered as a single number, create a variable to be used in the graphs
capture confirm number `true'
		if !_rc {
			qui gen true = `true'
			local true "true"
			}
di as text "working...."

foreach yvar of local yvars {
	
tempfile dataforgraph
qui save `dataforgraph'
	
qui keep `yvar' `xvar' `dgm' `true'


* range of upper part
local min .
local max .
summ `yvar' `if', meanonly
local min=min(`min',r(min))
local max=max(`max',r(max))


* resolve varlists in descriptors
local descriptorslist : list descriptors - scenario

local ndescriptors 0
foreach descriptor of local descriptorslist {
	local cts = substr("`descriptor'",1,2)=="c." 
	if `cts' local descriptor = substr("`descriptor'",3,.)
	local cts2 = cond(`cts',"c.","")
	foreach desc2 of varlist `descriptor' {
		local descriptors2 `descriptors2' `cts2'`desc2'
	}
	local ++ndescriptors 
}



* legend lines
* main graph goes from `min' to `max'
* `fraclegend' defines fraction of graph given to legend
* `fracgap' defines fraction of graph given to gap
* legends go from `lmin' to `lmax'
local fracsum = `fraclegend' + `fracgap'
local lmin = (`min'-`fracsum'*`max') / (1-`fracsum')
local lmax = `min' - `fracgap'*(`max'-`lmin')
local step = (`lmax'-`lmin') / ((`legendgap'+1)*`ndescriptors')
local j 0
foreach var of local descriptors2 {
	if substr("`var'",1,2)=="c." {
		di as error "Sorry, this program does not yet handle continuous variables"
		exit 498
	}
	local ++j
	summ `var' `if', meanonly
	tempvar S`var'
	qui gen `S`var'' = ( (`var'-r(min)) / (r(max)-r(min)) + (`legendgap'+1)*(`j'-1)) * `step' + `lmin' `if'
	local Svarname = ( (`legendgap'+1)*(`j' - 1)+2.2 ) * `step' + `lmin'
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
		* round numeric variables to 2 d.p. for dislpay on graph only
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
	local addplot text(`Svarname' 1 `"`varlabel' (`levelsnoquote')"', place(e) col(`legendcolor') size(`legendsize') justification(left)) 
	local addplots `addplots' `addplot'
	local order `order' `j'
}

* staggering: need to keep as graph of y* vs x, so I stack one dataset copy per yvar
if `stagger'>0 qui {
*	preserve
	tempvar id
	qui gen `id'=_n
	qui expand `nyvars'
	qui sort `id'
	qui by `id': gen copy = _n
	local k 0
	forvalues k = 1 / `nyvars' {
		local yvar`k' : word `k' of `yvars'
		qui replace `xvar' = `xvar' + `stagger'*(2*`k'-1-`nyvars')/(`nyvars'-1) if copy==`k'
		qui replace `yvar`k''=. if copy != `k'
	}
}

* add in to existing macros
local scenario "_scenario"
// prepare to show scenarios in 16s	
set more off
forvalues j=1/6 {
	local upp = 16*`j'
	local low = `upp'-15
	local mid = `upp'-7
	label def scen2 `mid' "`low'-`upp'", add
	local xlabs `xlabs' `mid'
}
label val _scenario scen2

*sort data ready for graphs
qui sort _scenario

* take * out of variable name for graph name
local yname = substr("`yvar'", 2, length("`yvar'") - 1)

local nmethodlabelsplus1 = `nmethodlabels' + 1

* for legend labels
forvalues i=1/`nmethodlabels' {
	local legend `legend' `i' `"Method `m`i''"'
	}
	
if "`yvar'" =="*mean" {
    local legend `legend' `nmethodlabelsplus1' "True theta" 
	local yvar `yvar' `true'
}
else local yvar `yvar'

local name = "simannestloop"

* Can't tokenize/substr as many "" in the string
if !mi(`"`options'"') {
	tempvar _namestring
	qui gen `_namestring' = `"`options'"'
	qui split `_namestring',  parse(`"name"')
	local options = `_namestring'1
	cap confirm var `_namestring'2
	if !_rc {
		local namestring = `_namestring'2
		local name = `namestring'
	}
}


* Took out	c(`connect' ...) from line `yvar' `xvar' `if' options and line `factorlist' `xvar' `if' options
* as connector making the lines too thick, can not see detail

*di "`yvar'"

* graph
#delimit ;
local cmd graph twoway 
(line `yvar' `xvar' `if', 
	`lcolor' `lpattern'	`lstyle' `lwidth'
	)
(line `factorlist' `xvar' `if', 
	lcol(`legendcolor' ...)
	lpattern(`legendpattern' ...)
	lwidth(`legendwidth' ...)
	lstyle(`legendstyle' ...)
	)
	,
	legend(order(`legend'))
	xtitle(`"`xvar'"')
	ytitle("`yname'") 
	yla(,nogrid) 
	`addplots' 
	`options'
	name(`name'_`yname', replace)
;
if !mi("`debug'") di as text `"Command is: "' as input `"`cmd'"';
`cmd';
global F9 `cmd';
#delimit cr


* don't want to add to existing factorlist etc, so clear macro contents ready for the next performance measure

local factorlist
local descriptors2
local connect
*local order
*local xlabs
local legend
local addplots

*desc _all
*macro list
*restore
* drop any temporary variables
*cap drop _00* 

use `dataforgraph', clear
}

qui drop _scenario
restore

end










