*!  version 1.0		24jul2025
*	version 0.11.7	17apr2025	IW remove export() option: handled by siman_nestloop
*	version 0.11.6	16apr2025	IW add dgreverse option; version number aligned with siman_nestloop
*	version 0.12.3	31mar2025	IW legend() is parsed, giving better defaults and handling of pos() rows() cols(); lcolor() etc. respect = and ..
*	version 0.12.2	17mar2025	IW bug fix: graphs were mislabelled in legend with true()
*	version 0.12.1	13mar2025	IW bug fix: graphs were mislabelled in legend if no true()
*   version 0.12.0	7jan2025	TM improved how 'true' line is drawn and introduced new option 'trueoptions()'
*   version 0.11.3	21nov2024	IW New standalone, called by siman_nestloop of same version number
program define nestloop
version 15
* nestloop exp, descriptor(theta rho pc tau2 k) method(method) true(theta)
// PARSE
syntax varname [if], DESCriptors(string) METHod(varname) ///
	[true(string) TRUEOPTions(string) ///
	STAGger(real 0) Connect(string) noREFline LEVel(cilevel) /// control main graph
	DGSIze(real 0.3) DGGAp(real 0) /// control sizing of descriptor graph
	DGINnergap(real 3) DGCOlor(string) MISsing DGREverse /// control descriptor graph
	DGPAttern(string) DGLAbsize(string) DGSTyle(string) DGLWidth(string) /// control descriptor graph
	LColor(string) LPattern(string) LSTYle(string) LWidth(string) legend(string) /// twoway options for main graph
	METHLEGend(string) SCENariolabel * /// other graph options
	NAMe(string) SAVing(string) /// twoway options for overall graph
	debug pause nodg /// undocumented
	]

* parse varname
local estimate `varlist'

* parse descriptors
local descriptors_order `descriptors'
local descriptors : subinstr local descriptors "-" "", all
local descriptors : subinstr local descriptors "+" "", all
unab descriptors : `descriptors'

* graph option parsing
if `dgsize'<=0 | `dgsize'>=1 {
	di as error "dgsize() must be >0 and <1"
	exit 498
}
if `dggap'<0 | `dggap'>=1 {
	di as error "dggap() must be >=0 and <1"
	exit 498
}
if mi("`connect'") local connect J // could be L
if mi("`dgcolor'") local dgcolor gs4
if mi("`dgpattern'") local dgpattern solid
if mi("`dglabsize'") local dglabsize vsmall

local cilevel `level'

if "`methlegend'"=="item" local methlegitem "`method': "
else if "`methlegend'"=="title" local methlegtitle title(`method')
else if "`methlegend'"!="" {
	di as error "Syntax: methlegend(item|title)"
	exit 198
}

local graphoptions `options'

*** END OF PARSING ***

preserve

* mark sample
marksample touse, novarlist
qui keep if `touse'

* create a variable `scenario' that uniquely identifies each of the descriptor combinations
tempvar scenario
* option to order descriptors and the direction of each descriptor (e.g. lowest to highest etc)	
if !mi("`descriptors_order'") {
    qui gsort `descriptors_order', gen(`scenario')
}
else qui gsort `descriptors', gen(`scenario')
summ `scenario', meanonly
local nscenarios = r(max)
if `nscenarios'==1 {
	di as error "nestloop requires more than 1 descriptor combination"
	exit 498
}
if upper("`connect'") != "L" {
	tempvar new
	qui expand 2 if `scenario'==`nscenarios', gen(`new')
	qui replace `scenario'=`scenario'+1 if `new'
	drop `new'
	qui replace `scenario' = `scenario'-0.5
}
label var `scenario' "Scenario"

************************
* DRAW NESTED LOOP GRAPH
************************
cap confirm string variable `method'
local methodstring = (_rc==0)
qui levelsof `method'
local nmethods = r(r)
forvalues i=1/`nmethods' {
	local m`i' : word `i' of `r(levels)'
	if `methodstring' local m2`i' `""`m`i''""'
	else {
		local m2`i' `m`i''
		local m`i' : label (`method') `m`i''
	}
}

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

* resolve varlists in descriptors: can in principle allow continuous descriptors
local ndescriptors 0
local descriptors2
foreach descriptor of local descriptors {
	local cts = substr("`descriptor'",1,2)=="c." 
	if `cts' local descriptor = substr("`descriptor'",3,.)
	local cts2 = cond(`cts',"c.","")
	foreach desc2 of varlist `descriptor' {
		local descriptors2 `descriptors2' `cts2'`desc2'
	}
	local ++ndescriptors 
}

* set up staggered versions of `scenario' 
if `stagger'>0  {
	forvalues k = 1 / `nmethods' {
		gen `scenario'`k' = `scenario' + `stagger'*(2*`k'-1-`nmethods')/(`nmethods'-1)
	}
}
if !mi("`scenariolabel'") local scenarioaxis xla(1/`nscenarios') xtitle("Scenario")
else local scenarioaxis xla(none) xtitle("") // default is no labels, no title

* range of upper part
summ `estimate', meanonly
local min=r(min)
local max=r(max)
if !mi("`true'") { // add true as another method
	summ `true', meanonly
	local min=min(`min',r(min))
	local max=max(`max',r(max))
	local nmethods2 = `nmethods'+1
}
else local nmethods2 = `nmethods'
if `max'<=`min' {
	di as smcl as text "{p 0 2}Warning: `estimate' does not vary{p_end}"
	local min = `min'-1
	local max = `max'+1
}

* CREATE GRAPH COMMAND FOR DESCRIPTOR LINES 
if "`dg'" != "nodg" {
	* main graph goes from y = `min' to `max'
	* `dgsize' defines fraction of graph given to legend
	* `dggap' defines fraction of graph given to gap
	* descriptor graph lines go from y = `lmin' to `lmax'
	local fracsum = `dgsize' + `dggap'
	local lmin = (`min'-`fracsum'*`max') / (1-`fracsum')
	local lmax = `min' - `dggap'*(`max'-`lmin')
	local step = (`lmax'-`lmin') / ((`dginnergap'+1)*`ndescriptors')
	* if !mi("`debug'") di as input "Descriptor graph: lmax=`lmax', lmin=`lmin', step=`step'"
	local j 0
	local descriptor_labels_cmd
	local factorlist
	foreach var of local descriptors2 {
		if substr("`var'",1,2)=="c." {
			di as error "Sorry, this program does not yet handle continuous variables"
			exit 498
		}
		qui levelsof `var', `missing'
		local thisdglevels = r(r)
		if `thisdglevels'==1 {
			if !mi("`debug'") di as smcl as input "{p 0 2}Warning: no variation for descriptor `var'{p_end}"
			continue
		}
		tempvar S`var' // this is the variable containing the y-axis position for descriptor `var'
		egen `S`var'' = group(`var'), label `missing'
		local ++j
		if mi("`dgreverse'") local jj = `j'-1
		else local jj = `ndescriptors'-`j'
		qui replace `S`var'' = ( (`S`var''-1) / (`thisdglevels'-1) + (`dginnergap'+1)*`jj') * `step' + `lmin'
		label var `S`var'' "y-value for descriptor `var'"
		local Svarname_ypos = ( (`dginnergap'+1)*`jj' + 2.2 ) * `step' + `lmin'
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
		local nextdgcolor : word `j' of `dgcolor'
		if !mi("`nextdgcolor'") local thisdgcolor `nextdgcolor' // keeps previous color if msg
		local descriptor_labels_cmd `descriptor_labels_cmd' ///
			text(`Svarname_ypos' 1 `"`varlabel' (`levelsnoquote')"', ///
			place(e) col(`thisdgcolor') size(`dglabsize') justification(left)) 
	}
	local descriptor_graph_cmd ///
		(line `factorlist' `scenario', c(`connect' ...) ///
		lcol(`dgcolor' ...)	lpattern(`dgpattern' ...) lwidth(`dglwidth' ...) ///
		lstyle(`dgstyle' ...) )
}

// CREATE MAIN GRAPH COMMAND
local legno 0
if !mi("`true'") {
	local main_graph_cmd (line `true' `scenario', c(`connect') lc(gs10) lw(medthick) `trueopts')
	local ++legno
	local legendorder `legendorder' `legno' `"True"'
}
else {
	local main_graph_cmd
	local legendorder
}
forvalues k = 1 / `nmethods' {
	//local istruevar = `k'>`nmethods' // handle "true" (if present) differently from the methods
	if `stagger'>0 local xvar `scenario'`k'
	else local xvar `scenario'
	//if `istruevar' local thisgraphcmd line `true' `scenario', c(`connect')
	local thisgraphcmd line `estimate' `xvar' if `method'==`m2`k'', c(`connect')
	foreach thing in lcolor lpattern lstyle lwidth {
		if "`repeat`thing''"=="yes" local this `previous`thing''
		else {
			local this : word `k' of ``thing''
			if "`this'"=="..." local this ..
			if "`this'"==".." local repeat`thing' yes
			if "`previous`thing''"==".." | "`this'"==".." | "`this'"=="=" local this `previous`thing''
			else local previous`thing' `this'
			}
		if !mi("`this'") local thisgraphcmd `thisgraphcmd' `thing'(`this')
	}
	local main_graph_cmd `main_graph_cmd' (`thisgraphcmd')
	//if `istruevar' local legendorder `legendorder' `k' `"True"'
	local ++legno
	local legendorder `legendorder' `legno' `"`methlegitem'`m`k''"'
}
local ytitle : var label `estimate'
if mi("`ytitle'") local ytitle `estimate'

// PARSE LEGEND
local 0 , `legend'
syntax, [POSition(int 6) Cols(int 0) Rows(int 0) *]
local legendopts `options' position(`position')
if `rows'>0 local legendopts `legendopts' rows(`rows') // rows overrides cols in Stata
else if `cols'>0 local legendopts `legendopts' cols(`cols')
else if inlist(`position',2,3,4,8,9,10) local legendopts `legendopts' cols(1)
else local legendopts `legendopts' rows(1)

// draw main graph
if !mi("`saving'") local savingopt saving(`saving'`savingopts')
local graph_cmd graph twoway 										///
	`main_graph_cmd'												///
	`descriptor_graph_cmd'											///
	,																///
	legend(order(`legendorder') `methlegtitle' `legendopts')		///
	ytitle(`ytitle')												///
	`scenarioaxis' yla(,nogrid) 									///
	`descriptor_labels_cmd'											///
	name(`name'`nameopts') `savingopt'	    						///
	`note' `yline'													///
	`graphoptions'

if !mi("`debug'") di as input "Debug: graph command is: " as input `"`graph_cmd'"'
if !mi("`pause'") {
	global F9 `graph_cmd'
	pause Press F9 to recall, optionally edit and run the graph command
}
`graph_cmd'

restore

end
