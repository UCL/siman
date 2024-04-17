*! version 1.9.8 27mar2024
* version 1.9.8 27mar2024	IW comment out lines creating ndgm, seems unused
*  version 1.9.7 03oct2023    EMZ update to warning message when if/by conditions used
*  version 1.9.6 19sep2023    EMZ accounting for lost labels on method numeric labelled string durng multiple reshapes
*  version 1.9.5 12sep2023    EMZ slight change to error message condition when no method variable
*  version 1.9.4 15aug2023    EMZ only allow estimate or se to be specified for siman swarm
*  version 1.9.3 26june2023   EMZ change: means are created with egen 'by' option.  Removed combinegraphoptions, cody tidy up.
*  version 1.9.2 19june2023   EMZ change so that all dgm/target combinations appear on 1 graph when dgm defined by >1 variable with a warning.
*  version 1.9.1 12june2023   EMZ minor bug fix to note()
*  version 1.9   06june2023   EMZ updates from IRW/TPM/EMZ joint testing
*  version 1.8   03may2023    EMZ minor formatting changes requested by IRW/TPM
*  version 1.7   07nov2022    EMZ small bug fix
*  version 1.6   26sep2022    EMZ added to code so now allows scatter graphs split out by every dgm variable and level if multiple dgm variables declared.
*  version 1.5   05sep2022    EMZ added additional error message.
*  version 1.4   14july2022   EMZ. Corrected bug where mean bars were displaced downwards. Changed graph title so uses dgm label (not value) if exists.
*							  Fixed bug so name() allowed if user specifies.
*  version 1.3   17mar2022    EMZ. Suppressed "DGM=1" from graph titles if only one dgm.
*  version 1.2   06dec2021    EMZ changes (bug fix)
*  version 1.1   18dec2021    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the siman swarm plot
******************************************************************************************************************************************************


capture program drop siman_swarm
program define siman_swarm, rclass
version 16

syntax [anything] [if][in] [, * MEANOFF MEANGRaphoptions(string) BY(varlist) BYGRaphoptions(string) GRAPHOPtions(string)]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}


if "`setuprun'"!="1" {
	di as error "siman_setup needs to be run first."
	exit 498
}

* if the data is read in long-long format, then reshaped to longwide, then there will be no method variable (only
* method values), so base the error message on number of methods
if (`nmethod'<1 | `nummethod'<1) & "`setuprun'"=="1" {
	di as error "The variable 'method' is missing so siman swarm can not be created.  Please create a variable in your dataset called method containing the method value(s)."
	exit 498
}
	
* if both estimate and se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") & mi("`se'") {
    di as error "siman swarm requires either estimate or se to plot"
	exit 498
}

tempfile origdata
qui save `origdata'

* If data is not in long-long format, then reshape to get method labels
if `nformat'!=1 {
	qui siman reshape, longlong
		foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
		}
}


* if statistics are not specified, run graphs for estimate only
* only allow estimate or se to be specified for siman swarm
local anythingcount: word count `anything'
if "`anything'"=="" local varlist `estimate'
else foreach thing of local anything {
	local varelement = "`thing'"
		if ("`varelement'"!="`estimate'" & "`varelement'"!="`se'") | "`anythingcount'"!="1" {
			di as error "only -estimate- or -se- allowed"
			exit 498
		}
	local varlist `varlist' `varelement'
}

* if the user has not specified 'if' in the siman swarm syntax, but there is one from siman setup then use that 'if'
if ("`if'"=="" & "`ifsetup'"!="") local ifswarm = `"`ifsetup'"'
else local ifswarm = `"`if'"'
tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `ifswarm' 
preserve
sort `dgm' `target' `method' `touseif'
* The 'if' condition will only apply to dgm, target and method.  The 'if' condition is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' condition can not be applied to 'rep' in siman swarm.  If you have not specified an 'if' in siman swarm, but you specified one in siman setup, then that 'if' will have been applied to siman swarm."  
	exit 498
}
restore
qui keep if `touseif'

* if the user has not specified 'in' in the siman swarm syntax, but there is one from siman setup then use that 'in'
if ("`in'"=="" & "`insetup'"!="") local inswarm = `"`insetup'"'
else local inswarm = `"`in'"'
tempvar tousein
qui gen `tousein' = 0
qui replace `tousein' = 1 `inswarm' 
qui keep if `tousein'

* Need to know number of dgms for later on
local numberdgms: word count `dgm'
if `numberdgms'==1 {
	qui tab `dgm'
	*local ndgm = `r(r)'
}
*if `numberdgms'!=1 local ndgm = `numberdgms'


* check number of methods (for example if the 'if' syntax has been used)
qui tab `method'
local nummethodnew = `r(r)'


if `nummethodnew' < 2 {
	di as error "There are not enough methods to compare, siman swarm requires at least 2 methods."
	exit 498
}
	

* Need to know what format method is in (string or numeric) for the below code
local methodstringindi = 0
capture confirm string variable `method'
if !_rc local methodstringindi = 1

* Need labelsof package installed to extract method labels
qui capture which labelsof
if _rc {
	di as smcl  "labelsof package required, please kindly install by clicking: "  `"{stata ssc install labelsof}"'
	exit
} 

* label values are lost during reshape so need to account for both versions
qui capture labelsof `method'
if !_rc qui ret list 
else qui capture levelsof `method'

if "`r(labels)'"!="" {
	local 0 = `"`r(labels)'"'

	forvalues i = 1/`nummethodnew' {  
		gettoken mlabel`i' 0 : 0, parse(": ")
		if `i'==1 local mgraphlabels `mlabel`i''
		else if `i'>1 local mgraphlabels `mgraphlabels' `mlabel`i''
	}
}
else {
qui levels `method', local(levels)
tokenize `"`levels'"'
	
	if `methodstringindi'==0 {
	
		forvalues i = 1/`nummethodnew' {  
			local mlabel`i' "Method: `i'"
			if `i'==1 local mgraphlabels `mlabel`i''
			else if `i'>1 local mgraphlabels `mgraphlabels' `mlabel`i''
		}
	}
	else if `methodstringindi'==1 {
	
		forvalues i = 1/`nummethodnew' {  
			local mlabel`i' "Method: ``i''"
			if `i'==1 local mgraphlabels `"`mlabel`i''"'
			else if `i'>1 local mgraphlabels `mgraphlabels' `"`mlabel`i''"'
		}
		
	}
}

preserve
* keeps estimates data only
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


* If method is a string variable, need to encode it to numeric format for graphs 
if `methodstringindi'==1 {
	encode `method', generate(numericmethod)	
	drop `method'
	rename numericmethod method
	local method = "method"
}

di as text "working....."

* For a nicer presentation and better better use of space
local nummethodminus1 = `nummethodnew'-1
local nummethodplus1 = `nummethodnew'+1

local maxrep = _N
forvalues g = 1/`nummethodnew' {
	local step = `maxrep'/`nummethodplus1'
	if `g'==1 qui gen newidrep = `rep' if `method' == `g'
	else qui replace newidrep = (`rep'-1)+ ceil((`g'-1)*`step') + 1 if `method' == `g'
	qui tabstat newidrep if `method' == `g', s(p50) save
	qui matrix list r(StatTotal) 
	local median`g' = r(StatTotal)[1,1]
	local ygraphvalue`g' = ceil(`median`g'')
	local labelvalues `labelvalues' `ygraphvalue`g'' "`mlabel`g''"
	if `g'==`nummethodnew' label define newidreplab `labelvalues'
}


* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
*if "`dgm'"=="" local ndgm=1

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
else {
    * need to re-count in case there is an 'if' statement.  Data is in long-long format from reshape above
	qui tab `target'   
	local numtargetcheck = `r(r)'
}
if "`totaldgmnum'" == "" local totaldgmnum = 1
if "`by'" == "`target'" local totaldgmnum = 1
if !mi("`by'") & strpos("`dgm'", "`by'")>0 {
    local numtargetcheck = 1
	cap qui tab `by'
	local totaldgmnum = `r(r)'
}

local graphnumcheck = `totaldgmnum' * `numtargetcheck'
if `graphnumcheck' > 15 {
	di as smcl as text "{p 0 2}Warning: `graphnumcheck' panels will be created: consider using 'if' or 'by' options as detailed in {help siman_swarm:siman swarm}{p_end}"
}

* defining 'by'
local byorig = "`by'"
if "`byorig'"=="" {
	if "`dgmcreated'" == "1" local by = "`target'"
	else local by = "`dgm' `target'"
}

* Can't tokenize/substr as many "" in the string
if !mi(`"`graphoptions'"') {
	tempvar _namestring
	qui gen `_namestring' = `"`graphoptions'"'
	qui split `_namestring',  parse(`"name"')
	local graphoptions = `_namestring'1
	cap confirm var `_namestring'2
		if !_rc {
			local namestring = `_namestring'2
			local name = `"name`namestring'"'
			local graphoptions: list graphoptions - name
		}
}

foreach el in `varlist' {
*	qui egen mean`el' = mean(`el'), by (`dgm' `method' `target')
	qui egen mean`el' = mean(`el'), by (`by')
	if mi(`"`name'"') local name "name(simanswarm_`el', replace)"		
		if "`meanoff'"=="" {
			local graphname `graphname' `el'
			local cmd twoway (scatter newidrep `el', ///
			msymbol(o) msize(small) mcolor(%30) mlc(white%1) mlwidth(vvvthin) `options')	///
			(scatter newidrep mean`el', msym(|) msize(huge) mcol(orange) `meangraphoptions')	///
			, ///
			by(`by', title("") noxrescale legend(off) `bygraphoptions')	///
			ytitle("") ylabel(`labelvalues', nogrid labsize(medium) angle(horizontal)) yscale(reverse) `name' `graphoptions'
			}
			else {
			local graphname `graphname' `el'
			local cmd twoway (scatter newidrep `el', ///
			msymbol(o) msize(small) mcolor(%30) mlc(white%1) mlwidth(vvvthin) `options')	///
			, ///
			by(`by', title("") noxrescale legend(off) `bygraphoptions')	///
			ytitle("") ylabel(`labelvalues', nogrid labsize(medium) angle(horizontal)) yscale(reverse) `name' `graphoptions'
			}
}


qui `cmd'
	
restore

qui use `origdata', clear

end


