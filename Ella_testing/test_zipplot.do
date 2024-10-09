/*
test_zipplot.do
IW 19jun2024
*/

local filename test_zipplot

prog drop _all
cd $testpath
cap log close
set linesize 100
graph drop _all

// START TESTING
log using `filename', replace text nomsg
siman which

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

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
