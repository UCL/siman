/*
test all the help files using my runhelpfile.ado
IW 2jan2025
*/

runhelpfile using siman.sthlp	
foreach cmd in blandaltman comparemethodsscatter describe lollyplot nestloop scatter setup swarm table zipplot {
	di as input _new(3) "*** Running help file for `cmd' ***"
	runhelpfile using siman_`cmd'.sthlp	
}
* analyse isn't set up for this
