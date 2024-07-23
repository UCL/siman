/*
test_lollyplot.do
IW 23jun2024
*/

local filename test_lollyplot

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
		if `: char _dta[siman_nummethod]' > 1 {
			dicmd siman analyse
			dicmd siman lollyplot, name(lollyplot_`feature'`n', replace) bygr(note(Test siman lollyplot using data `feature'`n')) legend(row(1)) 
		}
		else di as text "Skipped (only one method)"
	}
}

siman lollyplot bias mean cover power if mech==2, legend(row(1)) name(i1,replace)
siman lollyplot bias mean cover power if mech==2, legend(row(1)) name(i2,replace) nodrop
siman lollyplot bias mean cover power, legend(row(1)) name(i3,replace) labf(%6.3f %6.0f)

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
