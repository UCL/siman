/*
test_lollyplot.do
IW 29jul2024
NB includes some pause points when graphs or output need to be checked
*/

local filename test_lollyplot

prog drop _all
cd $testpath
cap log close
set linesize 100
graph drop _all

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg

// STANDARD TESTS
foreach feature in dgm target method {
	local N 6
	if "`feature'"=="dgm" local N 5
	forvalues n=1/`N' {
		dicmd use data/setupdata_`feature'`n', clear
		if `: char _dta[siman_nummethod]' > 1 {
			dicmd siman analyse
			siman table
			dicmd siman lollyplot, name(lollyplot_`feature'`n', replace) bygr(note(Test siman lollyplot using data `feature'`n')) legend(row(1)) 
		}
		else di as text "Skipped (only one method)"
	}
}

// CODE FROM OLD SIMAN_LOLLYPLOT_TEST.DO
local i 0

// ONE DGMVAR
* multiple targets
use $testpath/data/simlongESTPM_longE_longM.dta, clear
foreach var in rep dgm estimand method est se true {
	rename `var' my`var'
}
siman setup, rep(myrep) dgm(mydgm) target(myestimand) method(mymethod) ///
	estimate(myest) se(myse) true(mytrue)
siman analyse
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)
siman lol bias relprec power cover if myesti=="gamma", refpower(10) name(l`++i', replace)

* no target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman analyse
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)


// COMPARE METHOD AS UNLABELLED/LABELLED NUMERIC OR STRING

* method is numeric unlabelled
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse
siman lol bias relprec power cover, refpower(10) name(munlabelled,replace)

* method is numeric labelled
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
label def method 1 "1good" 2 "2bad"
label val method method
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse
siman lol bias relprec power cover, refpower(10) name(mlabelled,replace)

* method is string
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
gen methchar = cond(method==1,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
siman analyse
siman lol bias relprec power cover, refpower(10) name(mstring,replace) 
graph export mstring.pdf, replace
** NB name(string) gives funny error

* method is not 1...
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
replace method = method+1
gen methchar = cond(method==2,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
siman analyse
siman lol bias relprec power cover, refpower(10) name(mstringplus,replace) 
* graph should be same as mstring
graph export mstringplus.pdf, replace
!fc mstring.pdf mstringplus.pdf > result
type result
* Check "no differences encountered" above

* method orderings disagree: numeric ordering should be used
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
label def method 1 "good" 2 "bad"
label val method method
drop esti 
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse
siman lol bias relprec power cover, refpower(10) name(mstringrev,replace) 
* graph should be same as mstring
graph export mstringrev.pdf, replace
!fc mstring.pdf mstringplus.pdf > result
type result
* Check "no differences encountered" above
foreach file in mstring.pdf mstringplus.pdf mstringrev.pdf result {
	erase `file'
}

// RESTRICTING METHODS
use $testpath/data/extendedtestdata.dta, clear
sencode met, replace
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman lol if esti=="effect" & float(beta)==float(0) & float(pmiss)==float(0.2), name(meth3,replace) legend(row(1)) col(red blue green) debug
siman lol if esti=="effect" & float(beta)==float(0) & float(pmiss)==float(0.2) & meth!=1, name(meth2,replace) legend(row(1)) col(blue green) debug
* Compare graphs meth3 and meth2

// MULTIPLE DGMVARS
use $testpath/data/extendedtestdata.dta, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)

siman analyse
siman lol bias relprec power cover if float(beta)==float(0.5), labformat(none) ///
	refpower(90) dgmwidth(35) pmwidth(20) legend(col(1)) name(l`++i', replace) ///
	saving(mylolly, replace) export(pdf, replace)
foreach target in effect mean0 mean1 {
	erase mylolly_`target'.gph
	erase mylolly_`target'.pdf
}

* finish with a high quality graph
siman lol bias relprec power cover if float(beta)==float(0.5) & esti=="effect", ///
	legend(row(1)) name(l`++i', replace) col(red green blue) ///
	bygr(note(Good lollyplot for estimand effect) title(,size(medium))) ///
	labf(%6.3f %6.0f)

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
