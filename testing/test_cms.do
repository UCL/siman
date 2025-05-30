/*
test_cms.do
IW 25jun2024
Fewer graphs for faster run, 28oct2024
*/

local filename test_cms

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

foreach feature in dgm target method {
	local N 6
	if "`feature'"=="dgm" local N 5
	foreach n in 1 `N' {
		dicmd use data/setupdata_`feature'`n', clear
		if `: char _dta[siman_nummethod]' > 1 {
			dicmd siman cms estimate, name(cms_`feature'`n', replace) ///
				title(Test siman cms using data `feature'`n')
		}
		else di as text "Skipped (only one method)"
	}
}

use data/setupdata_method4, clear
siman cms if beta==0, saving(mycms) export(pdf)
erase mycms_1.gph
erase mycms_1.pdf
erase mycms_2.gph
erase mycms_2.pdf

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
