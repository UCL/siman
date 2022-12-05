*! version 1.7    11aug2022
*  version 1.7    11aug2022    EMZ fixed bug to allow name() in call  
*  version 1.6    11july2022   EMZ changed created variable names to start with _
*  version 1.5    19may2022    EMZ added error messages
*  version 1.4    31mar2022    EMZ changes from IW file (supress DGM=1 if only one dgm/dgm missing). Minor edits.
*  version 1.3    06jan2022    EMZ updates from IW testing.
*  version 1.2    02Dec2021    EMZ.  Changes to allow multiple dgms and variables with non-integer values.
*  version 1.1    01Nov2021    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. 

* File to produce the trellis plot

capture program drop siman_trellis
program define siman_trellis, rclass
version 16

// PARSE
syntax [anything] [if] [,* BYGRaphoptions(string)]
	
foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
	
}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman_trellis."
	exit 498
	}
	

if "`method'"=="" {
	di as error "The variable 'method' does not exist in the dataset.  siman trellis can not be run."
	exit 498
	}

* check if 'true' exists in the dataset / isn't a missing value, if not produce an error message
if "`true'"=="" {
	di as error "The variable 'true' does not exist in the dataset.  siman trellis can not be run."
	exit 498
	}
if "`true'"!="" {
		if `true'==. & _dataset==0 {
		di as error "The variable 'true' is a missing value in the dataset.  siman trellis can not be run."
		exit 498
	}
}

* If only 1 dgm in the dataset, produce error message as nothing will be graphed
if `ndgm'==1 {
	di as error "Only 1 dgm in the dataset, nothing to graph."
	exit 498
}

* if true is in the dataset, but has not been listed in dgm() as well then need to let user know this is required
* if one dgm variable with >1 level
local numberdgm: word count `dgm'
if `numberdgm'==1 {
	qui levelsof `dgm', local(dgmlevels)
*	tokenize `"`dgmlevels'"'
		if !mi("`true'") & !inlist("`true'", `"`dgmlevels'"') {
		di as error "for siman trellis to run, 'true' needs to be a variable and also needs to be included within dgm()."
		exit 498
		}
}

* if dgm is described by more than 1 variable
else if `numberdgm'!=1 {
	qui tokenize `dgm'

	* Need to get dgm vars/levels in to -inlist- format 
	forvalues l = 1/`ndgm' {
		if `l'! = `ndgm' local dgmlist `dgmlist' `""``l''","'
		else local dgmlist `dgmlist' "``l''"
	}

	if !mi("`true'") & !inlist("`true'", "`dgmlist'") {
		di as error "for siman trellis to run, 'true' needs to be a variable and also needs to be included within dgm()."
		exit 498
	}
}
	
* if performance measures are not specified, run graphs for all of them
if "`anything'"=="" {
	qui levelsof _perfmeascode, local(lablevelscode)
		foreach lablevelc of local lablevelscode {
			local varlist `varlist' *`lablevelc'
			local varnostar `varnostar' `lablevelc'
		}
}
else foreach thing of local anything {
	local varelement = "*`thing'"
	local varelementnostar = "`thing'"
	local varlist `varlist' `varelement'
	local varnostar `varnostar' `varelementnostar'
	}

*tempfile origdata 
*qui save `origdata'
preserve

* keep performance measures only
qui drop if `rep'>0


* Need data in wide format (with method/perf measures wide) which siman reshape does not offer, so do below.  Start with reshaping to long-long format if not already in this format
* If data is not in long-long format, then reshape
if `nformat'!=1 {
	qui siman reshape, longlong
		foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
	}
}

* if the user has not specified 'if' in the siman trellis syntax, but there is one from siman analyse then use that 'if'
if ("`if'"=="" & "`ifanalyse'"!="") local iftrellis = `"`ifanalyse'"'
else local iftrellis = `"`if'"'
tempvar touseif
qui generate `touseif' = 0
qui replace `touseif' = 1 `iftrellis' 
*preserve
sort `dgm' `target' `method' `touseif'
* The 'if' option will only apply to dgm, target and method.  The 'if' option is not allowed to be used on rep and an error message will be issued if the user tries to do so
capture by `dgm' `target' `method': assert `touseif'==`touseif'[_n-1] if _n>1
if _rc == 9 {
	di as error "The 'if' option can not be applied to 'rep' in siman_trellis."  
	exit 498
	}
*restore
qui keep if `touseif'

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm "dgm"
	local ndgm=1
}

* number of dgm levels without true included
local dgmnotrue: list dgm - true
qui tab `dgmnotrue'
local numdgm =  `r(r)'


* create a variable that uniquely identifies each of the dgm combinations
cap confirm variable exact _scenario
if !_rc {
	di as error "The variable _scenario already exists in the dataset.  Please rename your _scenario variable and run the siman suite again."
	exit 498
	}
qui egen _scenario = group(`dgm')
* add in to existing macros
local scenario "_scenario"
local dgm `scenario' `dgm'
local varlist `varlist' `scenario'

* Define descriptors as DGM	
local descriptors = `"`dgm'"'

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
if  substr("`df'",strlen("`df'"),1)=="_" local df = substr("`df'", 1, index("`df'","_") - 1)
if  substr("`ci'",strlen("`ci'"),1)=="_" local ci = substr("`ci'", 1, index("`ci'","_") - 1)
if  substr("`p'",strlen("`p'"),1)=="_" local p = substr("`p'", 1, index("`p'","_") - 1)
if  substr("`true'",strlen("`true'"),1)=="_" local true = substr("`true'", 1, index("`true'","_") - 1)


* rep now contains perf measures names only. 
*drop `rep'

* drop variables that we're not going to use
qui drop `se' `df' `ci' `p' 

* reshape to wide method format

* defining true value based on whether it contains 1 or >1 values
*if "`ntruevalue'"=="single" local optionlist `estimate'  
*else if "`ntruevalue'"=="multiple" local optionlist `estimate' `true' 
local optionlist `estimate' 

* create another perfmeascode variable with same labels as rep to use as graph titles later
qui gen graphtitles = _perfmeascode

	* Take out underscores at the end of method value labels if there are any.  
	* Need to tokenize the method variable again as might have changed in a previous reshape.
					
		qui tab `method'
		local nmethodlabels = `r(r)'
	
		qui levelsof `method', local(mlevels)
		tokenize `"`mlevels'"'
	
        cap quietly label drop `method'
		local labelchange = 0

		forvalues m = 1/`nmethodlabels' {
			if  substr("``m''",strlen("``m''"),1)=="_" {
				local label`m' = substr("``m''", 1, index("``m''","_") - 1)
				local metlabel`m' = "``m''"
				local labelchange = 1
					if `m'==1 {
						local labelvalues `m' "`label`m''" 
						local metlist `metlabel`m''
						}
					else if `m'>1 {
						local labelvalues `labelvalues' `m' "`label`m''" 
						local metlist `metlist' `metlabel`m''
						}
			}
			else {
			local metlabel`m' = "``m''"
			if `m'==1 local metlist `metlabel`m''
			else if `m'>=2 local metlist `metlist' `metlabel`m''
			}
		}	
		if `labelchange'==1 {
			label define methodlab `labelvalues'
			label values `method' methodlab
			}
			
		local valmethod = "`metlist'"
		
			forvalues i=1/`nmethodlabels' {
				local m`i' = "``i''"
				}

		
		* check if method elements are numeric (e.g. 1 2) or string (e.g. A B) for reshape
		local string = 0
		capture confirm numeric variable `method'
		if _rc local string = 1
					

		if `string' == 0 {
			qui reshape wide "`optionlist'", i(`dgm' `target' _perfmeascode) j(`method' "`valmethod'") 
		}
		else if `string' == 1 {
			qui reshape wide "`optionlist'", i(`dgm' `target' _perfmeascode) j(`method' "`valmethod'") string
		}
	

		foreach option in `optionlist' {
			forvalues j = 1/`nmethodlabels' {
				local `option'stubreshape`j' = "`option'`m`j''"
					if `j'==1 local optionlist2 ``option'stubreshape`j''
					else if `j'>=2 local optionlist2 `optionlist2' ``option'stubreshape`j''
					}
			}
				
		qui reshape wide `optionlist2', i(`rep' `dgm' `target') j(_perfmeascode) string	
		

* resolve varlists in descriptors
local descriptorslist : list descriptors - _scenario
*di "`descriptorslist'"

* for legend labels
forvalues i=1/`nmethodlabels' {
	local legend `legend' `i' `"Method `m`i''"'
	}

* don't create a pannel for thr true variable if included in dgm list
local graphdescriptorslist `descriptorslist'
local exclude "`true' `scenario'"
local graphdescriptorslist: list graphdescriptorslist - exclude 
*di "`graphdescriptorslist'"


* obtain true values for x axis scale (assign label values, rank so if values 0, 3, 10 for example will be evenly spaced)
* If true is not a single value entered in siman setup
capture confirm number `true'
	if _rc {
		qui egen ranktrue = group(`true')
		local ranktrue ranktrue
		qui tab `true'
		local tlabels = `r(r)'
		qui levelsof `true', local(tlevels)
		qui tokenize `"`tlevels'"'
		*cap quietly label drop `true'
		forvalues t = 1/`tlabels' {
			local tlabel`t' = "``t''"
			if `t'==1 {
				local labelvaluest `t' "`tlabel`t''" 
				local tlist `tlabel`t''
				}
				else if `t'>1 {
				local labelvaluest `labelvaluest' `t' "`tlabel`t''" 
				local tlist `tlist' `tlabel`t''
				}
		}	
		label define truelab `labelvaluest'
		label values `ranktrue' truelab
	}
	else {
		local tlabels = `true'
		local true = "true"
	}


di as text "working...."

local name = "simantrellis"

* Can't tokenize/substr as many "" in the string
if !mi(`"`options'"') {
	tempvar _namestring
	qui gen `_namestring' = `"`options'"'
	qui split `_namestring',  parse(`"name"')
	local options = `_namestring'1
	cap confirm var `_namestring'2
	if !_rc {
		local namestring = `_namestring'2
		local name = `namestring'
	}
}

if `numdgm' != 1 {
	foreach title in `varnostar' {
		foreach des in `graphdescriptorslist' {
			forvalues i=1/`nmethodlabels' {
				if `i'==1 local ygraph = "`estimate'`m`i''`title'"
				else local ygraph = "`ygraph' `estimate'`m`i''`title'"
				}
				twoway line `ygraph' `ranktrue', xtitle("`true'") ytitle("Estimate of `title'") xlabel(1/`tlabels', valuelabel) name(st_`title'_`true'_`des', replace) legend(order(`legend')) `options' by(`des', ixaxes `bygraphoptions') nodraw
				* eg. twoway line est1bias est2bias true 
				local graphlist_`title' `graphlist_`title'' st_`title'_`true'_`des'
		}
	}
}
else if `numdgm' == 1 {
	foreach title in `varnostar' {
			forvalues i=1/`nmethodlabels' {
				if `i'==1 local ygraph = "`estimate'`m`i''`title'"
				else local ygraph = "`ygraph' `estimate'`m`i''`title'"
				}
				twoway line `ygraph' `ranktrue', xtitle("`true'") ytitle("Estimate of `title'") xlabel(1/`tlabels', valuelabel) name(st_`title'_`true', replace) legend(order(`legend')) `options' nodraw
				* eg. twoway line est1bias est2bias true 
				local graphlist_`title' `graphlist_`title'' st_`title'_`true'
		}
}

* To get graph titles
foreach title in `varnostar' {
	qui levelsof `rep' if graphtitles == "`title'"
	assert `:word count `r(levels)''==1
	local repnumber = "`r(levels)'" 
	local graphtitle: label (`rep') `repnumber'
	graph combine `graphlist_`title'', name(`name'_`title',replace) title("`graphtitle'")
}

* restore original data set
*use `origdata', clear
restore
end










