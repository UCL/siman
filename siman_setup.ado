*!    version 0.9  3apr2024    
*    version 0.9  3apr2024       IW _methodvar not created till end, so not left on crash
*    version 0.8.8  14feb2024    IW reformat long messages
*    version 0.8.7  27nov2023    EMZ add check and error if true is not constant across methods
*    version 0.8.6  20nov2023    EMZ minor bug fix for when dgm is missing, count of variables specified in setup vs dataset mis-macth as dgm is a tempvar.
*    version 0.8.5  13nov2023    EMZ create a true variable if true is put in to the syntax as numeric e.g. true(0.5), for use by other siman programs
*    version 0.8.4  06nov2023    EMZ change so that if targets are wide and data is auto-reshaped by siman, then true becomes a long variable (does not 
*                                remain wide)
*    version 0.8.3  30oct2023    EMZ: fix for format 4, bug introduced from error checks - now fixed.  Warning if est or se is missing for siman analyse 
*                                later.  Note added that target variable being created when convert from wide-wide.
*    version 0.8.2  25sep2023    EMZ: produce warning if dgm variable(s) and/or method variables contain missing values.
*    version 0.8.1  18sep2023    EMZ: bug fix for when wide-long format and auto-reshpaed, allow for method being a numeric labelled string variable.  *                                Moved true error message to later in the code to account for wide true as well.
*    version 0.8.0  04july2023   EMZ: true has to be numeric only
*    version 0.7.9  26june2023   EMZ added methodcreated characteristic
*    version 0.7.8  06june2023	 EMZ bug fix: numeric target with string labels not displayed in siman describe table (displayed numbers not values)
*    version 0.7.7  29may2023	 EMZ added option if missing method
*    version 0.7.6  22may2023	 IW bug fix: label of encoded string dgmvar was lost
*    version 0.7.5  21march2023  EMZ bug fix: dataset variables not in siman setup
*    version 0.7.4  06march2023  EMZ added conditions to check dataset for additional variables not included in siman setup syntax
*    version 0.7.3  02march2023  EMZ bug fixes
*    version 0.7.2  30jan2023    IW handle abbreviated varnames; better error message for method(wrongvarame) or target(wrongvarname)
*    version 0.7.1  30jan2023    EMZ added in additional error msgs
*    version 0.7    23dec2022    IW require rep() to be numeric
*    version 0.6.1  20dec2023    TPM changed code so that string dgm are allowed, and are encoded to numeric.
*    version 0.6    12dec2022    Changes from TPM testing
*    version 0.5    11july2022   EMZ changes to error catching.
*    version 0.4    05may2022    EMZ changes to wide-long format import, string target variables are not now auto encoded to numeric. Changed defn of ndgm.
*    version 0.3    06jan2022    EMZ changes from IW testing
*    version 0.2    23June2020   IW changes
*    version 0.1    04June2020   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

* For history, see end of file

capture program drop siman_setup
program define siman_setup, rclass
version 15

syntax [if] [in], Rep(varname numeric) [ DGM(varlist) TARget(string) METHod(string)/* define the structure variables
	*/ ESTimate(string) SE(string) DF(string) LCI(string) UCI(string) P(string) TRUE(string) ORDer(string) CLEAR] 

/*
if method() contains one entry and target() contains one entry, then the program will assume that those entries are variable names and will select data format 1 (long-long).  
If method() and target() both contain more than one entry, then the siman program will assume that those entries are variable values and will assume data format 2 (wide-wide).  
If method() contains more than one entry and target() contains one entry only then data format 3 will be assumed (long-wide).
Please note that if method() contains one entry and target() contains more than one entry (wide-long) format then this will be auto-reshaped to long-wide (format 3).
*/

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

if mi("`estimate'") | mi("`se'") {
	di as text "{p 0 2}Warning: siman analyse will require est() and se() to be specified in set-up.{p_end}"
}

* produce a warning message if no method contained in dataset, and create a constant
local methodcreated = 0
if mi("`method'") {
	 di as text "{p 0 2}Warning: no method specified. siman will proceed assuming there is only one method. If this is a mistake, enter method() option in -siman setup-.{p_end}"
	 tempvar method
	 qui gen `method' = 1
	 local methodcreated = 1
}

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

* if there is no dgm variable listed in the dataset (i.e. there is only 1 dgm so it is not included in the data), then create a temporary variable for dgm * with values of 1.
local dgmcreated 0
cap confirm variable `dgm'
if _rc {
	tempvar dgm
	generate `dgm' = 1
	local dgm `dgm'
    local dgmcreated 1
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

* store setup if and in for use in other siman progs
local ifsetup = `"`if'"'
local insetup = `"`in'"'


* obtain target elements
cap confirm existence `target'
	if !_rc {
		local ntarget: word count `target'
		if `ntarget'>1 {
		    tokenize `target'
			forvalues j=1/`ntarget' {
				local t`j' "``j''"
				local tlist `tlist' `t`j''
			}
		}
	}
else local ntarget = 0


* obtain method elements
cap confirm existence `method'
	if !_rc {
		local nmethod: word count `method'
		if `nmethod'>1 {
			tokenize `method'
			forvalues i = 1/`nmethod' {
				local m`i' "``i''"
				local mlist `mlist' `m`i''
			}
		}
	}
else local nmethod 0

* check if method contains missing values
if `nmethod' == 1 {
	qui count if missing(`method')
	cap assert r(N)==0
	if _rc di as text "{p 0 2}Warning: variable `method' should not contain missing values.{p_end}"
}


* if the user has accidentally put the value of target or method instead of the variable name in long format, issue an error message
if `ntarget'==1 {
    cap confirm variable `target'
    if _rc {
		cap confirm new variable `target'
        if _rc==0 di as error "{p 0 2}target(`target'): variable `target' not found.{p_end}"
        else di as error "{p 0 2}Please either put the target variable name in siman_setup target() for long format, or the target values for wide format.{p_end}"
        exit 498
    }
	unab target : `target'
}

if `nmethod'==1 {
    cap confirm variable `method'
    if _rc {
		cap confirm new variable `method'
		if _rc==0 di as error "{p 0 2}method(`method'): variable `method' not found.{p_end}"
        else di as error "{p 0 2}Please either put the method variable name in siman_setup method() for long format, or the method values for wide format.{p_end}"
        exit 498
    }
	unab method : `method'
}
		
* need either a method or target otherwise siman setup will not be able to determine the data format (longlong/widewide/longwide are based on target/method combinations).
if "`target'"=="" & "`method'"=="" {
	di as error "{p 0 2}Need either target or method variable/values specified otherwise siman setup can not determine the data format.{p_end}"
	exit 498
}


* check that there are no issues with data e.g. if have estcc estmi cc mi all in dataset, need to make sure that the user has entered siman setup syntax correctly
forvalues i=1/`nmethod' {
	cap confirm variable `m`i''
	if !_rc {
		if "`estimate'"!="" {
			cap confirm variable `estimate'`m`i''
			if !_rc {
                di as error "{p 0 2}Both variables `m`i'' and `estimate'`m`i'' are contained in the dataset. Please take care when specifying the method and estimate variables in the siman setup syntax.{p_end}"
				exit 498
                /// TPM Is this really an `I'll proceed but think there might be a problem' warning, or should it error out?
				/// EMZ: needs to error out to use unab later
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
        di as error "{p 0 2}Multiple records per rep.  Please specify method/dgm values.{p_end}"
        exit 498
	}
}
else if "`target'"!="" & `ntarget'==1 & "`method'"=="" & "`dgm'"!="" {
    sort `rep' `dgm' `target'
    capture by `rep' `dgm' `target': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify method values.{p_end}"
        exit 498
	}
}
else if "`target'"!="" & `ntarget'>1 & "`method'"=="" & "`dgm'"=="" {
    sort `rep' 
    capture by `rep': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify method/dgm values.{p_end}"
        exit 498
	}
}
else if "`target'"!="" & `ntarget'>1 & "`method'"=="" & "`dgm'"!="" {
    sort `rep' `dgm' 
    capture by `rep' `dgm': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify method values.{p_end}"
        exit 498
	}
}
else if "`method'"!="" & `nmethod'==1 & "`target'"=="" & "`dgm'"=="" {
    sort `rep' `method'
    capture by `rep' `method': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify target/dgm values.{p_end}"
        exit 498
	}
}
else if "`method'"!="" & `nmethod'==1 & "`target'"=="" & "`dgm'"!="" {
    sort `rep' `dgm' `method'
    capture by `rep' `dgm' `method': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify target values.{p_end}"
        exit 498
	}
}
else if "`method'"!="" & `nmethod'>1 & "`target'"=="" & "`dgm'"=="" {
    sort `rep' 
    capture by `rep': assert `rep'!=`rep'[_n-1] if _n>1
	if _rc {
        di as error "{p 0 2}Multiple records per rep.  Please specify target/dgm values.{p_end}"
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
        di as error "{p 0 2}Multiple records per rep.  Please specify target values.{p_end}"
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
        local ndgmvars = `ndescdgm'
        tokenize `dgm'
        cap confirm numeric variable `1'
*	    if !_rc {
*		    qui tab `1'
*		    local ndgmvars = r(r)
*		    di "`ndgmvars'"
*	    }
*	    else {
        if _rc {
            di as error "{p 0 2}If there is more than 1 dgm, the main numerical dgm needs to be placed first in the siman setup dgm varlist.  Please re-run siman_setup accordingly.{p_end}"
            exit 498
        }
    }
    else if `ndescdgm'==1 {
        qui tab `dgm'
        local ndgmvars = r(r)
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

* If there is one entry in the method() syntax and one entry in the target() syntax then they are variable names and the data is format 1, long-long.
* If target is missing but method() has one entry, or vice-versa, or both target and method are missing then the data is in long-long format also.
if (`nmethod'==1 & `ntarget'==1 ) | (`nmethod'==1 & `ntarget'==0 ) | (`nmethod'==0 & `ntarget'==1 ) | (`nmethod'==0 & `ntarget'==0 ) {
	local nformat= 1 
	local format = "format 1: long-long"
	local targetformat = "long"
	local methodformat = "long"
}
else if `nmethod'>1 & `ntarget'>1 & `nmethod'!=0 & `ntarget'!=0 {
	local nformat= 2
	local format = "format 2: wide-wide"
	local targetformat = "wide"
	local methodformat = "wide"
}
* please note that 'wide-long' formats are given nformat=3 as they are auto-reshaped to long-wide format later before siman setup exits

else if (`nmethod'>1 & `ntarget'==1 & `nmethod'!=0) | (`ntarget'>1 & `nmethod'==1 & `ntarget'!=0) | (`nmethod'>1 & `ntarget'==0) | (`ntarget'>1 & `nmethod'==0) {

	local nformat= 3
	local format = "format 3: long-wide"
	local targetformat = "long"
	local methodformat = "wide"
}
* Note can only do the below for format 1 as if method was missing from format 3 then data would just in effect be long-long format.  If method
* and target were missing from format 2 than the data would just in effect be long-long format.
else if `nmethod'==0 & `ntarget'<=1 | `ntarget'==0  & `nmethod'<=1 {
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
        local compare = `maxrep' * `ndgmvars' * `count`target''  /* previously used countdgm but didn't work for multiple dgms with descriptors.  Same for other 2 lines below */
    }
    else if `ntarget'==0 & `nmethod'!=0 {
        local compare = `maxrep' * `ndgmvars' * `count`method'' 
    }
    else if `nmethod'==0 & `ntarget'==0 {
        local compare = `maxrep' * `ndgmvars' 
    }
	if `compare' == `maxnumdata' {
        local nformat= 1
        local format = "format 1: long-long"
	}
	
}


* If in wide-wide format and order is missing, exit with an error:
if `nformat'==2 & "`order'"=="" {
	di as error "{p 0 2}Input data is in wide-wide format but order() has not been specified.  Please specify order: either order(method) or order(target) in the syntax.{p_end}"
	exit 498
}


* Specify confidence limits
local ci `lci' `uci'

* produce error message if any other variables contained in the dataset, excluding tempvars
qui ds __*, not
* true can be missing, it can be a long variable in the dataset with either single or multiple values, it can be a stub in a wide dataset or it can have a value entered directly in to the siman syntax
* true might not be a variable in the dataset, it might have just been entered in to the syntax as true(0.5) for example, so add true macro just incase
* if true is in long format (can not do this if true is in wide format e.g. true1beta)
cap confirm variable `true'
if !_rc local truelong = 1
else local truelong = 0
if "`ntruevalue'"=="single" local datasetvarswithtrue `r(varlist)' `true'
else local datasetvarswithtrue `r(varlist)'
* if true was already in the dataset, only include `true' once
local datasetvars: list uniq datasetvarswithtrue
* for long-long format
	if `nformat' == 1 {
		* not including true as it can be a number e.g. true(0)
		* also do not include dgm if it has been created
		local simanvars0 `rep' `target' `estimate' `se' `df' `lci' `uci' `p' 
		if `dgmcreated' == 0 local simanvars0 `simanvars0' `dgm'
		if `methodcreated' == 0 local simanvars0 `simanvars0' `method'
		unab simanvars : `simanvars0'
		local simanvarswithtrue0 `simanvars' `true'
		* for cases where true is in dgm() and true(), only include once
		local simanvarswithtrue: list uniq simanvarswithtrue0
		local truevariables `true'
	}
	* wide-wide format, order = method
	else if `nformat' == 2 & "`order'" == "method"{
		foreach i in `mlist' {
			foreach j in `tlist' {
				if !mi("`estimate'") local estimatevariables `estimatevariables' `estimate'`i'`j'
				if !mi("`se'") local sevariables `sevariables' `se'`i'`j'
				if !mi("`df'") local dfvariables `dfvariables' `df'`i'`j'
				if !mi("`lci'") local lcivariables `lcivariables' `lci'`i'`j'
				if !mi("`uci'") local ucivariables `ucivariables' `uci'`i'`j'
				if !mi("`p'") local pvariables `pvariables' `p'`i'`j'
				if "`ntruevalue'"=="single" | `truelong' == 1 local truevariables `true'
				else local truevariables `truevariables' `true'`i'`j'
			}
		}
	if `dgmcreated'!=1 local simanvarswithtrue `rep' `dgm' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	else local simanvarswithtrue `rep' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	}
	* wide-wide format, order = target
	else if `nformat' == 2 & "`order'" == "target"{
		foreach j in `tlist'  {
			 foreach i in `mlist' {
				if !mi("`estimate'") local estimatevariables `estimatevariables' `estimate'`j'`i'
				if !mi("`se'") local sevariables `sevariables' `se'`j'`i'
				if !mi("`df'") local dfvariables `dfvariables' `df'`j'`i'
				if !mi("`lci'") local lcivariables `lcivariables' `lci'`j'`i'
				if !mi("`uci'") local ucivariables `ucivariables' `uci'`j'`i'
				if !mi("`p'") local pvariables `pvariables' `p'`j'`i'
				if "`ntruevalue'"=="single" | `truelong' == 1 local truevariables `true'
				else local truevariables `truevariables' `true'`j'`i'
			}
		}
	if `dgmcreated'!=1 local simanvarswithtrue `rep' `dgm' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	else local simanvarswithtrue `rep' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	}
	* long-wide format
	else if `nformat' == 3 & `nmethod'!=1 & `nmethod'!=0 {
		foreach i in `mlist' {
				if !mi("`estimate'") local estimatevariables `estimatevariables' `estimate'`i'
				if !mi("`se'") local sevariables `sevariables' `se'`i'
				if !mi("`df'") local dfvariables `dfvariables' `df'`i'
				if !mi("`lci'") local lcivariables `lcivariables' `lci'`i'
				if !mi("`uci'") local ucivariables `ucivariables' `uci'`i'
				if !mi("`p'") local pvariables `pvariables' `p'`i'
				if "`ntruevalue'"=="single" | `truelong' == 1 local truevariables `true'
				else local truevariables `truevariables' `true'`i'
		}
	if `dgmcreated'!=1 local simanvarswithtruenotuniq `rep' `dgm' `target' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	else local simanvarswithtruenotuniq `rep' `target' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
	local simanvarswithtrue: list uniq simanvarswithtruenotuniq
	}
	* long method, wide target
	else if (`nmethod'==1 | `nmethod' == 0) & `ntarget'> 1 {
		foreach j in `tlist' {
			if !mi("`estimate'") local estimatevariables `estimatevariables' `estimate'`j'
			if !mi("`se'") local sevariables `sevariables' `se'`j'
			if !mi("`df'") local dfvariables `dfvariables' `df'`j'
			if !mi("`lci'") local lcivariables `lcivariables' `lci'`j'
			if !mi("`uci'") local ucivariables `ucivariables' `uci'`j'
			if !mi("`p'") local pvariables `pvariables' `p'`j'
			if "`ntruevalue'"=="single" | `truelong' == 1 local truevariables `true'
			else local truevariables `truevariables' `true'`j'
		}
		local simanvarswithtrue `rep' `estimatevariables' `sevariables' `dfvariables' `lcivariables' `ucivariables' `pvariables' `truevariables'
		if `dgmcreated'!=1 local simanvarswithtrue `simanvarswithtrue' `dgm'
		if `methodcreated'!=1 local simanvarswithtrue `simanvarswithtrue' `method'
	}
	* test for equivalence
	local testothervars: list simanvarswithtrue === datasetvars
	if `testothervars' == 0 {
		local countdatasetvars: word count `datasetvars'
		local countsimanvarswithtrue: word count `simanvarswithtrue'

		if `countdatasetvars' > `countsimanvarswithtrue' {
			local wrongvars : list datasetvars - simanvarswithtrue
			di as error "{p 0 2}Additional variables found in dataset other than those specified in siman setup.  Please remove extra variables from data set and re-run siman.  Note that if your data is in wide-wide format and your variable names contain underscores, these will need to be included in the setup syntax.  See {help siman_setup:siman setup} for further details.{p_end}"
			di as error "{p 0 2}Unwanted variables are: `wrongvars'.{p_end}"
			exit 498
		}
		else {
			local wrongvars : list simanvarswithtrue - datasetvars 
			di as error "{p 0 2}There are variables specified in siman setup that are not in your dataset.  Note that if your data is in wide-wide format and your variable names contain underscores, these will need to be included in the setup syntax.  See {help siman_setup:siman setup} for further details.{p_end}"
			di as error "{p 0 2}Unfound variables are: `wrongvars'.{p_end}"
			exit 498
		}
	}
	
/*
IW code for error capture: does not work for wide targets
* check that true is constant accross methods.  Can only do this when method is a variable (otherwise `method' will be label values and can not sort)
if !mi("`truevariables'") & (`nformat' == 1 | `nformat' == 3 & (`nmethod'==1 | `nmethod' == 0)) & `methodcreated' == 0 {
	foreach truevar of varlist `truevariables' {
		cap bysort `dgm' `target' : assert `truevar' == `truevar'[1]
		if _rc {
			di as error "{p 0 2}`true' needs to be constant across methods.  Please make `true' constant across methods and then run -siman setup- again.{p_end}"
			exit 498
		}
	}
}
*/

	
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

local allthings allthings rep dgm target method estimate se df p true order lci uci ifsetup insetup
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

