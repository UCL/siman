*! version 0.5.1   13mar2024
*  version 0.5.1 13mar2024     IW new undocumented sort option 
*  version 0.5   17oct2022     EMZ minor change to table for when method values have a mix of undersocres after them e.g. X Y_
*  version 0.4   21july2022    EMZ change how dgms are displayed in the table
*  version 0.3   30 june2022   EMZ minor formatting changes from IW/TM testing
*  version 0.2   06jan2022     EMZ changes
*  version 0.1   04June2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
//  Some edits from Tim Morris to draft version 06oct2019

capture program drop siman_describe
program define siman_describe, rclass
version 15

syntax, [Chars Sort SAVing(string)]

if !mi("`chars'") {
	local allthings : char _dta[siman_allthings]
	if !mi("`sort'") local allthings : list sort allthings
	foreach thing of local allthings {
		char l _dta[siman_`thing']
	}
	if !mi("`saving'") {
		tempname post
		cap postclose `post'
		local maxl1 0
		local maxl2 0
		foreach thing of local allthings {
			if "`thing'"=="allthings" continue
			local maxl1 = max(`maxl1',length("siman_`thing'"))
			local maxl2 = max(`maxl2',length("`: char _dta[siman_`thing']'"))
		}
		postfile `post' str`maxl1' char str`maxl2' value using `saving'
		foreach thing of local allthings {
			if "`thing'"=="allthings" continue
			post `post' ("siman_`thing'") ("`: char _dta[siman_`thing']'")
		}
		postclose `post'
		di as text `"Chars written to `saving'"'
	}
	exit
}

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
            else if "`k'">"1" local valmethod "`valmethod'" " " "`l'"
            }
			else {
				if "`k'"=="1" local valmethod "``k''"
				else if "`k'">"1" local valmethod "`valmethod'" " " "``k''"
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

    foreach val in `estimate' `se' `df' `lci' `uci' `p' `true' {

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
	local totaldgmnum 1
	local dgmvarsandlevels N/A
}

    di as text _newline _col(`titlewidth') "SUMMARY OF DATA"
    di as text "_____________________________________________________" _newline

    di as text "Data-generating mechanism (DGM)"
//	if `dgmcount' == 1 di as text "The total number of dgms is: " as result _col(`colwidth') "`totaldgmnum'" 
//	else di as text "The total number of dgm vars is: " as result _col(`colwidth') "`totaldgmnum'"
    di as text "  DGM variables (# levels): " as result _col(`colwidth') `"`dgmvarsandlevels'"'
    di as text "  Total number of DGMs: " as result _col(`colwidth') "`totaldgmnum'" _newline

//  di as text "The siman format is:" as result _col(`colwidth') "`format'" 
    di as text "Targets"
//  di as text "The format for targets is:" as result _col(`colwidth') cond(inlist(`nformat',1,3),"long","wide")
    di as text "  Variable containing targets:" as result _col(`colwidth') "`target'"
    di as text "  Number of targets:" as result _col(`colwidth') "`numtarget'"
    if (`nformat'==1 & `ntarget'==0 & `nmethod'==0 ) {
        di as text "  Target values:" as result _col(`colwidth') "`valtarget'" _newline
    }
    else if (`nformat'==1 & `ntarget'==0 & `nmethod'!=0) | (`nformat'==2) {
        di as text "  Target values:" as result _col(`colwidth') `"`valtarget'"' _newline
    }
    else if (`nformat'==1 & `ntarget'!=0 & `nmethod'!=0) | (`nformat'==3) | (`nformat'==1 & `ntarget'!=0 & `nmethod'==0) {
        di as text "  Target values:" as result _col(`colwidth') "`valtarget'" _newline
    }
    
    di as text "Methods"
//	di as text "The format for methods is:" as result _col(`colwidth') cond(inlist(`nformat',1,4),"long","wide")
    di as text "  Variable containing methods:" as result _col(`colwidth') "`method'"
    di as text "  Number of methods:" as result _col(`colwidth') "`nummethod'"

    if (`nformat'==1 & `ntarget'==0 & `nmethod'==0) {
        di as text "  Method values:" as result _col(`colwidth') "`valmethod'"
    }
	else if (`nformat'==1 & `ntarget'!=0 & `nmethod'!=0) | (`nformat'==1 & `ntarget'==0 & `nmethod'!=0) | (`nformat'==3) | (`nformat'==2) {
		di as text "  Method values:" as result _col(`colwidth') "`valmethod'"
	}
	else if (`nformat'==1 & `ntarget'!=0 & `nmethod'==0)  {
		di as text "  Method values:" as result _col(`colwidth') `"`valmethod'"'
	}

    di as text _newline "Repetition-level output"
//	if "`estimate'"!="" di as result "Estimates are contained in the dataset"
//	else if "`estimate'"=="" di as result "Estimates are not contained in the dataset"
    di as text "  Point estimate `descriptiontype':" as result _col(`colwidth') cond( !mi("`estimate'"), "`estimate'", "N/A")
    di as text "  SE `descriptiontype':" as result _col(`colwidth') cond( !mi("`se'"), "`se'", "N/A")
    di as text "  df `descriptiontype':" as result _col(`colwidth') cond( !mi("`df'"), "`df'", "N/A")
    di as text "  Conf. limit `descriptiontype's:" as result _col(`colwidth') cond( !mi("`lci'"), "`lci'", "N/A") cond( !mi("`uci'"), " `uci'", cond( !mi("`lci'"), " N/A", ""))
    di as text "  p-value `descriptiontype':" as result _col(`colwidth') cond( !mi("`p'"), "`p'", "N/A")
	if "`truetype'" == "string" {
		di as text "  True value variable:" as result _col(`colwidth') cond( !mi("`true'"), "`true'", "N/A")
	}
	else di as text "  True value:" as result _col(`colwidth') cond( !mi("`true'"), "`true'", "N/A")
    di as text "_____________________________________________________"


end
