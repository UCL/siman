*! version 0.8     23dec2022   IW major rewrite: never pools over dgms, targets or methods
* version 0.7    05dec2022
*  version 0.7   05dec2022     EMZ removed 'if' option, as already applied by siman analyse to the data (otherwise applying it twice).
*  version 0.6   11july2022    EMZ changed generated variables to have _ infront
*  version 0.5   04apr2022     EMZ changes to the default column/row and fixed bug in col() option.
*  version 0.4   06dec2021     EMZ changes to the ordering of performance measures in the table (from TM testing).  Allowed subset of perf measures to be *                                  selected for the table display.
*  version 0.3   25nov2021     EMZ changes to table output when >4 dgms/targets
*  version 0.2   11June2020    IW  changes to output format
*  version 0.1   08June2020    Ella Marley-Zagar, MRC Clinical Trials Unit at UCL

capture program drop siman_table
prog define siman_table, rclass
version 15
syntax [anything] [if], [Column(varlist) debug]

// PARSING

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman_table."
	exit 498
	}
	

// PREPARE DATA

preserve

* reshape data to long-long format for output display
if `nformat'!=1 {
	qui siman_reshape, longlong                    
	foreach thing in `_dta[siman_allthings]' {
		local `thing' : char _dta[siman_`thing']
		}
	}

* remove underscores from variables est_ and se_ for long-long format
foreach val in `estvars' `sevars' {
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
if `dgmcreated' local dgm
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
		if r(N)==0 di as error "Warning: performance measure not found: `thing'"
		qui replace `keep' = 1 if _perfmeascode == "`thing'" 
		}
	qui keep if `keep'
	drop `keep'
}


* re-order performance measures for display in the table as per simsum
local perfvar = "bsims sesims bias empse relprec mse modelse relerror cover power mean rmse ciwidth"
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

if "`sevars'" == "N/A" local sevars


* sort out numbers of variables to be tabulated, and their levels
if `dgmcreated' local dgmvar
* identify non-varying dgmvars
foreach onedgmvar in `dgmvar' {
	summ `onedgmvar' `if', meanonly
	if r(min)<r(max) local newdgmvar `newdgmvar' `onedgmvar'
	else if !mi("`debug'") di as error "Ignoring non-varying dgmvar: `onedgmvar'"
	}
local dgmvar `newdgmvar'
local myfactors _perfmeascodeorder `dgmvar' `target' `method'
if !mi("`debug'") di as input "Factors to display: `myfactors'"
tempvar group
foreach thing in dgmvar target method {
	local n`thing'vars = wordcount("``thing''")
	if !mi("`thing'") {
		egen `group' = group(``thing'')
		qui levelsof `group'
		local n`thing'levels = r(r)
		}
	else n`thing'levels = 1
	if !mi("`debug'") di "`n`thing'levels' levels, `thing': `n`thing'vars' variables (``thing'')"
	drop `group'
	}


* decide what to put in columns
if "`column'"=="" { 
	if `nmethodlevels'>1 local column `method'
	else if `ntargetlevels'>1 local column `target'
	else local column : word 1 of `dgmvar'
}
if !strpos("`column'","perfmeas") local row _perfmeascodeorder
else di as error "siman table doesn't yet know how to format the table when perfmeas is in the columns"
local by : list myfactors - column
local by : list by - row
if wordcount("`by'")>4 {
	di as error "There are too many factors to display. Consider using an if condition for your dgmvars."
	
}


* display the table
local tablecommand tabdisp `row' `column' `if', by(`by') c(`estvars' `sevars') stubwidth(20)
if !mi("`debug'") {
	di "Table column: `column'"
	di "Table row: `row'"
	di "Table by: `by'"
	di "Table command: `tablecommand'"
}
`tablecommand'


* if mcses are reported, print the following note
cap assert missing(`sevars')  
if _rc {
	di "{it: NOTE: Where there are 2 entries in the table, }"
	di "{it: the first entry is the performance measure and }"
	di "{it: the second entry is its Monte Carlo error.}"
}

restore

end
