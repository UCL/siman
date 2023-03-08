*! version 1.10   8mar2023    
*							added warning if multiple targets overlaid
*							new moptions() changes the main plotting symbol
*							removed hard-coded imargin() -> can now be included in bygr()
*							added final graph combine using grc1leg2, if multiple PMs
*							spare options go into final graph
*							labformat() allows three formats as in simsum
*							yscale adapts to range of methods; yaxis suppressed
*							bug fix: local order renamed graphorder to avoid name clash after call to siman reshape
*							streamlined parsing of PMs and added check for invalid PMs (previously silently ignored)
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

syntax [anything] [if] [,GRaphoptions(string) BYGRaphoptions(string) LABFormat(string) debug Moptions(string) ///
	col(passthru) noCOMBine /// combined-graph options
	name(passthru) * /// final-graph options
	]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
	}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman lollyplot."
	exit 498
	}
	
* if performance measures are not specified, run graphs for all of them
qui levelsof _perfmeascode, local(allpms) clean 
local wrongpms : list anything - allpms
if !mi("`wrongpms'") {
	di as error "Performance measures wrongly specified: `wrongpms'"
	exit 498
}
if "`anything'"=="" local pmlist `allpms'
else local pmlist `anything'
local npm : word count `pmlist'

* check grc1leg2 is loaded if needed
cap unabcmd grc1leg2
if _rc & `npm'>1 {
	di as error "siman lollyplot with multiple performance measures requires program grc1leg2 to be installed."
	di as error `"Please use {stata "search grc1leg2"} and install the program."'
	exit 498
}		

if !mi("`debug'") local dicmd dicmd

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

* if the user has not specified 'if' in the siman lollyplot syntax, but there is one from siman analyse then use that 'if'
if ("`if'"=="" & "`ifanalyse'"!="") local iflollyplot = `"`ifanalyse'"'
else local iflollyplot = `"`if'"'
qui tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `iflollyplot' 
qui sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman lollyplot.  If you have not specified an 'if' in siman lollyplot, but you specified one in siman setup/analyse, then that 'if' will have been applied to siman lollyplot."
	exit 498
	}

qui keep if `touseif'

* issue warning if multiple targets are in data
cap assert `target'==`target'[1]
if _rc di as error "Your data have multiple targets. They will be overlaid in the lollyplot." _n "You may want to run the command with an if statement."

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

capture confirm variable _pm
if _rc {
	gen _pm = - `rep'
	}
else {
	di as error "siman would like to create a variable '_pm', but that name already exists in your dataset.  Please rename your variable _pm as something else."
	exit 498
	}
		
* generate ref variable
qui gen ref=.
qui replace ref=0 if inlist(_perfmeascode, "bias", "relerror", "relprec")
qui replace ref=95 if _perfmeascode=="cover"
qui replace ref=80 if _perfmeascode=="power"

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
capture confirm variable `lci'
if _rc {
	qui gen float lci = `estimate' + (`se'*invnorm(.025))
	local lci lci
	}
capture confirm variable `uci'
if _rc {
	qui gen float uci = `estimate' + (`se'*invnorm(.975))
	local uci uci
	}

* confidence interval markers for the graphs
qui gen l = "("
qui gen r = ")"


if "`method'"!="" {

	* for value labels of method
	qui tab `method'
	local nmethodlabels = `r(r)'
		
	qui levels `method', local(levels)
	qui tokenize `"`levels'"'
		forvalues i=1/`nmethodlabels' {
				local m`i' = "``i''"
		}

}

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

* If method is a string variable, need to encode it to numeric format for graphs 
capture confirm string variable `method'
if !_rc {
	encode `method', generate(numericmethod)
	local method numericmethod // new 8mar2023: means all remaining code handles both cases
}

* for graphs
qui levelsof _pm if _perfmeascode=="empse"
qui assert `:word count `r(levels)''==1
local listfive = "`r(levels)'" 
qui levelsof _pm if _perfmeascode=="rmse"
qui cap assert `:word count `r(levels)''==1
if _rc local normse = 1
local listeight = "`r(levels)'" 

* only keep the performance measures that the user has specified (or keep all if the user has not specified any) and only create lollyplot graphs for these.
qui gen tokeep = 0
foreach pm of local pmlist {
	qui replace tokeep = 1 if _perfmeascode == "`pm'"
	}

qui drop if tokeep == 0
qui drop tokeep

qui levelsof _pm, local(tograph)

if mi(`normse') local ifplot "`listfive',`listeight'"
else local ifplot "`listfive'"

di as text "working...."

if !mi("`if'") {
    local ampersand = " &"
	local if =  `"`if' `ampersand'"'
}
else local if "if"

* handle method
forvalues j = 1/`nmethodlabels' { 
	local label : label (`method') `j' // assumes method is coded 1,2,3...
	local graphorder `graphorder' `=`nmethodlabels'*3+`j'' "`label'" // don't use order, it's a siman setting after reshape
	}

* create separate plots 
if `npm'==1 local graphoptions `graphoptions' `options' // options apply to PM-specific graph if there's only one PM
summ `method', meanonly
local methodlabmin = r(min)-0.5
local methodlabmax = r(max)+0.5
foreach pm of local tograph {
	if !inlist(`pm',`ifplot') {
		local refline
		local rescale noxrescale
		}
	else {
		local rescale xrescale
		local refline (line `method' ref if _pm==`pm', lc(gs8))
		}

	forvalues j = 1/`nmethodlabels' { 
		local scatter`j' = `"(scatter `method' `estimate' `if' `method'==`j' & _pm==`pm', mlab(thelab) mlabpos(1) mcol("scheme p`j'") mlabcol("scheme p`j'") msym(o) `moptions')"'
		if `j'==1 local scatters `scatter`j''
		else if `j'>=2 local scatters `scatters' `scatter`j''

		local spike`j' = `"(rspike `estimate' ref `method' `if' `method'==`j' & _pm==`pm', lcol("scheme p`j'") hor)"'
		if `j'==1 local spikes `spike`j''
		else if `j'>=2 local spikes `spikes' `spike`j''	

		local bound`j' = `"(scatter `method' `lci' `if' `method'==`j' & _pm==`pm', msym(i) mlab(l) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'")) (scatter `method' `uci' `if' `method'==`j' & _pm==`pm', msym(i) mlab(r) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'"))"'
		if `j'==1 local bounds `bound`j''
		else if `j'>=2 local bounds `bounds' `bound`j''	
		} 
	
	* find short and long names for this PM
	local longpmname: label (`rep') -`pm'
	tempvar row
	gen `row' = _n
	qui summ `row' if `rep' == -`pm'
	local shortpmname = _perfmeascode[`=r(min)']
	assert _perfmeascode == "`shortpmname'" if `rep' == -`pm'

	* draw the graph
	if `npm'==1 local nameopt `name'
	else local nameopt name(simanlollyplot_`shortpmname', replace) 
 	#delimit ;
	`dicmd' graph twoway
		`refline' `spikes' `bounds' `scatters' 
		,
		by(`dgm', `rescale' note("") b1tit(`longpmname') `bygraphoptions')
		ytit("")
		yla(none) 
		yscale(off range(`methodlabmin', `methodlabmax') reverse)
		xla(, grid)
		legend(order(`graphorder'))
		`nameopt'
		`graphoptions'
	;
	#delimit cr
	local graphstocombine `graphstocombine' simanlollyplot_`shortpmname'
}

if `npm'>1 { // multiple PMs 
	if mi("`combine'") { // combine multiple PMs into a single graph
		if mi("`col'") local col col(1)
		`dicmd' grc1leg2 `graphstocombine', `col' `options' `name'
	}
	else { 
		di as error `"Warning: options ignored: `col' `options' `name'"'
	}
}
else if !mi("`col'") { 
	di as error `"Warning: options ignored: `col'"'
}

end



	
