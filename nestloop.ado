*!	version 0.11.3	21nov2024	IW New standalone, called by siman_nestloop of same version number
program define nestloop
version 15
* nestloop exp, descriptor(theta rho pc tau2 k) method(method) true(theta)
// PARSE
syntax varname [if], descriptors(varlist) method(varname) ///
	[true(string) descriptors_order(string) ///
	STAGger(real 0) Connect(string) noREFline LEVel(cilevel) /// control main graph
	DGSIze(real 0.3) DGGAp(real 0) /// control sizing of descriptor graph
	DGINnergap(real 3) DGCOlor(string) MISsing /// control descriptor graph
	DGPAttern(string) DGLAbsize(string) DGSTyle(string) DGLWidth(string) /// control descriptor graph
	debug pause nodg force /// undocumented
	LColor(string) LPattern(string) LSTYle(string) LWidth(string) /// twoway options for main graph
	METHLEGend(string) SCENariolabel * /// other graph options
	NAMe(string) SAVing(string) EXPort(string) /// twoway options for overall graph
	] 

* parse varname
local estimate `varlist'

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
	di as error "siman nestloop requires more than 1 descriptor combination"
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
qui levelsof `method'
local nmethods = r(r)
cap confirm string variable `method'
local methodstring = (_rc==0)
forvalues i=1/`nmethods' {
	local m`i' : word `i' of `r(levels)'
	if `methodstring' local m2`i' `""`m`i''""'
	else local m2`i' `m`i''
	local m`i' : label (`method') `m`i''
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

*sort data ready for graphs
qui sort `scenario'

local nmethodlabelsplus1 = `nmethods' + 1

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
	* legends go from y = `lmin' to `lmax'
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
		qui replace `S`var'' = ( (`S`var''-1) / (`thisdglevels'-1) + (`dginnergap'+1)*(`j'-1)) * `step' + `lmin'
		label var `S`var'' "y-value for descriptor `var'"
		local Svarname_ypos = ( (`dginnergap'+1)*(`j' - 1)+2.2 ) * `step' + `lmin'
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
local main_graph_cmd
local legend
forvalues k = 1 / `nmethods2' {
	local istruevar = `k'>`nmethods' // handle "true" (if present) differently from the methods
	if `stagger'>0 local xvar `scenario'`k'
	else local xvar `scenario'
	if `istruevar' local thisgraphcmd line `true' `scenario', c(`connect')
	else local thisgraphcmd line `estimate' `xvar' if `method'==`m2`k'', c(`connect')
	foreach thing in lcolor lpattern lstyle lwidth {
		local this : word `k' of ``thing''
		if !mi("`this'") local thisgraphcmd `thisgraphcmd' `thing'(`this')
	}
	local main_graph_cmd `main_graph_cmd' (`thisgraphcmd')
	if `istruevar' local legend `legend' `k' `"True"'
	else local legend `legend' `k' `"`methlegitem'`m`k''"'
}
local ytitle : var label `estimate'
if mi("`ytitle'") local ytitle `estimate'

// draw main graph
if !mi("`saving'") local savingopt saving(`saving'`savingopts')
local graph_cmd graph twoway 										///
	`main_graph_cmd'												///
	`descriptor_graph_cmd'											///
	,																///
	legend(pos(6) row(1) order(`legend') `methlegtitle')			///
	ytitle(`ytitle')												///
	`scenarioaxis' yla(,nogrid) 									///
	`descriptor_labels_cmd'											///
	name(`name'`nameopts') `savingopt'	    						///
	`note' `yline'													///
	`options'

if !mi("`debug'") di as input "Debug: graph command is: " as input `"`graph_cmd'"'
if !mi("`pause'") {
	global F9 `graph_cmd'
	pause Press F9 to recall, optionally edit and run the graph command
}
`graph_cmd'
if !mi("`export'") {
	local graphexportcmd graph export `"`saving'.`exporttype'"'`exportopts'
	if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
	cap noi `graphexportcmd'
	if _rc di as error "Error in export() option"
}

restore

end
