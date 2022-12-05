*! version 0.7   05dec2022
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
syntax [anything] [if], [Column(varlist)]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

* obtain the variable that 'if' is being applied to
if !mi("`if'") {
	gettoken if1 rest : 0, parse(" ==")
	gettoken ifvar rest : rest, parse(" ==")
}

* check if siman analyse has been run, if not produce an error message
if "`simananalyserun'"=="0" | "`simananalyserun'"=="" {
	di as error "siman analyse has not been run.  Please use siman_analyse first before siman_table."
	exit 498
	}
	
* reshape data in to long-long format for output display
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

preserve

* if performance measures are not specified then display table for all of them, otherwise only display for selected subset
if "`anything'"!="" {
		local nanything : word count `anything'
		local anycount = 1
		foreach thing of local anything {
		  if `anycount' != `nanything' local keep = `keep' `"_perfmeascode == "`thing'" |"'
		  else local keep = `"`keep' _perfmeascode == "`thing'""'
		  local anycount = `anycount' + 1
		}
qui keep if `keep'
}


* if the user has specified anything other than dgm, method or target in the for the 'if' statement then write error
if !mi("`if'") {
		if "`ifvar'" != "`dgm'" & "`ifvar'" != "`method'" & "`ifvar'" != "`target'" {
		di as error "'if' can only be used for dgm, method and target."
		exit 498
	}
}

/*
Don't need the below as siman analyse will have already applied this to the data
* if the user has not specified 'if' in the siman table syntax, but there is one from siman analyse then use that 'if'
if ("`if'"=="" & "`ifanalyse'"!="") local if = `"`ifanalyse'"'
tempvar touse
qui generate `touse' = 0
qui replace `touse' = 1 `if' 
qui keep if `touse'
*/

* use tabdisp command to tabulate performance measures, est and se  
qui drop if `rep'>0
* rename "`rep'" Performance_measure
* If more than 1 dgm, can only take the first one as otherwise tabsisp will not work, error message 'too many variables specified'
*tokenize `dgm'
*local tabledgm =  "`1'"

* IW 11jun2020: 
* 	use all factors
*	allow column option to move factors to columns
* 	force method in columns and perfmeas in rows
if `dgmcreated' == 1 {
    qui gen dgm = 1
	local dgm dgm
	local ndgm = 1
	local numdgm = 1
}

* for where there are more than 1 dgm in the dataset e.g. for nestloop and trellis graph data
if !mi("`dgm'") local numberofdgms: word count `dgm'

* if only 1 dgm in the data, set numdgm to be equal to the number of levels of dgm
if `ndgm' == 1 {
	qui tab `dgm'
	local numdgm = `r(r)'
	local numberofdgms = 1
}	

* obtain the number of levels for method and target
* NB. need to do this as the characteristics will have nummethod/target = "N/A" 
* when method/target is missing, as this was used in the siman describe table
if !mi("`method'") qui tab `method'
local nummethod = `r(r)'
if !mi("`target'") qui tab `target'
local numtarget = `r(r)'

if (!mi("`target'") & "`numtarget'" > "1") & (mi("`dgm'") | "`numdgm'" == "1")  local factors `target'
else if (mi("`target'") | "`numtarget'" == "1") & (!mi("`dgm'") & "`numdgm'" > "1") local factors `dgm'
else if (mi("`target'") | "`numtarget'" == "1") & (mi("`dgm'") | "`numdgm'" == "1") & ("`column'" != "`dgm'" | "`column'" != "`target'") local factors 
else local factors `dgm' `target' 
if !mi("`column'") {
	local ok : list column in factors
	if `ok' local factors : list factors - column
	* default is method in the column so don't print error msg if user specifies col(method)
	else if !`ok' & ("`column'" != "`method'" | "`column'" == "`method'" & & "`nummethod'" == "1") {
		di as error "column(`column') not used"
	}
	if !`ok' local column
*	if `count' == 0 di as error "column(`column') not used"
}
local count: word count `factors'

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

* If nothing is specified in col(), the default is to have method in the columns and other variables in the rows, unless number of method levels = 1 or if * method is missing.  If that is the case, put target in the columns and dgm in the rows, unless number of target levels = 1 or target is missing.  If that * is the case put dgm in the column.

* The tabdisp command has a maximum number of 4 variables allowed in the 'by' command.  If there are more than 4 dgms & targets, then 
* display the table as methods vs performance measures only

if "`sevars'" == "N/A" local sevars

if `count' <= 4 & `numberofdgms' == 1 {
	if mi("`column'") {
		if !mi("`method'") & "`nummethod'" > "1" {
			if !mi("`target'") & "`numtarget'" > "1" & "`numdgm'" > "1" {
				tabdisp `dgm' `method' `if', by(_perfmeascodeorder `target') c(`estvars' `sevars') stubwidth(20)
			}
			else if !mi("`target'") & "`numtarget'" > "1" & (mi("`numdgm'") | "`numdgm'" == "1") {
				tabdisp `target' `method' `if', by(_perfmeascodeorder) c(`estvars' `sevars') stubwidth(20)
			}
			else if (mi("`target'") | "`numtarget'" == "1") & "`numdgm'" > "1" {
				tabdisp `dgm' `method' `if', by(_perfmeascodeorder) c(`estvars' `sevars') stubwidth(20)
			}
			else if (mi("`target'") | "`numtarget'" == "1") & (mi("`numdgm'") | "`numdgm'" == "1") {
				tabdisp _perfmeascodeorder `method' `if', c(`estvars' `sevars') stubwidth(20)
			}
		}
		else if (mi("`method'") | "`nummethod'" == "1") {
			if !mi("`target'") & "`numtarget'" > "1" & "`numdgm'" > "1" {
				tabdisp `dgm' `target' `if', by(_perfmeascodeorder) c(`estvars' `sevars') stubwidth(20)
			}
			else if !mi("`target'") & "`numtarget'" > "1" & (mi("`numdgm'") | "`numdgm'" == "1") {
				tabdisp _perfmeascodeorder `target' `if' , c(`estvars' `sevars') stubwidth(20)
			}
			else if (mi("`target'") | "`numtarget'" == "1") & "`numdgm'" > "1" {
				tabdisp _perfmeascodeorder `dgm' `if' , c(`estvars' `sevars') stubwidth(20)
			}
			else if (mi("`target'") | "`numtarget'" == "1") & (mi("`numdgm'") | "`numdgm'" == "1") {
				tabdisp _perfmeascodeorder `if', c(`estvars' `sevars') stubwidth(20)
			}
		}
	}
	else if !mi("`column'") {
	   * If lots of dgms
		* gettoken factor1 factorrest : factors
		if (!mi("`method'") & "`nummethod'" > "1") tabdisp `method' `column' `if', by(_perfmeascodeorder `factors') c(`estvars' `sevars') stubwidth(20)
		else {
			if `count'!=0 tabdisp `factors' `column' `if', by(_perfmeascodeorder) c(`estvars' `sevars') stubwidth(20)
			else tabdisp _perfmeascodeorder `column', c(`estvars' `sevars') stubwidth(20)
		}
		
	}
}
else {
	if (mi("`column'") | "`numdgm'" > "1") tabdisp _perfmeascodeorder `method' `if', c(`estvars' `sevars') stubwidth(20)
	else tabdisp `method' `column' `if', by(_perfmeascodeorder) c(`estvars' `sevars') stubwidth(20)
}


* if mcses are reported, print the following note
tempvar countdataset
gen `countdataset' = _N
qui count if missing(`sevars')  
if r(N) != `countdataset' {
	di "{it: NOTE: Where there are 2 entries in the table, }"
	di "{it: the first entry is the performance measure and }"
	di "{it: the second entry is monte carlo error.}"
}

if `dgmcreated' == 1 qui drop dgm

restore

end
