/*
test_swarm.do
IW 18jun2024
*/

local filename test_swarm

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
			dicmd siman swarm estimate, name(swarm_`feature'`n', replace) bygr(title(Test siman swarm using data `feature'`n'))
		}
		else di as text "Skipped (only one method)"
	}
}

siman swarm estimate, nomean mcol(red) name(g1,replace)
siman swarm se, meangr(mcol(pink)) name(g2,replace) row(3)
siman swarm estimate se, bygr(note("I've changed the note")) name(g3,replace) by(mech beta) debug
foreach graph in g1_estimate g2_se g3_estimate g3_se {
	qui graph describe `graph'
}


di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
