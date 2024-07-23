*!	version 0.10	23jun2024	IW Correct handling of if/in
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

* keeps estimates data only
qui drop if `rep'<0
drop _dataset _perfmeascode

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
	di as error "There are not enough methods to compare, siman blandaltman requires at least 2 methods."
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
	if !mi("`debug'") {
		label list numericmethod
		tab `method', missing
		tab `method', missing nol
	}
}
if !mi("`debug'") mac l _methlist

* find method values and labels
local i 0
foreach thismethod of local methlist {
	local ++i
	local m`i' `thismethod' // raw value of ith method
	if `methodnature'==1 local mlabel`i' : label (`method') `i' 
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

drop `estimate'
drop `se'
drop if `method' == `m1'
su


/* avoid this by doing graphs with wide stats

*if mi("`methlist'") {
	qui tab strmeth
	local numstrmeth = `r(r)'
	qui gen byte method = 1 if strmeth=="`mlabel1'"
	if mi("`methlist'") local nforvalues = `nummethod'
	else local nforvalues = `nmethods'
	 forvalues n = 2/`nforvalues' {
		cap qui replace method = `n' if strmeth=="`mlabel`n''"
		local labelvalues `n' "`mlabel`n'' vs. `mlabel1'" `labelvalues'
		if `n'==`nforvalues' label define method `labelvalues'
	}
	lab val method method
}

qui gen byte thing = 1 if strthing=="`estimate'"
qui replace thing = 2 if strthing=="`se'"
qui drop strmeth

lab def thing 1 "`estimate' " 2 "`se'"
lab val thing thing
lab var diff "Difference"
lab var mean "Mean"


* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if mi("`dgm'") {
	qui gen dgm = 1
	local dgm "dgm"
	local ndgmvars=1
}

* Need to know number of dgms for later on
local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	local ndgmvars = `r(r)'
}
if `numberdgms'!=1 local ndgmvars = `numberdgms'

if `numberdgms'==1 {
	* Need to know what format dgm is in (string or numeric) for the below code
	local dgmstringindi = 0
	capture confirm string variable `dgm'
	if !_rc local dgmstringindi = 1
}
else local dgmstringindi = 1


* for 'by' syntax

if mi("`by'") {
	local dgmbyvar = "`by'"
}
else local dgmbyvar = "`dgm'"

foreach dgmvar in `dgmbyvar' {
	
	local dgmlabels = 0
	
	qui tab `dgmvar'
	local ndgmvar = `r(r)'

	* Get dgm label values
	cap qui labelsof `dgmvar'
	cap qui ret list

	if `"`r(labels)'"'!="" {
		local 0 = `"`r(labels)'"'

		forvalues i = 1/`ndgmvar' {  
			gettoken `dgmvar'dlabel`i' 0 : 0, parse(": ")
			local dgmlabels = 1
		}
	}
	else {
	local dgmlabels = 0
	qui levels `dgmvar', local(levels)
	tokenize `"`levels'"'
		
		if `dgmstringindi'==0 {
		
			forvalues i = 1/`ndgmvar' {  
				local `dgmvar'dlabel`i' `i'
			}
		}
		else if `dgmstringindi'==1 {
		
			forvalues i = 1/`ndgmvar' {  
				local `dgmvar'dlabel`i' ``i''
			}
			
		}
	}

	qui tab `dgmvar'
	local n`dgmvar'labels = `r(r)'
}

if mi(`"`options'"') {
	local options mlc(white%1) msym(O) msize(tiny)
}
		
local targetstringindi = 0
capture confirm string variable `target'
if !_rc local targetstringindi = 1

*/

local all `dgm' `target' `method'
if mi("`by'") local by `method'
if mi("`over'") local over : list all - by
if !mi("debug'") di as input "Graphing over `over' and by `by'"

* HANDLE DGM
* make a group for when dgm is defined by >1 variable
tempvar group
qui egen `group' = group(`over'), label
tab `group'
local ngroups = r(r)

* handle target
qui levelsof `target'
local ntargets = r(r)
local valtarget = r(levels)

* report graphs to be drawn
local ngraphs = `ngroups' * `ntargets' * `nstats'
local npanels `nmethods'
di as text "siman blandaltman will draw " as result `ngraphs' as text " graphs (`ngroups' dgms, `ntargets' targets, `nstats' stats) each with " as result `npanels' as text " panels"
if `npanels' > 15 {
	di as smcl as text "{p 0 2}Consider reducing the number of panels using 'if' condition or 'by' option{p_end}"
}


/*
* If target is not missing / 'by' is not by a dgm variable (i.e. not splitting out by target)
if "`valtarget'" != "N/A" & "`by'"!="`dgmbyvar'" {

	* check number of targets in case 'if' syntax has been applied
	qui tab `target',m
	local ntargetlabels = `r(r)'

	qui levels `target', local(levels)
	tokenize `"`levels'"'
	forvalues e = 1/`ntargetlabels' {
		local tarlabel`e' = "``e''"
		if `e'==1 local valtargetloop `tarlabel`e''
		else if `e'>=2 local valtargetloop `valtargetloop' `tarlabel`e''
	}
*/
	
forvalues g = 1/`ngroups' {
	local gname : label (`group') `g'
		foreach stat in `statlist' {
			if !mi("`debug'") di as input "Group `gname', stat `stat'"
			* graph titles
			if "`stat'"=="estimate" local eltitle = "`estimate'"
			else if "`stat'"=="se" local eltitle = "`se'" 
		
/*
			* use target labels if target numeric with string labels
			if `targetnature' == 1 local tlab: word `t' of `valtarget'
			else local tlab `t'
		
			local dgmlevels`d' : label (`group') `g'

			if ("`by'"=="" | "`by'"=="`dgm' `target'") {
		
				local bytitle = "`dgmbyvar': `dgmlevels`d'', target: `tlab'"
				
				if `targetstringindi' == 1 local byvarlist = `"`group'==`d' & `target'=="`t'""'
				else local byvarlist = `"`group'==`d' & `target'==`t'"'
		
				local byname = "`d'`tlab'"

			}

			else if "`by'"=="`dgmbyvar'" {
			local bytitle = "`dgmbyvar': `dgmlevels`d''"
			local byvarlist = `"`group'==`d'"'
			local byname = `d'
			}
			else if "`by'"=="`target'" {
			local bytitle = "target: `tlab'"
			if `targetstringindi' == 1 local byvarlist = `"`target'=="`t'""'
			else local byvarlist = `"`target'==`t'"'
			local byname = "`tlab'"
			}
			else if "`by'"=="`target' `dgm'" {
				di as err "'by' nesting order should be by(dgm target)"
				exit 198
			}
*/

		#delimit ;
			local graph_cmd twoway (scatter diff`stat' mean`stat' if `group'==`g', `options')
			,
			by(`by', note("Graphs for `eltitle', `over' = `gname'") iscale(1.1) title("") norescale `bygraphoptions')
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

/*
else {
	forvalues d = 1/`groupnum' {
		foreach stat in `statlist' {

			* graph titles
			if "`stat'"=="`estimate'" local eltitle = "`estimate'"
			else if "`stat'"=="`se'" local eltitle = "`se'" 
			
			local dgmlevels`d' : label grouplevels `d'

			if ("`by'"=="" | "`by'"=="`dgmbyvar'") {
				local bytitle = "`dgmbyvar': `dgmlevels`d''"
				local byvarlist = `"`group'==`d'"'
				local byname = `d'
			}	
			if `ndgmvars' > 1 {
				#delimit ;
				local graph_cmd twoway (scatter diff mean if `byvarlist', `options')
				,
				by(method, note("Graphs for `eltitle', `bytitle'") iscale(1.1) title("") norescale `bygraphoptions')
				yline(0, lp(l) lc(gs8))
				name( `name'_`byname'`stat' `nameopts')
				;
				#delimit cr
			}
			else {
				#delimit ;
				local graph_cmd twoway (scatter diff mean, `options')
				,
				by(method, note("Graphs for `eltitle'") iscale(1.1) title("") norescale `bygraphoptions')
				yline(0, lp(l) lc(gs8))
				name( `name'_`stat' `nameopts')
				;
				#delimit cr
			}
		}
	}
}
*/

end

