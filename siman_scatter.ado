*!  version 0.11.3   31mar2025    
*   version 0.11.3   31mar2025   TM moved default placement of by() note to clock pos 11 to make more prominent (based on feedback)
*   version 0.11.2   24oct2024   IW by default se on y not x axis; nicer labels
*   version 0.11.1   21oct2024   IW implement new dgmmissingok option
*   version 0.10     18jun2024   IW Clean up handling of varlist, if/in, by
*   version 0.7      22apr2024   IW remove ifsetup and insetup, test if/in more efficiently, rely on preserve
*   version 0.6.7    03oct2023   EMZ update to warning message when by() conditions used
*   version 0.6.6    18sep2023   EMZ updated warning of # panels to be printed based on 'if' subset
*   version 0.6.5    08aug2023   EMZ restricted siman scatter options to be -estimate se- or -se estimate- only
*   version 0.6.4    26jun2023   EMZ minor bug fix for when dgm/method is missing, and tidy up of code.
*   version 0.6.3    13jun2023   EMZ: changed if dgm is defined by > 1 variable, that a pannel for each dgm var/level, target and method is displayed on 1 *                            graph, with a warning to the user as per IRW/TPM request
*   version 0.6.2    06may2023   EMZ agreed updates from IRW/TPM/EMZ joint testing 
*   version 0.6.1    13mar2023   EMZ minor update to error message
*   version 0.6      23jan2023   EMZ bug fixes from changes to setup programs 
*   version 0.5      05dec2022   EMZ fixed bug so that dgm labels are used when 1 dgm variable, and scatter plots for each dgm when true not part of dgm *                            structure.
*   version 0.4      12sep2022   EMZ added to code so now allows scatter graphs split out by every dgm variable and level if multiple dgm variables declared.
*   version 0.3      05sep2022   EMZ added additional error message.
*   version 0.2      14jul2022   EMZ. Tidied up graph labels if 'by' option used.  Fixed bug if more than 1 dgm variable used.  Fixed bug so name() allowed if *                            user specifies.
*   version 0.1      17mar2022   EMZ. Suppressed "DGM=1" from graph titles if only one dgm.
*   version 0.0      09dec2019   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the siman scatter plot


program define siman_scatter
version 15

syntax [varlist(default=none max=2)] [if][in] [, BY(varlist) BYGRaphoptions(string) name(passthru) SAVing(string) EXPort(string) debug pause *]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
    di as error "siman setup needs to be run before siman scatter"
    exit 498
}

* if estimate or se are missing, give error message as program requires them for the graph(s)
if mi("`estimate'") | mi("`se'") | "`secreated'"=="1" {
    di as error "{p 0 2}siman scatter requires both estimate and se to have been declared in siman setup{p_end}"
    exit 498
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

* mark sample
marksample touse, novarlist

/* Start preparations */

preserve

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
    di as error "{p 0 2}Warning: this 'if' condition cuts across dgm, target and method. It is safest to subset only on dgm, target and method.{p_end}"
}
drop `meantouse'

qui count if `touse' & `rep'>0
if r(N)==0 error 2000

qui keep if `touse'
* keeps estimates data only
qui drop if `rep'<0
if mi("`: variable label `estimate''") label var `estimate' "Estimates (`estimate')"
if mi("`: variable label `se''") label var `se' "Standard errors (`se')"

* if statistics are not specified, run graphs for estimate and se, otherwise run for alternative order
local error 0
if "`varlist'"=="" local varlist `se' `estimate'
else {
    local y1 : word 1 of `varlist'
    if "`y1'"=="`estimate'" local y2needed `se'
    else if "`y1'"=="`se'" local y2needed `estimate'
    else local error 1
    if "`y2'"=="" local y2 `y2needed'
    else if "`y2'"!="se" local error 1
    local varlist `y1' `y2'
}
* di as error "{p 0 2}{p_end}"
if `error' {
    di as error "{p 0 2}Syntax: siman scatter [`estimate' `se' | `se' `estimate']{p_end}"
    exit 198
}

* For the purposes of the graphs below, if dgm is missing in the dataset then set
* the number of dgms to be 1.
if mi("`dgm'") {
    qui gen dgm = 1
    local dgm "dgm"
    local ndgmvars 1
    local dgmcreated 1
}
else local dgmcreated 0

* create by if missing
if mi("`by'") {
    if !`dgmcreated' local by0 `by0' `dgm'
    local by0 `by0' `target' 
    if !`methodcreated' local by0 `by0' `method'
    foreach thisby of local by0 {
        qui levelsof `thisby', `dgmmissingok'
        if r(r)>1 local by `by' `thisby'
    }
}

* count panels
if mi("`by'") { // i.e. if none of dgm target method varies
    local byoption `bygraphoptions'
    local npanels 1
}
else {
    local byoption by(`by', note(,pos(11)) `bygraphoptions' `dgmmissingok') 
    * count how many panels will be created
    tempvar unique
    egen `unique' = tag(`by'), `dgmmissingok'
    qui count if `unique'
    local npanels = r(N)
    drop `unique'
}

di as text "siman scatter will draw " as result 1 as text " graph with " as result `npanels' as text " panels"
if `npanels' > 15 {
    di as smcl as text "{p 0 2}Consider reducing the number of panels using 'if' condition or 'by' option{p_end}"
}

if mi("`name'") local name name(scatter, replace)
if !mi("`saving'") local savingopt saving(`"`saving'"'`savingopts')

local graph_cmd twoway scatter `varlist' `if', msym(o) msize(small) mcol(%30) `byoption' `name' `savingopt' `options'

if !mi("`debug'") di as input "Debug: graph command is: " as input `"`graph_cmd'"'
if !mi("`pause'") {
    global F9 `graph_cmd'
    pause Press F9 to recall, optionally edit and run the graph command
}
`graph_cmd'

if !mi("`export'") {
    local graphexportcmd graph export `"`saving'.`exporttype'"'`exportopts'
    if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
    cap noi `graphexportcmd'
    if _rc di as error "Error in export() option"
    exit _rc
}

end
