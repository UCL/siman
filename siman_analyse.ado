*! version 0.5  11july2022
*  version 0.5  11july2022   EMZ changing created variable names to start with _, and adding error catching messages
*  version 0.4  16may2022    EMZ minor bug fix with renaming of mcse's
*  version 0.3  28feb2022    Changes from IW testing
*  version 0.2  23june2020   IW change: added in notable option
*  version 0.1  08june2020   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
* Uses Ian's new simsumv2

capture program drop siman_analyse
program define siman_analyse, rclass
version 15

syntax [anything] [if], [performancemeasures PERFONLY replace noTABle]

capture which simsumv2.ado
if _rc == 111 {
	di as error "simsumv2.ado needs to be installed to run siman_analyse."  
	exit 498
	}

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`method'"=="" {
	di as error "The variable 'method' is missing so siman analyse can not be run.  Please create a variable in your dataset called method containing the method value(s)."
	exit 498
	}

if "`simananalyserun'"=="1" & "`replace'" == "" {
	di as error "There are already performance measures in the dataset.  If you would like to replace these, please use the 'replace' option"
	exit 498
	}


if mi("`estimate'") | mi("`se'") {
	di as error "siman analyse requires est() and se() to be specified in set-up"
	exit 498
	}
	
local estimatesindi = 0
cap confirm string variable `rep'
	if !_rc {
	qui destring `rep', gen(temprep)
	if temprep>0 local estimatesindi = 1 
	qui drop temprep
	}
	else if _rc { 
	preserve
	if `rep'[_N]>0 local estimatesindi = 1
	restore
	}

	
if "`simananalyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==1 {
	qui drop if `rep'<0
	qui drop _perfmeascode
	qui drop _dataset
	}
else if "`simananalyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==0 {
	di as error "There are no estimates data in the data set.  Please re-load data and use siman_setup to import data."
	exit 498
	}
	
local simananalyserun = 0

* check if siman setup has been run, if not produce an error message
if "`simansetuprun'"=="0" | "`simansetuprun'"=="" {
	di as error "siman setup has not been run.  Please use siman_setup first before siman_analyse."
	exit 498
	}
	
	
* if the user has not specified 'if' in the siman analyse syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifanalyse = `"`ifsetup'"'
else local ifanalyse = `"`if'"'
qui tempvar touse
qui generate `touse' = 0
qui replace `touse' = 1 `ifanalyse' 
preserve
if `nformat'!=1 {
	qui siman_reshape, longlong
	local method method
	}
qui sort `dgm' `target' `method' `touse'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touse'==`touse'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman_analyse."  
	exit 498
	}
restore
qui keep if `touse'


* if rep is in string format, set to float
capture confirm string variable `rep'
if !_rc {
	qui encode(`rep'), gen(rep_num)
	qui drop `rep'
	qui rename rep_num `rep'
	qui format `rep' %43.0g
	}
	

* put all variables in their original order in local allnames
qui unab allnames : *


*if "`perfonly'"=="" {
	tempfile estimatesdata 
	qui save `estimatesdata'
*	}

qui drop if  `rep'<0


* if the data has been reshaped, method could be in string format, otherwise numeric.  Need to know what format it is in for the append later
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

* make a list of the optional elements that have been entered by the user, that would be stubs in the reshape
*if "`ntruevalue'"=="single" local optionlist `estimate' `se' 
*else if "`ntruevalue'"=="multiple" local optionlist `estimate' `se' `true' 
local optionlist `estimate' `se' 


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

local estchange = 0
if  substr("`estimate'",strlen("`estimate'"),1)=="_" {
	local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
	local estchange = 1
	}
local sechange = 0
if  substr("`se'",strlen("`se'"),1)=="_" {
	local se = substr("`se'", 1, index("`se'","_") - 1) 
	local sechange = 1
	}

local optionlist `estimate' `se' 

if `nformat'==1 {


* final agreed order/sort
qui order `rep' `dgm' `target' `method'
qui sort `rep' `dgm' `target' `method'

	
* for value labels of method
	qui tab `method'
	local nmethodlabels = `r(r)'
		
	qui levels `method', local(levels)
	tokenize `"`levels'"'
	forvalues f = 1/`nmethodlabels' {
		if  substr("``f''",strlen("``f''"),1)=="_" local f = substr("``f''", 1, index("``f''","_") - 1)
		local methodlabel`f' = "``f''"
		if `f'==1 local methodlist `methodlabel`f''
		else if `f'>=2 local methodlist `methodlist' `methodlabel`f''
		}
	local valmethod = "`methodlist'"

		
* simsum doesn't like to parse "`estimate'" etc so define a macro for simsum for estimate and se
local estsimsum = "`estimate'"
local sesimsum = "`se'"


capture confirm variable _perfmeascode
		if !_rc {
			di as error "siman would like to name a variable '_perfmeascode', but that name already exists in your dataset.  Please rename your variable _perfmeascode as something else."
		exit 498
		}
		
capture confirm variable _dataset
		if !_rc {
			di as error "siman would like to name a variable '_dataset', but that name already exists in your data.  Please rename your variable _dataset as something else."
		exit 498
		}


qui simsumv2 `estsimsum' `if', true(`true') se(`sesimsum') method(`method') id(`rep') by(`dgm' `target') max(20) `anything' clear mcse


* rename the newly formed "*_mcse" variables as "se*" to tie in with those currently in the dataset
	foreach v in `methodlist' {
			if !mi("`se'") {
				qui rename `estimate'`v'_mcse `se'`v'
			}
				else qui rename `estimate'`v'_mcse se`v'
			}

* take out true from option list if included for the reshape, otherwise will be included in the optionlist as well as i() and reshape won't work
local optionlistreshape `optionlist'
local exclude "`true'"
local optionlistreshape: list optionlistreshape - exclude

if `methodstringindi'==1 {
	qui reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`valmethod'") string
	}
	else {
	qui reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`valmethod'")
	}
}

else


if `nformat'==3 {



* final agreed order/sort
qui order `rep' `dgm' `target'
qui sort `rep' `dgm' `target'

foreach v in `valmethod' {
				if  substr("`v'",strlen("`v'"),1)=="_" local v = substr("`v'", 1, index("`v'","_") - 1)
				local estlist`v' `estvars'`v' 
				local estlist `estlist' `estlist`v''
				local selist`v' `sevars'`v' 
				local selist `selist' `selist`v''
				}

* add in true if applicable
*if "`ntruevalue'"=="multiple" local estlist `estlist' `true' 


qui simsumv2 `estlist' `if', true(`true') se(`selist') id(`rep') by(`dgm' `target') max(20) `anything' clear mcse



foreach v in `valmethod' {
			if  substr("`v'",strlen("`v'"),1)=="_" local v = substr("`v'", 1, index("`v'","_") - 1)
			if `estchange' == 1 {
				* can't use `estimate' on it's own as if the variable was est_1, `estimate' is taken to be est_, the _ is removed above so then
				* `estimate' becomes est.  Then you are asking to rename est1_mcse when actually the variable is called est_1_mcse
				qui rename `estimate'_`v'_mcse `se'`v'
				}
				else {
				qui rename `estimate'`v'_mcse `se'`v'
				}
			if `sechange' == 1 qui rename `se'`v' `se'_`v'
			}

}

* labelling performance measures
qui gen indi = -_perfmeasnum
qui levelsof _perfmeasnum, local(lablevels)
foreach lablevel of local lablevels {
	local labvalue : label (_perfmeasnum) `lablevel'
	label define indilab -`lablevel' "`labvalue'", modify
}
label values indi indilab
qui drop _perfmeasnum


if `methodstringindi'==1 {
	capture quietly tostring `method', replace
	}

qui append using `estimatesdata'
qui replace indi = `rep' if `rep'>0 & `rep'!=.
qui drop `rep'

qui rename indi `rep'

* generate a byte variable ‘dataset’ with labels 0 “Estimates” 1 “Performance”
qui gen byte _dataset = `rep'>0 if `rep'!=.
label define estimatesperformancelab 0 "Performance" 1 "Estimates"
label values _dataset estimatesperformancelab


if "`perfonly'"!="" qui drop if `rep'>0 & `rep'!=.


* restore the original order 
qui order `allnames'

* Set indicator so that user can determine if siman analyse has been run (e.g. for use in siman lollyplot)
local simananalyserun = 1
local allthings `allthings' simananalyserun allthings ifanalyse estchange sechange

foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}

* IW change:
* output table to show that siman analyse has run
if "`table'"!="notable" siman_table
else di "siman analyse has run"

end



	
	


