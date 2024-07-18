/*
test_scatter.do
IW 18jun2024
*/

local filename test_scatter

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

foreach feature in dgm target method {
	local N 6
	if "`feature'"=="dgm" local N 5
	forvalues n=1/`N' {
		dicmd use data/setupdata_`feature'`n', clear
		siman scatter, name(scatter_`feature'`n', replace) bygr(title(Test siman scatter using data `feature'`n'))
	}
}

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
