/*
test all the help file examples using my runhelpfile.ado
IW 2jan2025
*/

cd "$codepath"
runhelpfile using siman.sthlp	
foreach cmd in blandaltman comparemethodsscatter describe lollyplot nestloop scatter setup swarm table zipplot {
	di as input _new(3) "*** Running help file for `cmd' ***"
	runhelpfile using siman_`cmd'.sthlp	
}
* analyse help file examples aren't set up for this

* erase files created by help lollyplot and others
foreach file in mylolly_beta.gph  mylolly_gamma.gph mylolly_beta.jpg  mylolly_gamma.jpg mycms_1.gph mycms_1.pdf mycms_2.gph mycms_2.pdf mycms_3.gph mycms_3.pdf my_effect_relerror.gph my_effect_relerror.pdf my_mean0_relerror.gph my_mean0_relerror.pdf my_mean1_relerror.gph my_mean1_relerror.pdf {
	cap erase `file'
}

