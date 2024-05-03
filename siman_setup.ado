program define siman_setup, rclass
version 15

syntax [if] [in], Rep(varname numeric) [ DGM(varlist) TARget(string) METHod(string)/* define the structure variables
	*/ ESTimate(string) SE(string) DF(string) LCI(string) UCI(string) P(string) TRUE(string) ORDer(string) CLEAR debug] 

/*
if method() contains one entry and target() contains one entry, then the program will assume that those entries are variable names and will select data format 1 (long-long).  
If method() and target() both contain more than one entry, then the siman program will assume that those entries are variable values and will assume data format 2 (wide-wide).  
If method() contains more than one entry and target() contains one entry only then data format 3 will be assumed (long-wide).
Please note that if method() contains one entry and target() contains more than one entry (wide-long) format then this will be auto-reshaped to long-wide (format 3).
*/

/*** START OF PARSING ***/
if !mi("`debug'") local dicmd `dicmd'
if !mi("`debug'") local di di
else local di *

preserve

* load setuprun indicator if present
cap local setuprun : char _dta[siman_setuprun]

if !mi("`setuprun'") {
	if `setuprun' == 1 {
		di as error "{p 0 2}siman setup has already been run on the dataset held in memory; siman setup should be run on the 'raw' estimates dataset produced by your simulation study.{p_end}"
	exit 498
	}
}

local setuprun 0

capture confirm variable _perfmeascode
if !_rc {
    di as error "{p 0 2}siman would like to name a variable '_perfmeascode', but that name already exists in your data. Please rename your variable _perfmeascode as something else.{p_end}"
    exit 498
}
		
capture confirm variable _pm
if !_rc {
    di as error "{p 0 2}siman would like to name a variable '_pm', but that name already exists in your data. Please rename your variable _pm as something else.{p_end}"
    exit 498
}		
		
capture confirm variable _dataset
if !_rc {
    di as error "{p 0 2}siman would like to name a variable '_dataset', but that name already exists in your data. Please rename your variable _dataset as something else.{p_end}"
    exit 498
}
		
capture confirm variable _scenario
if !_rc {
    di as error "{p 0 2}siman would like to name a variable '_scenario', but that name already exists in your data. Please rename your variable _scenario as something else.{p_end}"
    exit 498
}

cap confirm number `true'
if !_rc {
	capture confirm variable _true
	if !_rc {
		di as error "{p 0 2}siman would like to name a variable '_true', but that name already exists in your data. Please rename your variable _true as something else.{p_end}"
		exit 498
	}
gen _true = `true'
local true _true
}

* check that the following only have one entry: rep, est, se, df, lci, uci, p, order, true
foreach singlevar in "`rep'" "`estimate'" "`se'" "`df'" "`lci'" "`uci'" "`p'" "`order'" "`true'" {
	* have to tokenize to show which vars have been entered together by the user.  Otherwise if the user has
	* entered est(est se) se(se) then the loop will just take each of the following separately: est then se then se.
	tokenize `singlevar'
	if "`2'"!="" {
		di as error "{p 0 2}only one variable name is allowed where `singlevar' have been entered in siman setup.{p_end}"
        exit 498
    }
	local 2
}


* produce error message if no est, se, or ci contained in dataset
if mi("`estimate'") &  mi("`se'") & mi("`lci'") & mi("`uci'") {
	 di as error "{p 0 2}no estimates, SEs, or confidence intervals specified.  Need to specify at least one for siman to run.{p_end}"
    exit 498
}

* produce a warning message if no est and no se contained in dataset
if mi("`estimate'") &  mi("`se'") {
	 di as text "{p 0 2}Warning: no estimates or SEs, siman's output will be limited.{p_end}"
}

* obtain `if' and `in' conditions
tempvar touse
generate `touse' = 0
qui replace `touse' = 1 `if' `in'
if ("`if'" != "" | "`in'" != "") & "`clear'"== "clear" {
	keep if `touse' 
}
else if ("`if'" != "" | "`in'" != "") & "`clear'" != "clear" {
	di as error "{p 0 2}You have specified an if/in condition, meaning that data will be deleted by siman setup. Please use the 'clear' option to confirm.{p_end}"
	exit 498
}
* e.g. siman_setup in 1/100, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear


/*** START TO UNDERSTAND TARGET, DGM, METHOD ***/

/*** UNDERSTAND STUBS ***/

local stubvars `estimate' `se' `df' `lci' `uci' `p' 
local simanvars `rep' `order' `true' 
local ci `lci' `uci'


/*** UNDERSTAND DGM ***/

local ndgmvars: word count `dgm'

* check that dgm takes numerical values; if not, encode and replace so that siman can do its things.
if !mi("`dgm'") {
    foreach var of varlist `dgm' {
        cap confirm numeric variable `var'
        if _rc {
            tempvar t`var'
            encode `var', gen(`t`var'') label(`var')
            drop `var'
            rename `t`var'' `var'
            compress `var'
            di as text "{p 0 2}Warning: variable `var', which appears in dgm(), was stored as a string. It has been encoded as numeric so that subsequent siman commands will work. If you require a different order, encode `var' as numeric before running -siman setup-.{p_end}"
        }
		qui count if missing(`var')
		cap assert r(N)==0
		if _rc di as text "{p 0 2}Warning: variable `var' should not contain missing values.  Consider combining dgms.{p_end}"
    }
}

* check no non-integer values of dgm
if !mi("`dgm'") {
    foreach var of varlist `dgm' {
		cap assert `var' == round(`var', 0.1)
		if _rc {
			di as error "{p 0 2}Non-integer values of dgm are not permitted by siman: variable `var'.{p_end}"
			exit 498
		}
	}
}

local longvars `longvars' `dgm'


/*** UNDERSTAND TARGET ***/

local ntarget: word count `target'
cap confirm var `target'
local targetisvar = _rc==0
if `ntarget'>1 | `targetisvar'==0 {
	local targetformat wide
	local targetvalues `target'
}
else if `ntarget'==1 & `targetisvar'==1 {
	local targetformat long
	levelsof `target', local(targetvalues)
	local longvars `longvars' `target'
}
else {
	local targetformat none
	local targetvalues
}


/*** UNDERSTAND METHOD ***/

local nmethod: word count `method'
cap confirm var `method'
local methodisvar = _rc==0
local methodcreated 0
if `nmethod'>1 | `methodisvar'==0 {
	local methodformat wide
	local methodvalues `method'
}
else if `nmethod'==1 & `methodisvar'==1 {
	local methodformat long
	levelsof `method', local(methodvalues)
	local longvars `longvars ' `method'
}
else {
	di as text "{p 0 2}Warning: no method specified. siman will proceed assuming there is only one method. If this is a mistake, enter method() option in -siman setup-.{p_end}"
	tempvar method
	qui gen `method' = 1
	local methodcreated 1
	local methodformat none
	local methodvalues
}

* check if method contains missing values
if "`methodformat'" == "long" {
	cap assert !missing(`method')
	if _rc di as text "{p 0 2}Warning: variable `method' should not contain missing values.{p_end}"
}

/*** CHECK WIDE VARIABLES EXIST ***/
if "`methodformat'"=="wide" & "`targetformat'"=="wide" {
	foreach stubvar of local stubvars {
		foreach thismethod of local methodvalues {
			foreach thistarget of local targetvalues {
				if "`order'"=="target" local confirmvar `stubvar'`thistarget'`thismethod'
				else local confirmvar `stubvar'`thismethod'`thistarget'
				cap confirm variable `confirmvar'
				if _rc di as error "{p 0 2}Variable `confirmvar' was expected but not found{p_end}"
			}
		}
	}
}
if "`methodformat'"=="long" & "`targetformat'"=="wide" {
	foreach stubvar of local stubvars {
		foreach thistarget of local targetvalues {
			local confirmvar `stubvar'`thistarget'
			cap confirm variable `confirmvar'
			if _rc di as error "{p 0 2}Variable `confirmvar' was expected but not found{p_end}"
		}
	}
}
if "`methodformat'"=="wide" & "`targetformat'"=="long" {
	foreach stubvar of local stubvars {
		foreach thismethod of local methodvalues {
			local confirmvar `stubvar'`thismethod'
			cap confirm variable `confirmvar'
			if _rc di as error "{p 0 2}Variable `confirmvar' was expected but not found{p_end}"
		}
	}
}


/*** MOVE ON ***/

* If in wide-wide format and order is missing, exit with an error:
if "`targetformat'"=="wide" & "`methodformat'"=="wide" & "`order'"=="" {
	di as error "{p 0 2}Input data is in wide-wide format but order() has not been specified.  Please specify order(method) or order(target).{p_end}"
	exit 498
}

* check that there are not multiple records per rep
cap isid `rep' `dgm' `longvars'
if _rc {
	di as error "{p 0 2}Multiple records per `rep' `dgm' `longvars'.  Do you need to specify dgm/target/method?{p_end}"
	exit 498
}


/*** UNDERSTAND TRUE - TO REVISIT ***/

* obtain true elements: determine if there is only one true value or if it varies accross targets etc.  Could be in either long or wide format.
cap confirm variable `true'
local ntrue = 0
if !_rc {
	qui tab `true'
	local ntrue = r(r)
}

* if true is a stub assume it has different values across the target/method combinations
local ntruestub 0

if `nmethod'!=1 & `ntarget'!=1 {
	forvalues i=1/`nmethod' {
		forvalues j=1/`ntarget' {
			cap confirm variable `true'`t`j''`m`i''
			if !_rc {
				local ntrue = 2
				local ntruestub = 1
				capture confirm numeric variable `true'`t`j''`m`i'' 
					if _rc {
						di as error "{p 0 2}true must be a numeric variable/value in siman.{p_end}"
						exit 498
					}
			}
	   }
	}
}

if `ntarget'!=1 & `nmethod'!=1 {	
	forvalues j=1/`ntarget' {
		forvalues i=1/`nmethod' {
			cap confirm variable `true'`m`i''`t`j''
			if !_rc {
			local ntrue = 2
			local ntruestub = 1
			capture confirm numeric variable `true'`m`i''`t`j''
					if _rc {
						di as error "{p 0 2}true must be a numeric variable/value in siman.{p_end}"
						exit 498
					}
			}
		}
	}
}
	
if `nmethod'!=1 {	
	forvalues i=1/`nmethod' {
		cap confirm variable `true'`m`i''
		if !_rc {
			local ntrue = 2
			local ntruestub = 1
			capture confirm numeric variable `true'`m`i''
					if _rc {
						di as error "{p 0 2}true must be a numeric variable/value in siman.{p_end}"
						exit 498
					}
		}
	}
}

if `ntarget'!=1 {	
	forvalues j=1/`ntarget' {
		cap confirm variable `true'`t`j''
		if !_rc {
			local ntrue = 2
			local ntruestub = 1
			capture confirm numeric variable `true'`t`j''
					if _rc {
						di as error "{p 0 2}true must be a numeric variable/value in siman.{p_end}"
						exit 498
					}
		}
	}
}

* check that true is a numeric variable/value
if !mi("`true'") & "`ntrue'" != "2" {
	capture confirm number `true' 
		if _rc {
			capture confirm numeric variable `true' 
				if _rc {
					di as error "{p 0 2}true must be a numeric variable/value in siman.{p_end}"
					exit 498
				}
	
		}
}

if `ntrue'<=1 local ntruevalue = "single"
else if `ntrue'>1 & `ntrue'!=. local ntruevalue = "multiple"

* true can be missing, it can be a long variable in the dataset with either single or multiple values, it can be a stub in a wide dataset or it can have a value entered directly in to the siman syntax
* true might not be a variable in the dataset, it might have just been entered in to the syntax as true(0.5) for example, so add true macro just incase
* if true is in long format (can not do this if true is in wide format e.g. true1beta)
cap confirm variable `true'
if !_rc local truelong = 1
else local truelong = 0


/*** END OF UNDERSTAND TRUE ***/


/*** WE'RE READY TO REFORMAT ***/

if "`targetformat'"=="wide" & "`methodformat'"=="wide" & "`order'"=="method" { 
	`di' as text "reshaping wide-wide-method first to long-wide"
	local stubvarsinterim
	foreach stubvar of local stubvars {
		foreach methodvalue of local methodvalues {
			local stubvarsinterim `stubvarsinterim' `stubvar'`methodvalue'
		}
	}
	`dicmd' qui reshape long `stubvarsinterim', i(`rep' `longvars') j(target) string
	local targetformat long
	local target target
	local longvars `longvars' `target'
}

if "`targetformat'"=="wide" & "`methodformat'"=="wide" & "`order'"=="target" { 
	`di' as text "reshaping wide-wide-target first to wide-long - ouch"
	reshape long 
}

if "`targetformat'"=="long" & "`methodformat'"=="wide" { 
	`di' as text "reshaping long-wide to long-long"
	`dicmd' qui reshape long `stubvars', i(`rep' `longvars') j(method) string
	local methodformat long
	local method method
	local longvars `longvars' `method'
}

if "`targetformat'"=="wide" & "`methodformat'"=="long" { 
	`di' as text "reshaping wide-long to long-long"
	`dicmd' qui reshape long `stubvars', i(`rep' `longvars') j(target) string
	local targetformat long
	local target _targetvar
	local longvars `longvars' `target'
}


* produce error message if any other variables contained in the dataset, excluding tempvars
* do this later

* Assigning characteristics
******************************

* DGM
local dgmcreated 0
local allthings dgm dgmcreated ndgmvars
* Target
if !mi("`target'") {
	qui levelsof `target', local(valtarget) clean
	local numtarget : word count `valtarget'
}
local allthings `allthings' ntarget numtarget target targetlabels valtarget
* Method
if !mi("`method'") {
	cap confirm numeric variable `method'
	if _rc local methodlabels 2
	else local methodlabels = mi("`: value label `method''")
	qui levelsof `method', local(valmethod) clean
	local nummethod : word count `valmethod'
}
local nmethod 1
local allthings `allthings' method methodcreated methodlabels methodvalues nmethod nummethod valmethod
* Estimates
local descriptiontype variable
local allthings `allthings' descriptiontype estimate se df p rep lci uci 
* True values
local truedescriptiontype variable
local allthings `allthings' ntruestub ntruevalue true truedescriptiontype
* Data formats
local format long-long
local nformat 1
local allthings `allthings' format nformat targetformat methodformat 
* Utilities
local setuprun 1
local allthings `allthings' setuprun allthings
* Store them all
foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}

siman_describe
restore, not
end


/*
* Identifying elements for summary output table   
************************************************

* If format is long-long or long-wide 
* then 'number of targets' will be the number of variable labels for target 
* long-wide: nformat = 3 and target in long format i.e. ntarget =1
cap confirm numeric variable `target'
if _rc local targetstringindi = 1
else local targetstringindi = 0 

local targetlabels = 0

if `nformat'==1 | (`nformat'==3 & `ntarget'==1) { 
	if `ntarget'!=0 {
		qui tab `target', m
		local ntargetlabels = `r(r)'
						
		* Get target label values
		cap qui labelsof `target'
		cap qui ret list

			if `"`r(labels)'"'!="" {
			local 0 = `"`r(labels)'"'

			forvalues i = 1/`ntargetlabels' {  
				gettoken `target'label`i' 0 : 0, parse(": ")
				local tarlist `tarlist' ``target'label`i''
				local targetlabels = 1
				}
			}
	else {

	qui levels `target', local(levels)
	tokenize `"`levels'"'
		if `targetstringindi' == 0 {		
			forvalues i = 1/`ntargetlabels' {  
				local `target'label`i' `i'
				local tarlist `tarlist' ``target'label`i''
				}
		}
		else forvalues i = 1/`ntargetlabels' {  
				local `target'label`i' ``i''
				local tarlist `tarlist' ``target'label`i''
				}
	 }	
  }
}

* If format is long-long, or wide-long then 
* 'number of methods' will be the number of variable labels for method
* wide-long: nformat = 3 and method in long format i.e. nmethod =1
cap confirm numeric variable `method'
if _rc local methodstringindi = 1
else local methodstringindi = 0 

local methodlabels = 0

if `nformat'==1 | (`nformat'==3 & `nmethod'==1)  { 
	if `nmethod'!=0 {
		qui tab `method',m
		local nmethodlabels = `r(r)'
		
				
		* Get method label values
		cap qui labelsof `method'
		cap qui ret list

			if `"`r(labels)'"'!="" {
			local 0 = `"`r(labels)'"'

			forvalues i = 1/`nmethodlabels' {  
				gettoken `method'label`i' 0 : 0, parse(": ")
				local methlist `methlist' ``method'label`i''
				local methodlabels = 1
				}
			}
	else {

	qui levels `method', local(levels)
	tokenize `"`levels'"'
		if `methodstringindi' == 0 {		
			forvalues i = 1/`nmethodlabels' {  
				local `method'label`i' `i'
				local methlist `methlist' ``method'label`i''
				}
		}
		else forvalues i = 1/`nmethodlabels' {  
				local `method'label`i' ``i''
				local methlist `methlist' ``method'label`i''
				}
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
}	
	
* The below are the same for all formats:

* when target or method is missing
if `ntarget'==0 {
    local numtarget = "N/A"
    local valtarget = "N/A"
}

if `nmethod'==0 {
    local nummethod = "N/A"
    local valmethod = "N/A"
}

if `dgmcreated' ==1 {
	local dgm 
}


* define whether stub or variable
if "`ntruevalue'"=="single" local truedescriptiontype = "variable"
else if "`ntruevalue'"=="multiple" local truedescriptiontype = "stub"
* true will always be a variable if in long-long format and long-wide format
if `nformat'==1 local truedescriptiontype = "variable"
if `nformat'==3 & `ntarget'==1 local truedescriptiontype = "variable"

/*
NB. Can't loop as if variable is not present, then it will be blank so it will not be in the varlist, so it gets ignored completely
* Declaring the est, se, df, ci, p and true variables in the dataset for the summary output
foreach summary of varlist `estimate' `se' `df' `lci' `uci' `p' `true' {

		if "`summary'"!="" local `summary'vars = "`summary'"  	
		else local `summary'vars = "N/A"  
	
	}
*/

* if method is numeric labelled string, get numerical labels for reshape
if "`methodlabels'" == "1" {
     qui labelsof `method'
	local methodvalues `r(values)'
}
if `methodcreated' == 1 {
	rename `method' _methodvar
	local method _methodvar
}

* Assigning characteristics
******************************
* NB Have to do this before reshape otherwise there will be no macros to transfer over to siman reshape - so
* siman reshape won't recognise any of the variables/macros.

local allthings allthings rep dgm target method estimate se df p true order lci uci 
local allthings `allthings' format targetformat methodformat nformat ntarget ndgmvars nmethod numtarget valtarget nummethod valmethod ntruevalue dgmcreated targetlabels methodcreated methodlabels methodvalues ntruestub
local allthings `allthings' descriptiontype truedescriptiontype setuprun
* need m1, m2 etc t1, t2 etc for siman_reshape
forvalues me = 1/`nmethod' {
	local allthings `allthings' m`me'
}
forvalues ta = 1/`ntarget' {
	local allthings `allthings' t`ta'
}	
foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}

* Auto reshape wide-wide format in to long-wide
****************************************************

local autoreshape 0

* if in format 2, reshape to long-wide format
if `nformat'==2 {
	di as txt "note: converting to long-wide format, creating variable target"
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
* if have long method and wide targets (i.e. 'wide-long' format), then reshape in to long-wide format
else if `nformat'==3 & `nmethod'==1 {
	
	di as txt "note: converting to long-wide format, creating variable target"
	
    * need the est stub to be est`target1' est`target2' etc so create a macro list.  
   if "`ntruevalue'"=="single" local optionlist `estimate' `se' `df' `lci' `uci' `p'  
  else if "`ntruevalue'"=="multiple" local optionlist `estimate' `se' `df' `lci' `uci' `p' `true' 
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
    }
    else if "`ntruevalue'"=="multiple" {
        qui reshape long "`optionlist'", i(`rep' `dgm' `method') j(target "`valtarget'") 
*       if `methodstringindi' == 0 & "`methodlabels'" != "1" qui reshape wide "`optionlist'", i(`rep' `dgm' target) j(`method' "`methlist'") 	
*		else if `methodstringindi' == 1 qui reshape wide "`optionlist'", i(`rep' `dgm' target) j(`method' "`methlist'") string
*		else if `methodstringindi' == 0 & "`methodlabels'" == "1" qui reshape wide "`optionlist'", i(`rep' `dgm' target) j(`method' "`methodvalues'") 	
    }

	 local optionlist: list optionlist - true
	 if `methodstringindi' == 0 & "`methodlabels'" != "1" qui reshape wide "`optionlist'", i(`rep' `dgm' target `true') j(`method' "`methlist'")     	   
	 else if `methodstringindi' == 1 qui reshape wide "`optionlist'", i(`rep' `dgm' target `true') j(`method' "`methlist'") string
     else if `methodstringindi' == 0 & "`methodlabels'" == "1" qui reshape wide "`optionlist'", i(`rep' `dgm' target `true') j(`method' "`methodvalues'") 

	 local truedescriptiontype = "variable"
	 local ntruestub 0
	 char _dta[siman_truedescriptiontype] `truedescriptiontype'
     char _dta[siman_ntruestub] `ntruestub'
	 
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
            di as error "{p 0 2}siman would like to rename a variable 'targetnumerical', but that name already exists in your dataset.  Please rename your variable targetnumerical as something else.{p_end}"
            exit 498
            }		
                
    }
        
    cap quietly label drop target 	*/	


    local labelchange 0

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
                qui replace target = "`targetlabel'" if target == "``t''"
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
	di as txt "note: converting to long-long format, creating variable target"
    qui siman_reshape, longlong
    foreach thing in `_dta[siman_allthings]' {
        local `thing' : char _dta[siman_`thing']
    }
}



* SUMMARY OF IMPORT
**********************
* if have auto-reshaped above, program will print siman describe table twice so use the autoreshape macro to make sure only printed once
*if `autoreshape' == 0 siman_describe
siman_describe

* Set indicator so that user can determine if siman setup has been run already
local setuprun 1 
char _dta[siman_setuprun] `setuprun'

* Drop char order
char _dta[siman_order]

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

*/
