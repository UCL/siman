*!	version 0.11.4	08apr2025	
*	version 0.11.4	08apr2025	IW doesn't auto-call siman table
*	version 0.11.3	01apr2025	IW calls simsum with new semissingok option
*	version 0.11.2	17mar2025	IW doesn't call siman table if too many dgmvars
*	version 0.11.1	02jan2025	IW new char cilevel = the level at which coverage was computed
*	version 0.11	21oct2024		IW make analyse work correctly with if
*	version 0.9.1	14jun2024		IW remove code for nformat!=1 and nmethod!=1
* version 0.9		11jun2024		IW assume data are longlong, don't let 'if' delete data, tidy up chars
* version 0.8		8may2024		IW no longer remove any underscores
* version 0.7     3apr2024    IW make it work with missing se()
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

program define siman_analyse
version 15

syntax [anything] [if], [PERFonly REPlace noTABle /// documented options
	ref(string) Level(cilevel) * /// simsum options
	force debug pause nopreserve /// undocumented options
	]

if "`debug'"!="" di as input `"Debug: options to pass to simsum: `simsumoptions'"'
if "`debug'"=="" local qui qui

capture which simsum.ado
if _rc == 111 {
	di as error `"simsum needs to be installed to run siman analyse. Please use {stata "ssc install simsum"}"'
	exit 498
}
vercheck simsum, vermin(2.1.2) quietly message(`"{p 0 2}You can install the latest simsum using {stata "net from https://raw.githubusercontent.com/UCL/simsum/main/package/"}{p_end}"')

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

local simsumoptions level(`level') `options'
local cilevel `level' // overwrites current cilevel

if "`method'"=="" {
	di as error "The variable 'method' is missing so siman analyse can not be run. Please create a variable in your dataset called method containing the method value(s)."
	exit 498
}

if "`analyserun'"=="1" & "`replace'" == "" {
	di as error "There are already performance estimates in the dataset. If you would like to replace these, please use the 'replace' option"
	exit 498
}

local estimatesindi = (`rep'[_N]>0)
if mi("`estimate'") {
	di as error "{p 0 2}siman analyse requires estimate() to have been declared in siman setup{p_end}"
	exit 498
}

if "`analyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==1 {
	qui drop if `rep'<0
	qui drop _perfmeascode
	qui drop _dataset
}
else if "`analyserun'"=="1" & "`replace'" == "replace" & `estimatesindi'==0 {
	di as error "There are no estimates data in the data set. Please re-load data and use siman setup to import data."
	exit 498
}
	
local analyserun = 0

* check if siman setup has been run, if not produce an error message
if "`setuprun'"=="0" | "`setuprun'"=="" {
	di as error "siman setup has not been run. Please use siman setup first before siman analyse."
	exit 498
}

* true variable, to be used in reshape, if not in dgm
cap confirm variable `true'
if _rc==0 {
	local extratrue : list true - dgm
	if !mi("`extratrue'") local truevariable `true'
}

* if condition
qui tempvar touse
qui generate `touse' = 0
qui replace `touse' = 1 `if' 

* Warn the user if the 'if' condition is used other than on dgm target method
tempvar min max
egen `min' = min(`touse'), by(`dgm' `target' `method')
egen `max' = max(`touse'), by(`dgm' `target' `method')
cap assert `min'==`max'
if _rc == 9 {
	di as error "Warning: this 'if' condition will change the values of performance estimates. It is safest to subset only on dgm, target and method."  
}
drop `min' `max'

* Change estreps and sereps to bsims and sesims for simsum
local anything = subinstr("`anything'","estreps","bsims",.)
local anything = subinstr("`anything'","sereps","sesims",.)

* END OF PARSING


* START OF ANALYSIS
if "`preserve'" != "nopreserve" preserve

* put all variables in their original order in local allnames
qui unab allnames : *

* save current data, to be appended to simsum output
tempfile estimatesdata 
qui save `estimatesdata'

* get correct data
qui keep if `touse' & `rep'>0
if _N==0 {
	di as error "no observations"
	exit 2000
}

* if the data has been reshaped, method could be in string format, otherwise numeric. Need to know what format it is in for the append later
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

* create se variable if missing: it will hold the MCSE
if mi("`se'") {
	cap confirm new variable _se
	if _rc {
		di as error "{p 0 2}siman analyse wants to create a new variable _se, but it already exists{p_end}"
		exit 498
	}
	local se _se
	qui gen _se = .
	local secreated 1
}
else if mi("`secreated'") local secreated 0

* make a list of the stubs in the reshape
local optionlist `estimate' `se' 


*** PREPARE FOR SIMSUM
* save number format for method
local methodvallabel : value label `method'

* final agreed order/sort
qui order `rep' `dgm' `target' `method'
qui sort `rep' `dgm' `target' `method'

* for value labels of method
qui tab `method'
local nmethodlabels = `r(r)'
	
/* code changed 14oct2024 to work with if applied to method
qui levels `method', local(levels)
tokenize `"`levels'"'
forvalues f = 1/`nmethodlabels' { // edited 19dec2023
	if `methodstringindi' == 0 & `methodnature'!=1 local ff = "`f'"
	else local ff = "``f''"
	local methodlabel`f' `ff'
	local methodlist `methodlist' `methodlabel`f''
}
local valmethod `methodlist'
*/
qui levelsof `method', local(methodvalues)
if "`debug'"!="" di as input `"Debug: method values are `methodvalues'"'

* simsum doesn't like to parse "`estimate'" etc so define a macro for simsum for estimate and se
local estsimsum = "`estimate'"
if !`secreated' local sesimsum = "`se'"


capture confirm variable _perfmeascode
if !_rc {
	di as error "siman would like to name a variable '_perfmeascode', but that name already exists in your dataset. Please rename your variable _perfmeascode as something else."
	exit 498
}

capture confirm variable _dataset
if !_rc {
	di as error "siman would like to name a variable '_dataset', but that name already exists in your data. Please rename your variable _dataset as something else."
	exit 498
}

if !mi("`ref'") {
	local refopt ref(`ref')
}

* RUN SIMSUM (LONG DATA)
local simsumcmd simsum `estsimsum' `if', true(`true') se(`sesimsum') df(`df') lci(`lci') uci(`uci') p(`p') method(`method') id(`rep') by(`truevariable' `dgm' `target') max(20) `anything' clear mcse gen(_perfmeas) `force' `simsumoptions' `refopt' semissingok
if !mi("`pause'") {
	global F9 `simsumcmd'
	pause
}
if !mi("`debug'") noi di as input "Debug: running command: `simsumcmd'"
qui `simsumcmd'

* switch from bsims and sesims (simsum) to estreps and sereps (siman)
qui replace _perfmeascode = "estreps" if _perfmeascode == "bsims"
qui replace _perfmeascode = "sereps"  if _perfmeascode == "sesims"

* rename the newly formed "*_mcse" variables as "se*" to tie in with those currently in the dataset
foreach v in `methodvalues'  {
	cap confirm variable `estimate'`v'_mcse
	if _rc==111 continue
	else if _rc di as error "Error in siman analyse"
	if !mi("`se'") {
		qui rename `estimate'`v'_mcse `se'`v'
	}
	else qui rename `estimate'`v'_mcse se`v'
}

* take out true from option list if included for the reshape, otherwise will be included in the optionlist as well as i() and reshape won't work
local optionlistreshape `optionlist'
local exclude "`true'"
local optionlistreshape: list optionlistreshape - exclude

if `methodstringindi'==1 local stringopt string
`qui' reshape long `optionlistreshape', i(`dgm' `target' _perfmeasnum) j(`method' "`methodvalues'") `stringopt'
if `methodstringindi'==0 {
	* restore number format to method
	label value `method' `methodvallabel'
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
label define _dataset 0 "Performance" 1 "Estimates"
label values _dataset _dataset


if "`perfonly'"!="" qui drop if `rep'>0 & `rep'!=.


* restore the original order 
qui order `allnames'

* restore lost method labels in characteristics
* If format is long-long, or wide-long then 
* 'number of methods' will be the number of variable labels for method
if `methodcreated'!=1 {
	cap confirm numeric variable `method'
	if _rc local methodstringindi = 1
	else local methodstringindi = 0 

	local methodlabelsn = 0

	qui tab `method',m
	local nmethodlabels = `r(r)'
	
	* Get method label values
	cap qui labelsof `method'
	if _rc==199 {
		di as error "Please install the labelsof package using {stata ssc install labelsof}"
		exit _rc
	}

	if `"`r(labels)'"'!="" {
		local 0 = `"`r(labels)'"'

		forvalues i = 1/`nmethodlabels' {
			gettoken methodlabel`i' 0 : 0, parse(": ")
			local methlist `methlist' `methodlabel`i''
			local methodlabelsn = 1
		}
	}
	else {
		qui levels `method', local(levels)
		tokenize `"`levels'"'
		if `methodstringindi' == 0 {
			forvalues i = 1/`nmethodlabels' {
				local methodlabel`i' `i'
				local methlist `methlist' `methodlabel`i''
			}
		}
		else forvalues i = 1/`nmethodlabels' {
			local methodlabel`i' ``i''
			local methlist `methlist' `methodlabel`i''
		}
	}
	
	* For format 1, long-long: number of methods will be the number of method labels
	local valmethod = "`methlist'"
}

restore, not

* Set indicator so that user can determine if siman analyse has been run (e.g. for use in siman lollyplot)
local analyserun = 1
local analyseif `if'
local allthings `allthings' analyserun analyseif secreated cilevel
* de-duplicate
local allthings : list uniq allthings

foreach thing in `allthings' {
    char _dta[siman_`thing'] ``thing''
}

if `secreated' di as text "siman analyse has created variable _se to hold the MCSE"

di as text "siman analyse has run successfully"

/*
if "`table'"!="notable" {
	if `ndgmvars'>3 di as text "Too many dgmvars: skipping call to siman table"
	else {
		cap noi siman_table
		if _rc {
			di as text "siman analyse has run successfully, but presenting the results using siman table has failed"
			exit _rc
		}
	}
}
*/

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
version 15
syntax name, [vermin(string) nofatal file ereturn return quietly message(string)]
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
		if !mi(`"`message'"') di `"`message'"'
		exit `exitcode'
	}
	if "`match'"=="nover" {
		di as error `"`filename' has no version number found"'
		if !mi(`"`message'"') di `"`message'"'
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
