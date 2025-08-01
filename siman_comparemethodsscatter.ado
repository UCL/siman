*!  version 1.0		24jul2025
*   version 0.11.6   05jun2025    IW add pause option
*   version 0.11.5   06jan2025   IW new collapse() option
*   version 0.11.4   11nov2024   IW correct handling of aspect()
*   version 0.11.3   29oct2024   IW/TM aspect(1) not suppressed by other subgraphoptions
*   version 0.11.2   24oct2024   handle extra variables by using keep before reshape
*   version 0.11.1   21oct2024   IW implement new dgmmissingok option
*   version 0.10.1   08aug2024   IW Tidy up graph titles
*   version 0.10     25jun2024   IW Better handling of if/in, reshape; simplified loop over graphs
*   version 0.9.19   02may2024   IW allowed xsize() to be user-specified (ysize already is)
*   version 0.9.18   25oct2023   IW removed space before comma in note
*   version 0.9.17   16oct2023   EMZ produce error message if >=, <= or methlist(x/y) is used.
*   version 0.9.16   03oct2023   EMZ updates: don't allow 'by' option as will just print blank graphs in the grid (previously only allowed for by(target)). User
*                                should just use 'if' condition to subset.  Fix when if == target and warning messages
*   version 0.9.15   02oct2023   EMZ bug fix so graphs not displayed >1 time when by(dgm) used
*   version 0.9.14   12sep2023   EMZ correction to labels for methlist when method is a numeric string labelled variable
*   version 0.9.13   05sep2023   EMZ minor bug fix to prevent double looping
*   version 0.9.12   07aug2023   EMZ further minor formatting bug fixes: metlist
*   version 0.9.11   18jul2023   EMZ minor formatting bug fixes from IW testing
*   version 0.9.10   10jul2023   EMZ change so that one graph is created for each target level and dgm level combination, with a warning if high number of 
*                                graphs.
*   version 0.9.9    20jun2023   EMZ fix for when target is missing, update to note.
*   version 0.9.8    19jun2023   EMZ minor bug fix for numeric targets with string labels and long dgm names.  Small format to note.
*   version 0.9.7    14jun2023   TPM systematically went through indenting; moved some twoway options from layer-specific to general
*   version 0.9.6    12jun2023   EMZ change to split out graphs by target as well as dgm by default. 
*   version 0.9.5    30may2023   EMZ minor formatting as per IRW/TPM request i.e. dgm_var note, title and axis changes, fixed bug with 'if' statement when 
*                                string method
*   version 0.9.4    09may2023   EMZ minor bug fix: now working when method numeric with string labels and dgm defined by >1 variable
*   version 0.9.3    13mar2023   EMZ minor update to error message
*   version 0.9.2    06mar2023   EMZ fixed when method label numerical with string labels, issue introduced from of siman describe change
*   version 0.9.1    02mar2023   EMZ bug fix when subgraphoptions used, all constituent graphs were drawn, now fixed
*   version 0.9      23jan2023   EMZ bug fixes from changes to setup programs 
*   version 0.8      10oct2022   EMZ added to code so now allows graphs split out by every dgm variable and level if multiple dgm variables declared.
*   version 0.7      05sep2022   EMZ added additional error message
*   version 0.6      01sep2022   EMZ fixed bug to allow scheme to be specified
*   version 0.5      14jul2022   EMZ fixed bug to allow name() in call
*   version 0.4      30jun2022   EMZ minor formatting of axes from IW/TM testing
*   version 0.3      28apr2022   EMZ bug fix for graphing options
*   version 0.2      24mar2022   EMZ changes from IW testing
*   version 0.1      06dec2021   EMZ changes (bug fix)
*   version 0.0      25Nov2019   Ella Marley-Zagar, MRC Clinical Trials Unit at UCL. Based on Tim Morris' simulation tutorial do file.
* File to produce the siman comparemethodsscatter graph
******************************************************************************************************************************************************

program define siman_comparemethodsscatter
version 15

syntax [anything] [if][in] [, COMbine MATrix COLLapse(varlist) /// main options
    METHlist(string) noEQuality SUBGRaphoptions(string) * /// graph options
    name(string) SAVing(string) EXPort(string) /// standard options handled differently
    half debug pause /// undocumented options
    ]

foreach thing in `_dta[siman_allthings]' {
    local `thing' : char _dta[siman_`thing']
}

if "`setuprun'"!="1" {
    di as error "siman setup needs to be run first."
    exit 498
}

* parse statistics
foreach thing of local anything {
    if substr("estimate",1,length("`thing'")) == substr("`thing'",1,length("`thing'")) local thing estimate
    if substr("se",1,length("`thing'")) == substr("`thing'",1,length("`thing'")) local thing se
    if ("`thing'"!="estimate" & "`thing'"!="se") {
        di as error "only estimate or se allowed"
        exit 498
    }
    if mi("``thing''") {
        di as error "`thing'() was not specified in siman setup"
        exit 498
    }
    local statlist `statlist' `thing'
}
* default is set later, once #methods is known

if !mi("`debug'") local dicmd dicmd

if strpos(`"`subgraphoptions'"',"aspect(")==0 & strpos(`"`subgraphoptions'"',"aspectratio(")==0 local subgraphoptions aspect(1) `subgraphoptions'
local subgraphoptions graphregion(margin(zero)) plotregion(margin(zero)) `subgraphoptions'

if !mi("`matrix'") & !mi("`combine'") {
    di as error "Can't have both matrix and combine"
    exit 498
}

* parse name
if !mi(`"`name'"') {
    gettoken name nameopts : name, parse(",")
    local name = trim("`name'")
}
else {
    local name cms
    local nameopts , replace
}
if wordcount("`name'_something")>1 {
    di as error "Something has gone wrong with name()"
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

*** START ANALYSIS ***

* mark sample
marksample touse, novarlist

/* Approach is:
code methods as 1,2,... with names in locals mlabel1,mlabel2,...
reshape methods as wide
looping over dgm and target:
    if not matrix (default for 2 or 3 methods):
        draw graphs for diagonal
        draw graphs for off-diagonal, est and se
        combine
    if matrix (default for >3 methods):
        call graph matrix, est or se
*/

preserve

if "`analyserun'"=="1" {
    * keep estimates data only
    qui drop if `rep'<0
    drop _dataset _perfmeascode
}

* check if/in conditions
tempvar meantouse
egen `meantouse' = mean(`touse'), by(`dgm' `target' `method')
cap assert inlist(`meantouse',0,1)
if _rc {
    di as error "{p 0 2}Warning: this 'if' condition cuts across dgm, target and method. It is safest to subset only on dgm, target and method.{p_end}"
}
drop `meantouse'

* do if/in
qui keep if `touse'
if _N==0 error 2000
drop `touse'

* HANDLE METHODS
* only analyse the methods that the user has requested
* in preparation for method going wide:
*   recode method as 1..`nmethods' 
*   store method names as `mlabel1' etc
if mi("`methlist'") { // default methlist is all methods left by -if-
    qui levelsof `method', local(methlist)
}
else { // allow methlist(numlist)
    cap numlist "`methlist'"
    if !_rc local methlist = r(numlist)
}
if !mi("`debug'") di as input `"Debug: methlist = `methlist'"'

* count methods & choose type
local nmethods : word count `methlist'
if `nmethods' < 2 {
    di as error "{p 0 2}siman comparemethodsscatter requires at least 2 methods to compare{p_end}"
    exit 498
}
local type `matrix' `combine'
if mi("`type'") local type = cond(`nmethods'>3, "matrix", "combine")
if mi("`statlist'") {
    if mi("`se'") local statlist estimate 
    else if "`type'"=="combine" local statlist estimate se
    else if "`type'"=="matrix" local statlist estimate
}
local nstats : word count `statlist'
if "`type'"=="matrix" & `nstats'>1 {
    local ignored : word 2 of `statlist'
    local statlist : word 1 of `statlist'
    di as text "Matrix method can't display both estimate and se: ignoring `ignored'"
    local nstats 1
}
if !mi("`debug'") di as input "Debug: statlist = `statlist'"
local do_se = strpos("`statlist'","se")>0
local do_estimate = strpos("`statlist'","estimate")>0
if "`type'"=="combine" {
    if !`do_se' & !mi("`se'") di as text "Standard error not included in lower triangle (by request)"
    if !`do_se' & mi("`se'") di as text "Standard error not included in lower triangle (not available)"
    if !`do_estimate' di as text "Estimate not included in upper triangle (by request)"
}

tempvar newmethod
qui generate `newmethod' = .
forvalues i=1/`nmethods' {
    local thismeth : word `i' of `methlist'
    if `methodnature'==0 { // unlabelled numeric
        qui replace `newmethod' = `i' if `method' == `thismeth'
        local mlabel`i' `thismeth'
    }
    else if `methodnature'==1 { // labelled numeric
        qui replace `newmethod' = `i' if `method' == `thismeth'
        local mlabel`i' : label (`method') `thismeth'
    }
    else if `methodnature'==2 {
        qui replace `newmethod' = `i' if `method' == "`thismeth'"
        local mlabel`i' `thismeth'
    }
}
qui keep if !mi(`newmethod')

if `nmethods' > 5 {
    di as smcl as text "{p 0 2}Warning: with `nmethods' methods compared, this plot may be too dense to read.  If you find it unreadable, you can choose the methods to compare using -siman comparemethodsscatter, methlist(a b)- where a and b are the methods you are particularly interested to compare.{p_end}"
}

// RESHAPE METHODS TO WIDE
keep `estimate' `se' `dgm' `target' `rep' `newmethod' `true' 
    // drop doesn't work now that extra variables are allowed
qui reshape wide `estimate' `se', i(`dgm' `target' `rep') j(`newmethod')
if !mi("`debug'") di as input "Debug: reshape successful"


* IDENTIFY 'OVER' VARIABLE
local allvars `dgm' `target' 
local over : list allvars - collapse
local ouch : list collapse - allvars
if !mi("`ouch'") {
    di as error "collapse() variable(s) are not in dgm or target: `ouch' "
    exit 498
}
local over2 = cond(mi("`over'"),"[nothing]","`over'")
if !mi("`debug'") di as input "Debug: Graphing over `over2' and by `method'"
local novers : word count `over'

tempvar group
qui egen `group' = group(`over'), label `dgmmissingok'
qui tab `group'
local ngraphs = r(r)

* report graphs to be drawn
if `ngraphs'>1 local sg "s each"
di as text "siman comparemethodsscatter will draw " as result `ngraphs' as text " graph`sg' showing " as result `nmethods' as text " methods"
if `ngraphs' > 3 {
    di as smcl as text "{p 0 2}Consider reducing the number of graphs using 'if' condition{p_end}"
}


* DRAW GRAPH(S)

forvalues g = 1/`ngraphs' {
    local glabel : label (`group') `g'

    * nice label for this over-group
    local notetext
    forvalues v=1/`novers' {
        local thisvar : word `v' of `over'
        local thisval : word `v' of `glabel'
        if `v'>1 local notetext `notetext',
        local notetext `notetext' `thisvar'=`thisval'
    }
    if !mi("`notetext'") local notetextopt note("Graphs for `notetext'") 
    else local notetextopt 
    di as text `"Graph "' as result `"`name'_`g'"' as text `" is for "' as result `"`notetext'"' _c
    if !mi("`collapse'") di `", collapsing over `collapse'"' _c
    di

    if !mi("`saving'") local savingopt saving(`"`saving'_`g'"'`savingopts')

    if "`type'"=="combine" {

        * prepare
        local graphlist
        forvalues j = 1/`nmethods' { // min/max
            foreach stat of local statlist {
                summ ``stat''`j' if `group'==`g', meanonly
                local min`stat'`j'=r(min)
                local max`stat'`j'=r(max)
            }
        }
        if !`do_se' | !`do_estimate' { // create an empty graph
            `dicmd' twoway scatteri 0 0 (0) " " , ///
                ytit("") ylab(none) yscale(lstyle(none) range(-1 1)) ///
                xtit("") xlab(none) xscale(lstyle(none) range(-1 1)) ///
                msym(i) mlabs(vlarge) mlab(black) ///
                plotregion(style(none)) legend(off) ///
                `subgraphoptions' nodraw name(emptygraph, replace) 
        }
        if `do_se' local setitle l2title(Standard error (`se'), just(left) bexpand)
        if `do_estimate' local esttitle r2title(Estimate (`estimate'), just(left) bexpand orient(rvertical))

        * loop over constituent graphs
        forvalues j = 1/`nmethods' { // rows
            forvalues k = 1/`nmethods' { // cols
                
                if `j'==`k' { // GRAPHS ON DIAGONAL SHOW VARIABLE NAMES ONLY
                    `dicmd' twoway scatteri 0 0 (0) "`mlabel`j''" , ///
                        ytit("") ylab(none) yscale(lstyle(none) range(-1 1)) ///
                        xtit("") xlab(none) xscale(lstyle(none) range(-1 1)) ///
                        msym(i) mlabs(vlarge) mlab(black) ///
                        plotregion(style(none)) legend(off) ///
                        `subgraphoptions' nodraw name(graph`j'`k', replace) 
                }
                else if (`j'>`k' & !`do_se') | (`j'<`k' & !`do_estimate') {
                    local graphlist `graphlist' emptygraph
                    continue
                }
                else {
                    // GRAPHS ABOVE/BELOW DIAGONAL SCATTERPLOT ESTIMATE/SE
                    local stat = cond(`j'>`k', "se", "estimate")
                    local min=min(`min`stat'`j'',`min`stat'`k'')
                    local max=max(`max`stat'`j'',`max`stat'`k'')
                    if "`equality'"=="noequality" local eqgraph
                    else local eqgraph (function x, range(`min' `max') sort lcolor(gs10))
                    `dicmd' twoway ///
                        (scatter ``stat''`j' ``stat''`k' if `group'==`g', ///
                            ms(o) mlc(white%1) msize(tiny) ///
                            `subgraphoptions' nodraw) ///
                        `eqgraph' /// line of equality
                        , xtitle("") ytitle("") legend(off) ///
                        name(graph`j'`k', replace) // scatterplot of methods
                }
                local graphlist `graphlist' graph`j'`k'
            }
        }
		local graph_cmd graph combine `graphlist', name(`name'_`g'`nameopts') `savingopt' ///
            `notetextopt' title("") cols(`nmethods') `esttitle' `setitle' ///
            `options'  
		if !mi("`pause'") {
			global F9 `graph_cmd'
			pause Press F9 to recall, optionally edit and run the graph command
		}
        `dicmd' cap noi `graph_cmd'
        if _rc {
            if _rc!=1 di as error `"{p 0 2}siman comparemethodsscatter called graph combine, which failed with error "' _rc ". {p_end}"
            if _rc==111 di as error `"Try {stata "serset clear"} and {stata "graph drop _all"}"'
            if _rc==198 & !mi(`"`options'"') di as error `"{p 0 2}Were options -`options'- correct?{p_end}"'
            exit _rc
        }
        
        * drop constituent graphs - need capture since there may be duplicates
        foreach graph of local graphlist {
            cap graph drop `graph'
        }
    }

    else { // type = matrix
        local varlist
        forvalues j = 1/`nmethods' {
            local varlist `varlist' ``statlist''`j'
            label var ``statlist''`j' "`mlabel`j''"
        }
        local graph_cmd graph matrix `varlist' if `group'==`g', `half' title("") note("") ///
            ms(o) mlc(gs10) msize(tiny) ///
            name(`name'_`g',replace) `savingopt' note("Graphs for stat=`statlist', `notetext'") ///
            `options'
		if !mi("`pause'") {
			global F9 `graph_cmd'
			pause Press F9 to recall, optionally edit and run the graph command
		}
		`dicmd' `graph_cmd'
    }

    if !mi("`export'") {
        local graphexportcmd graph export `"`saving'_`g'.`exporttype'"'`exportopts'
        if !mi("`debug'") di as input `"Debug: `graphexportcmd'"'
        cap noi `graphexportcmd'
        if _rc di as error "Error in export() option"
        exit _rc
    }

}

end


program define dicmd
noi di as input `"Debug: `0'"'
`0'
end
