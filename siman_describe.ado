*	version 0.11.1	21oct2024	IW implement new dgmmissingok option
*!	version 0.11.1	21oct2024	
*	version 0.7	14jun2024	IW streamline for longlong only; calculate #dgms without assuming factorial; remove commented out code
* version 0.6   8may2024	IW no longer removes underscores from display
* version 0.5.1   13mar2024
*  version 0.5.1 13mar2024     IW new undocumented sort option 
*  version 0.5   17oct2022     EMZ minor change to table for when method values have a mix of undersocres after them e.g. X Y_
*  version 0.4   21july2022    EMZ change how dgms are displayed in the table
*  version 0.3   30 june2022   EMZ minor formatting changes from IW/TM testing
*  version 0.2   06jan2022     EMZ changes
*  version 0.1   04June2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL
//  Some edits from Tim Morris to draft version 06oct2019

program define siman_describe
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

* determine if true variable is numeric or string, for output table text
cap confirm number `true' 
if _rc local truetype "string"
else local truetype "numeric"

* For dgm description
if !mi("`dgm'") {
	local dgmcount: word count `dgm'
	qui tokenize `dgm'
	forvalues j = 1/`dgmcount' {
		qui tab ``j'', `dgmmissingok'
		local nlevels = r(r)
		local dgmvarsandlevels `"`dgmvarsandlevels'"' `"``j''"' `" (`nlevels') "'
	}
	* Count DGMs
	preserve
	tempvar first
	bysort `dgm': gen `first' = _n==1
	qui count if `first'
	local totaldgmnum = r(N)
	drop `first'
	restore
}
else {
	local dgmvarsandlevels N/A
	local totaldgmnum 1
}

* Print summary of data
di as text _newline _col(`titlewidth') "SUMMARY OF DATA"
di as text "_____________________________________________________" _newline

di as text "Data-generating mechanism (DGM)"
di as text "  DGM variables (# levels): " as result _col(`colwidth') `"`dgmvarsandlevels'"'
di as text "  Total number of DGMs: " as result _col(`colwidth') "`totaldgmnum'" _newline

di as text "Targets"
di as text "  Variable containing targets:" as result _col(`colwidth') "`target'"
di as text "  Number of targets:" as result _col(`colwidth') "`numtarget'"
di as text "  Target values:" as result _col(`colwidth') `"`valtarget'"' _newline

di as text "Methods"
di as text "  Variable containing methods:" as result _col(`colwidth') "`method'"
di as text "  Number of methods:" as result _col(`colwidth') "`nummethod'"

di as text "  Method values:" as result _col(`colwidth') "`valmethod'"

di as text _newline "Repetition-level output"
local descriptiontype variable // fix after removing this char from setup
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
