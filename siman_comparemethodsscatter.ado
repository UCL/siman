*! version 1.9.18 25oct2023
*  version 1.9.18 25oct2023   IW removed space before comma in note
*  version 1.9.17 16oct2023   EMZ produce error message if >=, <= or methlist(x/y) is used.
*  version 1.9.16 03oct2023   EMZ updates: don't allow 'by' option as will just print blank graphs in the grid (previously only allowed for by(target)). User
*                             should just use 'if' condition to subset.  Fix when if == target and warning messages
*  version 1.9.15 02oct2023   EMZ bug fix so graphs not displayed >1 time when by(dgm) used
*  version 1.9.14 12sep2023   EMZ correction to labels for methlist when method is a numeric string labelled variable
*  version 1.9.13 05sep2023   EMZ minor bug fix to prevent double looping
*  version 1.9.12 07aug2023   EMZ further minor formatting bug fixes: metlist
*  version 1.9.11 18july2023  EMZ minor formatting bug fixes from IW testing
*  version 1.9.10 10july2023  EMZ change so that one graph is created for each target level and dgm level combination, with a warning if high number of 
*                             graphs.
*  version 1.9.9 20june2023   EMZ fix for when target is missing, update to note.
*  version 1.9.8 19june2023   EMZ minor bug fix for numeric targets with string labels and long dgm names.  Small format to note.
*  version 1.9.7 14june2023   TPM systematically went through indenting; moved some twoway options from layer-specific to general
*  version 1.9.6 12june2023   EMZ change to split out graphs by target as well as dgm by default. 
*  version 1.9.5 30may2023    EMZ minor formatting as per IRW/TPM request i.e. dgm_var note, title and axis changes, fixed bug with 'if' statement when 
*                             string method
*  version 1.9.4 09may2023    EMZ minor bug fix: now working when method numeric with string labels and dgm defined by >1 variable
*  version 1.9.3 13mar2023    EMZ minor update to error message
*  version 1.9.2 06mar2023    EMZ fixed when method label numerical with string labels, issue introduced from of siman describe change
*  version 1.9.1 02mar2023    EMZ bug fix when subgraphoptions used, all constituent graphs were drawn, now fixed
*  version 1.9   23jan2023    EMZ bug fixes from changes to setup programs 
*  version 1.8   10oct2022    EMZ added to code so now allows graphs split out by every dgm variable and level if multiple dgm variables declared.
*  version 1.7   05sep2022    EMZ added additional error message
*  version 1.6   01sep2022    EMZ fixed bug to allow scheme to be specified
*  version 1.5   14july2022   EMZ fixed bug to allow name() in call
*  version 1.4   30june2022   EMZ minor formatting of axes from IW/TM testing
*  version 1.3   28apr2022    EMZ bug fix for graphing options
*  version 1.2   24mar2022    EMZ changes from IW testing
*  version 1.1   06dec2021    EMZ changes (bug fix)
*  version 1.0   25Nov2019    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the siman comparemethods scatter plot
* The graphs are automatically split out by dgm (one graph per dgm) and will compare the methods to each other.  Therefore the only option to split the 
* graphs with the `by' option is by target, so the by(varlist) option will only allow by(target).
* If the number of methods <= 3 then siman comparemethodsscatter will plot both estimate and se.  If methods >3 then the user can choose
* to only plot est or se (default is both).
******************************************************************************************************************************************************

capture program drop siman_comparemethodsscatter
program define siman_comparemethodsscatter, rclass
version 16

syntax [anything] [if][in] [,* Methlist(string) SUBGRaphoptions(string) debug]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
}

* if estimate or se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") | mi("`se'") {
    di as error "siman scattercomparemethods requires estimate and se to plot"
	exit 498
}	

if "`method'"=="" & "`valmethod'"=="" {
	di as error "The variable 'method' is missing so siman comparemethodsscatter can not be created.  Please create a variable in your dataset called method containing the method value(s)."
	exit 498
}

if `nummethod' < 2 {
	di as error "There are not enough methods to compare, siman comparemethods scatter requires at least 2 methods."
	exit 498
}
if !mi("`debug'") local dicmd dicmd

if !mi("`if'") {
	if strpos("`if'","<=")!= 0 | strpos("`if'","=>")!= 0 {
	di as error "<= and >= are not permitted.  Please use methlist() option if subsetting on method."
	exit 498
	}
}

if !mi("`methlist'") {
	if strpos("`methlist'","/")!= 0 {
	di as error "The notation x/y is not permitted.  Please write out methlist() subset in full."
	exit 498
	}
}

tempfile origdata
qui save `origdata'

* If data is not in long-long format, then reshape to get method labels
if `nformat'!=1 {
	qui siman reshape, longlong
	foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
	}
}

* Need to know what format method is in (string or numeric) for the below code
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

if mi("`methlist'") & `nummethod' > 5 {
    di as smcl as text "{p 0 2}Warning: with `nummethod' methods compared, this plot may be too dense to read.  If you find it unreadable, you can choose the methods to compare using -siman comparemethodsscatter, methlist(a b)- where a and b are the methods you are particularly interested to compare.{p_end}"
}

cap confirm variable `dgm'
	if !_rc {
		local numberdgms: word count `dgm'
		if `numberdgms'==1 {
	
			local dgmlabels 0
	
			qui tab `dgm'
			*	local ndgmvar = `r(r)'
			* Get dgm label values
			cap qui labelsof `dgm'
			cap qui ret list
	
			if `"`r(labels)'"' != "" {
			local 0 = `"`r(labels)'"'

				forvalues i = 1/`ndgmvars' {
					gettoken `dgm'dlabel`i' 0 : 0, parse(": ")
					local dgmlabels = 1
				}
			}
			else {
				local dgmlabels 0
				qui levels `dgm', local(levels)
		
				local loop 1
					foreach l of local levels {
						local `dgm'dlabel`loop' `l'
						local loop = `loop' + 1
					}
			}
		}
	}


* if the user has not specified 'if' in the siman comparemethods scatter syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifscatterc = `"`ifsetup'"'
else local ifscatterc = `"`if'"'
* handle if dgm defined by multiple variables, and user specifies 'if dgm1 == x'
local ifdgm = 0
if !mi("`ifscatterc'") & strpos("`dgm'", "`ifscatterc'")>0 {
	cap confirm variable `dgm'
	if !_rc {
		local numberdgms: word count `dgm'
		if `numberdgms'!=1 {
			gettoken dgmfilter ifscatterc: ifscatterc, parse("==")
			local ifremove "if "
			local dgmleft: list dgmfilter - ifremove
			local dgmorig = "`dgm'"
			local dgmtodrop: list dgm - dgmleft
			local ifdgm = 1
			* for value of dgm being filtered on
			gettoken dgmleft2 ifscatterc: ifscatterc, parse("==")
			local dgmfiltervalues = `ifscatterc'
			* to restore `if'
			local ifscatterc = `"`if'"'
		}
	}
}

tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifscatterc' 
preserve
sort `dgm' `target' `method' `touseif'
* The 'if' condition will only apply to dgm, target and method.  The 'if' condition is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' condition can not be applied to 'rep' in siman comparemethodsscatter (cms).  If you have not specified an 'if' in siman cms, but you specified one in siman setup, then that 'if' will have been applied to siman cms."  
	exit 498
}
restore
qui keep if `touseif'


* if the user has not specified 'in' in the siman comparemethods scatter syntax, but there is one from siman setup then use that 'in'
if ("`in'"=="" & "`insetup'"!="") local inscatterc = `"`insetup'"'
else local inscatterc = `"`in'"'
tempvar tousein
qui generate `tousein' = 0
qui replace `tousein' = 1 `inscatterc' 
qui keep if `tousein'


* Obtain dgm values
cap confirm variable `dgm'
if !_rc {
	local numberdgms: word count `dgm'
	if `numberdgms'==1 {
		qui tab `dgm'
		local ndgmlabels = `r(r)'
	
		qui levels `dgm', local(levels)
		tokenize `"`levels'"'
		forvalues i=1/`ndgmlabels' {
			local d`i' = "``i''"
			if `i'==1 local dgmvalues `d`i''
			else local dgmvalues `dgmvalues' `d`i''
		}
	}
	if `numberdgms'!=1 {
		local ndgmlabels = `numberdgms'
		local dgmvalues `dgm'
	}
}

preserve
* keeps estimates data only
qui drop if `rep'<0


* only analyse the methods that the user has requested
if !mi("`methlist'") {
*	numlist "`methlist'"
	local methodvaluesloop = "`methlist'"
	local methodcount: word count `methlist'
*	local nummethod = `count'
	tempvar tousemethod
	qui generate `tousemethod' = 0
    tokenize `methlist'
	foreach j in `methodvaluesloop' {
		if `methodstringindi' == 0 qui replace `tousemethod' = 1  if `method' == `j'
		else if `methodstringindi' == 1 qui replace `tousemethod' = 1  if `method' == "`j'"
	}
	qui keep if `tousemethod' == 1	
	qui drop `tousemethod'	
}

* check number of methods (for example if the 'if' syntax has been used)
qui tab `method'
local nummethodnew = `r(r)'

if `nummethodnew' < 2 {
	di as error "There are not enough methods to compare, siman comparemethodsscatter requires at least 2 methods."
	exit 498
}

* Need labelsof package installed to extract method labels
qui capture which labelsof
if _rc {
	di as smcl  "labelsof package required, please install by clicking: "  `"{stata ssc install labelsof}"'
	exit
} 

* label values are lost during reshape so need to account for both versions
qui capture labelsof `method'
if !_rc qui ret list 
else qui capture levelsof `method'


local methodlabels 0
if `"`r(labels)'"'!="" {
	local 0 = `"`r(labels)'"'

	forvalues i = 1/`nummethod' {  
		gettoken mlabel`i' 0 : 0, parse(": ")
		local methodvaluesloop `methodvaluesloop' `mlabel`i''
		local methodlabel`i': word `i' of `methodvaluesloop'
		local mlabelname`i' Method_`methodlabel`i''
		local methodlabels 1
	}
}
else {
	qui levels `method', local(levels)
	tokenize `"`levels'"'
	if `methodstringindi'==0 {
		numlist "`levels'"
		forvalues i = 1/`nummethod' {  
			local methodlabel`i': word `i' of `levels'
			local mlabel`i' Method: `i'
			local mlabelname`i' Method_`methodlabel`i''
			local methodlabel`i' `i'
			local methodvaluesloop `methodvaluesloop' `methodlabel`i''
		}
	}
	else if `methodstringindi'==1 {
		forvalues i = 1/`nummethod' { 
			local methodlabel`i': word `i' of `levels'
			local mlabel`i' Method: ``i''
			local mlabelname`i' Method_`methodlabel`i''
			local methodlabel`i' ``i''
			local methodvaluesloop `methodvaluesloop' `methodlabel`i''
		}
	}
}


* for numeric method variables with string labels, need to re-assign valmethod later on to be numerical values
if `nmethod'!=0 {
	qui tab `method',m
	local nmethodlabels = `r(r)'
	qui levels `method', local(levels)
	tokenize `"`levels'"'
	forvalues e = 1/`nmethodlabels' {
		local methlabel`e' = "``e''"
		if `e'==1 local valmethodnumwithlabel `methlabel`e''
		else if `e'>=2 local valmethodnumwithlabel `valmethodnumwithlabel' `methlabel`e''
	}	
}


* If data is not in long-wide format, then reshape for graphs
qui siman reshape, longwide
foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
}

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

if "`subgraphoptions'" == "" {
	local subgraphoptions aspect(1) graphregion(margin(zero)) plotregion(margin(zero)) xtit("") legend(off) 
}

	
di as text "Working....."

if `ifdgm' == 1 {
	qui drop `dgmtodrop'
	local dgm = "`dgmleft'"
	local dgmvalues = `dgmfiltervalues'
	local numberdgms = 1
}

if !mi("`methlist'") {
	local numbermethod = `methodcount'
	local methodvaluesloop `methlist'
}
else local numbermethod = `nummethod'

if mi("`methlist'") | (!mi("`methlist'") & `methodstringindi'==1) local forcommand = "forvalues j = 1/`numbermethod'"
else local forcommand = "foreach j in `methodvaluesloop'"


if "`by'"=="" local by ""
else if "`by'"=="`target'" local by by(`target', note("") legend(off))
else if !mi("`by'") & "`by'"!="`target'" {
	di as error "Can not have `by' as a 'by' option"
	exit 498
}

local c 1
`forcommand' {
	if `methodstringindi'==0 & `methodlabels' == 0 {
		label var `estimate'`j' "`estimate', `mlabel`j''"
		label var `se'`j' "`se', `mlabel`j''"
		local mlabel`c' Method: `j'
	}
	else if `methodstringindi'==0 & `methodlabels' == 1 {
		local k : word `j' of `valmethod'
		label var `estimate'`j' "`estimate', Method_`k'"
		label var `se'`j' "`se', Method_`k'"
		local mlabel`j' Method: `k'
	}
	else if `methodstringindi'==1 {
		label var `estimate'``j'' "`estimate', Method: ``j''"
		label var `se'``j'' "`se', Method: ``j''"
		local mlabel`c' Method: ``j''
	}
		
	* plot markers
	if `j'==1 {
		local pt1 = 0.7
		local pt2 = 0
	}
	else if `j'==2 {
		local pt1 = 0.5
		local pt2 = -0.5
	}
	else if `j'>2 {
		local pt1 = 0
		local pt2 = -0.5
	}		

	`dicmd' twoway scatteri 0 0 (0) "`mlabel`j''" .5 `pt1' (0) "" -.5 `pt2' (0) "", yscale(range(-1 1)) xscale(range(-1 1)) plotregion(style(none)) ///
		yscale(lstyle(none)) xscale(lstyle(none)) msym(i) mlabs(vlarge) xlab(none) ylab(none) xtit("") ytit("") legend(off) `nodraw' mlab(black) ///
		`subgraphoptions' nodraw name(`mlabelname`c'', replace) 
		local c = `c' + 1
}

* create ranges for theta and se graphs (min and max)
qui tokenize `methodvaluesloop'
forvalues m = 1/`numbermethod' {
	if `methodstringindi'==0 & mi("`methlist'")  {
		qui summarize `estimate'`m'
		local minest`m' = `r(min)'
		local maxest`m' = `r(max)'
		
		qui summarize `se'`m'
		local minse`m' = `r(min)'
		local maxse`m' = `r(max)'
	}
	else {
		qui summarize `estimate'``m''
		local minest`m' = `r(min)'
		local maxest`m' = `r(max)'
		
		qui summarize `se'``m''
		local minse`m' = `r(min)'
		local maxse`m' = `r(max)'
	}
	if `m'>1 {
		local n = `m' - 1
		if `minest`n'' < `minest`m'' local minest = `minest`n''
		else local minest = `minest`m''
		if `minse`n'' < `minse`m'' local minse = `minse`n''
		else local minse = `minse`m''
		
		if `maxest`n'' > `maxest`m'' local maxest = `maxest`n''
		else local maxest = `maxest`m''
		if `maxse`n'' > `maxse`m'' local maxse = `maxse`n''
		else local maxse = `maxse`m''
	}
}

* If have number of methods > 3 then need list of estimate and se variables in long-wide format e.g. est1 est2 est3 etc for graph matrix command

local track 1
foreach j in `methodvaluesloop' {
	foreach option in `estimate' `se' {
		local `option'`j' = "`option'`j'"
		if `track'==1 local `option'list ``option'`j''
		else if `track'>=2 local `option'list ``option'list' ``option'`j''
	}
	local track = `track' + 1
}

* if statistics are not specified, run graphs for estimate only if number of methods > 3, otherwise can run for se instead
if ("`anything'"=="" | "`anything'"=="`estimate'") local varlist ``estimate'list'
else if ("`anything'"=="`se'") local varlist ``se'list'
local countanything: word count `anything'
if (`countanything'==1 | `countanything'==0) local half half

local name = "simancms"

* Can't tokenize/substr as many "" in the string
if !mi(`"`options'"') {
	tempvar _namestring
	qui gen `_namestring' = `"`options'"'
	qui split `_namestring', parse(`"name"')
	local options = `_namestring'1
	cap confirm var `_namestring'2
	if !_rc {
		local namestring = `_namestring'2
		local name = `namestring'
	}
}

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if "`dgm'"=="" local dgmvalues=1 


*if `numberdgms'==1 local for "foreach m in `dgmvalues'"
*else if `numberdgms'!=1 {
*	qui tab `dgmvar'
*	local numlevelsdgmvar = `r(r)'	
*	labelsof `dgmvar'
*	local for "forvalues m = 1/`numlevelsdgmvar'"
*	local dgm `dgmvar'
*}

*local s1: "Standard"
*local s2: "Error"
*local seytit `""`s1'" "`s2'" "'

if `numberdgms'==1 {
	
	foreach m in `dgmvalues' {
		if !mi("`debug'") di as text "Loop for numberdgms = 1: m = `m'"
		* check if target is numeric with string labels for the looping over target values
		*if `targetlabels' == 1 {
		if "`valtarget'"!= "N/A" {
			qui levelsof `target', local(targetlevels)
			local foreachtarget "`targetlevels'"
		}
		*}
		*else if "`valtarget'"!= "N/A" local foreachtarget "`valtarget'"
		else local foreachtarget 1
		
		foreach t in `foreachtarget' {
			* for target, determine if string/string labels or not
			cap confirm numeric variable `target'
			if _rc local iftarget `"& `target' == "`t'""'
			else local iftarget `"& `target' == `t'"'
			if "`valtarget'"== "N/A" local iftarget
			
			local frtheta `minest' `maxest'
			local frse `minse' `maxse'
			
			if `methodstringindi'==0  {
				if mi("`methlist'") {
					* if numerical method without labels
					if `methodlabels'!= 1 local methodvaluesloop `valmethod'	
					* if numerical method with labels
					else local methodvaluesloop `valmethodnumwithlabel'
				}
				local maxmethodvaluesloop : word `numbermethod' of `methodvaluesloop'
				local maxmethodvaluesplus1 = substr("`methodvaluesloop'", -`numbermethod', .)
				*di "`maxmethodvaluesplus1'"
				local maxmethodvaluesminus1 = substr("`methodvaluesloop'", 1 ,`numbermethod')
				*di "`maxmethodvaluesminus1'"
				local counter = 1
				local counterplus1 = 2
				foreach j in `maxmethodvaluesminus1' {
					*di "`j'"
					foreach k in `maxmethodvaluesplus1' {
						if "`j'" != "`k'" {
							`dicmd' twoway (function x, range(`frtheta') lcolor(gs10)) (scatter `estimate'`j' `estimate'`k' if `dgm'==`m' `iftarget', ms(o) ///
								mlc(white%1) msize(tiny) xtit("") ytit("Estimate", size(medium)) legend(off) `subgraphoptions' nodraw), `by' name(`estimate'`j'`k'dgm`m'tar`t', replace) 
							`dicmd' twoway (function x, range(`frse') lcolor(gs10)) (scatter `se'`j' `se'`k' if `dgm'==`m' `iftarget', ms(o) mlc(white%1) ///
								msize(tiny) xtit("") ytit("Standard Error", size(medium)) legend(off) `subgraphoptions' nodraw), `by' name(`se'`j'`k'dgm`m'tar`t', replace) 
							local graphtheta`counter'`counterplus1'`m'`t' `estimate'`j'`k'dgm`m'tar`t'
							local graphse`counter'`counterplus1'`m'`t' `se'`j'`k'dgm`m'tar`t'
							local counterplus1 = `counterplus1' + 1
							if `counterplus1' > `numbermethod' local counterplus1 = `numbermethod'
						}
					}
					local counter = `counter' + 1
				}
			}

			else if `methodstringindi'==1 | !mi("`methlist'") {
				local counter = 1
				local counterplus1 = 2
				local maxmethodvaluesminus1 = `numbermethod' - 1
				*local maxmethodvaluesplus1  = `numbermethod' + 1
				forvalues j = 1/`maxmethodvaluesminus1' {
					forvalues k = 2/`numbermethod' {
						if "`j'" != "`k'" {
							`dicmd' twoway (function x, range(`frtheta') lcolor(gs10)) (scatter `estimate'``j'' `estimate'``k'' if `dgm'==`m' `iftarget', ms(o) ///
								mlc(white%1) msize(tiny) xtit("") ytit("Estimate", size(medium)) legend(off) `subgraphoptions' nodraw), `by' name(`estimate'``j''``k''dgm`m'tar`t', replace)
							`dicmd' twoway (function x, range(`frse') lcolor(gs10)) (scatter `se'``j'' `se'``k'' if `dgm'==`m'`iftarget', ms(o) ///
								mlc(white%1) msize(tiny) xtit("") ytit("Standard Error", size(medium)) legend(off) `subgraphoptions' nodraw), `by' name(`se'``j''``k''dgm`m'tar`t', replace)
							local graphtheta`counter'`counterplus1'`m'`t' `estimate'``j''``k''dgm`m'tar`t'
							local graphse`counter'`counterplus1'`m'`t' `se'``j''``k''dgm`m'tar`t'
							local counterplus1 = `counterplus1' + 1
							if `counterplus1' > `numbermethod' local counterplus1 = `numbermethod'
						}
					}
					local counter = `counter' + 1
				}
			}
			
			* use target labels if target numeric with string labels
			if `targetlabels' == 1 {
				local tlab: word `t' of `valtarget'
				local targetlab ", `target': `tlab'"
			}
			else {
				local tlab `t'
				local targetlab ", `target': `tlab'"
			}
			if "`valtarget'"== "N/A" local targetlab
			
			if mi("``dgm'dlabel`m''") local `dgm'dlabel`m' `m'
			
			if `numbermethod'==2 {
				`dicmd' graph combine `mlabelname1' `graphtheta12`m'`t'' ///
					`graphse12`m'`t'' `mlabelname2' ///
					, title("") note("Graphs for `dgm': ``dgm'dlabel`m''`targetlab'") cols(2)	///
					xsize(4)	///
					name(`name'_dgm`m'`tlab', replace) `options'
			}
			else if `numbermethod'==3 {
				`dicmd' graph combine `mlabelname1' `graphtheta12`m'`t'' `graphtheta13`m'`t''	///
					`graphse12`m'`t'' `mlabelname2' `graphtheta23`m'`t''	///
					`graphse13`m'`t'' `graphse23`m'`t'' `mlabelname3'	///
					, title("") note("Graphs for `dgm': ``dgm'dlabel`m''`targetlab'") cols(3)	///
					xsize(4)	///
					name(`name'_dgm`m'`tlab', replace) `options'
			}
			else if `numbermethod'>3 {
				if mi("`anything'") local anything = "est"
				`dicmd' graph matrix `varlist' if `dgm'==`m' `iftarget', `half' `by' title("") note("") ms(o) mlc(gs10) msize(tiny) ///
				name(`name'_`anything'`j'`k'dgm`m'`tlab', replace) `options'
			}
		}
	}
}

else if `numberdgms' != 1 {
		
	foreach dgmvar in `dgmvalues' {
		if !mi("`debug'") di as text "Loop for numberdgms > 1: m = `m'"
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
			
			local loop = 1
			foreach l of local levels {
				local `dgmvar'dlabel`loop' `l'
				local loop = `loop' + 1
			}
		}
	}

*		if `dgmlabels' == 0 local dgmfilter = "`dgmvar' == ``dgmvar'dlabel`d''"
*		else if `dgmlabels' == 1 local dgmfilter = "`dgmvar'==`d'"
			
		tempvar _group
		qui egen `_group' = group(`dgmvalues'), label lname(grouplevels)
		local group "`_group'"
		qui tab `group'
		local groupnum = `r(r)'
			
		* give user a warning if lots of graphs will be created
		if "`numtarget'" == "N/A" local numtargetcheck = 1
		else {
				* need to re-count in case there is an 'if' statement.  Data is in long-long format from reshape above
				qui tab `target'   
				local numtargetcheck = `r(r)'
		}
		if "`groupnum'" == "" local totalgroupnum = 1
		else local totalgroupnum = `groupnum'

			local graphnumcheck = `totalgroupnum' * `numtargetcheck'
			if `graphnumcheck' > 15 {
				di as smcl as text "{p 0 2}Warning: `graphnumcheck' graphs will be created: consider using 'if' condition as detailed in {help siman_comparemethodsscatter:siman comparemethodsscatter}{p_end}"
			}


		forvalues d = 1/`groupnum' {
			    
			local dgmfilter = "`group'==`d'"
			local dgmlevels`d' : label grouplevels `d'
	
			* check if target is numeric with string labels for the looping over target values
			*if `targetlabels' == 1 {
			if "`valtarget'"!= "N/A" {
				qui levelsof `target', local(targetlevels)
				local foreachtarget "`targetlevels'"
			}
			*}
			*else local foreachtarget "`valtarget'"
			*else if "`valtarget'"!= "N/A" local foreachtarget "`valtarget'"
			else local foreachtarget 1

			foreach t in `foreachtarget' {

				* for target, determine if string/string labels or not
				cap confirm numeric variable `target'
				if _rc local iftarget `"& `target' == "`t'""'
				else local iftarget `"& `target' == `t'"'	
				if "`valtarget'"== "N/A" local iftarget
				
				local frtheta `minest' `maxest'
				local frse `minse' `maxse'
				
				if `methodstringindi'==0   {		
					if mi("`methlist'") {
						* if numerical method without labels
						if `methodlabels'!= 1 local methodvaluesloop `valmethod'	
						* if numerical method with labels
						else local methodvaluesloop `valmethodnumwithlabel'
					}
					local maxmethodvaluesloop : word `numbermethod' of `methodvaluesloop'
					local maxmethodvaluesplus1 = substr("`methodvaluesloop'", -`numbermethod', .)
					*di "`maxmethodvaluesplus1'"
					local maxmethodvaluesminus1 = substr("`methodvaluesloop'", 1 ,`numbermethod')
					*di "`maxmethodvaluesminus1'"
					local counter = 1
					local counterplus1 = 2
					
					foreach j in `maxmethodvaluesminus1' {
					*	di "`j'"

						foreach k in `maxmethodvaluesplus1' {
							if "`j'" != "`k'" {
								`dicmd' twoway (function x, range(`frtheta') lcolor(gs10)) ///
									(scatter `estimate'`j' `estimate'`k' ///
									if `dgmfilter' `iftarget', ms(o) mlc(white%1) msize(tiny)), ///
									xtit("") ytit("Estimate", size(medium)) legend(off) `subgraphoptions' nodraw ///
									`by' name(`estimate'`j'`k'`d'tar`t', replace)
								`dicmd' twoway (function x, range(`frse') lcolor(gs10)) ///
									(scatter `se'`j' `se'`k' if ///
									`dgmfilter' `iftarget', ms(o) mlc(white%1) msize(tiny)), ///
									xtit("") ytit("Standard Error", size(medium)) legend(off) `subgraphoptions' nodraw ///
									`by' name(`se'`j'`k'`d'tar`t', replace) 
								local graphtheta`counter'`counterplus1'`d'`t' `estimate'`j'`k'`d'tar`t'
								local graphse`counter'`counterplus1'`d'`t'  `se'`j'`k'`d'tar`t'
								local counterplus1 = `counterplus1' + 1
								if `counterplus1' > `numbermethod' local counterplus1 = `numbermethod'
						    }
						}
						local counter = `counter' + 1
					}
				}
						
				else if `methodstringindi'==1 | !mi("`methlist'") {
					local counter = 1
					local counterplus1 = 2
					local maxmethodvaluesminus1 = `numbermethod' - 1
				*	local maxmethodvaluesplus1 = `nummethod' + 1
					forvalues j = 1/`maxmethodvaluesminus1' {
						forvalues k = 2/`numbermethod' {
							if "`j'" != "`k'" {
								`dicmd' twoway (function x, range(`frtheta') lcolor(gs10)) (scatter `estimate'``j'' `estimate'``k'' ///
									if `dgmfilter' `iftarget', ms(o) mlc(white%1) msize(tiny) xtit("") ///
									ytit("Estimate", size(medium)) legend(off) `subgraphoptions' nodraw), ///
									`by' name(`estimate'``j''``k''`d'tar`t', replace)
								`dicmd' twoway (function x, range(`frse') lcolor(gs10)) (scatter `se'``j'' `se'``k'' if ///
									`dgmfilter' `iftarget', ms(o) mlc(white%1) msize(tiny) xtit("") ///
									ytit("Standard Error", size(medium)) legend(off) `subgraphoptions' nodraw), ///
									`by' name(`se'``j''``k''`d'tar`t', replace)
								local graphtheta`counter'`counterplus1'`d'`t' `estimate'``j''``k''`d'tar`t'
								local graphse`counter'`counterplus1'`d'`t' `se'``j''``k''`d'tar`t'
								local counterplus1 = `counterplus1' + 1		
								if `counterplus1' > `numbermethod' local counterplus1 = `numbermethod'
							}
						}
						local counter = `counter' + 1
					}
				}
						
				* use target labels if target numeric with string labels
				if `targetlabels' == 1 { 
					local tlab: word `t' of `valtarget'
					local targetlab ", `target': `tlab'"
				}
				else {
					local tlab `t'
					local targetlab ", `target': `tlab'"
				}
				if "`valtarget'"== "N/A" local targetlab

				if `numbermethod'==2 {

					`dicmd' graph combine `mlabelname1' `graphtheta12`d'`t'' `graphse12`d'`t'' `mlabelname2', ///
						title("") note("Graphs for `dgmvalues': `dgmlevels`d''`targetlab'") cols(2)	xsize(4) ///
						name(`name'_`d'`tlab', replace) `options'
				}
				else if `numbermethod'==3 {
					`dicmd' graph combine `mlabelname1' `graphtheta12`d'`t'' `graphtheta13`d'`t'' ///
						`graphse12`d'`t'' `mlabelname2' `graphtheta23`d'`t'' ///
						`graphse13`d'`t'' `graphse23`d'`t'' `mlabelname3', ///
						title("") note("Graphs for `dgmvalues': `dgmlevels`d''`targetlab'") cols(3)	xsize(4) ///
						name(`name'_`d'`tlab', replace) `options'
				}
				else if `numbermethod'>3 {
					if mi("`anything'") local anything = "est"
					`dicmd' graph matrix `varlist' if `group'==`d' `iftarget', `half' `by' title("") note("") ms(o) mlc(gs10) msize(tiny)///
						name(`name'_`anything'`j'`k'`d'`tlab', replace) `options'
				}
			}
		}
}


restore

local dgm = "`dgmorig'"

qui use `origdata', clear

end


program define dicmd
noi di as input `"`0'"'
`0'
end
