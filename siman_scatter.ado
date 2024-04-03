*! version 1.6.7 03oct2023
*  version 1.6.7 03oct2023   EMZ update to warning message when by() conditions used
*  version 1.6.6 18sept2023  EMZ updated warning of # panels to be printed based on 'if' subset
*  version 1.6.5 08aug2023   EMZ restricted siman scatter options to be -estimate se- or -se estimate- only
*  version 1.6.4 26june2023  EMZ minor bug fix for when dgm/method is missing, and tidy up of code.
*  version 1.6.3 13june2023  EMZ: changed if dgm is defined by > 1 variable, that a pannel for each dgm var/level, target and method is displayed on 1 *							graph, with a warning to the user as per IRW/TPM request
*  version 1.6.2 06may2023   EMZ agreed updates from IRW/TPM/EMZ joint testing 
*  version 1.6.1 13mar2023   EMZ minor update to error message
*  version 1.6   23jan2023   EMZ bug fixes from changes to setup programs 
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
	
* if estimate or se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") | mi("`se'") {
    di as error "siman scatter requires estimate and se to plot"
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
* The 'if' condition will only apply to dgm, target and method.  The 'if' condition is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' condition can not be applied to 'rep' in siman scatter. If you have not specified an 'if' in siman scatter, but you specified one in siman setup, then that 'if' will have been applied to siman scatter."  
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
local anythingcount: word count `anything'
if "`anything'"=="" local varlist `estimate' `se'
else foreach thing of local anything {
	local varelement = "`thing'"
		if ("`varelement'"!="`estimate'" & "`varelement'"!="`se'") | "`anythingcount'"!="2" {
			di as error "only -estimate se- or -se estimate- allowed"
			exit 498
		}
	local varlist `varlist' `varelement'
}

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgmvars=1
}

local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	local ndgmlabels = `r(r)'
}
if `numberdgms'!=1 local ndgmlabels = `numberdgms'


if !mi("`by'") {
	local byvar = "`by'"
}
else if mi("`by'") {
	if "`dgmcreated'" == "1" & "`methodcreated'" == "1" local byvar "`target'"
	else if "`dgmcreated'" == "1" & "`methodcreated'" == "0" local byvar "`target' `method'"
	else if "`dgmcreated'" == "0" & "`methodcreated'" == "1" local byvar "`dgm' `target'"
	else local byvar = "`dgm' `target' `method'"
}

/*
* handle by if contains dgm: make dgmvar equal to the `by' option only
if !mi("`by'") {
	local keep `by'
	local vars `dgm'
	local tokeep : list vars & keep
	if !mi("`tokeep'") {
		local dgmvar = "`by'"
		qui tab `by'
		local ndgmlabels = `r(r)'
	}
}
*/

* scatter plot
* check if many graphs will be created - if so warn the user
local dgmcount: word count `dgm'
qui tokenize `dgm'
if `dgmcreated' == 0 {
	forvalues j = 1/`dgmcount' {
		qui tab ``j''
		local nlevels = r(r)
		local dgmvarsandlevels `"`dgmvarsandlevels'"' `"``j''"' `" (`nlevels') "'
		if `j' == 1 local totaldgmnum = `nlevels'
		else local totaldgmnum = `totaldgmnum'*`nlevels'
	}
}

if "`numtarget'" == "N/A" local numtargetcheck = 1
else {
    * need to re-count in case there is an 'if' statement.  Data is in long-long format from reshape above
	qui tab `target'   
	local numtargetcheck = `r(r)'
}
if "`nummethod'" == "N/A" local nummethodcheck = 1
else {
      * need to re-count in case there is an 'if' statement.  Data is in long-long format from reshape above
	qui tab `method'   
	local nummethodcheck = `r(r)'
}
if "`totaldgmnum'" == "" local totaldgmnum = 1

if !mi("`by'") & strpos("`dgm'", "`by'")>0 {
	local numtargetcheck = 1
	local nummethodcheck = 1
	cap qui tab `by'
	local totaldgmnum = `r(r)'
}
if !mi("`by'") & "`by'" == "`target'" {
	local totaldgmnum = 1
	local nummethodcheck = 1
}
if !mi("`by'") & "`by'" == "`method'" {
	local totaldgmnum = 1
	local numtargetcheck = 1
}


local graphnumcheck = `totaldgmnum' * `nummethodcheck' * `numtargetcheck'
if `graphnumcheck' > 15 {
	di as smcl as text "{p 0 2}Warning: `graphnumcheck' panels will be created: consider using 'if' condition or 'by' option as detailed in {help siman_scatter:siman scatter}{p_end}"
}

* if dgm is defined by multiple variables, default is to plot scatter graphs for each dgm variable, split out by each level

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
			local options: list options - name
		}
}
if mi("`name'") local name "name(simanscatter, replace)"
	
twoway scatter `varlist' `if', msym(o) msize(small) mcol(%30) by(`byvar', ixaxes `bygraphoptions') `name' `options'

restore

qui use `origdata', clear

end


