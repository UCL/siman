*!  v0.11.1   11apr2025     
*   v0.11.1   11apr2025  IW remove unwanted output, add level(), call siman describe
*   v0.11     27mar2025  IW Broaden to include missing dgm/target/method and all method types; test properly
*   v0.1      28oct2024  IW Rough starter
* Import dataset of performance statistics into siman format

prog def siman_import
syntax, Perf(varname string) ESTimate(varname numeric) [Dgm(varlist) TArget(varname) Method(varname) se(varname numeric) TRue(varname numeric) Level(real 0)]

// Create locals to store characteristics

* DGMs
local dgm `dgm'
local ndgmvars : word count `dgm'
local dgmmissingok 
 
* TARGETS
if !mi("`target'") {
    qui levelsof `target', clean
    local numtarget = r(r)
    local targetnature 0
    local valtarget = r(levels)
}

* METHODS
if !mi("`method'") {
    cap confirm string var `method'
    if !_rc local methodnature 2
    else local methodnature = !mi("`: value label `method''")
    qui levelsof `method', clean
    local nummethod = r(r)
    if `methodnature'==1 { // 
        foreach i in `r(levels)' {
            local valmethod `valmethod' `: label (`method') `i''
        }
    }
    else local valmethod = r(levels)
    local methodcreated 0
}

* PMs - uses list from simsum of PMs allowed
qui replace `perf' = "estreps" if `perf' == "bsims"
qui replace `perf' = "sereps" if `perf' == "sesims"
local pmsallowed estreps sereps bias pctbias mean empse relprec mse rmse modelse ciwidth relerror cover power 
qui levelsof `perf', local(pmsindata) clean
local pmsbad : list pmsindata - pmsallowed
if !mi("`pmsbad'") {
    di as error "Performance measures not allowed: `pmsbad'"
    exit 498
}
local pmsneedlevel cover power
local pmsneedlevel : list pmsindata & pmsneedlevel
if !mi("`pmsneedlevel'") { // set characteristic cilevel
    if `level'==0 {
        local level $S_level
        di as text "Assuming coverage/power were calculated at `level'% level"
    }
    local cilevel `level'
}

* Estimates 
local estimate `estimate'
local se `se'

* Data formats 
local setuprun 0

* Characteristics 
local analyserun 1
local secreated 

// Create rep variable
encode `perf', gen(rep0)
gen _rep = - rep0
labelit _rep `perf' // IW command below
drop rep0
local rep _rep
qui rename `perf' _perfmeascode

// Store as siman characteristics
local allthings dgm ndgmvars dgmmissingok target numtarget targetnature valtarget method nummethod methodnature valmethod methodcreated estimate se rep true setuprun analyserun secreated cilevel allthings
foreach char of local allthings {
    char _dta[siman_`char'] ``char''
}

siman describe

end






/******************************************************************************/


*! version 2.2 13feb2018  -  label name is just var2 (otherwise can be too long)
*! version 2.1 11feb2013  -  blank labels for empty strings
* version 2 15dec2005  -  if, in, check for duplications
prog def labelit
version 15
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
      else if "`blanks'"!="noblanks" local label `label' `i' " "
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
