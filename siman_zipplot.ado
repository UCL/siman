*! version 1.8.8 05sep2023   EMZ
*  version 1.8.8 05sep2023   EMZ specified name used if true >1 value, named graph with suffix _x
*  version 1.8.7 15aug2023   EMZ minor bug fix in name for when multiple graphs being printed out
*  version 1.8.6 21july2023  IW suppress unwanted "obs dropped" message
*  version 1.8.5 04july2023  EMZ major re-write for graphs when dgm is defined by > 1 variable, all combinations displayed on 1 graph. lpoint/rpoint not 
*                            hard coded.
*  version 1.8.4 16may2023   EMZ bug fix for multiple estimands with multiple targets, formatting to title
*  version 1.8.3 27mar2023   EMZ minor bug fix for when missing method
*  version 1.8.2 06mar2023   EMZ minor bug fix for when method is string
*  version 1.8.2 02mar2023   EMZ fixed bug, now if dgm and method are numeric labelled string, the label values will be used in the graphs
*  version 1.8.1 30jan2023   IW removed rows() and xsize() so they can be user-specified (in bygr() and outside, respectively)
*  version 1.8   07nov2022   EMZ added to code so now allows graphs split out by every dgm variable and level if multiple dgm variables declared.
*  version 1.7   05sep2022   EMZ added additional error message
*  version 1.6   14july2022  EMZ fixed bug so name() allowed in call
*  version 1.5   30june2022  EMZ fixed bug where axis crosses
*  version 1.4   24mar2022   EMZ changes (suppress DGM=1 if no DGM/only 1 DGM)
*  version 1.3   02mar2022   EMZ changes from IW further testing
*  version 1.2   06jan2021   EMZ updates from IW testing (bug fixes)
*  version 1.1   25Jan2021   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the zip plot
*******************************************************************************************************************************************************

capture program drop siman_zipplot
program define siman_zipplot, rclass
version 15

syntax [if][in] [,* BY(varlist) ///
                    NONCOVeroptions(string) COVeroptions(string) SCAtteroptions(string) TRUEGRaphoptions(string) BYGRaphoptions(string) ///
					SCHeme(string)]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`simansetuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
}
	
* if estimate or se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") | mi("`se'") {
    di as error "siman zipplot requires estimate and se to plot"
	exit 498
}	

* if true is missing, produce an error message
if "`true'"=="" {
	di as error "The variable 'true' is missing so siman zipplot can not be created.  Please create a variable in your dataset called true containing the true value(s) re-run siman setup with true() option specified."
	exit 498
}

tempfile origdata
qui save `origdata'

* If data is not in long-long format, then reshape
if `nformat'!=1 {
	qui siman reshape, longlong
		foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
		}
}

* if the user has not specified 'if' in the siman zipplot syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifzipplot = `"`ifsetup'"'
else local ifzipplot = `"`if'"'
qui tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifzipplot' 
preserve
qui sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman zipplot. If you have not specified an 'if' in siman zipplot, but you specified one in siman setup, then that 'if' will have been applied to siman zipplot."  
	exit 498
}
restore
qui keep if `touseif'

* if the user has not specified 'in' in the siman zipplot syntax, but there is one from siman setup then use that 'in'
if ("`in'"=="" & "`insetup'"!="") local inzipplot = `"`insetup'"'
else local inzipplot = `"`in'"'
qui tempvar tousein
qui generate `tousein' = 0
qui replace `tousein' = 1 `inzipplot' 
qui keep if `tousein'


preserve
* keep estimates data only
qui drop if `rep'<0

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
		
if  substr("`estimate'",strlen("`estimate'"),1)=="_" local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
if  substr("`se'",strlen("`se'"),1)=="_" local se = substr("`se'", 1, index("`se'","_") - 1)

* define 'by'
if !mi("`by'") {
	local byvar = "`by'"
}
else if mi("`by'") {
	if "`dgmcreated'" == "1" & "`methodcreated'" == "1" local byvar "`target'"
	else if "`dgmcreated'" == "1" & "`methodcreated'" == "0" local byvar "`target' `method'"
	else if "`dgmcreated'" == "0" & "`methodcreated'" == "1" local byvar "`dgm' `target'"
	else local byvar = "`dgm' `target' `method'"
}

* Zip plot of confidence intervals

capture confirm variable _lci
if _rc {
		qui gen float _lci = `estimate' + (`se'*invnorm(.025))
		local lci _lci
}
capture confirm variable _uci
if _rc {
		qui gen float _uci = `estimate' + (`se'*invnorm(.975))
		local uci _uci
}

if "`method'"!="" {

* for value labels of method
	qui tab `method'
	local nmethodlabels = `r(r)'
	
	qui levels `method', local(levels)
	tokenize `"`levels'"'
		forvalues m = 1/`nmethodlabels' { 
		    local methodlabel`m' "``m''"
		}
}
		
		
if "`target'"!="" {

* for value labels of target
	qui tab `target'
	local ntargetlabels = `r(r)'
	
	qui levels `target', local(levels)
	tokenize `"`levels'"'
		forvalues k = 1/`ntargetlabels' { 
		    local targetlabel`k' "``k''"
		}
}

capture confirm number `true'
if _rc {
	qui gen `true'calc = .
	if "`true'"!="" {
		qui tab `true'
		local ntrue = `r(r)'
			if `r(r)'==1 {
				qui levelsof `true', local(levels)   
				local `true'value = `r(levels)'
				local `true'value1 = `r(levels)'
				local `true'label1 = `r(levels)'
				*local `true'number`truevalue' `truevalue'
				qui replace `true'calc = `truevalue'
				
			}
			else if `r(r)'>1 {
				* Get true label values
				cap qui labelsof `true'
				cap qui ret list

				if `"`r(labels)'"'!="" {
				local 0 = `"`r(labels)'"'

					forvalues t = 1/`ntrue' {  
					gettoken `true'label`t' 0 : 0, parse(" ")
	*				local `true'number`t' `t' 
					local `true'value`t' `t'
					qui replace `true'calc = ``true'value`t'' if `true' == `t'
					local truelabels = 1
					}
				}
				else {
					local truelabels = 0
					qui tab `true'
					local ntrue = `r(r)'
					qui levelsof `true', local(levels)
					tokenize `"`levels'"'
				
					forvalues t = 1/`ntrue' {  
					local `true'label`t' ``t''
					local `true'value`t' `t'
					qui replace `true'calc = ``true'value`t'' if `true' == ``t''
					}
				}
				
				/*
			    qui levels `true', local(truelevels)
				tokenize `"`truelevels'"'
				forvalues j = 1/`ntrue' { 
					local truevalue`j' "``j''"
				
				}
				*/			
			
				
			}
	}
}
else {
	local ntrue = 1
	local truevalue = `true'
	local truevalue1 = `true'
	local truelabel1 = `true'
	local truenumber1 1
	qui gen truecalc = `true'
	local true "true"
}

local dgmorig = "`dgm'"
local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	local ndgmlabels = `r(r)'
}
if `numberdgms'!=1 {
	local ndgmlabels = `numberdgms'
	local dgmexcludetrue: list dgm - true
	local dgm `dgmexcludetrue'
}

foreach dgmvar in `dgm' {
		
	local dgmlabels = 0
		
	qui tab `dgmvar'
	local ndgmvar = `r(r)'

	* Get dgm label values
	cap qui labelsof `dgmvar'
	cap qui ret list

	if `"`r(labels)'"'!="" {
		local 0 = `"`r(labels)'"'

		forvalues i = 1/`ndgmvar' {  
			gettoken `dgmvar'dlabel`i' 0 : 0, parse(": ")
			local dgmlabels = 1
		}
	}
	else {
	local dgmlabels = 0
	qui levels `dgmvar', local(levels)
	tokenize `"`levels'"'
			
		forvalues i = 1/`ndgmvar' {  
			local `dgmvar'dlabel`i' `i'
		}
	}

	qui tab `dgmvar'
	local n`dgmvar'labels = `r(r)'
}

* For coverage (or type I error), use true θ for null value
* so p<=.05 is a non-covering interval
* make sure using actual true value and not the label value (e.g. using 0.5, 0.67 and not 1, 2 etc)
* if true is just one value, then sorting on it won't make a difference so can use the below code for all cases of true

capture confirm variable _p`estimate'
if _rc {
	qui bysort `true': gen float _p`estimate' = 1-normal(abs(`estimate'-`true'calc)/`se')  // if sim outputs df, use ttail and remove 1-'
}
capture confirm variable _covers 
if _rc {
	qui bysort `true' : gen byte _covers = _p`estimate' > .025   // binary indicator of whether ci covers true estimate
}		
sort `byvar' `true' _p`estimate'
capture confirm variable _p`estimate'rank
if _rc {
	qui bysort `byvar' `true': gen double _p`estimate'rank = 100 - (_n/(_N/100))  // scale from 0-100. This will be vertical axis.
}

* Create MC conf. int. for coverage
capture confirm variable _covlb
if _rc {
	qui gen float _covlb = .
}
capture confirm variable _covub
if _rc {
	qui gen float _covub = .
}

		
* Need to know what format method is in (string or numeric)
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

* to get lb and ub of CIs per dgm/method/target/true combinations, create groups to map these on to
sort `byvar' `true'
qui egen group = group(`byvar' `true')

tempfile masterdata
qui save `masterdata'

qui statsby, by(group) clear: ci proportions _covers
tempfile statsbydata
qui save `statsbydata'

qui use `masterdata', clear
qui merge m:1 group using `statsbydata', keepusing(lb ub) 

* check
* ci proportions _covers if method == 1 & estimand == 1 & true == 0.5

qui replace _covlb = 100*(lb)
qui replace _covub = 100*(ub)
qui drop _merge lb ub


qui bysort `byvar': replace _covlb = . if _n>1
qui bysort `byvar' : replace _covub = . if _n>1
	
capture confirm variable _lpoint
	if _rc {
	qui egen _lpoint = min(`lci') if !missing(_covlb), by(`byvar' `true') 
	}
capture confirm variable _rpoint
	if _rc {
	qui egen _rpoint = max(`uci') if !missing(_covlb), by(`byvar' `true') 
	}	
	
* Can't tokenize/substr as many "" in the string
if !mi(`"`options'"') {
	tempvar _namestring
	qui gen `_namestring' = `"`options'"'
	qui split `_namestring',  parse(`"name"')
	local options = `_namestring'1
	cap confirm var `_namestring'2
	if !_rc {
		local namestring = `_namestring'2
		local name = `"name`namestring'"'
		local options: list options - name
	}
}

* strip out the actual name out of the command
local namelastpart = subinstr(`"`name'"',"name("," ",1)
local namefirstpart = strtrim(subinstr(`"`namelastpart'"',", replace)"," ",1))
*di `"`namefirstpart'"'
local namestub = substr(`"`namefirstpart'"',1,.)

* check if many graphs will be created - if so warn the user
local dgmcount: word count `dgm'
qui tokenize `dgm'
if `dgmcreated' == 0 {
	forvalues j = 1/`dgmcount' {
		qui tab ``j''
		local nlevels = r(r)
		local dgmvarsandlevels `"`dgmvarsandlevels'"' `"``j''"' `" (`nlevels') "'
		if `j' == 1 local totaldgmnum = `nlevels'
		else local totaldgmnum = `totaldgmnum'*`nlevels'
	}
}

if "`numtarget'" == "N/A" local numtargetcheck = 1
else local numtargetcheck = `numtarget'
if "`nummethod'" == "N/A" local nummethodcheck = 1
else local nummethodcheck = `nummethod'
if "`totaldgmnum'" == "" local totaldgmnum = 1

local graphnumcheck = `totaldgmnum' * `nummethodcheck' * `numtargetcheck'
if `graphnumcheck' > 15 {
	di as error "{it: WARNING: `graphnumcheck' panels will be created, consider using 'if' or 'by' options as detailed in {help siman_zipplot:siman zipplot}}"
}
	
* Plot of confidence interval coverage:
* First two rspike plots: Monte Carlo confidence interval for percent coverage
* second two rspike plots: confidence intervals for individual reps
* blue intervals cover, purple do not
* scatter plot (white dots) are point estimates - probably unnecessary

tempfile graphdata
qui save `graphdata'

if `ntrue' == 1 {
		#delimit ;
				twoway (rspike _lpoint _rpoint _covlb, hor lw(thin) pstyle(p5)) // MC 
				(rspike _lpoint _rpoint _covub, hor lw(thin) pstyle(p5))
				(rspike `lci' `uci' _p`estimate'rank if _covers, hor lw(medium) pstyle(p1) lcol(%30) `coveroptions')
				(rspike `lci' `uci' _p`estimate'rank if !_covers, hor lw(medium) pstyle(p2) lcol(%30) `noncoveroptions')	
				(scatter _p`estimate'rank `estimate', msym(p) mcol(white%30) `scatteroptions') // plots point estimates in white
				(pci 0 `truevalue' 100 `truevalue', pstyle(p5) lw(thin) `truegraphoptions')
			, 
			xtit("95% confidence intervals")
			ytit("Centile of ranked p-values for null: θ=`truevalue'")  
			ylab(5 50 95)
			by(`byvar', ixaxes noxrescale iscale(*.8) `bygraphoptions') scale(.8)
			legend(order(3 "Coverers" 4 "Non-coverers"))
			`scheme'
			`options'
			;
		#delimit cr
}
else if `ntrue'>1 {
* note have to use true_`j' in name to get true_1 etc, not value as will error out if e.g. have 0.25 in the name                           
	forvalues k = 1/`ntrue' {
		qui keep if `true'calc == `k'
* have to create local noname for the loop (to re-set name later, so that each graph is named)
        local noname 0
		if mi("`name'") local noname = 1
		if `noname'==1 local name "name(simanzip_true_`k', replace)"
		else local name "name(`namestub'_`k', replace)"
		#delimit ;
			twoway (rspike _lpoint _rpoint _covlb, hor lw(thin) pstyle(p5)) // MC 
			   (rspike _lpoint _rpoint _covub, hor lw(thin) pstyle(p5))
			   (rspike `lci' `uci' _p`estimate'rank if _covers & `true'calc == `k', hor lw(medium) pstyle(p1) lcol(%30) `coveroptions')
			   (rspike `lci' `uci' _p`estimate'rank if !_covers & `true'calc == `k', hor lw(medium) pstyle(p2) lcol(%30) `noncoveroptions')
			   (scatter _p`estimate'rank `estimate' if `true'calc == `k', msym(p) mcol(white%30) `scatteroptions') // plots point estimates in white
			   (pci 0 ``true'label`k'' 100 ``true'label`k'', pstyle(p5) lw(thin) `truegraphoptions')
				,
				`name'
				xtit("95% confidence intervals")
				ytit("Centile of ranked p-values for null: θ=``true'label`k''") 
				ylab(5 50 95)
				by(`byvar', ixaxes noxrescale iscale(*.8) `bygraphoptions') scale(.8)
				legend(order(3 "Coverers" 4 "Non-coverers"))
				`scheme'
				`options'
				;
		#delimit cr
		use `graphdata', clear
		* have to re-set otherwise name will not be updated
		if `noname' == 1 local name ""
	}
}

restore

local dgm = "`dgmorig'"

qui use `origdata', clear 

end

