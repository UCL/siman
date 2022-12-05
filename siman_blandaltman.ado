*! version 1.6   26sep2022 
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

capture program drop siman_blandaltman
program define siman_blandaltman, rclass
version 15

syntax [anything] [if][in] [,* Methlist(string) BY(varlist) BYGRaphoptions(string)]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`simansetuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
	}


if "`method'"=="" {
	di as error "The variable 'method' is missing so siman blandaltman can not be created.  Please create a variable in your dataset called method containing the method value(s)."
	exit 498
	}

* if both estimate and se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") & mi("`se'") {
    di as error "siman blandaltman requires either estimate or se to plot"
	exit 498
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

* if statistics are not specified, run graphs for estimate only, otherwise run for all that are specified
if "`anything'"=="" local varlist `estimate'
else foreach thing of local anything {
	local varelement = "`thing'"
	local varlist `varlist' `varelement'
	}
	
	
* if the user has not specified 'if' in the siman blandaltman syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifba = `"`ifsetup'"'
else local ifba = `"`if'"'
tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifba' 
preserve
sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman_blandaltman."  
	exit 498
	}
restore
qui keep if `touseif'

* if the user has not specified 'in' in the siman blandaltman syntax, but there is one from siman setup then use that 'in'
if ("`in'"=="" & "`insetup'"!="") local inba = `"`insetup'"'
else local inba = `"`in'"'
tempvar tousein
generate `tousein' = 0
qui replace `tousein' = 1 `inba' 
qui keep if `tousein'
	
	
if `nummethod' < 2 {
	di as error "There are not enough methods to compare, siman blandaltman requires at least 2 methods."
	exit 498
	}


* Need to know what format method is in (string or numeric) for the below code
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1


* Need labelsof package installed to extract method labels
qui capture which labelsof
if _rc {
	di as smcl  "labelsof package required, please kindly install by clicking: "  `"{stata ssc install labelsof}"'
	exit
} 

qui labelsof `method'
qui ret list

if "`r(labels)'"!="" {
	local 0 = `"`r(labels)'"'

	forvalues i = 1/`nummethod' {  
		gettoken mlabel`i' 0 : 0, parse(": ")
	}
}
else {
qui levels `method', local(levels)
tokenize `"`levels'"'
	
	if `methodstringindi'==0 {
	
		forvalues i = 1/`nummethod' {  
			local mlabel`i' `i'
		}
	}
	else if `methodstringindi'==1 {
	
		forvalues i = 1/`nummethod' {  
			local mlabel`i' ``i''
		}
		
	}
}


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


* only analyse the methods that the user has requested
if !mi("`methlist'") {
	local methodvalues = "`methlist'"
	local count: word count `methlist'
	tempvar tousemethod
	qui generate `tousemethod' = 0
    tokenize `methodvalues'
		if `methodstringindi' == 0 {
			foreach j in `methodvalues' {
				qui replace `tousemethod' = 1  if `method' == `j'
			}
		}
		else if `methodstringindi' == 1 {
			foreach j in `methodvalues' {
				qui replace `tousemethod' = 1  if method == "`j'"
			}
		}
qui keep if `tousemethod' == 1
qui drop `tousemethod'		
}	

* If method is a string variable, need to encode it to numeric format for graphs 
if `methodstringindi'==1 & mi("`methlist'") {
	qui encode `method', generate(numericmethod)	
	qui drop `method'
	qui rename numericmethod method
	local method = "method"
	}

* Comparing each method vs. each other method
if !mi("`methlist'") local nummethod = `count'

* Have the first method as the 'reference' method by default, so if have methods A, B, C and D, then calculate B-A, C-A, D-A.
* check number of methods hasn't changed (for example if the 'if' syntax has been used)
qui tab `method'
local nummethodloop = `r(r)'

* If data is not in long-wide format, then reshape for graphs
qui siman reshape, longwide
* have to do this first to get new number of methods etc
foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
	}
	
	
if mi("`methlist'") {		
		forvalues j = 2/`nummethodloop' {
			foreach s in `estimate' `se' {
					qui gen float diff`s'`mlabel`j'' = `s'`j' - `s'1									
					qui gen float mean`s'`mlabel`j'' = (`s'`j'+`s'1)/2
							}
							local j = `j' + 1
		}	
}
else {
	tokenize `methlist'
			foreach s in `estimate' `se' {
				    local methlabel = "`2'"
					qui gen float diff`s'`methlabel' = `s'`2' - `s'`1'									
					qui gen float mean`s'`methlabel' = (`s'`2'+`s'`1')/2
					local mlabel1 `1'
					local mlabel2 `2'
							}
}

forvalues f = 1/`nummethod' {
	cap qui drop `estimate'`f'
	cap qui drop `se'`f'
}


di as text "working...."

qui reshape long diff`estimate' mean`estimate' diff`se' mean`se', i(`rep' `dgm' `target') j(strmeth) string	
qui reshape long diff mean, i(`rep' `dgm' `target' strmeth) j(strthing) string

if mi("`methlist'") {
	qui tab strmeth
	local numstrmeth = `r(r)'
	qui gen byte method = 1 if strmeth=="`mlabel1'"
	forvalues n = 2/`nummethod' {
		cap qui replace method = `n' if strmeth=="`mlabel`n''"
		local labelvalues `n' "Method: `mlabel`n'' vs. `mlabel1'" `labelvalues'
		if `n'==`nummethod' label define method `labelvalues'
	}
	lab val method method
}
else {
	qui gen byte method = 1
	label define method 1 "Method: `mlabel2' vs. `mlabel1'"
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
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

* Need to know number of dgms for later on
local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	local ndgm = `r(r)'
}
if `numberdgms'!=1 local ndgm = `numberdgms'

if `numberdgms'==1 {
	* Need to know what format dgm is in (string or numeric) for the below code
	local dgmstringindi = 0
	capture confirm string variable `dgm'
	if !_rc local dgmstringindi = 1
}
else local dgmstringindi = 1

* for 'by' syntax

if !mi("`by'") {
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

	if mi(`"`options'"') {
		local options mlc(white%1) msym(O) msize(tiny)
		}
		
	local name = "simanblandaltman"

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
	
	local targetstringindi = 0	
	* If target is not missing	
	if "`valtarget'" != "N/A" {
		
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
		
		forvalues d = 1/`ndgmvar' {
			foreach t in `valtargetloop' {
					foreach el in `varlist' {

			* determine if target is numeric or not
			cap confirm number `t'
			if _rc local targetstringindi = 1
	/*		* also check labels as could be numerical data with string labels
			qui labelsof `target'
			tokenize `"`r(values)'"'
			cap confirm number `1'
			if _rc local targetstringindi = 1
			if !_rc local targetstringindi = 0 */
			
			* graph titles
			if "`el'"=="`estimate'" local eltitle = "`estimate' "
			else if "`el'"=="`se'" local eltitle = "`se' " 

			if `n`dgmvar'labels' > 1 & ("`by'"=="" | "`by'"=="`dgmvar' `target'") {
				local bytitle = "DGM = ``dgmvar'dlabel`d'', Target = `t'"
				
				if `dgmlabels' == 1 {						
					if `targetstringindi' == 1 local byvarlist = `"`dgmvar'==`d' & `target'=="`t'""'
					else local byvarlist = `"`dgmvar'==`d' & `target'==`t'"'
				}				
				else if `dgmlabels' == 0 {						
					if `targetstringindi' == 1 local byvarlist = `"`dgmvar'== ``dgmvar'dlabel`d'' & `target'=="`t'""'
					else local byvarlist = `"`dgmvar'== ``dgmvar'dlabel`d'' & `target'==`t'"'
				}				
				if `numberdgms' > 1 local byname = "`dgmvar'`d'`t'"
				else local byname = "`d'`t'"
			}
			else if `n`dgmvar'labels' == 1 & ("`by'"=="" | "`by'"=="`dgmvar' `target'")  {
				local bytitle = "Target = `t'"
				if `targetstringindi' == 1 local byvarlist = `"`target'=="`t'""'
				else local byvarlist = `"`target'==`t'"'
				local byname = "`t'"
			}
			else if "`by'"=="`dgmvar'" {
				local bytitle = "DGM = ``dgmvar'dlabel`d''"
				if `dgmlabels' == 1 local byvarlist = `"`dgmvar'==`d'"'
				else if `dgmlabels' == 0 local byvarlist = `"`dgmvar'==``dgmvar'dlabel`d''"'
				if `numberdgms' > 1 local byname = `dgmvar'`d'
				else local byname = `d'
			}
			else if "`by'"=="`target'" {
				local bytitle = "Target = `t'"
				if `targetstringindi' == 1 local byvarlist = `"`target'=="`t'""'
				else local byvarlist = `"`target'==`t'"'
				local byname = "`t'"
			}
			else if "`by'"=="`target' `dgmvar'" {
				di as err "'by' nesting order should be by(dgm target)"
				exit 198
			}

			#delimit ;
				twoway (scatter diff mean if strthing == "`el'" & `byvarlist', `options')
				,
				xsize(5)
				by(method, note("") iscale(1.1) title("Bland Altman, `eltitle', `bytitle'") `bygraphoptions') ///
				name( `name'_`byname'`el', replace)
				;
			#delimit cr
				}
			}    
		}   
	}
	else {
			forvalues d = 1/`ndgmvar' {
					foreach el in `varlist' {

						* graph titles
						if "`el'"=="`estimate'" local eltitle = "`estimate' "
						else if "`el'"=="`se'" local eltitle = "`se' " 

						if `n`dgmvar'labels' > 1 & ("`by'"=="" | "`by'"=="`dgmvar'") {
							local bytitle = "DGM = ``dgmvar'dlabel`d''"
							if `dgmlabels' == 1 local byvarlist = `"`dgmvar'==`d'"'
							else if `dgmlabels' == 0 local byvarlist = `"`dgmvar'==``dgmvar'dlabel`d''"'
							if `numberdgms' > 1 local byname = "`dgmvar'`d'"
							else local byname = "`d'"
						}	
						if `n`dgmvar'labels' > 1 {
						   #delimit ;
							twoway (scatter diff mean if strthing == "`el'" & `byvarlist', `options')
							,
							xsize(5)
							by(method, note("") iscale(1.1) title("Bland Altman, `eltitle', `bytitle'") `bygraphoptions') ///
							name( `name'_`byname'`el', replace)
							;
							#delimit cr
						}
						else {
							#delimit ;
							twoway (scatter diff mean if strthing == "`el'", `options')
							,
							xsize(5)
							by(method, note("") iscale(1.1) title("Bland Altman, `eltitle'") `bygraphoptions') ///
							name( `name'_`el', replace)
							;
							#delimit cr
						}
			
				} 
		}   
	}
}
restore 

use `origdata', clear  

end

