*! version 1.9   23dec2022   IW added labformat() option; changed to use standard twoway graph with standard legend
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

syntax [anything] [if] [,* GRaphoptions(string) BYGRaphoptions(string) LABFormat(string) debug]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
	}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman_lollyplot."
	exit 498
	}
	
* if performance measures are not specified, run graphs for all of them
if "`anything'"=="" {
	qui levelsof _perfmeascode, local(lablevelscode)
		foreach lablevelc of local lablevelscode {
			local varlist `varlist' `lablevelc'
		}
}
else foreach thing of local anything {
	local varelement = "`thing'"
	local varlist `varlist' `varelement'
	}

if !mi("`debug'") local dicmd dicmd

preserve   
	
* If data is not in long-long format, then reshape
if `nformat'!=1 {
	siman reshape, longlong
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
	di as error "The 'if' option can not be applied to 'rep' in siman_lollyplot."  
	exit 498
	}

qui keep if `touseif'

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
if mi("`labformat'") local labformat %12.4g
qui gen thelab = string(`estimate',"`labformat'")
qui replace thelab = string(`estimate',"%6.0g") if inlist( _perfmeascode,"bsims","sesims")

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

* Need to know what format method is in (string or numeric) for the below code
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

* If method is a string variable, need to encode it to numeric format for graphs 
if `methodstringindi'==1 encode `method', generate(numericmethod)
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
foreach var of local varlist {
	qui replace tokeep = 1 if _perfmeascode == "`var'"
	}

qui drop if tokeep == 0
qui drop tokeep

qui tab _pm
local npm = `r(r)'

qui levelsof _pm, local(tograph)

if mi(`normse') local ifplot "`listfive',`listeight'"
else local ifplot "`listfive'"

di as text "working...."

if !mi("`if'") {
    local ampersand = " &"
	local if =  `"`if' `ampersand'"'
}
else local if "if"

forvalues j = 1/`nmethodlabels' { 
	local label : label (`method') `j' // assumes method is coded 1,2,3...
	local order `order' `=`nmethodlabels'*3+`j'' "`label'"
	}

* create separate plots 
foreach pm of local tograph {
	if !inlist(`pm',`ifplot') {
		local refline
		local rescale noxrescale
		}
	else {
		local rescale xrescale
		if `methodstringindi'==0 local refline (line `method' ref if _pm==`pm', lc(gs8))
		if `methodstringindi'==1 local refline (line numericmethod ref if _pm==`pm', lc(gs8))
		}

	forvalues j = 1/`nmethodlabels' { 
		if `methodstringindi'==0 {
			local scatter`j' = `"(scatter `method' `estimate' `if' `method'==`j' & _pm==`pm', mlab(thelab) mlabpos(1) mcol("scheme p`j'") mlabcol("scheme p`j'") msym(o))"'
			if `j'==1 local scatters `scatter`j''
			else if `j'>=2 local scatters `scatters' `scatter`j''
	
			local spike`j' = `"(rspike `estimate' ref `method' `if' `method'==`j' & _pm==`pm', lcol("scheme p`j'") hor)"'
			if `j'==1 local spikes `spike`j''
			else if `j'>=2 local spikes `spikes' `spike`j''	

			local bound`j' = `"(scatter `method' `lci' `if' `method'==`j' & _pm==`pm', msym(i) mlab(l) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'")) (scatter `method' `uci' `if' `method'==`j' & _pm==`pm', msym(i) mlab(r) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'"))"'
			if `j'==1 local bounds `bound`j''
			else if `j'>=2 local bounds `bounds' `bound`j''	
			} 

		else if `methodstringindi'==1 {
						
			local scatter`j' = `"(scatter numericmethod `estimate' `if' numericmethod==`j' & _pm==`pm', mlab(thelab) mlabpos(1) mcol("scheme p`j'") mlabcol("scheme p`j'") msym(o))"'
			if `j'==1 local scatters `scatter`j''
			else if `j'>=2 local scatters `scatters' `scatter`j''
	
			local spike`j' = `"(rspike `estimate' ref numericmethod `if' numericmethod==`j' & _pm==`pm', lcol("scheme p`j'") hor)"'
			if `j'==1 local spikes `spike`j''
			else if `j'>=2 local spikes `spikes' `spike`j''	
			
			local bound`j' = `"(scatter numericmethod `lci' `if' numericmethod==`j' & _pm==`pm', msym(i) mlab(l) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'")) (scatter numericmethod `uci' `if' numericmethod==`j' & _pm==`pm', msym(i) mlab(r) mlabpos(0) mcol("scheme p`j'") mlabcol("scheme p`j'"))"' 
			if `j'==1 local bounds `bound`j''
			else if `j'>=2 local bounds `bounds' `bound`j''	
			} 

		}
	
	* find short and long names for this PM
	local longpmname: label (`rep') -`pm'
	tempvar row
	gen `row' = _n
	qui summ `row' if `rep' == -`pm'
	local shortpmname = _perfmeascode[`=r(min)']
	assert _perfmeascode == "`shortpmname'" if `rep' == -`pm'

 	#delimit ;
	`dicmd' graph twoway
		`refline' `spikes' `bounds' `scatters' 
		,
		by(`dgm', `rescale' note("") imargin(tiny)
			b1tit(`longpmname') `bygraphoptions'
		)
		ytit("")
		yla(0 4, val grid labc(white) labsize(*.1))
		xla(, grid)
		ysca(reverse)
		legend(order(`order'))
		name(simanlollyplot_`shortpmname', replace) 
		`graphoptions'
	;
	#delimit cr
}

end



	
