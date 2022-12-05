*! version 0.4   21july2022  
*  version 0.4   21july2022    EMZ change how dgms are displayed in the table
*  version 0.3   30 june2022   EMZ minor formatting changes from IW/TM testing
*  version 0.2   06jan2022     EMZ changes
*  version 0.1   04June2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
//  Some edits from Tim Morris to draft version 06oct2019

capture program drop siman_describe
prog define siman_describe, rclass
version 15

* siman_describe only describes the data set, it does not change it.  So it should not have it's own [if] and [in] options.
syntax
foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}


local titlewidth 20
local colwidth 35

* remove underscores from the end of method and target labels if there are any (for aesthetic purposes in the output table)
if strpos("`valmethod'","_")!=0 {
    tokenize "`valmethod'"
        forvalues k=1/`nummethod' {
            if  substr("``k''",strlen("``k''"),1)=="_" {
            local l = substr("``k''", 1,strlen("``k''","_") - 1)
            if "`k'"=="1" local valmethod "`l'"
            else if "`l'">"1" local valmethod "`valmethod'" " " "`l'"
            }
    }
}

if strpos("`valtarget'","_")!=0 {
    tokenize "`valtarget'"
        forvalues p=1/`numtarget' {
            if  substr("``p''",strlen("``p''"),1)=="_" {
            local q = substr("``p''", 1,strlen("``p''","_") - 1)
            if "`p'"=="1" local valtarget "`q'"
            else if "`q'">"1" local valtarget "`valtarget'" " " "`q'"
            }
    }
}




* remove underscores from variables (e.g. est_ se_) if long-long format
if `nformat'==1 {

    foreach val in `estvars' `sevars' `dfvars' `civars' `pvars' `truevars' {

        if strpos("`val'","_")!=0 {
                if substr("`val'",strlen("`val'"),1)=="_" {
                    local l = substr("`val'", 1,strlen("`val'","_") - 1)    
                    local `l'vars = "`l'"
                }
        }
    }
}

	char _dta[siman_estimate] `estimate'
	char _dta[siman_se] `se'
	if "`estimate'"!="" char _dta[siman_estvars]   `estimate'
	if "`se'"!="" char  _dta[siman_sevars]   `se'
	
* determine if true variable is numeric or string, for output table text
cap confirm number `true' 
if _rc local truetype "string"
else local truetype "numeric"

* For dgm description
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
else if `dgmcreated' == 1 {
	local totaldgmnum = 0
	local dgmvarsandlevels "none"
}

    di as text _newline _col(`titlewidth') "SUMMARY OF DATA"
    di as text "_____________________________________________________" _newline
    di as text "The siman format is:" as result _col(`colwidth') "`format'" 
	di as text "The format for targets is:" as result _col(`colwidth') "`targetformat'"
	di as text "The format for methods is:" as result _col(`colwidth') "`methodformat'"
    di as text "The number of targets is:" as result _col(`colwidth') "`numtarget'"

    if (`nformat'==1 & `ntarget'==0 & `nmethod'==0 ) {
        di as text "The target values are:" as result _col(`colwidth') "`valtarget'"
    }
    else
    if (`nformat'==1 & `ntarget'==0 & `nmethod'!=0) | (`nformat'==2) {
        di as text "The target values are:" as result _col(`colwidth') `"`valtarget'"'
    }
    else if (`nformat'==1 & `ntarget'!=0 & `nmethod'!=0) | (`nformat'==3) | (`nformat'==1 & `ntarget'!=0 & `nmethod'==0) {
         di as text "The target values are:" as result _col(`colwidth') "`valtarget'"
    }
    di as text _newline "The number of methods is:" as result _col(`colwidth') "`nummethod'"

    if (`nformat'==1 & `ntarget'==0 & `nmethod'==0) {
        di as text "The method values are:" as result _col(`colwidth') "`valmethod'"
    }

	else
	if (`nformat'==1 & `ntarget'!=0 & `nmethod'!=0) | (`nformat'==1 & `ntarget'==0 & `nmethod'!=0) | (`nformat'==3) | (`nformat'==2) {
		di as text "The method values are:" as result _col(`colwidth') "`valmethod'"
	}
	else if (`nformat'==1 & `ntarget'!=0 & `nmethod'==0)  {
		di as text "The method values are:" as result _col(`colwidth') `"`valmethod'"'
	}

    di as result _newline "Data generating mechanism (dgm)
	di as text "The total number of dgms is: " as result _col(`colwidth') "`totaldgmnum'" 
    di as text "The dgm variables (# levels): " as result _col(`colwidth') `"`dgmvarsandlevels'"' _newline
	if "`estimate'"!="" di as result "Estimates are contained in the dataset"
	else if "`estimate'"=="" di as result "Estimates are not contained in the dataset"
    di as text _newline "The estimates `descriptiontype' " "is:" as result _col(`colwidth') "`estvars'"
    di as text "The se `descriptiontype' is:" as result _col(`colwidth') "`sevars'"
    di as text "The df `descriptiontype' is:" as result _col(`colwidth') "`dfvars'"
    di as text "The ci `cidescriptiontype' are:" as result _col(`colwidth') "`civars'"
    di as text "The p `descriptiontype' is:" as result _col(`colwidth') "`pvars'"
	if "`truetype'" == "string" {
		di as text "The true variable is:" as result _col(`colwidth') "`truevars'"
	}
	else di as text "The true value is:" as result _col(`colwidth') "`truevars'"
    di as text "_____________________________________________________"


end
