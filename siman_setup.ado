*!  version 0.5    11july2022
*   version 0.5    11july2022   EMZ changes to error catching.
*   version 0.4    05may2022    EMZ changes to wide-long format import, string target variables are not now auto encoded to numeric. Changed defn of ndgm.
*   version 0.3    06jan2022    EMZ changes from IW testing
*   version 0.2    23June2020   IW changes
*   version 0.1    04June2020   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
* For history, see end of file

capture program drop siman_setup
program define siman_setup, rclass
version 15

syntax [if] [in], Rep(varname) [ DGM(varlist) TARget(string) METHod(string)/* define the structure variables
	*/ ESTimate(string) SE(string) DF(string) LCI(string) UCI(string) P(string) TRUE(string) ORDer(string) CLEAR] 

/*
if method() contains one entry and target() contains one entry, then the program will assume that those entries are variable names and will select data format 1 (long-long).  
If method() and target() both contain more than one entry, then the siman program will assume that those entries are variable values and will assume data format 2 (wide-wide).  
If method() contains more than one entry and target() contains one entry only then data format 3 will be assumed (long-wide).
Please note that if method() contains one entry and target() contains more than one entry (wide-long) format then this will be auto-reshaped to long-wide (format 3).
*/

local simansetuprun = 0

capture confirm variable _perfmeascode
		if !_rc {
			di as error "siman would like to name a variable '_perfmeascode', but that name already exists in your dataset.  Please rename your variable _perfmeascode as something else."
		exit 498
		}
		
capture confirm variable _pm
		if !_rc {
			di as error "siman would like to name a variable '_pm', but that name already exists in your dataset.  Please rename your variable _pm as something else."
		exit 498
		}		
		
capture confirm variable _dataset
		if !_rc {
			di as error "siman would like to name a variable '_dataset', but that name already exists in your data.  Please rename your variable _dataset as something else."
		exit 498
		}
		
capture confirm variable _scenario
		if !_rc {
			di as error "siman would like to name a variable '_scenario', but that name already exists in your dataset.  Please rename your variable _scenario as something else."
		exit 498
		}
		
* check that the following only have one entry: rep, est, se, df, lci, uci, p, order, true
foreach singlevar in "`rep'" "`estimate'" "`se'" "`df'" "`lci'" "`uci'" "`p'" "`order'" "`true'" {
	* have to tokenize to show which vars have been entered together by the user.  Otherwise if the user has
	* entered est(est se) se(se) then the loop will just take each of the following separately: est then se then se.
	tokenize `singlevar'
	if "`2'"!="" {
		di as error "only one variable name is allowed where `singlevar' have been entered in siman setup."
			exit 498
			}
	local 2 
}

* check that dgm is a numerical value (with string labels if necc)
if !mi("`dgm'") {
	cap confirm numeric variable `dgm'
	if _rc {
		di as error "dgm needs to be numerical format for the siman suite."
		exit 498
	}
}
	
* if there is no dgm variable listed in the dataset (e.g. there is only 1 dgm so it is not included in the data), then create a temporary variable for dgm * with values of 1.

local dgmcreated = 0
cap confirm variable `dgm'
if _rc {
	tempvar dgm
	generate `dgm' = 1
	local dgm `dgm'
    local dgmcreated = 1
}

* obtain `if' and `in' conditions
tempvar touse
generate `touse' = 0
qui replace `touse' = 1 `if' `in'
if ("`if'"!= "" | "`in'"!= "") & "`clear'"== "clear" {
	keep if `touse'
	}
else if ("`if'"!= "" | "`in'"!= "") & "`clear'"!= "clear" {
	di as error "Data will be deleted, please use clear option to confirm."
	exit 498
	}

* store setup if and in for use in other siman progs
local ifsetup = `"`if'"'
local insetup = `"`in'"'


* obtain target elements
cap confirm existence `target'
	if !_rc {
		local ntarget: word count `target'
		tokenize `target'
			forvalues j=1/`ntarget' {
			local t`j' = "``j''"
			}
	}
else local ntarget = 0


* obtain method elements
cap confirm existence `method'
	if !_rc {
		local nmethod: word count `method'
		tokenize `method'
			forvalues i=1/`nmethod' {
			local m`i' = "``i''"
			}
	}
else local nmethod = 0


* if the user has accidentaly put the value of target or method instead of the variable name in long format, issue an error message
if `ntarget'==1 {
		cap confirm variable `target'
			if _rc {
			di as error "Please either put the target variable name in siman_setup target() for long format, or the target values for wide format"
			exit 498
			}
		}
		
if `nmethod'==1 {
		cap confirm variable `method'
			if _rc {
			di as error "Please either put the  method variable name in siman_setup method() for long format, or the method values for wide format"
			exit 498
			}
		}
		
* need either a method or target otherwise siman setup will not be able to determine the data format (longlong/widewide/longwide are based on target/method combinations).
if "`target'"=="" & "`method'"=="" {
	di as error "Need either target or method variable/values specified otherwise siman setup can not determine the data format."
	exit 498
	}


* check that there are no issues with data e.g. if have estcc estmi cc mi all in dataset, need to make sure that the user has entered siman setup syntax correctly
forvalues i=1/`nmethod' {
	cap confirm variable `m`i''
	if !_rc {
		if "`estimate'"!="" {
			cap confirm variable `estimate'`m`i''
			if !_rc {
			di as error "Both variables `m`i'' and `estimate'`m`i'' are contained in the dataset.  Please take care when specifying the method and estimate variables in the siman setup syntax"
			}
		}
	}
}

* check that there are not multiple records per rep where possible
preserve
if "`target'"!="" & `ntarget'==1 & "`method'"=="" & "`dgm'"=="" {
sort `rep' `target'
capture by `rep' `target': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify method/dgm values."
	exit 498
	}
}
else if "`target'"!="" & `ntarget'==1 & "`method'"=="" & "`dgm'"!="" {
sort `rep' `dgm' `target'
capture by `rep' `dgm' `target': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify method values."
	exit 498
	}
}
else if "`target'"!="" & `ntarget'>1 & "`method'"=="" & "`dgm'"=="" {
sort `rep' 
capture by `rep': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify method/dgm values."
	exit 498
	}
}
else if "`target'"!="" & `ntarget'>1 & "`method'"=="" & "`dgm'"!="" {
sort `rep' `dgm' 
capture by `rep' `dgm': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify method values."
	exit 498
	}
}
else if "`method'"!="" & `nmethod'==1 & "`target'"=="" & "`dgm'"=="" {
sort `rep' `method'
capture by `rep' `method': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify target/dgm values."
	exit 498
	}
}
else if "`method'"!="" & `nmethod'==1 & "`target'"=="" & "`dgm'"!="" {
sort `rep' `dgm' `method'
capture by `rep' `dgm' `method': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify target values."
	exit 498
	}
}
else if "`method'"!="" & `nmethod'>1 & "`target'"=="" & "`dgm'"=="" {
sort `rep' 
capture by `rep': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify target/dgm values."
	exit 498
	}
}
else if "`method'"!="" & `nmethod'>1 & "`target'"=="" & "`dgm'"!="" {
*tempvar scenario
*egen `scenario' = group(`rep' `dgm')
*egen scenario = group(`rep' `dgm')
sort `rep' `dgm'
capture by `rep' `dgm': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
	di as error "Multiple records per rep.  Please specify target values."
	exit 498
	}
}
restore

* If there is more than one dgm listed, the user needs to have put the main dgm variable (containing numerical values) at the start of the varlist for it to work
* obtain number of dgms

cap confirm variable `dgm'
	if !_rc {
		local ndescdgm: word count `dgm'
		if `ndescdgm'!=1 {
		local ndgm = `ndescdgm'
		tokenize `dgm'
		cap confirm numeric variable `1'
*			if !_rc {
*			qui tab `1'
*			local ndgm = r(r)
*			di "`ndgm'"
*			}
*			else {
	if _rc{
			di as error "If there is more than 1 dgm, the main numerical dgm needs to be placed first in the siman setup dgm varlist.  Please re-run siman_setup accordingly."
			exit 498
			} 
		}
		else if `ndescdgm'==1 {
			qui tab `dgm'
			local ndgm = r(r)
		}
	}


* obtain true elements: determine if there is only one true value or if it varies accross targets etc.  Could be in either long or wide format.
cap confirm variable `true'
local ntrue = 0
if !_rc {
	qui tab `true'
	local ntrue = r(r)
}

* if true is a stub assume it has different values accross the target/method combinations

forvalues i=1/`nmethod' {
	forvalues j=1/`ntarget' {
		cap confirm variable `true'`t`j''`m`i''
		if !_rc local ntrue = 2
			}
	}
	
forvalues j=1/`ntarget' {
	forvalues i=1/`nmethod' {
		cap confirm variable `true'`m`i''`t`j''
		if !_rc local ntrue = 2
			}
	}
	
forvalues i=1/`nmethod' {
		cap confirm variable `true'`m`i''
		if !_rc local ntrue = 2
	}
	
forvalues j=1/`ntarget' {
		cap confirm variable `true'`t`j''
		if !_rc local ntrue = 2
	}


if `ntrue'<=1 local ntruevalue = "single"
else if `ntrue'>1 & `ntrue'!=. local ntruevalue = "multiple"

* If there is one entry in the method() syntax and one entry in the target() syntax then they are variable names and the data is format 1, long-long.
* If target is missing but method() has one entry, or vice-versa, or both target and method are missing then the data is in long-long format also.
if (`nmethod'==1 & `ntarget'==1 ) | (`nmethod'==1 & `ntarget'==0 ) | (`nmethod'==0 & `ntarget'==1 ) | (`nmethod'==0 & `ntarget'==0 ) {
	local nformat= 1 
	local format = "format 1: long-long"
	local targetformat = "long"
	local methodformat = "long"
}
else
if `nmethod'>1 & `ntarget'>1 & `nmethod'!=0 & `ntarget'!=0 {
	local nformat= 2
	local format = "format 2: wide-wide"
	local targetformat = "wide"
	local methodformat = "wide"
}
else
* please note that 'wide-long' formats are given nformat=3 as they are auto-reshaped to long-wide format later before siman setup exits
if (`nmethod'>1 & `ntarget'==1 & `nmethod'!=0) | (`ntarget'>1 & `nmethod'==1 & `ntarget'!=0) | (`nmethod'>1 & `ntarget'==0) | (`ntarget'>1 & `nmethod'==0) {
	local nformat= 3
	local format = "format 3: long-wide"
	local targetformat = "long"
	local methodformat = "wide"
}
else
* Note can only do the below for format 1 as if method was missing from format 3 then data would just in effect be long-long format.  If method
* and target were missing from format 2 than the data would just in effect be long-long format.
if `nmethod'==0 & `ntarget'<=1 | `ntarget'==0  & `nmethod'<=1 {
    * get number of rows of the data 
	local maxnumdata _N 
	
	* get maximum of rep
	qui summarize `rep'
	local maxrep = r(max)
	
	* find out how many dgms, targets, methods
	foreach k in `dgm' `target' `method' {
		qui tab `k'
		local count`k' = r(r)
		}
			if `nmethod'==0 & `ntarget'!=0 {
			local compare = `maxrep' * `ndgm' * `count`target''  /* previously used countdgm but didn't work for multiple dgms with descriptors.  Same for other 2 lines below */
			}
			else
			if `ntarget'==0 & `nmethod'!=0 {
			local compare = `maxrep' * `ndgm' * `count`method'' 
			}
			else
			if `nmethod'==0 & `ntarget'==0 {
			local compare = `maxrep' * `ndgm' 
			}
	if `compare' == `maxnumdata' {
	local nformat= 1
	local format = "format 1: long-long"
	}
	
}	


* If in wide-wide format and order is missing, exit with an error:
if `nformat'==2 & "`order'"=="" {
	di as error "Input data is in wide-wide format but order() has not been specified.  Please specify order: either order(method) or order(target) in the syntax."
	exit 498
}


* Specify confidence intervals
local ci `lci' `uci'



* Identifying elements for summary output table   
************************************************

* If format is long-long, or long-wide then 
* 'number of targets' will be the number of variable labels for target 


if `nformat'==1 | (`nformat'==3 & `ntarget'==1)  {

	if `ntarget'!=0 {

		qui tab `target',m
		local ntargetlabels = `r(r)'

		qui levels `target', local(levels)
		tokenize `"`levels'"'
		forvalues e = 1/`ntargetlabels' {
			local tarlabel`e' = "``e''"
			if `e'==1 local tarlist `tarlabel`e''
			else if `e'>=2 local tarlist `tarlist' `tarlabel`e''
			}
		
	}
}

* If format is long-long, or wide-long then 
* 'number of methods' will be the number of variable labels for method

if `nformat'==1 | (`nformat'==3 & `nmethod'==1)  {
 
	if `nmethod'!=0 {
	
		qui tab `method',m
		local nmethodlabels = `r(r)'

		qui levels `method', local(levels)
		tokenize `"`levels'"'
		forvalues e = 1/`nmethodlabels' {
			local methlabel`e' = "``e''"
			if `e'==1 local methlist `methlabel`e''
			else if `e'>=2 local methlist `methlist' `methlabel`e''
			}	
		}

}




* for summary output 
**********************

if `nformat'==1 {

* For format 1, long-long: number of methods will be the number of method labels
* and the number of targets will be the number of target labels
	local nummethod = "`nmethodlabels'"
	local numtarget = "`ntargetlabels'"
	
* the method and target values will be the variable labels
	local valmethod = "`methlist'"
	local valtarget = "`tarlist'"
	
	* define whether stub or variable
	local descriptiontype = "variable"	
	local cidescriptiontype = "variables"	
}

else if `nformat'==2 {

* number of methods will be the number of methods that the user specified
* and the number of targets will be the number of targets that the user specified
	local nummethod = "`nmethod'"
	local numtarget = "`ntarget'"
	
* the method and target values will be those entered by the user
	local valmethod = "`method'"
	local valtarget = "`target'"
	
* define whether stub or variable
	local descriptiontype = "stub"
	local cidescriptiontype = "stubs"

}
else if `nformat'==3 {

* For format 3, long-wide format
* will be in long-wide with long targets and wide methods after auto-reshape
	

	if `ntarget'==1 {
	* the number of targets will be the number of target labels
		local numtarget = "`ntargetlabels'"
		local valtarget = "`tarlist'"
	}
	else if `ntarget'>=1 & `ntarget'!=. {
	*  number of targets will be the number of targets that the user specified
		local numtarget = "`ntarget'"
		local valtarget = "`target'"
	}
	if `nmethod'==1 {
	* the number of methods will be the number of method labels
		local nummethod = "`nmethodlabels'"
		local valmethod = "`methlist'"
	}
	else if `nmethod'>=1 & `nmethod'!=. {
	*  number of methods will be the number of methods that the user specified
		local nummethod = "`nmethod'"
		local valmethod = "`method'"
	}


* define whether stub or variable
	local descriptiontype = "stub"
	local cidescriptiontype = "stubs"
}	
	
* Then the below are the same for all formats:

* when target or method is missing
	if `ntarget'==0 {
		local numtarget = "N/A"
		local valtarget = "N/A"
	}
	
	if `nmethod'==0 {
		local nummethod = "N/A"
		local valmethod = "N/A"
	}

	
* Declaring the dgm variables	
	if "`dgm'"!="" {
		local dgmvar = "`dgm'"  
		local numdgm = "`ndgm'"
			if `dgmcreated' ==1 {
				local dgmvar "not in dataset"
				local numdgm "N/A"
			}
		}
	else {
		local dgmvar = "N/A"	
		local numdgm = "N/A"
		}

* Declaring the estimate variables	
	if "`estimate'"!="" local estvars = "`estimate'"  	
	else local estvars = "N/A"  
	
* Declaring the se variables	
	if "`se'"!="" local sevars = "`se'"  	
	else local sevars = "N/A"  
	
* Declaring the df variables	
	if "`df'"!="" local dfvars = "`df'"  
	else local dfvars = "N/A"
	
* Declaring the ci variables	
	if "`ci'"!="" local civars = "`ci'"  
	else local civars = "N/A"
	
* Declaring the p variables	
	if "`p'"!="" local pvars = "`p'"  
	else local pvars = "N/A"


* Declaring the true variables	
	if "`true'"!="" local truevars = "`true'"  
	else local truevars = "N/A"

* define whether stub or variable
	if "`ntruevalue'"=="single" local truedescriptiontype = "variable"
	else if "`ntruevalue'"=="multiple" local truedescriptiontype = "stub"
	* true will always be a variable if in long-long format and long-wide format
	if `nformat'==1 local truedescriptiontype = "variable"
	if `nformat'==3 & `ntarget'==1 local truedescriptiontype = "variable"

/*
NB.  Can't loop as if variable is not present, then it will be blank so it will not be in the varlist, so it gets ignored completely
* Declaring the est, se, df, ci, p and true variables in the dataset for the summary output
foreach summary of varlist `estimate' `se' `df' `ci' `p' `true' {

		if "`summary'"!="" local `summary'vars = "`summary'"  	
		else local `summary'vars = "N/A"  
	
	}
*/



* Set indicator so that user can determine if siman analyse has been run (e.g. for use in siman lollyplot)
local simansetuprun = 1


* Assigning characteristics
******************************
* NB Have to do this before reshape otherwise there will be no macros to transfer over to siman reshape - so
* siman reshape won't recognise any of the variables/macros.


local allthings rep dgm target method estimate se df ci p true order lci uci ifsetup insetup
local allthings `allthings' format targetformat methodformat nformat ntarget ndgm nmethod numtarget valtarget nummethod valmethod ntrue ntruevalue dgmvar numdgm dgmcreated allthings
local allthings `allthings' descriptiontype cidescriptiontype truedescriptiontype estvars sevars dfvars civars pvars truevars simansetuprun allthings
* need m1, m2 etc t1, t2 etc for siman_reshape
forvalues me=1/`nmethod' {
	local allthings `allthings'  m`me'
	}
forvalues ta=1/`ntarget' {
	local allthings `allthings'  t`ta'
	}	
foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}


* Auto reshape wide-wide format in to long-wide
****************************************************

local autoreshape = 0

* if in format 2, reshape to long-wide format
	if `nformat'==2 {
		qui siman_reshape, longwide
		local autoreshape = 1
		
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
    }
	
else

* if have long method and wide targets (i.e. 'wide-long' format), then reshape in to long-wide format
	if `nformat'==3 & `nmethod'==1 {
	
	* need the est stub to be est`target1' est`target2' etc so create a macro list.  
	if "`ntruevalue'"=="single" local optionlist `estimate' `se' `df' `ci' `p'  
	else if "`ntruevalue'"=="multiple" local optionlist `estimate' `se' `df' `ci' `p' `true' 
		
		forvalues j = 1/`ntarget' {
			foreach option in `optionlist' {
				local `option'stubreshape`t`j'' = "`option'`t`j''"
				if `j'==1 local `option'stubreshapelist ``option'stubreshape`t`j'''
				else if `j'>=2 local `option'stubreshapelist ``option'stubreshapelist' ``option'stubreshape`t`j'''
			    }
		}
* need to get into long-wide format with long target and wide method

if "`ntruevalue'"=="single" {
	qui reshape long "`optionlist'", i(`rep' `dgm' `method' `true') j(target "`valtarget'") 
	qui reshape wide "`optionlist'", i(`rep' `dgm' target `true') j(`method' "`methlist'") 	
	}
else if "`ntruevalue'"=="multiple" {
	qui reshape long "`optionlist'", i(`rep' `dgm' `method') j(target "`valtarget'") 
	qui reshape wide "`optionlist'", i(`rep' `dgm' target) j(`method' "`methlist'") 	
}


* Take out underscores at the end of target value labels if there are any.  
* Firstly, if they are string variables then encode to numeric. - removed *****************
* Need to tokenize the target variable again as might have changed in the reshape.
		
		cap confirm numeric variable target
		if _rc local targetstringindi = 1
		else local targetstringindi = 0 
				
		qui tab target
		local ntargetlabels = `r(r)'
	
		qui levels target, local(tlevels)
		tokenize `"`tlevels'"'
/*		
		capture confirm numeric variable target
		if _rc {
			capture confirm variable targetnumerical
				if _rc {
					encode target, gen(targetnumerical)
					drop target
					rename targetnumerical target
					}
				else {
				di as error "siman would like to rename a variable 'targetnumerical', but that name already exists in your dataset.  Please rename your variable targetnumerical as something else."
				exit 498
				}		
					
		}
			
        cap quietly label drop target 	*/	
		

		local labelchange = 0

		forvalues t = 1/`ntargetlabels' {
			if  substr("``t''",strlen("``t''"),1)=="_" {
					if `targetstringindi' == 0 {
						local label`t' = substr("``t''", 1, index("``t''","_") - 1)
						local tarlabel`t' = "``t''"
						local labelchange = 1
							if `t'==1 {
								local labelvalues `t' "`label`t''" 
								local tarlist `tarlabel`t''
								}
							else if `t'>1 {
								local labelvalues `labelvalues' `t' "`label`t''" 
								local tarlist `tarlist' `tarlabel`t''
								}
							else {
							local tarlabel`t' = "``t''"
							if `t'==1 local tarlist `tarlabel`t''
							else if `t'>=2 local tarlist `tarlist' `tarlabel`t''
							}	
						if `labelchange'==1 {
							label define targetlab `labelvalues'
							label values target targetlab
								}
							
						local valtarget = "`tarlist'"
						}
				else if `targetstringindi' == 1 {
					 local targetlabel = substr("``t''", 1, index("``t''","_") - 1)
					 replace target = "`targetlabel'" if target == "``t''"
				}
			}
		}
			


* final agreed order/sort
order `rep' `dgm' target
sort `rep' `dgm' target

* redefine target elements
tokenize target
forvalues j=1/`ntarget' {
	local t`j' = "``j''"
	}

* redefine characteristics
char _dta[siman_target] "target"
char _dta[siman_valtarget] `valtarget'

forvalues ta=1/`ntarget' {
	char _dta[siman_`ta'] `ta'
	}	

char _dta[siman_valmethod] `methlist'
char _dta[siman_nmethod] `nmethodlabels'
char _dta[siman_nummethod] `nmethodlabels'

}



* If method is missing and target is wide, siman setup will auto reshape this to long-long format (instead of reading in the data as it is and calling it format 3).
if (`nmethod'==0 & `ntarget'>1 ) {
		qui siman reshape, longlong
		foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
		}
}


* SUMMARY OF IMPORT
**********************
* if have auto-reshaped above, program will print siman describe table twice so use the autoreshape macro to make sure only printed once
*if `autoreshape' == 0 siman_describe
siman_describe

/*
* Note can't do the following as it doesn't work for 1st example in wide-wide data.  Variables est1_ etc are not recognised by Stata as meeting the criteria variable *_
capture confirm variable *_
				if !_rc {                        
					foreach u of var *_ { 
					local U : subinstr local u "_" "", all
					capture rename `u' `U' 
					if _rc di as txt "problem with `u'"
					} 
			}
*/


end
	
	
/*
History
Version 0.1 # Ella Marley-Zagar # 03June2020
*/





