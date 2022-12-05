*! version 1.5   05dec2022
*  version 1.5   05dec2022   EMZ fixed bug so that dgm labels are used when 1 dgm variable, and scatter plots for each dgm when true not part of dgm *                            structure.
*  version 1.4   12sep2022   EMZ added to code so now allows scatter graphs split out by every dgm variable and level if multiple dgm variables declared.
*  version 1.3   05sep2022   EMZ added additional error message.
*  version 1.2   14july2022  EMZ. Tidied up graph labels if 'by' option used.  Fixed bug if more than 1 dgm variable used.  Fixed bug so name() allowed if *                            user specifies.
*  version 1.1   17mar2022   EMZ. Suppressed "DGM=1" from graph titles if only one dgm.
*  version 1.0   9dec2019    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the siman scatter plot
******************************************************************************************************************************************************

capture program drop siman_scatter
program define siman_scatter, rclass
version 16

syntax [anything] [if][in] [,* BY(varlist) BYGRaphoptions(string)]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`simansetuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
	}
	
* if both estimate and se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") & mi("`se'") {
    di as error "siman scatter requires either estimate or se to plot"
	exit 498
}

tempfile origdata
qui save `origdata'

* If data is not in long-long format, then reshape
if `nformat'!=1 {
	qui siman reshape, longlong
		foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
	}
}

di as text "working....."

* if the user has not specified 'if' in the siman scatter syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifscatter = `"`ifsetup'"'
else local ifscatter = `"`if'"'
tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifscatter' 
preserve
sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman_scatter."  
	exit 498
	}
restore
qui keep if `touseif'

* if the user has not specified 'in' in the siman scatter syntax, but there is one from siman setup then use that 'in'
if ("`in'"=="" & "`insetup'"!="") local inscatter = `"`insetup'"'
else local inscatter = `"`in'"'
tempvar tousein
qui generate `tousein' = 0
qui replace `tousein' = 1 `inscatter' 
qui keep if `tousein'

preserve
* keeps estimates data only
qui drop if `rep'<0

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


* if statistics are not specified, run graphs for estimate and se, otherwise run for alternative order
if "`anything'"=="" local varlist `estimate' `se'
else foreach thing of local anything {
	local varelement = "`thing'"
	local varlist `varlist' `varelement'
	}

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	local ndgmlabels = `r(r)'
}
if `numberdgms'!=1 local ndgmlabels = `numberdgms'


/*
*create a variable with DGM = `dgm', Target = `target' and Method = `method' for use in the graphs
foreach var of varlist `dgm' `target'  `method' {
/*	
	if `numberdgms'==1 {
		local `var'labelindi=0
		cap qui labelsof `var'
		cap qui ret list
		if !mi("`r(labels)'") local `var'labelindi=1	
					
				
		tempvar `var'label`var'
		if ``var'labelindi'== 1 qui decode `var', gen(``var'label`var'')
		else qui gen ``var'label`var'' = `var'
		
		
		tempvar `var'equals
		qui gen ``var'equals' = "`var' = "
		tempvar `var'title
		qui egen ``var'title' = concat(``var'equals' ``var'label`var'')
		if "`by'"=="" local by = "``var'title`var''"
	} 
	else {*/
		tempvar `var'equals
		qui gen ``var'equals' = "`var' = "
		tempvar `var'title
		qui egen ``var'title' = concat(``var'equals' `var')
		local `var'title ``var'title'
		*if "`by'"=="`var'" local by ``var'title'
*	}
}


if !mi("`by'") {
    local bycount: word count `by'
    tokenize `by'
		forvalues i = 1/`bycount' {
			local bylabel`i' = "``i''"
			local bylist `bylist' ``bylabel`i''title'
		}
		local by `bylist'
}
*/

if !mi("`by'") {
	local byvar = "`by'"
}
else local byvar `dgm' `target' `method'


foreach var in `byvar' { 
		
	if `numberdgms'==1 {
		
			local `var'labelindi=0
			cap qui labelsof `var'
			cap qui ret list
			if !mi("`r(labels)'") local `var'labelindi=1	
			
		
			tempvar label`var'
			if ``var'labelindi'== 1 qui decode `var', gen(label`var')
			else qui gen label`var' = `var'
			tempvar `var'equals
			qui gen ``var'equals' = "`var': "
			tempvar `var'title
					
			qui egen ``var'title' = concat(``var'equals' label`var')
			
	} 
	else {			
			
			tempvar label`var'
			qui gen `label`var'' = `var'
			
			tempvar `var'equals
			qui gen ``var'equals' = "`var': "
			tempvar title`var'
			qui egen `title`var'' = concat(``var'equals' `label`var'')
			local byvar = "`title`var''"
	}
}


* scatter plot

* if dgm is defined by multiple variables, default is to plot scatter graphs for each dgm variable, split out by each level

if `numberdgms'!=1 & mi("`if'") {
	
	foreach dgmvar in `dgm' {
		twoway scatter `varlist', msym(o) msize(small) mcol(%30) by(`dgmvar', note("") `bygraphoptions') name(simanscatter_dgm_`dgmvar') `options'
	}
}
* if dgm is defined by 1 variable
else {
	
	if "`by'"=="" & `ndgmlabels' == 1 local byvar `target' `methodtitle' 
	else if "`by'"=="" & `ndgmlabels' != 1 local byvar `dgmtitle' `target' `methodtitle'
	local name = "name(simanscatter, replace)"

	* Can't tokenize/substr as many "" in the string
	if !mi(`"`options'"') {
		tempvar _namestring
		qui gen `_namestring' = `"`options'"'
		qui split `_namestring',  parse(`"name"')
		local options = `_namestring'1
		cap confirm var `_namestring'2
			if !_rc {
				local namestring = `_namestring'2
				local name = `"name`namestring'"'
			}
	}
	
	
	twoway scatter `varlist', msym(o) msize(small) mcol(%30) by(`byvar', note("") `bygraphoptions') `name' `options' 
}

restore

use `origdata', clear

end


