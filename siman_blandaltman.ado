*!	version 0.10	24jun2024
*	version 0.10	24jun2024	IW Correct handling of if/in
*								NB reduce version # to match other programs
*  version 1.7 22apr2024     IW remove ifsetup and insetup, test if/in more efficiently, rely on preserve
*  version 1.6.12 20feb2024  TPM removed xsize(5) as default and added yline(0, ...) to graphs
*  version 1.6.11 16oct2023  EMZ produce error message if >=, <= or methlist(x/y) is used.
*  version 1.6.11 16oct2023  EMZ update to warning message when if condition used
*  version 1.6.10 03oct2023  EMZ update to warning message when if condition used
*  version 1.6.9 02oct2023   EMZ bug fix when dgm defined >1 variable, by() option now working again
*  version 1.6.8 19sep2023   EMZ accounting for lost labels on method numeric labelled string durng multiple reshapes
*  version 1.6.7 11july2023  EMZ change so that one graph is created for each target level and dgm level combination.
*  version 1.6.6 19june2023  EMZ small changes to note.
*  version 1.6.5 13june2023  EMZ methlist fix: can now have flexible reference method e.g. methlist(C A B) for method C as the reference (before only 2 *                            methods in methlist allowed), minor formatting to title and note, setting default norescale.
*  version 1.6.4 05june2022  EMZ expanded note to include dgm name and level when dgm defined by more than 1 variable
*  version 1.6.3 29may2022   EMZ minor bug fix when target is numeric, IRW/TPM formatting requests
*  version 1.6.2 27mar2022   EMZ minor bug fix when target has string labels in graph
*  version 1.6.1 13mar2022   EMZ minor update to error message
*  version 1.6   26sep2022   EMZ added to code so now allows graphs split out by every dgm variable and level if multiple dgm variables declared.
*  version 1.5   05sep2022   EMZ bug fix allow norescale, added extra error message
*  version 1.4   14july2022  EMZ fixed bug so name() allowed in call.
*  version 1.3   21mar2022   EMZ changes after Ian testing (supressing DGM = 1 if only 1 DGM)
*  version 1.3   30june2022  EMZ changes to graph formatting from IW/TM testing
*  version 1.2   03mar2022   EMZ changed metlist() to methlist()
*  version 1.1   6jan2021    EMZ updates from IW testing (bug fixes)
*  version 1.0   2Dec2019    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the Bland-Altman plot
* Last update 29/09/2021
******************************************************************************************************************************************************

program define siman_blandaltman, rclass
version 15

syntax [anything] [if][in] [, ///
	Methlist(string) BY(varlist) BYGRaphoptions(string) name(string) * /// documented options
	debug pause /// undocumented options
	]

foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
}

* if statistics are not specified, run graphs for estimate only
* only allow estimate or se to be specified
foreach thing of local anything {
	if ("`thing'"!="estimate" & "`thing'"!="se") {
		di as error "only estimate or se allowed"
		exit 498
	}
	if mi("``thing''") {
		di as error "`thing'() was not specified in siman setup"
		exit 498
	}
}
if "`anything'"=="" local statlist estimate
else local statlist `anything'
local nstats : word count `statlist'

* parse name
if !mi(`"`name'"') {
	gettoken name nameopts : name, parse(",")
	local name = trim("`name'")
}
else {
	local name simanbland
	local nameopts , replace
}
if wordcount("`name'_something")>1 {
	di as error "Something has gone wrong with name()"
	exit 498
}

* mark sample
marksample touse, novarlist

*** END OF PARSING ***

preserve

if "`analyserun'"=="1" {
	* keep estimates data only
	qui drop if `rep'<0
	drop _dataset _perfmeascode
}

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
	di as error "{p 0 2}Warning: this 'if' condition cuts across dgm, target and method. It is safest to subset only on dgm, target and method.{p_end}"
}
drop `meantouse'

* do if/in
qui keep if `touse'
if _N==0 error 2000
drop `touse'

* HANDLE METHODS
* only analyse the methods that the user has requested
if !mi("`methlist'") {
	if !mi("`debug'") di as input "methlist = `methlist'"
	cap numlist "`methlist'"
	if !_rc local methlist = r(numlist)
	if !mi("`debug'") di as input "methlist = `methlist'"

	tempvar tousemethod
	qui generate `tousemethod' = 0
	foreach j in `methlist' {
		if `methodnature'!=2 qui replace `tousemethod' = 1 if `method' == `j'
		else qui replace `tousemethod' = 1 if `method' == "`j'"
	}
	qui keep if `tousemethod' == 1
	qui drop `tousemethod'
	local nmethods : word count `methlist'
}
else {
	qui levelsof `method', local(methlist)
	local nmethods = r(r)
}
if `nmethods' < 2 {
	di as error "{p 0 2}siman blandaltman requires at least 2 methods to compare{p_end}"
	exit 498
}

* If method is a string variable, encode it to numeric format, in the specified order
if `methodnature'==2 {
	local i 0
	qui gen numericmethod = .
	cap label drop numericmethod
	foreach methodvalue of local methlist {
		local ++i
		qui replace numericmethod = `i' if method == "`methodvalue'"
		label def numericmethod `i' "`methodvalue'", add
		local newmethlist `newmethlist' `i'
	}
	label val numericmethod numericmethod
	qui drop `method'
	qui rename numericmethod `method'
	local methodnature 1
	local methlist `newmethlist'
}

* find method values and labels
local i 0
foreach thismethod of local methlist {
	local ++i
	local m`i' `thismethod' // raw value of ith method
	if `methodnature'==1 local mlabel`i' : label (`method') `thismethod' 
		// label of ith method
	else local mlabel`i' `thismethod'
	if !mi("`debug'") di `"Method `i': value `m`i'', label `mlabel`i''"'
}

// AVOID RESHAPE!!!
foreach s in `statlist' {
	tempvar ref`s'
	egen `ref`s'' = mean(cond(`method' == `m1',``s'',.)), by(`dgm' `target' `rep')
	qui gen float diff`s'`mlabel`j'' = ``s'' - `ref`s''
	qui gen float mean`s'`mlabel`j'' = (``s'' + `ref`s'') / 2
	drop `ref`s''
}

drop `estimate' `se'
qui drop if `method' == `m1'


* IDENTIFY OVER AND BY VARIABLES
local all `dgm' `target' `method'
if mi("`by'") local by `method'
if mi("`over'") local over : list all - by
local over2 = cond(mi("`over'"),"[nothing]","`over'")
local by2 = cond(mi("`by'"),"[nothing]","`by'")
if !mi("`debug'") di as input "Graphing over `over2' and by `by2'"

tempvar group
qui egen `group' = group(`over'), label
qui tab `group'
local novervalues = r(r)
local novervars : word count `over'

tempvar bygroup
qui egen `bygroup' = group(`by')
qui levelsof `bygroup'
local npanels = r(r)
drop `bygroup'

* report graphs to be drawn
local ngraphs = `novervalues' * `nstats'
if `ngraphs'>1 local sg "s each"
if `npanels'>1 local sp "s"
di as text "siman blandaltman will draw " as result `ngraphs' as text " graph`sg' with " as result `npanels' as text " panel`sp'"
if `npanels' > 15 | `ngraphs' > 3 {
	di as smcl as text "{p 0 2}Consider reducing the number of graphs/panels using 'if' condition or 'by' option{p_end}"
}


forvalues g = 1/`novervalues' { // loop over graphs
	local glabel : label (`group') `g'

	if !mi("`over'") {
		* nice label for this over-group
		local notetext
		forvalues v=1/`novervars' {
			local thisvar : word `v' of `over'
			local thisval : word `v' of `glabel'
			local notetext `notetext', `thisvar'=`thisval'
		}
	}

	if !mi("`debug'") di as input `"--> Drawing graph `g': `notetext'"'
	if `nmethods'>2 local panelnote ". Panels: `by'."

	foreach stat in `statlist' { // loop over stats
		if !mi("`debug'") di as input "Group `glabel', stat `stat'"
		* graph titles
		if "`stat'"=="estimate" local eltitle = "`estimate'"
		else if "`stat'"=="se" local eltitle = "`se'" 
		local elnote "stat=`stat'"
		#delimit ;
		local graph_cmd twoway (scatter diff`stat' mean`stat' if `group'==`g', `options')
		,
		by(`by', note("Graph: `elnote'`notetext'`panelnote'") iscale(1.1) title("") norescale `bygraphoptions')
		yline(0, lp(l) lc(gs8))
		name(`name'_`g'_`stat' `nameopts')
		ytitle(Difference vs `mlabel1') xtitle(Average `eltitle')
		;
		#delimit cr
		
		if !mi("`debug'") di as text "Graph command is: " as input `"`graph_cmd'"'
		if !mi("`pause'") {
			global F9 `graph_cmd'
			pause Press F9 to recall, optionally edit and run the graph command
		}
		`graph_cmd'
	}
}

end

