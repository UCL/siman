/*
test_zipplot.do
IW 19jun2024
*/

local filename test_zipplot

prog drop _all
cd "$testpath"
cap log close
set linesize 100
graph drop _all

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg

foreach feature in dgm target method {
	local N 6
	if "`feature'"=="dgm" local N 5
	forvalues n=1/`N' {
		dicmd use data/setupdata_`feature'`n', clear
		dicmd siman zipplot, name(zipplot_`feature'`n', replace) bygr(title(Test siman zipplot using data `feature'`n'))
	}
}

// Compare zips made from se and from ci
use data/extendedtestdata, clear
siman setup, rep(re) dgm(beta pmi mech) target(esti) method(meth) estimate(b) se(se) true(true)
siman zip if mech==1 & float(pmiss)==float(0.2) & estimand=="effect", noncov(lcol(red)) cov(lcol(blue)) sca(mcol(red)) truegr(lcol(green)) bygr(row(3)) scheme(s1color) name(g1,replace)

use data/extendedtestdata, clear
gen lower=b-invnorm(.975)*se
gen upper=b+invnorm(.975)*se
drop se
siman setup, rep(re) estimate(b) dgm(beta pmi mech) target(esti) method(meth) lci(lower) uci(upper) true(true)
siman zip if mech==1 & float(pmiss)==float(0.2) & estimand=="effect", noncov(lcol(red)) cov(lcol(blue)) sca(mcol(red)) truegr(lcol(green)) bygr(row(3)) scheme(s1color) name(g2,replace)

// Check sensible answers when SE is systematically missing
// Also check saving & export
use data/simcheck.dta, clear
replace se = . if dgm=="MAR" & method==2
siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman zipplot, saving(myzip) export(tif)
cap noi siman zipplot, saving(myzip) export(tif)
assert _rc==602
siman zipplot, saving(myzip,replace) export(tif,replace)
erase myzip.gph
erase myzip.tif

// Check nosort option
siman zipplot if rep<=40 & dgm==1, nosort name(zipns,replace) coveropt(lcol(blue)) ///
	noncoveropt(lcol(red))scatteropt(mcol(black) ms(S)) bygr(row(1)) xla(-2 0 2) 

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
