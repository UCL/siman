use "https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta", clear
siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)
set scheme mrc

siman scatter

siman swarm

siman comparemethodsscatter 

siman blandaltman 

siman zipplot
