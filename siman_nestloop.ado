*!	version 0.11.3	21nov2024	
*	version 0.11.3	21nov2024	IW Graph drawing moved to new standalone nestloop
*	version 0.11.2	25oct2024	IW improve saving() and export() options
*	version 0.11.1	21oct2024	IW implement new dgmmissingok option; make -if- work correctly
*	version 0.10.1	26jun2024	IW added saving() and export() options
*	version 0.10	23jun2024	IW Correct handling of if/in
*								PMs default to just bias or mean
*								NB reduce version # to match other programs
* version 1.8.2 17aug2023	  IW renamed descriptor graph options from frac* and legend* to dg*; new checks for wrong dgmorder(), only 1 dgm; handle missing or numeric target; remove some unwanted `if's; handle method as any type
* version 1.8.1 16aug2023	  IW changed how main graph is written, so that stagger works; correct looping over PMs and targets; general tidying up and clarifying; correct use of true
* version 1.8   14aug2023	  IW extended lines to include last scenario; reduced default PMs; range correctly allows for all methods
* version 1.7.3    01aug2023  IW added legendoff option; made name() work
*  version 1.7.2   22may2023  IW fixes
*  version 1.7.1 13mar2023    EMZ added error message
*  version 1.7   11aug2022    EMZ fixed bug to allow name() in call  
*  version 1.6   11july2022   EMZ renamed created variables to have _ infront
*  version 1.5   19may2022    EMZ added error message
*  version 1.4   31mar2022    EMZ minor updates
*  version 1.3   10jan2022    EMZ updates from IW testing.
*  version 1.2   06Dec2021    Numeric dgm variable labels to 2d.p. in graph. dgm() in nestloop to take the order specified in dgmorder() so that 
*                             siman_setup does not need to be re-run if the user would like to change the order of the dgms.
*  version 1.1   02Dec2021    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Ian White's nplot.ado

program define siman_nestloop
version 15

* siman_nestloop [performancemeasures] [if] [, *]

// PARSE
syntax [anything] [if], [DGMOrder(string) ///
	NAMe(string) SAVing(string) EXPort(string) /// twoway options for overall graph
	debug force  /// undocumented
	*]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* Check DGMs are in the dataset, if not produce an error message
if "`dgm'"=="" {
	di as error "siman nestloop requires at least 2 dgm variables."
	exit 498
}
	
* If only 1 dgm in the dataset, produce error message as nothing will be graphed
if `ndgmvars'==1 {
	di as error "siman nestloop expects at least 2 dgm variables."
	if mi("`force'") exit 498
}

* check if siman analyse has been run, if not produce an error message
if "`analyserun'"=="0" | "`analyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman analyse first before siman nestloop."
	exit 498
}

* Allow bsims and sesims for estreps and sereps
local anything = subinstr("`anything'","bsims", "estreps",.)
local anything = subinstr("`anything'","sesims","sereps", .)

* check performance measures
qui levelsof _perfmeascode, local(allpms) clean 
if "`anything'"=="" {
	if !mi("`true'") {
		local pmdefault bias
	}
	else {
		local pmdefault mean
		local missedmessage " and no true value"
	}
	di as text "{p 0 2}Performance measures not specified`missedmessage': defaulting to " as result "`pmdefault'{p_end}"
	local anything `pmdefault'
}
else if "`anything'"=="all" local anything `allpms'
local pmlist `anything'
local wrongpms : list pmlist - allpms
if !mi("`wrongpms'") {
	di as error "Performance measures not in data: `wrongpms'"
	exit 498
}	
local npms : word count `pmlist'

* parse name
if !mi(`"`name'"') {
	gettoken name nameopts : name, parse(",")
	local name = trim("`name'")
}
else {
	local name nestloop
	local nameopts , replace
}
if wordcount("`name'_something")>1 {
	di as error "Something has gone wrong with name()"
	exit 498
}

* parse optional saving
if !mi(`"`saving'"') {
	gettoken saving savingopts : saving, parse(",")
	local saving = trim("`saving'")
	if strpos(`"`saving'"',".") & !strpos(`"`saving'"',".gph") {
		di as error "Sorry, saving() must not contain a full stop"
		exit 198
	}
}

* parse optional export
if !mi(`"`export'"') {
	gettoken exporttype exportopts : export, parse(",")
	local exporttype = trim("`exporttype'")
	if mi("`saving'") {
		di as error "Please specify saving(filename) with export()"
		exit 198
	}
}

*** END OF PARSING ***

preserve

* keep performance measures only
qui drop if `rep'>0

* mark sample
marksample touse, novarlist

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
	di as error "{p 0 2}Warning: this 'if' condition cuts across dgm, target and method. It is safest to subset only on dgm, target and method.{p_end}"
}
drop `meantouse'

* do if/in
qui keep if `touse'
if _N==0 {
	di as error "{p 0 2}No observations: perhaps you used a variable other than dgm, target and method variables in the -if- condition?{p_end}"
	exit 2000
}

* If user has specified an order for dgm, check it includes all dgmvars
if !mi("`dgmorder'") {
	local ndgmorder: word count `dgmorder'
	qui tokenize `dgmorder'
	local dgmnew
	forvalues d = 1/`ndgmorder' {
		local thisdgmvar ``d''
		if  substr("`thisdgmvar'",1,1)=="-" {
			local thisdgmvar = substr("`thisdgmvar'", 2, strlen("`thisdgmvar'"))
		}
		unab thisdgmvar : `thisdgmvar'
		local dgmnew `dgmnew' `thisdgmvar'
	}
	local dgmsurplus: list dgmnew - dgm
	local dgmmissing: list dgm - dgmnew
	if !mi("`dgmsurplus'") {
		di as error "Surplus vars found in dgmorder(): `dgmsurplus'"
		exit 498
	}
	if !mi("`dgmmissing'") {
		di as error "dgm missing from dgmorder(): `dgmmissing'"
		exit 498
	}
}

* drop variables that we're not going to use
if !mi("`se'`df'`lci'`uci'`p'") qui drop `se' `df' `lci' `uci' `p' 

* Process methods
* If method is a string variable, encode it to numeric format
if `methodnature'==2 {
	rename `method' `method'0
	encode `method'0, generate(`method')
	drop `method'0
}

************************
* DRAW NESTED LOOP GRAPH
************************

* sort out target as an existing string variable
if mi("`target'") {
	tempvar target
	gen `target' = "1"
	label var `target' "target (always 1)"
	local targetcreated true
}
cap confirm string var `target'
if _rc {
	if !mi("`: value label `target''") decode `target', gen(`target'char)
	else gen `target'char = string(`target')
	drop `target'
	rename `target'char `target'
}

* summarise targets
qui levelsof `target', local(targetlist)
local ntargets = r(r)

* report panels and graphs
local ngraphs = `ntargets'*`npms'
di as text "siman nestloop will draw " as result `ngraphs' as text " graphs (" as result `ntargets' as text " targets * " as result `npms' as text " performance measures)"

* process options
if !mi("`dgmorder'") local descriptorsopt descriptors(`dgmorder') 
else local descriptorsopt descriptors(`dgm') 
if !mi("`dgmmissingok'") local options missing `options'

foreach thispm of local pmlist { // loop over PMs
	* nicer names for PMs (same as in lollyplot)
	if "`thispm'"=="estreps" local thispm2 "Est. reps"
	if "`thispm'"=="bias" local thispm2 "Bias"
	if "`thispm'"=="ciwidth" local thispm2 "CI width"
	if "`thispm'"=="cover" local thispm2 "Coverage"
	if "`thispm'"=="empse" local thispm2 "Empirical SE"
	if "`thispm'"=="mean" local thispm2 "Mean"
	if "`thispm'"=="modelse" local thispm2 "Model SE"
	if "`thispm'"=="mse" local thispm2 "MSE"
	if "`thispm'"=="pctbias" local thispm2 "% bias"
	if "`thispm'"=="power" local thispm2 "Power"
	if "`thispm'"=="relerror" local thispm2 "% error in SE"
	if "`thispm'"=="relprec" local thispm2 "% precision gain"
	if "`thispm'"=="rmse" local thispm2 "RMSE"
	if "`thispm'"=="sereps" local thispm2 "SE reps"

	* reference lines
	if "`refline'"!="norefline" {
		if "`thispm'"=="cover" local ref `cilevel'
		else if inlist("`thispm'", "bias", "relprec", "relerror") local ref 0
		else local ref
		if !mi("`ref'") local options yline(`ref',lcol(gs12)) `options'
	}

	if "`thispm'" =="mean" & !mi("`true'") local trueopt true(`true')
	else local trueopt
	
	foreach thistarget of local targetlist { // loop over targets

		local nameopt name(`name'_`thistarget'_`thispm'`nameopts')
		if !mi("`saving'") local savingopt saving(`"`saving'_`thistarget'_`thispm'"'`savingopts')

		local nestloopcmd nestloop `estimate' if `target'=="`thistarget'" & _perfmeascode=="`thispm'", `descriptorsopt' method(`method') `trueopt' `nameopt' `savingopt' `options' ytitle(`thispm2') `debug'
		
		if !mi("`debug'") di as input `"Debug: `nestloopcmd'"'
		
		`nestloopcmd'

		if !mi("`export'") {
			local graphexportcmd graph export `"`saving'_`thistarget'_`thispm'.`exporttype'"'`exportopts'
			if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
			cap noi `graphexportcmd'
			if _rc di as error "Error in export() option"
		}

	} // end of loop over targets

} // end of loop over PMs

restore

end
