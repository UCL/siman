*!  version 0.3   26sep2022
*   version 0.3   26sep2022     EMZ fixed bug when transforming to longwide with dgm defined by multiple variables and true in both dgm() and true()
*   version 0.2   05sep2022     EMZ added additional error messages
*   version 0.1   08june2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

capture program drop siman_reshape
program define siman_reshape, rclass
version 15

syntax, [LONGWIDE LONGLONG]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* if both estimate and se are missing, give error message as requires something to reshape
if mi("`estimate'") & mi("`se'") {
    di as error "siman reshape requires either estimate or se, otherwise nothing to reshape"
	exit 498
}

* make a list of the optional elements that have been entered by the user, that would be stubs in the reshape
if "`ntruevalue'"=="single" local optionlist `estimate' `se' `df' `ci' `p'  
else if "`ntruevalue'"=="multiple" local optionlist `estimate' `se' `df' `ci' `p' `true' 	
*di "`optionlist'"

* create an identifier if true has been entered as a number, as reshape option list will need to be changed accordigly (can't reshape on a number)
local truenumber = 0
cap confirm number `true' 
if !_rc local truenumber = 1

* if dgm is missing in the dataset (i.e. only 1 dgm) then create for the reshape
if `dgmcreated' == 1 {
    cap confirm variable dgm
	if _rc {
		qui gen dgm = 1
		local dgm dgm
		local ndgm = 1
	}
}


* RESHAPE: If format 2: reshape from wide-wide to long-wide
************************************************************

if "`longwide'"!="" {

if `nformat'==2 { 			
* if method is first in the variable label (i.e. if order = method) create the stubs e.g. for est this would be estmethod

	if "`order'" == "method" {

		* need the est stub to be est`method1' est`method2' etc so create a macro list.  
		forvalues j = 1/`nmethod' {
			foreach option in `optionlist' {
				local `option'stubreshape`m`j'' = "`option'`m`j''"
				if `j'==1 local `option'stubreshapelist ``option'stubreshape`m`j'''
				else if `j'>=2 local `option'stubreshapelist ``option'stubreshapelist' ``option'stubreshape`m`j'''
			
			}	
        }
					
* if target is first in the variable label (i.e. if order = target) create the stubs e.g. for est this would be  esttarget

	} 
	else if "`order'" == "target" {
     
	 * need the est stub to be est`target1' est`target2' etc so create a macro list.  
		forvalues j = 1/`ntarget' {
			foreach option in `optionlist' {
				local `option'stubreshape`t`j'' = "`option'`t`j''"
				if `j'==1 local `option'stubreshapelist ``option'stubreshape`t`j'''
				else if `j'>=2 local `option'stubreshapelist ``option'stubreshapelist' ``option'stubreshape`t`j'''
			
			}
		}

	}


	if "`ntruevalue'"=="single" & `truenumber' == 0 {
		qui reshape long "``estimate'stubreshapelist' ``se'stubreshapelist' ``df'stubreshapelist' ``lci'stubreshapelist' ``uci'stubreshapelist' ``p'stubreshapelist'", i(`rep' `dgm' `true') j(`j') string
	}
	else if "`ntruevalue'"=="multiple" | `truenumber' == 1 {
		qui reshape long "``estimate'stubreshapelist' ``se'stubreshapelist' ``df'stubreshapelist' ``lci'stubreshapelist' ``uci'stubreshapelist' ``p'stubreshapelist'", i(`rep' `dgm') j(`j') string
	}
		
	* j(`j' "`valmethod'") string
	
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
	
	if `nformat'==2 & "`order'" == "method" {
	capture confirm variable target
		if _rc {
			rename _j target
			local target = "target"
		}
		else {
		di as error "siman would like to rename the target variable 'target', but that name already exists in your dataset.  Please rename your variable target as something else."
		exit 498
		}
		
		* redefine characteristics:
		
		char _dta[siman_format] "format 3: long-wide"
		char _dta[siman_targetformat] "long"
		char _dta[siman_methodformat] "wide"
		char _dta[siman_nformat] 3
		
		char _dta[siman_target] "`target'"
		if `ntarget'!=0 char _dta[siman_ntarget] 1
		char _dta[siman_descriptiontype] "stub"
		if "`ntruevalue'"=="single" char _dta[siman_truedescriptiontype] "variable"
		if "`ntruevalue'"=="multiple" char _dta[siman_truedescriptiontype] "stub"
		char _dta[siman_cidescriptiontype] "stubs"
		
		siman_describe
		
		}
	if `nformat'==2 & "`order'" == "target" {
	capture confirm variable method
		if _rc {
			rename _j method
			local method = "method"
		}
		else {
		di as error "siman would like to rename the method variable 'method', but that name already exists in your dataset.  Please rename your variable method as something else."
		exit 498
		}
			
		* need to get into long-wide format with long target and wide method
		
		qui reshape long "`optionlist'", i(`rep' `dgm' `method') j(target) string		
		qui reshape wide "`optionlist'", i(`rep' `dgm' target) j(`method' "`valmethod'") string
		
		
		* redefine characteristics:
		
		char _dta[siman_format] "format 3: long-wide"
		char _dta[siman_targetformat] "long"
		char _dta[siman_methodformat] "wide"
		char _dta[siman_nformat] 3
		
		char _dta[siman_target] "target"
		if `ntarget'!=0 char _dta[siman_ntarget] 1
		char _dta[siman_descriptiontype] "stub"
		char _dta[siman_order]: method
		if "`ntruevalue'"=="single" char _dta[siman_truedescriptiontype] "variable"
		if "`ntruevalue'"=="multiple" char _dta[siman_truedescriptiontype] "stub"
		char _dta[siman_cidescriptiontype] "stubs"
		
		if "`truevaluecreated'" == "1" {
			local truevars `trueuser'
			char _dta[siman_[siman_truevars] "`trueuser'"
		}
		
		siman_describe

		}

}
else if `nformat'==1 & `nmethod'!=0 {	

	* There might be underscores at the end of the macro names from previous reshaping, so remove
	if  substr("`estimate'",strlen("`estimate'"),1)=="_" local estimate = substr("`estimate'", 1, index("`estimate'","_") - 1)
	if  substr("`se'",strlen("`se'"),1)=="_" local se = substr("`se'", 1, index("`se'","_") - 1)
	if  substr("`df'",strlen("`df'"),1)=="_" local df = substr("`df'", 1, index("`df'","_") - 1)
	if  substr("`ci'",strlen("`ci'"),1)=="_" local ci = substr("`ci'", 1, index("`ci'","_") - 1)
	if  substr("`p'",strlen("`p'"),1)=="_" local p = substr("`p'", 1, index("`p'","_") - 1)
	if  substr("`true'",strlen("`true'"),1)=="_" local true = substr("`true'", 1, index("`true'","_") - 1)

	
	if "`ntruevalue'"=="single" local optionlist `estimate' `se' `df' `ci' `p'  
	else if "`ntruevalue'"=="multiple" local optionlist `estimate' `se' `df' `ci' `p' `true' 
	
	* if dgm is defined by multiple variables, and the true value is included in dgm() as well as true() [e.g. for siman trellis and nestloop]
	* then only include true in the dgm value for the reshape (-reshape- will not accept it twice)
	local numberdgms: word count `dgm'
	if `numberdgms'!=1 local optionlist `estimate' `se' `df' `ci' `p'


	* Take out underscores at the end of method value labels if there are any.  
	* Need to tokenize the method variable again as might have changed in a previous reshape.
					
		qui tab `method'
		local nmethodlabels = `r(r)'
	
		qui levels `method', local(mlevels)
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
		
			forvalues i=1/`nmethod' {
				local m`i' = "``i''"
				}
				

		* check if method elements are numeric (e.g. 1 2) or string (e.g. A B) for reshape
		local string = 0
		capture confirm numeric variable `method'
		if _rc local string = 1

		if `string' == 0 {
			qui reshape wide "`optionlist'", i(`rep' `dgm' "`target'") j(`method' "`valmethod'") 
		}
		else if `string' == 1 {
			qui reshape wide "`optionlist'", i(`rep' `dgm' "`target'") j(`method' "`valmethod'") string
		}

		
					
*       redefine characteristics:
		
		char _dta[siman_format] "format 3: long-wide"
		char _dta[siman_targetformat] "long"
		char _dta[siman_methodformat] "wide"
		char _dta[siman_nformat] 3
		
		forvalues i=1/`nummethod' {
			char _dta[siman_m`i'] `i'
			
				if `i'==1 local siman_method `i'
				else if `i'>=2 local siman_method `siman_method' `i'
				
		}
		
		char _dta[siman_estimate] `estimate'
		char _dta[siman_se] `se'
		char _dta[siman_df] `df'
		char _dta[siman_ci] `ci'
		char _dta[siman_p] `p'
		char _dta[siman_true] `true'
		
		if "`estimate'"!="" char _dta[siman_estvars]   `estimate'
		if "`se'"!="" char  _dta[siman_sevars]   `se'
		if "`df'"!="" char  _dta[siman_dfvars]   `df'
		if "`ci'"!="" char  _dta[siman_civars]   `ci'
		if "`p'"!="" char  _dta[siman_pvars]    `p'
		if "`true'"!="" char  _dta[siman_truevars] `true'
			
		
		char _dta[siman_method] "`siman_valmethod'"
		char _dta[siman_descriptiontype] "stub"
		if "`ntruevalue'"=="single" char _dta[siman_truedescriptiontype] "variable"
		if "`ntruevalue'"=="multiple" char _dta[siman_truedescriptiontype] "stub"
		char _dta[siman_cidescriptiontype] "stubs"
		
		
		siman_describe
}

else if `nformat'==1 & `nmethod'==0 {
	di as error "Can not reshape targets to wide format"
	exit 498
	}
}


else

if "`longlong'"!="" {

*  Shouldn't ever be wide-wide as this is auto reshaped to long-wide in siman setup.  
	
	if `nformat'==3 {
	
	* remove underscores from valmethod elements if there are any
	tokenize "`valmethod'"

	if `nmethod'!=0 {
		forvalues v=1/`nummethod' {
			if  substr("``v''",strlen("``v''"),1)=="_" {
				local valmethod`v' = substr("``v''", 1, index("``v''","_") - 1) 
				if `v'==1 local valmethod `valmethod`v''
				else if `v'>=2 local valmethod `valmethod' `valmethod`v''
				}
			}
	}
	
	* check if method elements are numeric (e.g. 1 2) or string (e.g. A B) for reshape
	local string = 0
	forvalues i=1/`nmethod' {
		capture confirm number `m`i''
		if _rc {
			local string = 1
			}
	}

	* if underscores were removed in siman_analyse need to put them back for reshape to work
	if "`estchange'" == "1" local estimateunderscore = "`estvars'"
	if "`sechange'" == "1" local seunderscore = "`sevars'"
	
	if ("`estchange'" != "1" & "`sechange'" != "1") local optionlist `estimate' `se' `df' `ci' `p'
	if ("`estchange'" == "1" & "`sechange'" != "1") local optionlist `estimateunderscore' `se' `df' `ci' `p'
	if ("`estchange'" != "1" & "`sechange'" == "1") local optionlist `estimate' `seunderscore' `df' `ci' `p'
	if ("`estchange'" == "1" & "`sechange'" == "1") local optionlist `estimateunderscore' `seunderscore' `df' `ci' `p'
	
	   	
	* reshape according to whether true is a long variable or a stub

	* take out true from option list if included for the reshape, otherwise will be included in the optionlist as well as i() and reshape won't work
	local optionlistreshape `optionlist'
	local exclude "`true'"
	local optionlistreshape: list optionlistreshape - exclude

		
	if "`truedescriptiontype'" == "stub" | `truenumber' == 1 {
		
		* need a different reshape for nestloop where the true value is a separate variable AND also included in the dgm list
		* so if the data is in the format of the nestloop data, use a different list to reshape on.
		* If true is not in the dgm list:
		local trueindgm = strpos("`dgm'","`true'")
		if `trueindgm' == 0 local optionlistreshape `optionlist' `true' 
		* or if it is:
		else local optionlistreshape `optionlist'
		if `truenumber' == 1 local optionlistreshape `optionlist'

		if `string' == 0 & `ntarget'<=1 & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' `target') j(method "`valmethod'") 
			}
		else if `string' == 1 & `ntarget'<=1 & `nmethod'!=0  {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' `target') j(method "`valmethod'") string
			}
		else if `ntarget'>1 & `ntarget'!=. & `nmethod'==0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm') j(target "`valtarget'") 
			}
		else if `string' == 0 & `ntarget'>1 & `ntarget'!=. & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' target) j(method "`valmethod'")
			}
		else if `string' == 1 & `ntarget'>1 & `ntarget'!=. & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' target) j(method "`valmethod'") string
			}
	} 
	else if "`truedescriptiontype'" == "variable" & `truenumber' == 0 {
		
		if `string' == 0 & `ntarget'<=1 & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' `target' `true') j(method "`valmethod'")    
			}

		else if `string' == 1 & `ntarget'<=1 & `nmethod'!=0  {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' `target' `true') j(method "`valmethod'") string
			}
		else if `ntarget'>1 & `ntarget'!=. & `nmethod'==0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' `true') j(target "`valtarget'") 
			}
		else if `string' == 0 & `ntarget'>1 & `ntarget'!=. & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' target `true') j(method "`valmethod'")
			}
		else if `string' == 1 & `ntarget'>1 & `ntarget'!=. & `nmethod'!=0 {
			qui reshape long "`optionlistreshape'", i(`rep' `dgm' target `true') j(method "`valmethod'") string
			}
	} 
		
		
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
	
	* redefine characteristics
  
	char _dta[siman_format] "format 1: long-long"
	char _dta[siman_targetformat] "long"
	char _dta[siman_methodformat] "long"
	char _dta[siman_nformat] 1
	if `nmethod'!=0 char _dta[siman_method] "method"
	if `nmethod'!=0 char _dta[siman_nmethod] 1
	char _dta[siman_descriptiontype] "variable"
	char _dta[siman_truedescriptiontype] "variable"
	char _dta[siman_cidescriptiontype] "variables"
	
	char _dta[siman_estimate] `estimate'
	char _dta[siman_se] `se'
	if "`estimate'"!="" char _dta[siman_estvars]   `estimate'
	if "`se'"!="" char  _dta[siman_sevars]   `se'

	* if siman_analyse has been run, make sure order or performance measures is as required
	* put non-missing point estimates at the top 
	if "`simananalyserun'"=="1" {
	preserve
	tempfile sortperf
	drop if `rep'<0 
	save `sortperf'
	restore
	drop if `rep'>0
	gsort -`rep' `dgm' `target' `method'
	append using `sortperf'
	}



	siman_describe
	
	}
	
	
}

if `dgmcreated' == 1 qui drop dgm

end


	
	


