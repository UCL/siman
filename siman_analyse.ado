*! version 0.6.15 14mar2024
* version 0.6.15 14mar2024    IW respect lci, uci and p from setup
* version 0.6.14 12mar2024    IW make ref() option work in longwide; add undocumented pause option 
* version 0.6.13 07mar2024    IW allow any simsum options
* version 0.6.12 14feb2024    IW pass df to simsum (previously ignored in computing PMs)
* version 0.6.11 19dec2023    IW bug fix in method values for reshape
* version 0.6.10  13nov2023   EMZ bug fix: labelling mcse vars when method a numeric labelled string variable - use values not labels
* version 0.6.9   07nov2023   EMZ bug fix: restoring lost method labels issue for when method has been created by siman (i.e. _methodvar = 1)
* version 0.6.8   30oct2023   EMZ: retained underscores instead of removing them to tidy up wide variable names
* version 0.6.7   25oct2023   IW made clearer output when analyse runs but table fails
* version 0.6.6   18sep2023   EMZ: updated valmethod to take method values, for use in siman reshape
* version 0.6.5   12sep2023   EMZ: restored missing characteristics for method labels after simsum run
* version 0.6.4   22aug2023   IW: fix bug causing error if truevar also a dgmvar; new force option to pass to simsum
* version 0.6.3   16aug2023   IW: if true is a variable and not a dgmvar, it is stored in the PM data
* version 0.6.2   21jul2023   IW: use simsum not simsumv2
* version 0.6.1   05may2023   IW: remove unused performancemeasures option
* version 0.6     23dec2022   IW: preserves value label for method
* version 0.5  11july2022     EMZ changing created variable names to start with _, and adding error catching messages
* version 0.4  16may2022      EMZ minor bug fix with renaming of mcse's
* version 0.3  28feb2022      Changes from IW testing
* version 0.2  23june2020     IW change: added in notable option
* version 0.1  08june2020     Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
* Uses Ian's new simsumv2

capture program drop siman_analyse
program define siman_analyse, rclass
version 15

syntax [anything] [if], [PERFONLY replace /// documented options
	ref(string) * /// simsum options
	noTABle force debug pause /// undocumented options
	]
local simsumoptions `options'
if "`debug'"!="" di as input `"Options to pass to simsum: `options'"'
if "`debug'"=="" local qui qui

capture which simsum.ado
if _rc == 111 {
	di as error "simsum needs to be installed to run siman analyse. Please use {stata: ssc install simsum}"  
	exit 498
	}
vercheck simsum, vermin(2.1.2) quietly

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
	* otherwise pf graphs won't run later
	exit 498
	}
	
local estimatesindi = (`rep'[_N]>0)
	
if "`simananalyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==1 {
	qui drop if `rep'<0
	qui drop _perfmeascode
	qui drop _dataset
	}
else if "`simananalyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==0 {
	di as error "There are no estimates data in the data set.  Please re-load data and use siman setup to import data."
	exit 498
	}
	
local simananalyserun = 0

* check if siman setup has been run, if not produce an error message
if "`setuprun'"=="0" | "`setuprun'"=="" {
	di as error "siman setup has not been run.  Please use siman setup first before siman analyse."
	exit 498
	}

* true variable, to be used in reshape, if not in dgm
cap confirm variable `true'
if _rc==0 {
	local extratrue : list true - dgm
	if !mi("`extratrue'") local truevariable `true'
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
	if `methodcreated' == 0 local method method
	else local method `method'
	}
qui sort `dgm' `target' `method' `touse'
* The 'if' condition will only apply to dgm, target and method.  The 'if' condition is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touse'==`touse'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' condition can not be applied to 'rep' in siman analyse."  
	exit 498
	}
restore
qui keep if `touse'


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

	* save number format for method
	local methodvallabel : value label `method'

	* final agreed order/sort
	qui order `rep' `dgm' `target' `method'
	qui sort `rep' `dgm' `target' `method'

		
	* for value labels of method
	qui tab `method'
	local nmethodlabels = `r(r)'
		
	qui levels `method', local(levels)
	tokenize `"`levels'"'
	forvalues f = 1/`nmethodlabels' { // edited 19dec2023
		if `methodstringindi' == 0 & `methodlabels'!=1 local ff = "`f'"
		else local ff = "``f''"
		if  substr("`ff'",strlen("`ff'"),1)=="_" local ff = substr("`ff'", 1, index("`ff'","_") - 1)
		local methodlabel`f' `ff'
		local methodlist `methodlist' `methodlabel`f''
		}
	local valmethod `methodlist'

		
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

	if !mi("`ref'") {
		local refopt ref(`ref')
	}
	
	* RUN SIMSUM (LONG DATA)
	local simsumcmd simsum `estsimsum' `if', true(`true') se(`sesimsum') df(`df') lci(`lci') uci(`uci') p(`p') method(`method') id(`rep') by(`truevariable' `dgm' `target') max(20) `anything' clear mcse gen(_perfmeas) `force' `simsumoptions' `refopt'
	if !mi("`pause'") {
		global F9 `simsumcmd'
		pause
	}
	if !mi("`debug'") noi di as input "Running: `simsumcmd'"
	qui `simsumcmd'


	* rename the newly formed "*_mcse" variables as "se*" to tie in with those currently in the dataset
	if `methodlabels' == 0 local methodloop `valmethod'
	else local methodloop `methodvalues' 
	foreach v in `methodloop'  {
		if !mi("`se'") {
			if  substr(" `estimate'`v'",strlen(" `estimate'`v'"),1)=="_" qui rename `estimate'`v'mcse `se'`v'
			else qui rename `estimate'`v'_mcse `se'`v'
		}
		else if  substr(" `estimate'`v'",strlen(" `estimate'`v'"),1)=="_" qui rename `estimate'`v'mcse se`v'
		else qui rename `estimate'`v'_mcse se`v'
	}
	

	* take out true from option list if included for the reshape, otherwise will be included in the optionlist as well as i() and reshape won't work
	local optionlistreshape `optionlist'
	local exclude "`true'"
	local optionlistreshape: list optionlistreshape - exclude
	
	if !mi("`metlist'") local methodreshape `metlist'
	else local methodreshape `valmethod'

	if `methodstringindi'==1  {
		`qui' reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`methodreshape'") string
		}
	else if `methodstringindi'==0 & `methodlabels' == 0 {
		`qui' reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`methodreshape'")
		* restore number format to method
		label value `method' `methodvallabel'
		}
	else if `methodstringindi'==0 & `methodlabels' == 1 {
		`qui' reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`methodvalues'")
		* restore number format to method
		label value `method' `methodvallabel'
		}

}

else if `nformat'==3 {

* final agreed order/sort
qui order `rep' `dgm' `target'
qui sort `rep' `dgm' `target'


* if method is numeric labelled string, get numerical labels for reshape
if `methodstringindi' == 0 & "`methodlabels'" == "1" local methodloop `methodvalues'
else local methodloop `valmethod'

foreach v in `methodloop' {
	if  substr("`v'",strlen("`v'"),1)=="_" local v = substr("`v'", 1, index("`v'","_") - 1)
	foreach stat in estimate se df lci uci p {
		if mi("``stat''") continue 
		local `stat'list`v' ``stat''`v' 
		local `stat'list ``stat'list' ``stat'list`v''
	}
}

* add in true if applicable
*if "`ntruevalue'"=="multiple" local estimatelist `estimatelist' `true' 

if !mi("`ref'") {
	cap confirm var `estimate'`ref'
	if _rc di as error "siman analyse has failed to parse the ref(`ref') option so has ignored it"
	else local refopt ref(`estimate'`ref')
}

* RUN SIMSUM (WIDE DATA)
local simsumcmd simsum `estimatelist' `if', true(`true') se(`selist') df(`dflist') lci(`lcilist') uci(`ucilist') p(`plist') id(`rep') by(`truevariable' `dgm' `target') max(20) `anything' clear mcse gen(_perfmeas) `force' `simsumoptions' `refopt'
if !mi("`pause'") {
	global F9 `simsumcmd'
	pause
}
if !mi("`debug'") noi di as input "Running: `simsumcmd'"
qui `simsumcmd'

foreach v in `methodloop' {
			if  substr("`v'",strlen("`v'"),1)=="_" local v = substr("`v'", 1, index("`v'","_") - 1)
			if `estchange' == 1 {
				* can't use `estimate' on it's own as if the variable was est_1, `estimate' is taken to be est_, the _ is removed above so then
				* `estimate' becomes est.  Then you are asking to rename est1_mcse when actually the variable is called est_1_mcse
				qui rename `estimate'_`v'_mcse `se'`v'
				}
				else {
				if  substr(" `estimate'`v'",strlen(" `estimate'`v'"),1)=="_" qui rename `estimate'`v'mcse `se'`v'
				else qui rename `estimate'`v'_mcse `se'`v'
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

* restore lost method labels in characteristics
* If format is long-long, or wide-long then 
* 'number of methods' will be the number of variable labels for method
* wide-long: nformat = 3 and method in long format i.e. nmethod =1
if `methodcreated'!=1 {
	cap confirm numeric variable `method'
	if _rc local methodstringindi = 1
	else local methodstringindi = 0 

	local methodlabelsn = 0

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
					local methodlabelsn = 1
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
	else local methlist `valmethod'
	
	if `nformat'==1 {
		* For format 1, long-long: number of methods will be the number of method labels
		local valmethod = "`methlist'"
	}
	else if `nformat'==2 {
		* number of methods will be the number of methods that the user specified
		local valmethod = "`method'"
	}
	else if `nformat'==3 {
		* For format 3, long-wide format
		* will be in long-wide with long targets and wide methods after auto-reshape
		if `nmethod'==1 {
			* the number of methods will be the number of method labels
			local valmethod = "`methlist'"
		}
		else if `nmethod'>=1 & `nmethod'!=. {
			*  number of methods will be the number of methods that the user specified
			* need valmethod to be method values for use in reshape command
	*		local valmethod = "`method'"
			local valmethod = "`methlist'"
		}
	}
}


* Set indicator so that user can determine if siman analyse has been run (e.g. for use in siman lollyplot)
local simananalyserun = 1
local allthings `allthings' simananalyserun ifanalyse estchange sechange 

foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}

di as text "siman analyse has run successfully"

if "`table'"!="notable" {
	cap noi siman_table
	if _rc {
		di as text "siman analyse has run successfully, but presenting the results using siman table has failed"
		exit _rc
	}
}

end



	
************************** START OF PROGRAM VERCHECK ******************************************	

program define vercheck, sclass
/* 
9aug2023 new syntax
	new options ereturn and return search e/r(progname_version) instead of/as well as file comments
	example: vercheck simsum, vermin(2.0.4) return
26jul2023 improved output if ok
17sep2020
	better error if called with no args
	now finds version stated like v2.6.1 - specifically, any word starting v|ver|version then a number
4sep2019 - ignores comma after version number, better error handling
8may2015 - bug fix - handles missing values
11mar2015 - bug fix - didn't search beyond first line
*/
version 9.2
syntax name, [vermin(string) nofatal file ereturn return quietly]
// Parsing
local progname `namelist'
if mi("`progname'") {
	di as error "Syntax: vercheck progname [vermin [opt]]
	exit 498
}
* default to checking file
if mi("`file'`ereturn'`return'") local file file
* If nofatal is set & an error is found, program exits without an error code.
if missing("`fatal'") local exitcode 498
if !mi("`quietly'") local ifnoi *


// read version (3 ways) and store in local vernum
// read version from r()
if !mi("`return'") {
	cap `progname'
	if "`r(`progname'_version)'"!="" local vernum = r(`progname'_version)
	local filename Program `progname'
}
// read version from e()
if !mi("`ereturn'") & mi("`vernum'") {
	cap `progname'
	if "`e(`progname'_version)'"!="" local vernum = e(`progname'_version)
	local filename Program `progname'
}
// read version from top of file 
if !mi("`file'") & mi("`vernum'") {
	tempname fh
	qui findfile `progname'.ado // exits with error 601 if not found
	local filename `r(fn)'
	file open `fh' using `"`filename'"', read
	local stop 0
	while `stop'==0 {
		file read `fh' line
		if r(eof) continue, break
		cap { 
			// suppress error message if line contains expression like `=`a'' when a is empty
			// cap { tokenize } achieves this, cap tokenize doesn't!
			tokenize `"`line'"', parse(", ")
		}
		if `"`1'"' != `"*!"' continue
		while "`1'" != "" {
			mac shift
			if inlist("`1'","version","ver","v") {
				local vernum `2'
				local stop 1
				continue, break
			}
			if regexm("`1'","^v[0-9]") {
				local vernum = substr("`1'",2,.)
				local stop 1
				continue, break
			}
			if regexm("`1'","^ver[0-9]") {
				local vernum = substr("`1'",4,.)
				local stop 1
				continue, break
			}
			if regexm("`1'","^version[0-9]") {
				local vernum = substr("`1'",8,.)
				local stop 1
				continue, break
			}
		}
		if "`vernum'"!="" continue, break
	}
}

sreturn local version `vernum'

if "`vermin'" != "" {
	if "`vernum'"=="" local match nover
	else {
		local vermin2 = subinstr("`vermin'","."," ",.)
		local vernum2 = subinstr("`vernum'","."," ",.)
		local words = max(wordcount("`vermin2'"),wordcount("`vernum2'"))
		local match equal
		forvalues i=1/`words' {
			local wordmin = real(word("`vermin2'",`i'))
			local wordnum = real(word("`vernum2'",`i'))
			if `wordmin' == `wordnum' continue
			if `wordmin' > `wordnum' local match old
			if `wordmin' < `wordnum' local match new
			if mi(`wordmin') local match new
			else if mi(`wordnum') local match old
			continue, break
		}
	}
	if "`match'"=="old" {
		di as error `"`filename' is version `vernum' which is older than target `vermin'"'
		exit `exitcode'
	}
	if "`match'"=="nover" {
		di as error `"`filename' has no version number found"'
		exit `exitcode'
	}
	if "`match'"=="new" {
		`ifnoi' di as text `"`filename' is version "' as result `"`vernum'"' as text `" which is newer than target"'
	}
	if "`match'"=="equal" {
		`ifnoi' di as text `"`filename' is version "' as result `"`vernum'"' as text `" which is same as target"'
	}
}
else {
	`ifnoi' if "`vernum'"!="" di as text `"`filename' is version `vernum'"'
	`ifnoi' else di as text `"`filename' has no version number found"'
}

end

************************** END OF PROGRAM VERCHECK ******************************************	
