*!	version 0.11.5	31mar2025	
*	version 0.11.5	31mar2025	TM added mfcolors() and mlcolors() options
*	version 0.11.4	02jan2025	IW use new char cilevel = the level at which coverage was computed
*	version 0.11.3	18dec2024	IW add reference lines for pctbias
*	version 0.11.2	25oct2024	IW new saving() and export() options
*	version 0.11.2	24oct2024	IW make default PMs work if no se
*	version 0.11.1	21oct2024	IW implement new dgmmissingok option; correct coding of non-integer dgmvars; nicer names for PMs
*	version 0.10.2	19aug2024	IW add undocumented nodgmtitle option
*	version 0.10.1	29jun2024	IW add labformat(none) option
*	version 0.10	23jun2024	IW Clean up handling of if/in
*								Drop non-varying dgmvars, unless dgmshow option used
*								Correct DGM labelling at top of graph (was wrongly alpha-sorted)
*								refpower defaults to off
*								fix errors when method isn't 1,2...
*								NB reduce version # to match other programs
* version 1.13.2  15dec2023
* version 1.13.2  15dec2023   IW 'if' is a condition not an option
* version 1.13.1  25oct2023   IW clearer error if no obs; helpful message with pause option
* version 1.13  13sep2023     IW add level() option; streamline pm variables; show PMs in order requested; use pstyle to harmonise graph; new logit option calculates CI for power & coverage on logit scale 
* version 1.12.3  22aug2023   IW bug fix with name("n")
* version 1.12.2  22aug2023   IW handles target = numeric or string 
* version 1.12.1  17aug2023   IW 
* version 1.12    14aug2023   IW changed to fast graph without graph combine; works for one or multiple dgm. NB gr() no longer valid.
* version 1.11    05may2023   IW add "DGM=" to subtitles and "method" as legend title
* version 1.10    08mar2023    
*							added warning if multiple targets overlaid
*							new moptions() changes the main plotting symbol
*							removed hard-coded imargin() -> can now be included in bygr()
*							added final graph combine using grc1leg2, if multiple PMs
*							spare options go into final graph
*							labformat() allows three formats as in simsum
*							yscale adapts to range of methods; yaxis suppressed
*							bug fix: local order renamed graphorder to avoid name clash after call to siman reshape
*							streamlined parsing of PMs and added check for invalid PMs (previously silently ignored)
*							bug fix: now doesn't assume method = 1,2,3,...
* version 1.9   23dec2022    IW added labformat() option; changed to use standard twoway graph with standard legend
*  version 1.8   05dec2022   TM added 'rows(1)' so that dgms all appear on 1 row.
*  version 1.7   14nov2022   EMZ added bygraphoptions().
*  version 1.6   05sep2022   EMZ bug fix to allow if target == "x".
*  version 1.5   14july2022  EMZ fixed bug to allow name() in call. 
*  version 1.4   11july2022  EMZ changed pm and perfeascode to _pm and _perfmeascode.
*  version 1.3   16may2022   EMZ bug fixing with graphical displays.  Added in graphoptions() for constituent graph options.
*  version 1.2   24mar2022   EMZ further updates from IW testing.
*  version 1.1   10jan2021   EMZ updates from IW testing (bug fix).
*  version 1.0   09Dec2020   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the lollyplot
* changed to incorporate 3 new perfomance measures created by simsumv2.ado

program define siman_lollyplot
version 15

syntax [anything] [if] [, ///
	LABFormat(string) COLors(string) MFColors(string) MLColors(string) MSymbol(string)  ///
	REFPower(real -1) METHLEGend(string) DGMShow DGMTItle(string) /// specific graph options
	MCLevel(cilevel) logit /// calculation options
	BYGRaphoptions(string) name(string) * /// general graph options
	pause SAVing(string) EXPort(string) /// advanced graph option
	dgmwidth(int 30) pmwidth(int 24) debug rangeadd(real 0.2) /// undocumented options
	]

foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
}

* check if siman analyse has been run, if not produce an error message
if "`analyserun'"=="0" | "`analyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman analyse first before siman lollyplot."
	exit 498
}

* Allow bsims and sesims for estreps and sereps
local anything = subinstr("`anything'","bsims", "estreps",.)
local anything = subinstr("`anything'","sesims","sereps", .)

* check performance measures
qui levelsof _perfmeascode, local(allpms) clean 
if "`anything'"=="" {
	if "`secreated'"=="1" local missedmessage ", no standard errors"
	if !mi("`true'") {
		if "`secreated'"=="1" local pmdefault bias empse
		else local pmdefault bias empse cover
	}
	else {
		if "`secreated'"=="1" local pmdefault mean empse 
		else local pmdefault mean empse relerror
		local missedmessage `missedmessage', no true values
	}
	di as text "{p 0 2}Performance measures not specified`missedmessage': defaulting to " as result "`pmdefault'{p_end}"
	local pmlist `pmdefault'
}
else if "`anything'"=="all" local pmlist `allpms'
else local pmlist `anything'
local wrongpms : list pmlist - allpms
if !mi("`wrongpms'") {
	di as error "Performance measures wrongly specified: `wrongpms'"
	exit 498
}
local npms : word count `pmlist'

* defaults
if !mi("`debug'") local digraph_cmd digraph_cmd

* parse name
if !mi(`"`name'"') {
	gettoken name nameopts : name, parse(",")
	local name = trim("`name'")
}
else {
	local name lolly
	local nameopts , replace
}
if wordcount("`name'_something")>1 {
	di as error "Something has gone wrong with name()"
	exit 498
}

if "`methlegend'"=="item" local methlegitem "`method': "
else if "`methlegend'"=="title" local methlegtitle title(`method')
else if "`methlegend'"!="" {
	di as error "Syntax: methlegend(item|title)"
	exit 198
}

* require est() and se()
if mi("`estimate'","`se'") {
	di as error "siman lollyplot requires both estimate and se"
	exit 498
}

if !inlist("`dgmtitle'","off","on","") {
	di as error "Syntax: dgmtitle(off|on|)"
	exit 198
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
if !mi(`"`export'"') {
	gettoken exporttype exportopts : export, parse(",")
	local exporttype = trim("`exporttype'")
	if mi("`saving'") {
		di as error "Please specify saving(filename) with export()"
		exit 198
	}
}

* mark sample
marksample touse, novarlist

*** END OF PARSING ***

preserve

* keep performance measures only
qui drop if `rep'>0

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

* HANDLE DGMS
if mi("`dgmshow'") {
	* drop non-varying dgmvars
	local dgmvary
	foreach dgmvar of local dgm {
		cap assert `dgmvar'==`dgmvar'[1]
		if _rc local dgmvary `dgmvary' `dgmvar'
		else di as text "Ignoring non-varying dgm variable " as result "`dgmvar'"
	}
	local dgm `dgmvary'
}
if mi("`dgm'") {
*	tempvar dgm
*	qui gen `dgm' = 1
	local ndgmvars 1
	local ndgmlevels 1
}
else {
	local ndgmvars : word count `dgm'
	tempvar dgmgroup
	egen `dgmgroup' = group(`dgm'), label `dgmmissingok'
	qui tab `dgmgroup', `dgmmissingok'
	local ndgmlevels = r(r)
	if "`dgmtitle'"=="on" | (`ndgmvars'==1 & "`dgmtitle'"=="") local dgmequals `dgm'=

	* create graph title for top
	forvalues i=1/`ndgmlevels' {
		local thisdgmname : label (`dgmgroup') `i'
		local dgmnames `"`dgmnames' `"`dgmequals'`thisdgmname'"'"'
	}
	padding `dgmnames', width(`dgmwidth')
	local titlepadded = s(titlepadded)
	else local titlepadded `"`"`titlepadded'"'"'
}

* HANDLE TARGETS
if !mi("`target'") {
	cap confirm numeric var `target'
	if _rc { // convert string to numeric
		rename `target' `target'0
		encode `target'0, gen(`target')
		drop `target'0
	}
	qui levelsof `target', local(targetlevels) clean
	local ntargetlevels = r(r)
}
else {
	local target 0
	local targetlevels 0
	local ntargetlevels 1
}

* HANDLE METHODS
* If method is a string variable, need to encode it to numeric format for graphs 
if `methodnature'==2 {
	rename `method' `method'0
	encode `method'0, generate(`method')
	drop `method'0
}

* find levels of method
qui levelsof `method', local(methodlevels)
local nmethods = r(r)
sum `method', meanonly
local methodmin = r(min)-`rangeadd'
local methodmax = r(max)+`rangeadd'

* set labels, colours and symbols for methods
local i 0
foreach j of local methodlevels {
	local ++i
	local label`i' : label (`method') `j' // defaults to `j' if no label
	local mcol`i' : word `i' of `colors'
	if mi("`mcol`i''") local mcol`i' "p`i'"
	local mfcol`i' : word `i' of `mfcolors'
	if mi("`mfcol`i''") local mfcol`i' "white"
	local mlcol`i' : word `i' of `mlcolors'
	if mi("`mlcol`i''") local mlcol`i' "p`i'"
	local msym`i' : word `i' of `msymbol'
	if mi("`msym`i''") & `i'==1 local msym`i' O
	else if mi("`msym`i''") & `i'>1 local msym`i' `msym`=`i'-1''
}
* HANDLE PERFORMANCE MEASURES
* relprec = 0 for reference method
qui replace `estimate' = 0 if _perfmeascode=="relprec" & mi(`estimate')

* generate ref variable - gives vertical dashed line when a reference value exists
tempvar ref
qui gen `ref'=.
qui replace `ref' = 0 if inlist(_perfmeascode, "bias", "pctbias", "relerror", "relprec")
qui replace `ref' = `cilevel' if _perfmeascode=="cover"
if `refpower'>=0 qui replace `ref' = `refpower' if _perfmeascode=="power"
if !mi("`true'") qui replace `ref' = `true' if _perfmeascode=="mean"

* gen thelab variable - numerical value that will label each graph
if "`labformat'"!="none" {
	forvalues i=1/3 {
		local labformat`i' : word `i' of `labformat'
		cap di 0 `labformat`i''
		if _rc {
			di as error "Error in labformat(): format `labformat`i'' not found, ignored"
			local labformat`i'
		}
	}
	if mi("`labformat1'") local labformat1 %12.4g
	if mi("`labformat2'") local labformat2 %6.1f 
	if mi("`labformat3'") local labformat3 %6.0f
	tempvar thelab
	qui gen `thelab' = string(`estimate',"`labformat1'")
	qui replace `thelab' = string(`estimate',"`labformat2'") if inlist(_perfmeascode, "pctbias", "relprec", "relerr", "power", "cover")
	qui replace `thelab' = string(`estimate',"`labformat3'") if inlist(_perfmeascode, "estreps", "sereps")
	local mlabel mlabel(`thelab')
}

* confidence intervals
tempvar lci uci l r
local alpha2 = 1/2 - `mclevel'/200
qui gen float `lci' = `estimate' + `se'*invnorm(`alpha2')
qui gen float `uci' = `estimate' + `se'*invnorm(1-`alpha2')
qui gen `l' = "("
qui gen `r' = ")"
if !mi("`logit'") { // logit transform for CIs for power and cover
	if !mi("`debug'") di as input "Debug: computing CI for power and coverage on logit scale"
	qui replace `lci' = 100 * invlogit( logit(`estimate'/100) + `se'*invnorm(`alpha2')/(`estimate'*(1-`estimate'/100))) ///
		if inlist( _perfmeascode,"power","cover")
	qui replace `uci' = 100 * invlogit( logit(`estimate'/100) + `se'*invnorm(1-`alpha2')/(`estimate'*(1-`estimate'/100))) ///
		if inlist( _perfmeascode,"power","cover")
	qui replace `lci' = `estimate' if inlist(`estimate',0,100) & inlist( _perfmeascode,"power","cover")
	qui replace `uci' = `estimate' if inlist(`estimate',0,100) & inlist( _perfmeascode,"power","cover")
}

* keep the performance measures that the user has specified, in the order specified
tempvar pmvar
qui gen `pmvar' = 0
label var `pmvar' "tempvar pmvar"
local i 0
foreach pm of local pmlist {
	local ++i
	qui replace `pmvar' = `i' if _perfmeascode == "`pm'"
	label def `pmvar' `i' "`pm'", add
}
qui drop if `pmvar' == 0
label val `pmvar' `pmvar'

* nicer names for PMs (same as in nestloop)
foreach pm of local pmlist {
	if "`pm'"=="estreps" local pmlist2 `"`pmlist2' "Est. reps""'
	if "`pm'"=="bias" local pmlist2 `"`pmlist2' "Bias""'
	if "`pm'"=="ciwidth" local pmlist2 `"`pmlist2' "CI width""'
	if "`pm'"=="cover" local pmlist2 `"`pmlist2' "Coverage""'
	if "`pm'"=="empse" local pmlist2 `"`pmlist2' "Empirical SE""'
	if "`pm'"=="mean" local pmlist2 `"`pmlist2' "Mean""'
	if "`pm'"=="modelse" local pmlist2 `"`pmlist2' "Model SE""'
	if "`pm'"=="mse" local pmlist2 `"`pmlist2' "MSE""'
	if "`pm'"=="pctbias" local pmlist2 `"`pmlist2' "% bias""'
	if "`pm'"=="power" local pmlist2 `"`pmlist2' "Power""'
	if "`pm'"=="relerror" local pmlist2 `"`pmlist2' "% error in SE""'
	if "`pm'"=="relprec" local pmlist2 `"`pmlist2' "% prec gain""'
	if "`pm'"=="rmse" local pmlist2 `"`pmlist2' "RMSE""'
	if "`pm'"=="sereps" local pmlist2 `"`pmlist2' "SE reps""'
}

* create graph title for left
padding `pmlist2', width(`pmwidth') reverse
local ytitlepadded = s(titlepadded)

* REPORT PANELS AND GRAPHS
local npanels = `ndgmlevels' * `npms'
di as text "siman lollyplot will draw " as result `ntargetlevels' as text plural(`ntargetlevels'," graph") " with " as result `npanels' as text " panels (" as result `npms' as text " PMs by " as result `ndgmlevels' as text " DGMs)"
if `ndgmlevels' > 6 {
	di as smcl as text "{p 0 2}Consider reducing the number of panel columns using 'if' condition{p_end}"
}

* CREATE GRAPH
foreach thistarget of local targetlevels {
	if `ntargetlevels'>1 {
		local thistargetname : label (`target') `thistarget'
		local iftargetcond if `target'==`thistarget'
		local andtargetcond & `target'==`thistarget'
		local note `"`target' = `thistargetname'. "'
		if !mi("`debug'") di as input `"Debug: drawing graph for `iftargetcond'"'
	}
	if !mi("`dgm'") local note `note' Graphs by `dgm'.
	local graph_cmd twoway 
	local i 1
	local graphorder
	foreach thismethod of local methodlevels {
		local graphorder `graphorder' `=4*`i'' "`methlegitem'`label`i''"
		* line from ref to main marker
		local graph_cmd `graph_cmd' (rspike `estimate' `ref' `method' ///
			if `method'==`thismethod' `andtargetcond', pstyle(p`i'line) ///
			horiz /*lcol(`mcol`i'')*/ )
		* brackets for LCL and UCL
		local graph_cmd `graph_cmd' (scatter `method' `lci' ///
			if `method'==`thismethod' `andtargetcond', pstyle(p`i') ///
			/*mlabcol(`mcol`i'')*/ msym(i) mlab(`l') mlabpos(0) )
		local graph_cmd `graph_cmd' (scatter `method' `uci' ///
			if `method'==`thismethod' `andtargetcond', pstyle(p`i') ///
			/*mlabcol(`mcol`i'')*/ msym(i) mlab(`r') mlabpos(0) )
		* main marker
		local graph_cmd `graph_cmd' (scatter `method' `estimate' ///
			if `method'==`thismethod' `andtargetcond', pstyle(p`i') mlabstyle(p`i') ///
			msym(`msym`i'') /* mcol(`mcol`i'')*/ mfcol(`mfcol`i'') `mlabel' mlabpos(12) /*mlabcol(`mcol`i'') */ )
		local ++i
	}
	if !mi("`saving'") local savingopt saving(`"`saving'_`thistargetname'"'`savingopts')
	local graph_cmd `graph_cmd' scatter `method' `ref' `iftargetcond', ///
		msym(i) c(l) col(gray) lpattern(dash)
	local graph_cmd `graph_cmd' , by(`pmvar' `dgmgroup', note(`"`note'"') col(`ndgmlevels') xrescale title(`titlepadded', size(medium) just(center)) imargin(r=5) `bygraphoptions' `dgmmissingok') 
	local graph_cmd `graph_cmd' subtitle("") ylab(none) ///
		ytitle(`"`ytitlepadded'"', size(medium)) yscale(reverse range(`methodmin' `methodmax')) ///
		legend(col(1) order(`graphorder') `methlegtitle') `savingopt'
	if `ntargetlevels'<=1 local graph_cmd `graph_cmd' name(`name'`nameopts')
	else local graph_cmd `graph_cmd' name(`name'_`thistargetname'`nameopts')
	local graph_cmd `graph_cmd' `options'

	if !mi("`debug'") di as input "Debug: graph command is: " as input `"`graph_cmd'"'
	if !mi("`pause'") {
		global F9 `graph_cmd'
		pause Press F9 to recall, optionally edit and run the graph command
	}
	`graph_cmd'

	if !mi("`export'") {
		local graphexportcmd graph export `"`saving'_`thistargetname'.`exporttype'"'`exportopts'
		if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
		cap noi `graphexportcmd'
		if _rc di as error "Error in export() option"
		exit _rc
	}

}

end




******************* START OF PROGRAM PADDING ************************

* separate out the given words to create a title of given width
program define padding, sclass
syntax anything, width(int) [reverse debug]
local ndgm 0
local spacel : _length " "
foreach dgm in `anything' {
	local ++ndgm
}
foreach dgm in `anything' {
	local dgml : _length "`dgm'"
	local nspaces = round((`width'/`ndgm'-`dgml')/`spacel'/2,1)
	if `nspaces'<0 {
		if !mi("`debug'") di as input `"Debug: error in subroutine padding: "`dgm'" too long"'
		local padding
	}
	else local padding : display _dup(`nspaces') " "
	if mi("`reverse'") local titlepadded = `"`titlepadded'`padding'`dgm'`padding'"'
	else local titlepadded = `"`padding'`dgm'`padding'`titlepadded'"'
}
sreturn local titlepadded `"`titlepadded'"'
end

******************* END OF PROGRAM PADDING ************************
