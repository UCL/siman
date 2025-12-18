*!  version 1.1		18dec2025
*  version 1.1		18dec2025	resubmit to SJ
*  version 1.0		24jul2025	submit to SJ
*	version 0.11.7	16apr2025	IW undocumented nosort option
*	version 0.11.6	01apr2025	TM added faint default gridlines at (0 100) [when no ymin is specified] or at (100) [when ymin(#) uses #<0]
*	version 0.11.5	31mar2025	TM moved default placement of by() note to clock pos 11 to make more prominent (based on feedback)
*	version 0.11.4	12mar2025	IW bug fix - didn't generate CIs when dfvar was present but with missing value
*	version 0.11.3	02jan2025	IW new coverlevel() option
*	version 0.11.2	11nov2024	IW handle case of no byvar
*	version 0.11.1	21oct2024	IW implement new dgmmissingok option; drop PMs
*   version 0.10    19jul2024	IW align with new setup; respect true but don't separate graphs by true; respect cilevel; allow ci instead of se
*							    align versioning with siman.ado
*   version 0.9     22apr2024
*   version 0.9     22apr2024   IW remove ifsetup and insetup, test if/in more efficiently, rely on preserve
*   version 0.8.12  25oct2023   IW Added true value to note
*   version 0.8.11  16oct2023   EMZ minor update to warning message (# graphs each of # panels)
*   version 0.8.10  03oct2023   EMZ update to warning message when if/by conditions used
*   version 0.8.9   02oct2023   EMZ bug fix so works with dgm == x when dgm defined >1 variable
*   version 0.8.8   05sep2023   EMZ specified name used if true >1 value, named graph with suffix _x
*   version 0.8.7   15aug2023   EMZ minor bug fix in name for when multiple graphs being printed out
*   version 0.8.6   21july2023  IW suppress unwanted "obs dropped" message
*   version 0.8.5   04july2023  EMZ major re-write for graphs when dgm is defined by > 1 variable, all combinations displayed on 1 graph. lpoint/rpoint not hard coded.
*   version 0.8.4   16may2023   EMZ bug fix for multiple estimands with multiple targets, formatting to title
*   version 0.8.3   27mar2023   EMZ minor bug fix for when missing method
*   version 0.8.2   06mar2023   EMZ minor bug fix for when method is string
*   version 0.8.2   02mar2023   EMZ fixed bug, now if dgm and method are numeric labelled string, the label values will be used in the graphs
*   version 0.8.1   30jan2023   IW removed rows() and xsize() so they can be user-specified (in bygr() and outside, respectively)
*   version 0.8     07nov2022   EMZ added to code so now allows graphs split out by every dgm variable and level if multiple dgm variables declared.
*   version 0.7     05sep2022   EMZ added additional error message
*   version 0.6     14july2022  EMZ fixed bug so name() allowed in call
*   version 0.5     30june2022  EMZ fixed bug where axis crosses
*   version 0.4     24mar2022   EMZ changes (suppress DGM=1 if no DGM/only 1 DGM)
*   version 0.3     02mar2022   EMZ changes from IW further testing
*   version 0.2     06jan2021   EMZ updates from IW testing (bug fixes)
*   version 0.1     25Jan2021   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce zip plots
*******************************************************************************************************************************************************

program define siman_zipplot
version 15

syntax [if][in] [, * BY(varlist) ///
	NONCOVeroptions(string) COVeroptions(string) SCAtteroptions(string) ///
	TRUEGRaphoptions(string) BYGRaphoptions(string) SCHeme(passthru) ymin(integer 0) name(passthru) SAVing(string) EXPort(string) Level(cilevel) COVERLevel(cilevel) ///
	debug pause noSOrt /// undocumented
	]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
	di as error "siman setup needs to be run first."
	exit 498
}

* if estimate or se are missing, give error message as program requires them for the graph(s)
capture confirm variable `lci' `uci'
if _rc {
	if mi("`estimate'") | mi("`se'") {
		di as error "{p 0 2}siman zipplot requires either lower & upper CI or estimate & se{p_end}"
		exit 498
	}
}
if mi("`lci'")!=mi("`uci'") {
	di as error "siman zipplot doesn't know how to draw one-sided CIs"
	exit 498
}

* if true is missing, produce an error message
if "`true'"=="" {
	di as error "{p 0 2}siman zipplot requires true() to be specified in siman setup{p_end}"
	exit 498
}

if mi("`name'") local name name(zipplot, replace)

* parse optional saving (standard code)
if !mi(`"`saving'"') {
	gettoken saving savingopts : saving, parse(",")
	local saving = trim("`saving'")
	if strpos(`"`saving'"',".") & !strpos(`"`saving'"',".gph") {
		di as error "Sorry, saving() must not contain a full stop"
		exit 198
	}
}

* parse optional export (standard code)
if !mi(`"`export'"') {
	gettoken exporttype exportopts : export, parse(",")
	local exporttype = trim("`exporttype'")
	if mi("`saving'") {
		di as error "Please specify saving(filename) with export()"
		exit 198
	}
}

*** END OF PARSING ***

/* Start preparations */

preserve

* mark sample
marksample touse, novarlist

qui count if `touse' & `rep'>0
if r(N)==0 error 2000

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
	di as error "{p 0 2}Warning: this 'if' condition cuts across dgm, target and method. It is safest to subset only on dgm, target and method.{p_end}"
}
drop `meantouse'
qui keep if `touse' & `rep'>0

* default 'by' is all varying among dgm target method
if mi("`by'") {
	local mayby `dgm' `target' `method'
	foreach var of local mayby {
		cap assert `var'==`var'[1]
		if _rc local by `by' `var'
	}
}
if mi("`by'") {
	tempvar by
	gen `by' = 1
	if !mi("`debug'") di as input "Debug: graphing by: nothing"
	local bycreated 1
}
else if !mi("`debug'") di as input "Debug: graphing by: `by'"

* create confidence intervals, if not already there
local level2 = 1/2+`level'/200
tempvar critval
if !mi("`df'") { // there's a df variable - but it may be missing
	qui gen `critval' = invttail(`df', 1-`level2') if !mi(`df')
	qui replace `critval' = invnorm(`level2') if mi(`df')
}
else gen `critval' = invnorm(`level2') // no df variable
if mi("`lci'") {
	tempvar lci
	qui gen `lci' = `estimate' - `se'*`critval'
	label var `lci' "lci"
}
if mi("`uci'") {
	tempvar uci
	qui gen `uci' = `estimate' + `se'*`critval'
	label var `uci' "uci"
}
drop `critval'

* store method names in locals mlabel`i'
qui levelsof `method'
local methods = r(levels)
local nummethodnew = r(r)
forvalues i = 1/`nummethodnew' {
	if `methodnature'==1 local mlabel`i' : label (`method') `i'
	else if `methodnature'==2 local mlabel`i' : word `i' of `methods'
	else local mlabel`i' `i'
}

* For coverage (or type I error), use true θ for null value
* so p<=.05 is a non-covering interval
* make sure using actual true value and not the label value (e.g. using 0.5, 0.67 and not 1, 2 etc)
* if true is just one value, then sorting on it won't make a difference so can use the below code for all cases of true

* create covering indicator
tempvar covers
gen byte `covers' = inrange(`true',`lci',`uci')
label var `covers' "covers"
		
* create sort order
if mi("`sort'") {
	tempvar zstat
	if !mi("`se'") qui gen float `zstat' = -abs(`estimate'-`true')/`se'
	else qui gen float `zstat' = -abs(`estimate'-`true')/abs(`uci'-`lci')
	sort `by' `zstat' // check: was sorted by by true zstat
	drop `zstat'
}
tempvar rank
qui bysort `by': gen double `rank' = 100*(1 - _n/_N)

* Create MC conf. int. for coverage
if mi("`sort'") {
	local coverlevel2 = 1/2+`coverlevel'/200
	tempvar cov ncov covlb covub
	qui egen `cov' = mean(`covers'), by(`by')
	qui egen `ncov' = count(`covers'), by(`by')
	gen `covlb' = 100 * (`cov' - invnorm(`coverlevel2')*sqrt(`cov'*(1-`cov')/`ncov'))
	gen `covub' = 100 * (`cov' + invnorm(`coverlevel2')*sqrt(`cov'*(1-`cov')/`ncov'))
	qui bysort `by': replace `covlb' = . if _n>1
	qui bysort `by': replace `covub' = . if _n>1
	drop `cov' `ncov'
}

* find range to plot over
tempvar lpoint rpoint
qui egen `lpoint' = min(`lci') , by(`by') 
qui egen `rpoint' = max(`uci') , by(`by') 

* count panels
tempvar unique
egen `unique' = tag(`by'), `dgmmissingok'
qui count if `unique'
local npanels = r(N)
drop `unique'

di as text "siman zipplot will draw " as result 1 as text " graph with " as result `npanels' as text " panels"
if `npanels' > 15 {
	di as smcl as text "{p 0 2}Consider reducing the number of panels using 'if' condition or 'by' option{p_end}"
}

* Plot of confidence interval coverage:
* First two rspike plots: Monte Carlo confidence interval for percent coverage
* second two rspike plots: confidence intervals for individual reps
* blue intervals cover, purple do not
* scatter plot (white dots) are point estimates - probably unnecessary
tempvar truemax truemin
gen `truemax'=100
gen `truemin'=`ymin'
if mi("`sort'") {
	if `ymin'<=5 local ylab ylab(5 50 95) ytick(0 100, tl(zero) grid glp(l))
	else if `ymin'<=50 local ylab ylab(50 95) ytick(100, tl(zero) grid glp(l))
	else if `ymin'<=75 local ylab ylab(75 95) ytick(100, tl(zero) grid glp(l))
	else if `ymin'<=95 local ylab ylab(95) ytick(100, tl(zero) grid glp(l))
	else local ylab
	local ytitle Centile
}
else {
	local ylab ylab(none)
	local ytitle 
}
if "`bycreated'"!="1" local byopt by(`by', ixaxes noxrescale iscale(*.9) note(,pos(11)) `bygraphoptions' `dgmmissingok')
else local byopt note(,pos(11)) `bygraphoptions' `dgmmissingok'
if !mi("`saving'") local savingopt saving(`"`saving'"'`savingopts')
#delimit ;
local graph_cmd twoway
	(rspike `lci' `uci' `rank' if !`covers' & `rank'>=`ymin', hor lw(medium) pstyle(p2) lcol(%30) `noncoveroptions') // non-covering CIs
	(rspike `lci' `uci' `rank' if  `covers' & `rank'>=`ymin', hor lw(medium) pstyle(p1) lcol(%30) `coveroptions') // covering CIs
	(scatter `rank' `estimate' if `rank'>=`ymin', msym(p) mcol(white%30) `scatteroptions') // plots point estimates in white
	(rspike `truemax' `truemin' `true', pstyle(p5) lw(thin) `truegraphoptions') // vertical line at true value
	;
if mi("`sort'") local graph_cmd `graph_cmd' 	
	(rspike `lpoint' `rpoint' `covlb', hor lw(thin) pstyle(p5)) // MC CI for obs coverage
	(rspike `lpoint' `rpoint' `covub', hor lw(thin) pstyle(p5))
	;
local graph_cmd `graph_cmd', 
	xtitle("`level'% confidence intervals")
	ytitle("`ytitle'")
	`ylab'
	`byopt'
	legend(order(1 "Non-coverers" 2 "Coverers"))
	`scheme'
	`options'
	`name'
	`savingopt'
;
#delimit cr

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
	exit _rc
}


end
