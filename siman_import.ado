*! 	v0.1 	28oct2024 	IW 	Rough starter

prog def siman_import
syntax, perf(varname) dgm(varlist) target(varname) method(varname) estimate(varname)

// Create locals to store characteristics

* DGMs
local dgm `dgm'
local ndgmvars : word count `dgm'
local dgmmissingok 
 
* TARGETS
local target `target'
qui levelsof `target', clean
local numtarget = r(r)
local targetnature 0
local valtarget = r(levels)

* METHODS
local method `method'
qui levelsof `method', clean
local nummethod = r(r)
local methodnature 2
local valmethod = r(levels)
local methodcreated 0

* Estimates 
local estimate `estimate'
local se `se'

* True values 
local true 

* Data formats 
local setuprun 0

* Characteristics 
local analyserun 1
local secreated 

// Create rep variable
encode _perfmeascode, gen(rep0)
gen _rep = - rep0
labelit _rep _perfmeascode // IW command below
drop rep0
local rep _rep

// Store as siman characteristics
local allthings dgm ndgmvars dgmmissingok target numtarget targetnature valtarget method nummethod methodnature valmethod methodcreated estimate se df lci p rep uci true setuprun analyserun secreated allthings
foreach char of local allthings {
	char _dta[siman_`char'] ``char''
}

end






/******************************************************************************/


*! version 2.2 13feb2018  -  label name is just var2 (otherwise can be too long)
*! version 2.1 11feb2013  -  blank labels for empty strings
* version 2 15dec2005  -  if, in, check for duplications
prog def labelit
version 9
syntax varlist(min=2 max=2) [if] [in], [modify usefirst noBLAnks]
tokenize "`varlist'"
confirm numeric variable `1'
confirm string variable `2'
marksample touse, novarlist
qui summ `1' if `touse'
local imin=r(min)
local imax=r(max)
tempvar id 
gen `id'=_n
forvalues i = `imin'/`imax' {
   qui summ `id' if `1'==`i' & `touse'
   if r(N)>0 {
      local doit 1
      local j=r(min)
      local value = `2'[`j']
      cap assert `2'=="`value'" if `1'==`i' & `touse'
      if _rc>0 {
        di as text "Warning: multiple values of `2' found for `1'==`i'"
        tab `2' if `1'==`i' & `touse', missing
        if "`usefirst'"!="usefirst" {
            di as error "To use the first value, specify usefirst option"
            exit 498
        }
        else di as text "Using the first value, `2'=`value'"
      } 
      if "`value'"~="" local label `label' `i' "`value'"
	  else if "`blanks"!="noblanks" local label `label' `i' " "
      cap assert `2'=="`value'" if `1'==`i'
      if _rc>0  {
         di as text "Warning: multiple values of `2' for `1'==`i' - but only outside if/in expression"
         label var `touse' "to use"
         tab `2' `touse' if `1'==`i', missing
      }
   }
}
label def `2' `label', `modify'
label val `1' `2'
end
