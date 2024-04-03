*! version 1.13.2  15dec2023
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
/*
Ella's notes:
**************
Not sure how to make it faster with -graph, by()- than with -graph combine-, have tried but not managed to get it to work as yet.
*/



capture program drop siman_lollyplot
program define siman_lollyplot, rclass
version 15

syntax [anything] [if] [, ///
	LABFormat(string) COLors(string) MSymbol(string)  ///
	REFPower(real 80) /// specific graph options
	Level(cilevel) logit /// calculation options
	BYGRaphoptions(string) name(string) * /// general graph options
	pause /// advanced graph option
	dgmwidth(int 30) pmwidth(int 24) debug METHLEGend(string) /// undocumented options
	]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
	}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman analyse first before siman lollyplot."
	exit 498
	}
	
* check performance measures
qui levelsof _perfmeascode, local(allpms) clean 
if "`anything'"=="" {
	if !mi("`true'") {
		local pmdefault bias empse cover
	}
	else {
		local pmdefault mean empse relerror
		local missedmessage " and no true value"
	}
	di as text "Performance measures not specified`missedmessage': defaulting to `pmdefault'"
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
	local name simanlolly
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

*** END OF PARSING ***

preserve   
	
* If data is not in long-long format, then reshape
if `nformat'!=1 {
	siman reshape, longlong nodescribe
	foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
		}
}

* keep performance measures only
qui drop if `rep'>0
qui replace `estimate' = 0 if _perfmeascode=="relprec" & mi(`estimate')

* if the user has not specified 'if' in the siman lollyplot syntax, but there is one from siman analyse then use that 'if'
if ("`if'"=="" & "`ifanalyse'"!="") local iflollyplot = `"`ifanalyse'"'
else local iflollyplot = `"`if'"'
qui tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `iflollyplot' 
qui sort `dgm' `target' `method' `touseif'
* The 'if' condition will only apply to dgm, target and method.  The 'if' condition is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' condition can not be applied to 'rep' in siman lollyplot.  If you have not specified an 'if' in siman lollyplot, but you specified one in siman setup/analyse, then that 'if' will have been applied to siman lollyplot."
	exit 498
	}

qui keep if `touseif'

if _N==0 error 2000

* take out underscores at the end of variable names if there are any
foreach u of var * {
	if substr("`u'",strlen("`u'"),1)=="_" {
		local U = substr("`u'", 1, index("`u'","_") - 1)
		if "`U'" != "" {
			capture rename `u' `U' 
			if _rc di as txt "problem with `u'"
			} 
		}
	}
	
if  substr("`estimate'",strlen("`estimate'"),1)=="_" local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
if  substr("`se'",strlen("`se'"),1)=="_" local se = substr("`se'", 1, index("`se'","_") - 1)

* generate ref variable
tempvar ref
qui gen `ref'=.
qui replace `ref' = 0 if inlist(_perfmeascode, "bias", "relerror", "relprec")
qui replace `ref' = $S_level if _perfmeascode=="cover"
qui replace `ref' = `refpower' if _perfmeascode=="power"

* gen thelab variable
local labformat1 : word 1 of `labformat'
if mi("`labformat1'") local labformat1 %12.4g
local labformat2 : word 2 of `labformat'
if mi("`labformat2'") local labformat2 %6.1f 
local labformat3 : word 3 of `labformat'
if mi("`labformat3'") local labformat3 %6.0f

qui gen thelab = string(`estimate',"`labformat1'")
qui replace thelab = string(`estimate',"`labformat2'") if inlist( _perfmeascode,"relprec","relerr","power","cover")
qui replace thelab = string(`estimate',"`labformat3'") if inlist( _perfmeascode,"bsims","sesims")

* confidence intervals
tempvar lci uci l r
local alpha2 = 1/2 - `level'/200

qui gen float `lci' = `estimate' + (`se'*invnorm(`alpha2'))
qui gen float `uci' = `estimate' + (`se'*invnorm(1-`alpha2'))

* logit transform for power and cover
if !mi("`logit'") {
	if !mi("`debug'") di as text "Computing CI for power and coverage on logit scale"
	qui replace `lci' = 100 * invlogit( logit(`estimate'/100) + `se'*invnorm(`alpha2')/(`estimate'*(1-`estimate'/100))) ///
		if inlist( _perfmeascode,"power","cover")
	qui replace `uci' = 100 * invlogit( logit(`estimate'/100) + `se'*invnorm(1-`alpha2')/(`estimate'*(1-`estimate'/100))) ///
		if inlist( _perfmeascode,"power","cover")
	qui replace `lci' = `estimate' if inlist(`estimate',0,100) & inlist( _perfmeascode,"power","cover")
	qui replace `uci' = `estimate' if inlist(`estimate',0,100) & inlist( _perfmeascode,"power","cover")
}

* confidence interval markers for the graphs
qui gen `l' = "("
qui gen `r' = ")"


* If method is a string variable, need to encode it to numeric format for graphs 
capture confirm string variable `method'
if !_rc {
	rename `method' `method'0
	encode `method'0, generate(`method')
	drop `method'0
}

* find levels of method
qui levelsof `method', local(methodlevels)
local nmethods = r(r)

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgmvars=1
}

* only keep the performance measures that the user has specified (or keep all if the user has not specified any) and only create lollyplot graphs for these.
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


if !mi("`if'") {
    local ampersand = " &"
	local if =  `"`if' `ampersand'"'
}
else local if "if"


* handle method
local graphpos = `nmethods'*3 // number of graphs that don't appear in legend
local i 0
foreach j of local methodlevels { 
	local label`j' : label (`method') `j' // defaults to `j' if no label
	local ++i
	local mcol`j' : word `i' of `colors'
	if mi("`mcol`j'") local mcol`j' "scheme p`i'"
	local msym`j' : word `i' of `msymbol'
	if mi("`msym`j'") & `j'==1 local msym`j' O
	else if mi("`msym`j'") & `j'>1 local msym`j' `msym`=`j'-1'
}
// don't use local order, which is a siman setting after reshape


* handle targets
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
	local ntargetlevels 0
}

* handle DGMs
*local ndgmvars : word count `dgm'
if `ndgmvars'>1 {
	tempvar dgmgroup 
	egen `dgmgroup' = group(`dgm'), label
	local varname novarname
}
else local dgmgroup `dgm'
qui maketitlevar `dgmgroup', `varname'
local dgmtitlevar = r(newvars)
qui levelsof `dgmtitlevar', local(dgmnames)
local ndgmlevels = r(r)
padding `dgmnames', width(`dgmwidth')
local titlepadded = s(titlepadded)
if `ndgmvars'>1 local titlepadded `"`"`dgm'"' `"`titlepadded'"'"'

* create PM graph title for left
padding `pmlist', width(`pmwidth') reverse
local ytitlepadded = s(titlepadded)

if `ntargetlevels'>1 {
	di as text "Drawing `ntargetlevels' graphs (one per target)..."
	local each "each "
}
else di as text "Drawing graph..."
if `npms'>5  di as smcl as text "{p 0 2}Warning: `each'graph will have `npms' rows of panels: consider using fewer performance measures{p_end}"
if `ndgmlevels'>5 di as smcl as text "{p 0 2}Warning: `each'graph will have `ndgmlevels' columns of panels: consider using 'if' condition as detailed in {help siman lollyplot}{p_end}"

* create graph
foreach thistarget of local targetlevels {
	if `ntargetlevels'>0 {
		local thistargetname : label (`target') `thistarget'
		local targetcond `target'==`thistarget'
		local note `target': `thistargetname'
		if !mi("`debug'") di as text `"Drawing graph for `targetcond'"'
	}
	else {
		local targetcond 1
		local note
	}
	local graph_cmd twoway 
	local i 1
	local graphorder
	foreach thismethod of local methodlevels {
		local graphorder `graphorder' `=4*`i'-3' "`methlegitem'`label`i''"
		* main marker
		local graph_cmd `graph_cmd' scatter `method' `estimate' ///
			if `method'==`thismethod' & `targetcond', pstyle(p`i') mlabstyle(p`i') ///
			mcol(`mcol`i'') msym(`msym`i'') mlab(thelab) mlabpos(12) mlabcol(`mcol`i'') ||
		* brackets for LCL and UCL
		local graph_cmd `graph_cmd' scatter `method' `lci' ///
			if `method'==`thismethod' & `targetcond', pstyle(p`i') ///
			mlabcol(`mcol`i'') msym(i) mlab(`l') mlabpos(0) ||
		local graph_cmd `graph_cmd' scatter `method' `uci' ///
			if `method'==`thismethod' & `targetcond', pstyle(p`i') ///
			mlabcol(`mcol`i'') msym(i) mlab(`r') mlabpos(0) ||
		* line from ref to main marker
		local graph_cmd `graph_cmd' rspike `estimate' `ref' `method' ///
			if `method'==`thismethod' & `targetcond', pstyle(p`i') ///
			horiz lcol(`mcol`i'') ||
		local ++i
	}
	local graph_cmd `graph_cmd' scatter `method' `ref' if `targetcond', ///
		msym(i) c(l) col(gray) lpattern(dash)
	local graph_cmd `graph_cmd' , by(`pmvar' `dgm', note(`"`note'"') col(`ndgmlevels') xrescale title(`titlepadded', size(medium) just(center)) imargin(r=5) `bygraphoptions') 
	local graph_cmd `graph_cmd' subtitle("") ylab(none) ///
		ytitle(`"`ytitlepadded'"', size(medium)) yscale(reverse range(0.8)) ///
		legend(order(`graphorder') `methlegtitle')
	if `ntargetlevels'<=1 local graph_cmd `graph_cmd' name(`name'`nameopts')
	else local graph_cmd `graph_cmd' name(`name'_`thistargetname'`nameopts')
	local graph_cmd `graph_cmd' `options'

	global F9 `graph_cmd'
	if !mi("`debug'") di as text "Graph command is: " as input `"`graph_cmd'"'
	if !mi("`pause'") pause Press F9 to recall, optionally edit and run the graph command for `targetcond'
	`graph_cmd'
}

end



	
/* 
Create a string variable with values "varname=value", for graphs
IW 5may2023
*/
program define maketitlevar, rclass
syntax varlist, [suffix(string) novarname]
if mi("`suffix'") local suffix title
foreach var of local varlist {
	qui {
		cap confirm string variable `var'
		if !_rc {
			local source "string"
			gen `var'`suffix' = `var'
		}
		else {
			cap decode `var', gen(`var'`suffix')
			if !_rc {
				local source "labelled numeric"
			}
			else if _rc {
				local source "unlabelled numeric"
				cap gen `var'`suffix' = strofreal(`var')
			}
		}
		if _rc di as error "maketitlevar: something went wrong"
		if mi("`varname'") replace `var'`suffix' = "`var': "+`var'`suffix' if !mi(`var')
	}
	di as text "Created " as result "`var'`suffix'" as text " from " as result "`source'" as text " variable " as result "`var'"
	local newvars `newvars' `var'`suffix'
}
return local newvars `newvars'
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
		if !mi("`debug'") di as text `"Error in subroutine padding: "`dgm'" too long"'
		local padding
	}
	else local padding : display _dup(`nspaces') " "
	if mi("`reverse'") local titlepadded = `"`titlepadded'`padding'`dgm'`padding'"'
	else local titlepadded = `"`padding'`dgm'`padding'`titlepadded'"'
}
sreturn local titlepadded `"`titlepadded'"'
end

******************* END OF PROGRAM PADDING ************************