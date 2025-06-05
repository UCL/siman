/*
test_graph_names.do
test name(), saving(), export() and pause options in all graph commands, according to Table 2 in siman paper
based on view_graphs.do
IW 5jun2025
*/

clear all
cd "C:\ian\git\siman\testing"
use data/extendedtestdata, clear
siman setup, rep(re) dgm(beta pmiss mech) target(estimand) method(method) estimate(b) se(se) true(true)

* remove graphs if they already exist
!del xx*.*
graph drop _all

siman describe 
pause off
siman scatter if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect", pause name(xx) saving(xx) export(jpg)
graph drop xx
erase xx.gph
erase xx.jpg

siman swarm estimate se if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect", pause name(xx) saving(xx) export(jpg)
foreach name in xx_estimate xx_se {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman zipplot if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect", pause name(xx) saving(xx) export(jpg)
graph drop xx
erase xx.gph
erase xx.jpg

siman comparemethodsscatter if float(beta)==float(0) & float(pmiss)==float(0.2) & mech==1, pause name(xx) saving(xx) export(jpg)
foreach name in xx_1 xx_2 xx_3 {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman blandaltman estimate se if float(beta)==float(0) & float(pmiss)==float(0.2) & mech==1, pause name(xx) saving(xx) export(jpg)
foreach name in xx_1_estimate xx_1_se xx_2_estimate xx_2_se xx_3_estimate xx_3_se {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman analyse 

siman lollyplot if float(beta)==float(0) & float(pmiss)==float(0.2) & estim=="effect", legend(row(1)) pause name(xx) saving(xx) export(jpg)
foreach name in xx {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman lollyplot if float(beta)==float(0) & float(pmiss)==float(0.2), legend(row(1)) pause name(xx) saving(xx) export(jpg)
foreach name in xx_effect xx_mean0 xx_mean1 {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman nestloop bias cover if estim=="effect", legend(row(1)) stagger(.05) lcol(red blue green) pause name(xx) saving(xx) export(jpg)
foreach name in xx_effect_bias xx_effect_cover {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

siman nestloop bias cover if estim!="effect", legend(row(1)) stagger(.05) lcol(red blue green) pause name(xx) saving(xx) export(jpg)
foreach name in xx_mean0_bias xx_mean0_cover xx_mean1_bias xx_mean1_cover {
	graph drop `name'
	erase `name'.gph
	erase `name'.jpg
}

ls xx*.*
