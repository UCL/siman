*!  version 0.11.8  08apr2025    
*   version 0.11.7  08apr2025   IW use Stata15 syntax
*   version 0.11.6  02apr2025   IW graphs are now sorted by rep
*   version 0.11.5  31mar2025   TM moved default placement of by() note to clock pos *     version 0.11.4     02jan2025   IW correct the count of #panels    
*   version 0.11.3  25oct2024   IW/TM allow only 1 method
*   version 0.11.2  25oct2024   IW Default by() ignores non-varying variables
*   version 0.11.1  21oct2024   IW implement new dgmmissingok option
*   version 0.11    21oct2024   IW fix y-scale when rep is not 1,2,3,... (e.g. res.dta)
*   version 0.10    19jul2024   IW align with new setup: clean up anything (use "estimate" not "`estimate'"), if/in, locals
*                               change meanoff to nomean; reorganise options, new scatteroptions, re-parse name
*                               align versioning with siman.ado
*   version 0.10    22apr2024   IW remove ifsetup and insetup, test if/in more efficiently, rely on preserve
*   version 0.9.8   27mar2024   IW comment out lines creating ndgm, seems unused
*   version 0.9.7   03oct2023   EMZ update to warning message when if/by conditions used
*   version 0.9.6   19sep2023   EMZ accounting for lost labels on method numeric labelled string durng multiple reshapes
*   version 0.9.5   12sep2023   EMZ slight change to error message condition when no method variable
*   version 0.9.4   15aug2023   EMZ only allow estimate or se to be specified for siman swarm
*   version 0.9.3   26jun2023   EMZ change: means are created with egen 'by' option.  Removed combinegraphoptions, cody tidy up.
*   version 0.9.2   19jun2023   EMZ change so that all dgm/target combinations appear on 1 graph when dgm defined by >1 variable with a warning.
*   version 0.9.1   12jun2023   EMZ minor bug fix to note()
*   version 0.9     06jun2023   EMZ updates from IRW/TPM/EMZ joint testing
*   version 0.8     03may2023   EMZ minor formatting changes requested by IRW/TPM
*   version 0.7     07nov2022   EMZ small bug fix
*   version 0.6     26sep2022   EMZ added to code so now allows scatter graphs split out by every dgm variable and level if multiple dgm variables declared.
*   version 0.5     05sep2022   EMZ added additional error message.
*   version 0.4     14jul2022   EMZ. Corrected bug where mean bars were displaced downwards. Changed graph title so uses dgm label (not value) if exists.
*                               Fixed bug so name() allowed if user specifies.
*   version 0.3     17mar2022   EMZ. Suppressed "DGM=1" from graph titles if only one dgm.
*   version 0.2     06dec2021   EMZ changes (bug fix)
*   version 0.1     18dec2021   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce swarm plots
******************************************************************************************************************************************************


program define siman_swarm
version 15

syntax [anything] [if][in] [, * nomean MEANGRaphoptions(string) BY(varlist) BYGRaphoptions(string) GRAPHOPtions(string) SCatteroptions(string) name(string) msymbol(passthru) msize(passthru) mcolor(passthru) title(passthru) note(passthru) row(passthru) col(passthru) xtitle(passthru) ytitle(passthru) debug pause gap(real .1) SAVing(string) EXPort(string)]

* attempt to assign graph options correctly
local scatteroptions `scatteroptions' `msymbol' `msize' `mcolor' `options'
local bygraphoptions `bygraphoptions' `title' `note' `row' `col'
local graphoptions `graphoptions' `xtitle' `ytitle'

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
    di as error "siman setup needs to be run before siman swarm"
    exit 498
}

* if statistics are not specified, run graphs for estimate only
* only allow estimate or se to be specified for siman swarm
foreach thing of local anything {
    if ("`thing'"!="estimate" & "`thing'"!="se") {
        di as error "only estimate or se allowed"
        exit 498
    }
    if mi("``thing''") {
        di as error "`thing'() was not specified in siman setup"
        exit 498
    }
}
if "`anything'"=="" local statlist estimate
else local statlist `anything'
local ngraphs : word count `statlist'

tokenize `"`name'"', parse(",")
local name `1'
local replace `3'
if mi("`name'") {
    local name swarm
    local replace replace
}

* parse optional saving (standard code)
if !mi(`"`saving'"') {
    gettoken saving savingopts : saving, parse(",")
    local saving = trim("`saving'")
    if strpos(`"`saving'"',".") & !strpos(`"`saving'"',".gph") {
        di as error "Sorry, saving() must not contain a full stop"
        exit 198
    }
}

* parse optional export (standard code)
if !mi(`"`export'"') {
    gettoken exporttype exportopts : export, parse(",")
    local exporttype = trim("`exporttype'")
    if mi("`saving'") {
        di as error "Please specify saving(filename) with export()"
        exit 198
    }
}

*** END OF PARSING ***

/* Start preparations */

preserve

* mark sample
marksample touse, novarlist

qui count if `touse' & `rep'>0
if r(N)==0 error 2000

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
    di as error "{p 0 2}Warning: this 'if'/'in' condition cuts across dgm, target and/or method. It is safest to subset only on dgm, target and/or method.{p_end}"
}
drop `meantouse'
qui keep if `touse'

* check number of methods (for example if the 'if' syntax has been used)
if mi("`method'") local nummethodnew = 1
else {
    qui tab `method'
    local nummethodnew = `r(r)'
}

* store method names in locals mlabel`i'
qui levelsof `method'
local methods = r(levels)
forvalues i = 1/`nummethodnew' {
    if `methodnature'==1 local mlabel`i' : label (`method') `i'
    else if `methodnature'==2 local mlabel`i' : word `i' of `methods'
    else local mlabel`i' `i'
}

* keeps estimates data only
qui drop if `rep'<0

* If method is a string variable, encode it to numeric format for graphs 
if `methodnature'==2 {
    tempvar numericmethod
    encode `method', generate(`numericmethod')
    drop `method'
    rename `numericmethod' `method'
}

* default 'by' is all varying among dgm target
if mi("`by'") {
    local mayby `dgm' `target'
    foreach var of local mayby {
        cap assert `var'==`var'[1]
        if _rc local by `by' `var'
        else di as text "Ignoring non-varying " as result "`var'"
    }
    if !mi("`debug'") di as input "Debug: graphing by: `by'"
}

* For a nicer presentation and better better use of space
sort `by' `method' `rep' // 2/4/2025
if !mi("`by'") by `by': gen newidrep = _n
else gen newidrep = _n
summ newidrep, meanonly
local maxnewidrep = r(max)
sort `method' `by' `rep' // 1/4/2025
by `method': gen first = _n==1
qui replace newidrep = newidrep + `gap'*`maxnewidrep'*sum(first)
forvalues g = 1/`nummethodnew' {
    * if `g'==1 qui gen newidrep = `rep' if `method' == `g'
    * else qui replace newidrep = (`rep'-1)+ ceil((`g'-1)*`step') + 1 if `method' == `g'
    qui tabstat newidrep if `method' == `g', s(p50) save
    tempname result
    matrix `result' = r(StatTotal) 
    local ygraphvalue`g' = ceil(`result'[1,1])
    local labelvalues `labelvalues' `ygraphvalue`g'' "`mlabel`g''"
    if `g'==`nummethodnew' label define newidreplab `labelvalues'
}

* Count how many graphs will be created
if !mi("`by'") {
    tempvar first
    bysort `by': gen `first' = _n==1
    qui count if `first'
    local npanels = r(N)
    drop `first'
}
else {
    local npanels 1
}

if `ngraphs'==2 local s "s each "
di as text "{p 0 2}siman swarm will draw " as result `ngraphs' as text " graph`s' with " as result `npanels' as text " panels{p_end}"
if `npanels'>15 di "{p 0 2}Consider reducing the number of panels using 'if' condition or 'by' option{p_end}"

foreach el of local statlist { // estimate and/or se
    local graph_cmd twoway (scatter newidrep ``el'', msymbol(o) msize(small) mcolor(%30) mlc(white%1) mlwidth(vvvthin) `scatteroptions')
    if "`mean'"!="nomean" {
        if "`el'"=="estimate" qui egen mean`el' = mean(``el''), by(`by' `method')
        if "`el'"=="se" {
            tempvar sesq
            qui gen `sesq' = ``el''^2
            qui egen mean`el' = mean(`sesq'), by(`by' `method')
            qui replace mean`el' = sqrt(mean`el')
        }
        local graph_cmd `graph_cmd' (scatter newidrep mean`el', msym(|) msize(huge) mcol(orange) `meangraphoptions')
    }
    local nameopt name(`name'_`el', `replace')
    if !mi("`saving'") local savingopt saving(`"`saving'_`el'"'`savingopts')
    if !mi("`by'") local byopt by(`by', title("") noxrescale legend(off) note(,pos(11)) `bygraphoptions' `dgmmissingok') 
    else local byopt title("") legend(off) `bygraphoptions' `dgmmissingok'
    local graph_cmd `graph_cmd', `byopt' ytitle("") ylabel(`labelvalues', nogrid labsize(medium) angle(horizontal)) yscale(reverse) `nameopt' `graphoptions' `savingopt'

    if !mi("`debug'") di as input "Debug: graph command is: " as input `"`graph_cmd'"'
    if !mi("`pause'") {
        global F9 `graph_cmd'
        pause Press F9 to recall, optionally edit and run the graph command
    }
    `graph_cmd'

    if !mi("`export'") {
        local graphexportcmd graph export `"`saving'_`el'.`exporttype'"'`exportopts'
        if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
        cap noi `graphexportcmd'
        if _rc di as error "Error in export() option"
        exit _rc
    }
}

end
