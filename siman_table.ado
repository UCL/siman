*!  version 0.11.9   30may2025   
*   version 0.11.9  30may2025   IW correct output if only 1 PM
*   version 0.11.8  24apr2025   IW better capitalisation of performance measures
*   version 0.11.7  16apr2025   IW make rows and columns work correctly
*   version 0.11.6  10apr2025   IW correct table footnote
*   version 0.11.5  08apr2025   IW no version, call tabdisp or table according to Stata version, new default arrangement of variables
*   version 0.11.4  17mar2025   IW better fail if too many dgmvars
*   version 0.11.3  11mar2025   IW catch no valid PMs; don't show PM if only one; new nomcse option; pass options to tabdisp; remove stubwidth(20)
*   version 0.11.2  28oct2024   IW implement new concise option
*   version 0.11.1  21oct2024   IW implement new dgmmissingok option
*   version 0.8.3   03apr2024   IW ignore method if methodcreated
*                   14feb2024   IW allow new performance measure (pctbias) from simsum
*   version 0.8.2   20dec2023   IW add row() option (undocumented at present)
*   version 0.8.1   25oct2023   IW put PMs in same order as in simsum
*   version 0.8     23dec2022   IW major rewrite: never pools over dgms, targets or methods
*   version 0.7     05dec2022   EMZ removed 'if' condition, as already applied by siman analyse to the data (otherwise applying it twice).
*   version 0.6     11jul2022   EMZ changed generated variables to have _ infront
*   version 0.5     04apr2022   EMZ changes to the default column/row and fixed bug in col() option.
*   version 0.4     06dec2021   EMZ changes to the ordering of performance measures in the table (from TM testing).  Allowed subset of perf measures to be *                                  selected for the table display.
*   version 0.3     25nov2021   EMZ changes to table output when >4 dgms/targets
*   version 0.2     11Jun2020   IW  changes to output format
*   version 0.1     08Jun2020   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

program define siman_table
* not versioned, so that we can use new -table- if available
syntax [anything] [if], [Column(varlist) Row(varlist) TABDisp TABLe ///
    noMCse mcci MCLevel(cilevel) /// documented options 
    * /// tabdisp/table options
    debug pause  /// undocumented options
    ]

// PARSING

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* check if siman analyse has been run, if not produce an error message
if "`analyserun'"=="0" | "`analyserun'"=="" {
    di as error "siman analyse has not been run. Please use siman analyse first before siman table."
    exit 498
}

* tabdisp vs table
if c(version)<17 & !mi("`table'") {
    di as text "Stata version below 17: table option ignored"
    local table
}
if !mi("`tabdisp'") & !mi("`table'") {
    di as error "can't use both tabdisp and table options"
    exit 498
}
if mi("`tabdisp'") & mi("`table'") {
    if c(version)<17 local tabdisp tabdisp
    else local table table
}
if !mi("`tabdisp'") & wordcount("`column'")>2 {
    di as error "column(): too many variables specified with tabdisp"
    exit 498
}

// PREPARE DATA

preserve

* remove underscores from variables est_ and se_ for long-long format
foreach val in `estimate' `se' {
    if strpos("`val'","_")!=0 {
        if substr("`val'",strlen("`val'"),1)=="_" {
            local l = substr("`val'", 1,strlen("`val'","_") - 1)    
            local `l'vars = "`l'"
        }
    }
}


* choose sample
qui drop if `rep'>0
tempvar touse
marksample touse


* if the 'if' condition varies within dgm, method and target then write error
cap bysort `dgm' `method' `target' : assert `touse'==`touse'[1] 
if _rc {
    di as error "'if' can only be used for dgm, method and target."
    exit 498
}


local perfvar = "estreps sereps bias pctbias mean empse relprec mse rmse modelse ciwidth relerror cover power"
* if performance measures are not specified then display table for all of them, otherwise only display for selected subset
if "`anything'"!="" {
    tempvar keep
    gen `keep' = 0
    foreach thing of local anything {
        local ok : list thing in perfvar
        if !`ok' {
            di as smcl as error "{p 0 2}Invalid performance measure: `thing'{p_end}"
            exit 198
        }
        qui count if _perfmeascode == "`thing'" 
        if r(N)==0 di as smcl as text "{p 0 2}Performance measure not in data: `thing'{p_end}"
        qui replace `keep' = 1 if _perfmeascode == "`thing'" 
        }
    qui keep if `keep'
    drop `keep'
}

qui levelsof _perfmeascode if `rep'<0, clean
if r(N)>0 local perfmeaslist = strproper(r(levels))
local npms = r(r)
if `npms'==0 {
    di as error "No valid performance measures specified"
    exit 498
}

* re-order performance measures for display in the table as per simsum
qui gen _perfmeascodeorder=.
local p = 0
foreach perf of local perfvar {
    qui replace _perfmeascodeorder = `p' if _perfmeascode == "`perf'"
    if inlist("`perf'","mse","rmse") local Perf = upper("`perf'")
    else if "`perf'"=="sereps" local Perf = "SEreps"
    else if "`perf'"=="ciwidth" local Perf = "CIwidth"
    else local Perf = strproper("`perf'")
    local perflabels `perflabels' `p' "`Perf'"
    local p = `p' + 1
}
label define perfl `perflabels'
label values _perfmeascodeorder perfl 
label variable _perfmeascodeorder "Performance measure"
drop _perfmeascode
rename _perfmeascodeorder _perfmeascode


* sort out numbers of variables to be tabulated, and their levels
if `methodcreated' local method
* identify non-varying dgm
* NB for table, keep if varying in data even if constant in sample
*    for tabdisp, keep if varying in sample
local ifset = cond(mi("`tabdisp'"),"","if `touse'")
if !mi("`dgm'") {
    foreach onedgmvar in `dgm' {
        qui levelsof `onedgmvar' `ifset', `dgmmissingok'
        if r(r)>1 local newdgmvars `newdgmvars' `onedgmvar'
    }
}
if !mi("`target'") {
    qui levelsof `target' `ifset'
    if r(r)==1 local target
}
if !mi("`method'") {
    qui levelsof `method' `ifset'
    if r(r)==1 local method
}

local myfactors `newdgmvars' `target' `method' _perfmeascode
local nfactors = wordcount("`myfactors'") + (`npms'>1)
if !mi("`tabdisp'") & `nfactors'>7 {
    di as error "There are too many factors to display. Consider using an if condition for your dgm."
    exit 498
}
if !mi("`debug'") di as input "Debug: factors to display: `myfactors'"

* decide what to put in columns
* default approach: columns = method within target; rows = PM; by = DGMs
* but drop anything that's single-valued across the data
if "`column'"=="" { 
    local column `target' `method'
    local column : list column - row
}
if !mi("`tabdisp'") & wordcount("`column'")==2 { // tabdisp has fastest-varying first
    local column `: word 2 of `column'' `: word 1 of `column''
}
if "`row'"=="" {
    local row _perfmeascode
    local row : list row - column
}
local by : list myfactors - column
local by : list by - row
if mi("`row'") {
    local nbyvars = wordcount("`by'")
    local row : word `nbyvars' of `by'
    local by : list by - row
}
local nrowvars = wordcount("`row'")
if !mi("`tabdisp'") & `nrowvars'>1 { // move other rowvars to by
    local tomove : word 1 of `row'
    local row : list row - tomove
    local by : list by | tomove
}
local by : list by - row
if wordcount("`by'")>4 & !mi("`tabdisp'") {
    di as error "There are too many factors to display. Consider using an if condition for your dgm."
    exit 498
}

* display the table
if "`mcci'" == "mcci" {
    tempvar lcivar ucivar
    local zcrit = invnorm((1/2+`mclevel'/200))
    qui gen `lcivar' = `estimate' - `zcrit'*`se'
    qui gen `ucivar' = `estimate' + `zcrit'*`se'
    label var `lcivar' "Lower MC CI"
    label var `ucivar' "Upper MC CI"
}
if "`mcse'" == "nomcse" {
    drop `se'
    local se
}
if !mi("`tabdisp'") local tablecommand tabdisp `row' `column' `if', by(`by') c(`estimate' `se' `lcivar' `ucivar') `options'
else local tablecommand table (`row') (`column') (`by') `if', stat(mean `estimate' `se' `lcivar' `ucivar') nototal `options'
label var `estimate' "Estimate"
if !mi("`se'") label var `se' "MCSE"
if !mi("`debug'") {
    di as input "Debug: table features:"
    di "    column:  `column'"
    di "    row:     `row'"
    di "    by:      `by'"
    di `"    command: `tablecommand'"'
}
if !mi("`pause'") {
    global F9 `tablecommand'
    pause Press F9 to recall, optionally edit and run the table command
}
`tablecommand'

* print the cilevel
qui count if _perfmeascode == "Cover":perfl
local hascover = r(N)>0
qui count if _perfmeascode == "Power":perfl
local haspower = r(N)>0
local covpow = cond(`hascover',"Coverage","")+cond(`hascover'&`haspower'," and ","")+cond(`haspower',"Power","")
if `hascover' | `haspower' di as text "Note: `covpow' calculated at `cilevel'% level"
if !mi("`mcci'") & !mi("`table'") di as text "Note: Monte Carlo CIs calculated at `mclevel'% level"

* if mcses or mccis are reported, print the following note
if (mi("`mcse'") | !mi("`mcci'")) & !mi("`tabdisp'") {
    di as smcl as text "{p 0 2}Note: where there are multiple entries per performance measure, these are estimated performance, followed by"
    if mi("`mcse'") di "Monte Carlo standard error"
    if mi("`mcse'") & !mi("`mcci'") di "and"
    if !mi("`mcci'") di "Monte Carlo `mclevel'% confidence limits"
    di "{p_end}"
}

restore

end
