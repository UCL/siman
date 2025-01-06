/*
test all the help file examples using my runhelpfile.ado
IW 2jan2025
*/

cd $codepath
runhelpfile using siman.sthlp	
foreach cmd in blandaltman comparemethodsscatter describe lollyplot nestloop scatter setup swarm table zipplot {
	di as input _new(3) "*** Running help file for `cmd' ***"
	runhelpfile using siman_`cmd'.sthlp	
}
* analyse help file examples aren't set up for this
