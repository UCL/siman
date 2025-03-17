*!	version 0.11.4	17mar2025	
*	version 0.11.4	17mar2025	better fail if too many dgmvars
*	version 0.11.3	11mar2025	IW catch no valid PMs; don't show PM if only one; new nomcse option; pass options to tabdisp; remove stubwidth(20)
*	version 0.11.2	28oct2024	IW implement new concise option
*	version 0.11.1	21oct2024	IW implement new dgmmissingok option
*	version 0.8.3   3apr2024
*  version 0.8.3    3apr2024 IW ignore method if methodcreated
*                  14feb2024 IW allow new performance measure (pctbias) from simsum
*  version 0.8.2   20dec2023   IW add row() option (undocumented at present)
*  version 0.8.1 25oct2023     IW put PMs in same order as in simsum
*  version 0.8   23dec2022     IW major rewrite: never pools over dgms, targets or methods
*  version 0.7   05dec2022     EMZ removed 'if' condition, as already applied by siman analyse to the data (otherwise applying it twice).
*  version 0.6   11july2022    EMZ changed generated variables to have _ infront
*  version 0.5   04apr2022     EMZ changes to the default column/row and fixed bug in col() option.
*  version 0.4   06dec2021     EMZ changes to the ordering of performance measures in the table (from TM testing).  Allowed subset of perf measures to be *                                  selected for the table display.
*  version 0.3   25nov2021     EMZ changes to table output when >4 dgms/targets
*  version 0.2   11June2020    IW  changes to output format
*  version 0.1   08June2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

program define siman_table
version 15
syntax [anything] [if], [Column(varlist max=2) noMCse mcci Level(cilevel) /// documented option 
	* /// tabdisp options
	Row(varlist) debug pause tabdisp /// undocumented options
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


* if performance measures are not specified then display table for all of them, otherwise only display for selected subset
if "`anything'"!="" {
	tempvar keep
	gen `keep' = 0
	foreach thing of local anything {
		qui count if _perfmeascode == "`thing'" 
		if r(N)==0 di as smcl as text "{p 0 2}Warning: ignoring invalid/missing performance measure: `thing'{p_end}"
		qui replace `keep' = 1 if _perfmeascode == "`thing'" 
		}
	qui keep if `keep'
	drop `keep'
}
qui tab _perfmeascode if `rep'<0
local npms = r(r)
if `npms'==0 {
	di as error "No valid performance measures specified"
	exit 498
}

* re-order performance measures for display in the table as per simsum
local perfvar = "estreps sereps bias pctbias mean empse relprec mse rmse modelse ciwidth relerror cover power"
qui gen _perfmeascodeorder=.
local p = 0
foreach perf of local perfvar {
	qui replace _perfmeascodeorder = `p' if _perfmeascode == "`perf'"
	local perflabels `perflabels' `p' "`perf'"
	local p = `p' + 1
}
label define perfl `perflabels'
label values _perfmeascodeorder perfl 
label variable _perfmeascodeorder "performance measure"
drop _perfmeascode
rename _perfmeascodeorder _perfmeascode


* sort out numbers of variables to be tabulated, and their levels
if `methodcreated' local method
* identify non-varying dgm
foreach onedgmvar in `dgm' {
	qui levelsof `onedgmvar' `if', `dgmmissingok'
	if r(r)>1 local newdgmvar `newdgmvar' `onedgmvar'
	else if !mi("`debug'") di as input "Debug: ignoring non-varying dgmvar: `onedgmvar'"
}
local dgm `newdgmvar'
local myfactors `dgm' `target' `method'
if `npms'>1 local myfactors _perfmeascode `myfactors'
if !mi("`debug'") di as input "Debug: factors to display: `myfactors'"
tempvar group
foreach thing in dgm target method {
	local n`thing'vars = wordcount("``thing''")
	if !mi("`thing'") {
		egen `group' = group(``thing''), `dgmmissingok'
		qui levelsof `group'
		local n`thing'levels = r(r)
    }
	else n`thing'levels = 1
	if !mi("`debug'") di as input "Debug: `thing' has `n`thing'levels' levels, `n`thing'vars' variables (``thing'')"
	drop `group'
}


* decide what to put in columns
if "`column'"=="" { 
	if `nmethodlevels'>1 local column `method'
	else if `ntargetlevels'>1 local column `target'
	else local column : word 1 of `dgm'
}
local myfactors : list myfactors - column
if "`row'"=="" {
	if !strpos("`column'","perfmeas") & `npms'>1 local row _perfmeascode
	else local row : word 1 of `myfactors'
}
local by : list myfactors - row
if wordcount("`by'")>4 {
	di as error "There are too many factors to display. Consider using an if condition for your dgm."
	exit 498
}

* display the table
if "`mcci'" == "mcci" {
	tempvar lcivar ucivar
	local zcrit = invnorm((1/2+`level'/200))
	qui gen `lcivar' = `estimate' - `zcrit'*`se'
	qui gen `ucivar' = `estimate' + `zcrit'*`se'
}
if "`mcse'" == "nomcse" {
	drop `se'
	local se
}
local tablecommand tabdisp `row' `column' `if', by(`by') c(`estimate' `se' `lcivar' `ucivar') `options'
* in version>=17, could have: table (`row') (`column') (`by') `if', stat(sum `estimate' `se' `lcivar' `ucivar') nototal `options'
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
qui count if inlist(_perfmeascode,"cover":perfl,"power":perfl)
if r(N) di as text "Note: coverage and power calculated at `level'% level"

* if mcses or mccis are reported, print the following note
cap assert mi("`mcse'") | !mi("`mcci'") 
if !_rc {
	di as smcl as text "{p 0 2}Note: where there are multiple entries in the table, they are the estimated performance measure, followed by"
	if mi("`mcse'") di "its Monte Carlo error"
	if mi("`mcse'") & !mi("`mcci'") di "and"
	if !mi("`mcci'") di "its Monte Carlo `level'% confidence limits"
	di "{p_end}"
}

restore

end
