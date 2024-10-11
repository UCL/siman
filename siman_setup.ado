*!	version 0.11	09oct2024	
*	version 0.11	09oct2024	IW allow non-integer dgmvar; allow extra variables; new sep() option for wide formats; new check for true constant within dgm & target
*	version 0.10.2	14jun2024	IW wide target/method: numeric/string comes out as numeric/numeric-labelled and respects string order; remove more unwanted chars
*	version 0.10.1	11jun2024	IW allow variable abbreviations
*	version 0.10	 7may2024	IW major restructure
*	version 0.9.1	12apr2024	IW remove chars ifsetup, insetup
*	version 0.9		03apr2024	IW _methodvar not created till end, so not left on crash
*	version 0.8.8	14feb2024	IW reformat long messages
*	version 0.8.7	27nov2023	EMZ add check and error if true is not constant across methods
*	version 0.8.6	20nov2023	EMZ minor bug fix for when dgm is missing, count of variables specified in setup vs dataset mis-macth as dgm is a tempvar.
*	version 0.8.5	13nov2023	EMZ create a true variable if true is put in to the syntax as numeric e.g. true(0.5), for use by other siman programs
*	version 0.8.4	06nov2023	EMZ change so that if targets are wide and data is auto-reshaped by siman, then true becomes a long variable (does not 
*								remain wide)
*	version 0.8.3	30oct2023	EMZ: fix for format 4, bug introduced from error checks - now fixed.  Warning if est or se is missing for siman analyse 
*								later.	 Note added that target variable being created when convert from wide-wide.
*	version 0.8.2	25sep2023	EMZ: produce warning if dgm variable(s) and/or method variables contain missing values.
*	version 0.8.1	18sep2023	EMZ: bug fix for when wide-long format and auto-reshpaed, allow for method being a numeric labelled string variable.  
*								Moved true error message to later in the code to account for wide true as well.
*	version 0.8.0	04july2023	EMZ: true has to be numeric only
*	version 0.7.9	26june2023	EMZ added methodcreated characteristic
*	version 0.7.8	06june2023	EMZ bug fix: numeric target with string labels not displayed in siman describe table (displayed numbers not values)
*	version 0.7.7	29may2023	EMZ added option if missing method
*	version 0.7.6	22may2023	IW bug fix: label of encoded string dgmvar was lost
*	version 0.7.5	21march2023	EMZ bug fix: dataset variables not in siman setup
*	version 0.7.4	06march2023	EMZ added conditions to check dataset for additional variables not included in siman setup syntax
*	version 0.7.3	02march2023	EMZ bug fixes
*	version 0.7.2	30jan2023	IW handle abbreviated varnames; better error message for method(wrongvarame) or target(wrongvarname)
*	version 0.7.1	30jan2023	EMZ added in additional error msgs
*	version 0.7		23dec2022	IW require rep() to be numeric
*	version 0.6.1	20dec2023	TPM changed code so that string dgm are allowed, and are encoded to numeric.
*	version 0.6		12dec2022	Changes from TPM testing
*	version 0.5		11july2022	EMZ changes to error catching.
*	version 0.4		05may2022	EMZ changes to wide-long format import, string target variables are not now auto encoded to numeric. Changed defn of ndgm.
*	version 0.3		06jan2022	EMZ changes from IW testing
*	version 0.2		23June2020	IW changes
*	version 0.1		04June2020	Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

program define siman_setup
version 15

syntax [if] [in], ///
	Rep(varname numeric min=1 max=1) ///
	[DGM(varlist) TARget(string) METHod(string) /// structure variables
	ESTimate(name) SE(name) DF(name) LCI(name) UCI(name) P(name) /// estimation result variables
	TRUE(string) ORDer(string) ///
	CLEAR ///
	debug sep(string) /// undocumented
	] 

/*
if method() contains one entry and target() contains one entry, then the program will assume that those entries are variable names and will select data format 1 (long-long).  
If method() and target() both contain more than one entry, then the siman program will assume that those entries are variable values and will assume data format 2 (wide-wide).	 
If method() contains more than one entry and target() contains one entry only then data format 3 will be assumed (long-wide).
Please note that if method() contains one entry and target() contains more than one entry (wide-long) format then this will be auto-reshaped to long-wide (format 3).
*/

/*** START OF PARSING ***/

if !mi("`debug'") local dicmd dicmd
else local dicmd qui
if !mi("`debug'") local di di as input "Debug: " 
else local di *

* check whether setup already run
local setuprun : char _dta[siman_setuprun]
if "`setuprun'" == "1" {
	di as error "{p 0 2}siman setup has already been run on the dataset held in memory; siman setup should be run on the 'raw' estimates dataset produced by your simulation study..{p_end}"
	exit 498
}
local setuprun 0

* check for forbidden varnames in data
foreach varname in _perfmeascode _pm _dataset _scenario _true {
	capture confirm variable `varname'
	if !_rc {
		di as error "{p 0 2}siman would like to name a variable '`varname'', but that name already exists in your data. Please rename your variable `varname' as something else.{p_end}"
		exit 498
	}
}

* produce error message if no est, se, or ci contained in dataset
if mi("`estimate'") &  mi("`se'") & mi("`lci'") & mi("`uci'") {
	di as error "{p 0 2}no estimates, SEs, or confidence intervals specified. Need to specify at least one for siman to run.{p_end}"
	exit 498
}

* produce a warning message if no est and no se contained in dataset
if mi("`estimate'") &  mi("`se'") {
	di as text "{p 0 2}Warning: no estimates or SEs, siman's output will be limited{p_end}"
}

/*** END OF PARSING ***/


/*** PRESERVE AND IMPLEMENT IF/IN ***/

preserve

* respect `if' and `in' conditions
marksample touse
qui count if !`touse'
if r(N)>0 {
	if "`clear'" != "clear" {
		di as error "{p 0 2}You have specified an if/in condition, meaning that data will be deleted by siman setup. Please use the 'clear' option to confirm.{p_end}"
		exit 498
	}
	keep if `touse'
}

/*** UNDERSTAND DGM ***/

local ndgmvars: word count `dgm'
local longvars `longvars' `dgm'

* check that dgm takes numerical values; if not, encode and replace so that siman can do its things.
if !mi("`dgm'") {
	foreach var of varlist `dgm' {
		cap confirm numeric variable `var'
		if _rc {
			tempvar t`var'
			encode `var', gen(`t`var'') label(`var')
			drop `var'
			rename `t`var'' `var'
			qui compress `var'
			di as text "{p 0 2}Warning: dgm variable " as result "`var'" as text " has been converted from string to numeric. If you require its levels to be ordered differently, encode " as result "`var'" as text " as numeric before running -siman setup-.{p_end}"
		}
		qui count if missing(`var')
		cap assert r(N)==0
		if _rc di as error "{p 0 2}Warning: dgm variable " as result "`var'" as text " contains missing values. This may cause problems. Consider recoding as non-missing.{p_end}"
	}
}

* recast dgmvars as double if they have non-integer values
if !mi("`dgm'") {
	foreach var of varlist `dgm' {
		cap assert `var' == int(`var')
		if _rc & "`: type `var''" == "float" {
			di as text "{p 0 2}Warning: dgm variable " as result "`var'" as text " has non-integer values: converting from float to double " _c
			summ `var', meanonly
			local prec = ceil(log10(epsfloat()*r(max)))
			recast double `var' 
			replace `var' = round(`var', 1E`prec')
			di as text "{p_end}"
		}
	}
}


/*** UNDERSTAND TARGET ***/
local ntarget: word count `target'
cap confirm var `target'
local targetisvar = _rc==0
if `targetisvar' unab target : `target'
if `ntarget'>1 | (`ntarget'==1 & `targetisvar'==0) {
	local targetformat wide
	local valtarget `target'
	local numtarget `ntarget'
	cap numlist `"`target'"'
	if _rc local targetstring string // when reshaping target as long, create it as string
	* create a value label for use after reshape
	cap label drop targetlabel
	local i 0
	foreach thistarget of local target {
		label def targetlabel `++i' `"`thistarget'"', add
	}
}
else if `ntarget'==1 & `targetisvar'==1 {
	local targetformat long
	qui levelsof `target', local(valtargetorig) clean
	local longvars `longvars' `target'
	local numtarget = r(r)
	local targetvallab : value label `target'
	if !mi("`targetvallab'") {
		foreach val of local valtargetorig {
			local thisval : label (`target') `val'
			local valtarget `valtarget' `thisval'
		}
	}
	else local valtarget `valtargetorig'
}
else if mi("`target'") {
	local targetformat long
	local valtarget
	local numtarget 1
}
else {
	di as error "Program error: siman setup failed to parse target(`target')"
	exit 499
}

/*** UNDERSTAND METHOD ***/

local methodcreated 0
if mi("`method'") {
	di as text "{p 0 2}Warning: no method specified. siman will proceed assuming there is only one method. If this is a mistake, enter method() option in -siman setup-.{p_end}"
	local method _method
	qui gen _method = 1
	local methodcreated 1
	local methodformat none
	local methodvalues
}
local nmethod: word count `method'
cap confirm var `method'
local methodisvar = _rc==0
if `methodisvar' unab method : `method'
if `nmethod'>1 | `methodisvar'==0 {
	local methodformat wide
	local methodvalues `method'
	cap numlist `"`method'"'
	if _rc local methodstring string // when reshaping method as long, create it as string
	* create a value label for use after reshape
	cap label drop methodlabel
	local i 0
	foreach thismethod of local method {
		label def methodlabel `++i' `"`thismethod'"', add
	}
}
else if `nmethod'==1 & `methodisvar'==1 {
	local methodformat long
	qui levelsof `method', local(methodvalues) clean
	local longvars `longvars' `method'
}

* check if method contains missing values
if "`methodformat'" == "long" {
	cap assert !missing(`method')
	if _rc di as text "{p 0 2}Warning: variable `method' should not contain missing values{p_end}"
}

/*** UNDERSTAND STUBS ***/

local simanvars `rep'
local ci `lci' `uci'
if "`methodformat'"=="long" & "`targetformat'"=="long" {
	foreach simanvar in estimate se df lci uci p {
		if mi("``simanvar''") continue
		unab `simanvar' : ``simanvar''
		local simanvars `simanvars' ``simanvar''
	}
}
else local stubvars `estimate' `se' `df' `lci' `uci' `p' 

/*** CHECK WIDE VARIABLES EXIST, AND REMOVE SEPARATOR FROM VARNAME ***/

if !mi("`debug'") di as input "Debug: method format = `methodformat', target format = `targetformat'"

if "`methodformat'"=="wide" & "`targetformat'"=="wide" {
	foreach stubvar of local stubvars {
		foreach thismethod of local methodvalues {
			foreach thistarget of local valtarget {
				if "`order'"=="target" {
					local widevar `stubvar'`sep'`thistarget'`sep'`thismethod'
					local widevarnew `stubvar'`thistarget'`thismethod'
				}
				else {
					local widevar `stubvar'`sep'`thismethod'`sep'`thistarget'
					local widevarnew `stubvar'`thismethod'`thistarget'
				}
				cap confirm variable `widevar'
				if _rc {
					di as error "{p 0 2}Variable `widevar' was expected but not found{p_end}"
					exit 498
				}
				if !mi("`sep'") rename `widevar' `widevarnew'
				local widevars `widevars' `widevarnew'
			}
		}
	}
}
if "`methodformat'"=="long" & "`targetformat'"=="wide" {
	foreach stubvar of local stubvars {
		foreach thistarget of local valtarget {
			local widevar `stubvar'`sep'`thistarget'
			local widevarnew `stubvar'`thistarget'
			cap confirm variable `widevar'
			if _rc {
				di as error "{p 0 2}Variable `widevar' was expected but not found{p_end}"
				exit 498
			}
			if !mi("`sep'") rename `widevar' `widevarnew'
			local widevars `widevars' `widevarnew'
		}
	}
}
if "`methodformat'"=="wide" & "`targetformat'"=="long" {
	foreach stubvar of local stubvars {
		foreach thismethod of local methodvalues {
			local widevar `stubvar'`sep'`thismethod'
			local widevarnew `stubvar'`thismethod'
			cap confirm variable `widevar'
			if _rc {
				di as error "{p 0 2}Variable `widevar' was expected but not found{p_end}"
				exit 498
			}
			if !mi("`sep'") rename `widevar' `widevarnew'
			local widevars `widevars' `widevarnew'
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
local shouldbeid `rep' `longvars'
local createdvar _method
local shouldbeid : list shouldbeid - createdvar
*cap isid `shouldbeid'
tempvar shouldbe1
bysort `shouldbeid': gen `shouldbe1' = _n
cap assert `shouldbe1'==1
if _rc {
	di as error "{p 0 2}Multiple records per `shouldbeid'."
	if mi("`dgm'") di "Do you need to specify dgm()?"
	if mi("`target'") di "Do you need to specify target()?"
	if `methodcreated' di "Do you need to specify method()?"
	di "{p_end}"
	exit 498
}


/*** UNDERSTAND TRUE ***/

* true can be missing, it can be a long variable in the dataset with either single or multiple values, it can be a stub in a wide dataset or it can have a value entered directly in to the siman syntax
* true might not be a variable in the dataset, it might have just been entered in to the syntax as true(0.5) for example, so add true macro just incase

* find true type
cap confirm string variable `true'
if !_rc {
	di as error "true() cannot be a string variable"
	exit 498
}
if mi("`true'") local truetype blank
if mi("`truetype'") {
	cap confirm number `true'
	if !_rc {
		gen _true = `true'
		local true _true
		local truetype variable
	}
}
if mi("`truetype'") {
	cap confirm numeric variable `true'
	if !_rc local truetype variable
}
if mi("`truetype'") {
	cap confirm name `true'
	if !_rc local truetype stub
}
if mi("`truetype'") {
	di as error "true(`true') not allowed: must be true(#|var|stub)"
	exit 498
}
if "`truetype'"=="variable" unab true : `true'

* checks
if "`truetype'"=="variable" {
	cap assert !mi("`true'")
	if _rc {
		di as error "true variable `true' cannot have missing values"
		exit 498
	}
	local truevars `true'
}
if "`targetformat'"=="long" & "`truetype'"=="stub" {
	di as error "true(`true') not allowed with long target: must be true(#|var)"
	exit 498
}
* if true is a stub, check the correct variables exist
if "`targetformat'"=="wide" & "`truetype'"=="stub" {
	foreach thistarget of local valtarget {
		local truevar `true'`thistarget'
		cap confirm variable `truevar'
		if _rc {
			di as error "{p 0 2}Variable `truevar' was expected but not found{p_end}"
			exit 498
		}
		local truevars `truevars' `truevar'
	}
}

/*** END OF UNDERSTAND TRUE ***/


/*** CHECK THE RIGHT VARIABLES ARE PRESENT ***/

if !mi("`debug'") {
	di as input "Debug: list of variables:"
	di "  Long vars:  `longvars'"
	di "  Stub vars:  `stubvars'"
	di "  Siman vars: `simanvars'"
	di "  Wide vars:  `widevars'"
	di "  True vars:  `truevars'"
}

cap ds __*, not // picks out everything except tempvars
if _rc unab allvars : _all
else local allvars = r(varlist)
local simanvars `longvars' `simanvars' `widevars' `truevars'
local simanvars : list uniq simanvars // remove duplicate if true is a dgmvar
local toomany : list allvars - simanvars
local toofew : list simanvars - allvars
if !mi("`toomany'") {
	di as text "{p 0 2}Warning: siman setup found unwanted variables: " as result "`toomany'{p_end}"
	*exit 498
}
if !mi("`toofew'") {
	di as error "{p 0 2}siman setup did not find needed variables: `toofew'{p_end}"
	exit 498
}


/*** WE'RE READY TO REFORMAT ***/
cap which sencode
if _rc {
	di as error `"{p 0 2}sencode needs to be installed to run siman setup. Please use {stata "ssc install sencode"}"'
	exit 498
}

if "`truetype'"=="stub" local truestub `true'

if "`targetformat'"=="wide" & "`methodformat'"=="wide" & "`order'"=="method" { 
	`di' "reshaping wide-wide (method first) to long-wide"
	local stubvarsinterim
	foreach stubvar of local stubvars {
		foreach methodvalue of local methodvalues {
			local stubvarsinterim `stubvarsinterim' `stubvar'`methodvalue'
		}
	}
	`dicmd' reshape long `stubvarsinterim' `truestub', i(`rep' `longvars') j(target `target') `targetstring'
	local targetformat long
	local target target
	local longvars `longvars' `target'
	if "`targetstring'"=="string" sencode target, label(targetlabel) replace
	else label value target // empty label can get used
	if "`truetype'"=="stub" {
		local truetype variable
		local truestub
		local longvars `longvars' `true'
	}
}

if "`targetformat'"=="wide" & "`methodformat'"=="wide" & "`order'"=="target" { 
	`di' "reshaping wide-wide (target first) to wide-long"
	local stubvarsinterim
	foreach stubvar of local stubvars {
		foreach targetvalue of local valtarget {
			local stubvarsinterim `stubvarsinterim' `stubvar'`targetvalue'
		}
	}
	`dicmd' reshape long `stubvarsinterim', i(`rep' `longvars') j(method `method') `methodstring'
	local methodformat long
	local method method
	local longvars `longvars' `method'
	if "`methodstring'"=="string" sencode method, label(methodlabel) replace
	else label value method // empty label can get used
}

if "`targetformat'"=="long" & "`methodformat'"=="wide" { 
	`di' "reshaping long-wide to long-long"
	`dicmd' reshape long `stubvars', i(`rep' `longvars') j(method `method') `methodstring'
	local methodformat long
	local method method
	local longvars `longvars' `method'
	if "`methodstring'"=="string" sencode method, label(methodlabel) replace
	else label value method // empty label can get used
}

if "`targetformat'"=="wide" & "`methodformat'"=="long" { 
	`di' "reshaping wide-long to long-long"
	`dicmd' reshape long `stubvars' `truestub', i(`rep' `longvars') j(target `target') `targetstring'
	local targetformat long
	local target target
	local longvars `longvars' `target'
	if "`targetstring'"=="string" sencode target, label(targetlabel) replace
	else label value target // empty label can get used
	if "`truetype'"=="stub" {
		local truetype variable
		local truestub
		local longvars `longvars' `true'
	}
}


/* CHECK TRUE IS CONSTANT BY DGM AND TARGET */

if !mi("`dgm'") & !mi("`true'") {
	cap bysort `dgm' `target': assert `true'==`true'[1]
	if _rc {
		di as error "{p 0 2}True value is not constant within dgm{p_end}"
		exit 498
	}
}


/* ASSIGN CHARACTERISTICS */

* DGM
local allthings dgm ndgmvars
* Target
if !mi("`target'") { // find local targetnature
	cap confirm numeric variable `target'
	if _rc local targetnature 2
	else {
		local targetlabelname : value label `target'
		local targetnature = !mi("`targetlabelname'")
	}
}
else local targetnature .
local allthings `allthings' numtarget target targetnature valtarget
* Method
if !mi("`method'") {
	cap confirm numeric variable `method'
	if _rc local methodnature 2
	else {
		local methodlabelname : value label `method'
		local methodnature = !mi("`methodlabelname'")
	}
	if `methodnature'==1 { // numeric labelled
		qui levelsof `method', local(valmethodorig) clean
		local valmethod
		foreach val of local valmethodorig {
			local thisval : label (`method') `val'
			local valmethod `valmethod' `thisval'
		}
		local methodnature 1
		local methodvalues `valmethodorig'
	}
	else {
		qui levelsof `method', local(valmethod) clean
		local methodvalues `valmethod'
	}
	local nummethod : word count `valmethod'
}
local allthings `allthings' method methodcreated methodnature methodvalues nummethod valmethod
* Estimates
local allthings `allthings' estimate se df p rep lci uci 
* True values
local allthings `allthings' true 
* Data formats
local format long-long
local nformat 1 // keep for now, until all graphs cope without
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



program define dicmd
noi di as input `"Debug: `0'"'
`0'
end
