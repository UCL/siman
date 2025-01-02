* Siman analyse does have a problem: lower coverage than reported by simsum
* now solved
* But missing values in dgm are still a problem

version 16

capture log close
log using test_ovletter , replace text nomsg

* Estimates data from our letter to the editor about not fixing complete dataset
use data/est_ovletter, clear

simsum b , true(true) id(rep) method(analysis) by(dgm fixed_seed) se(se) df(df) ref("Complete data") cover


capture siman setup , rep(rep) dgm(dgm_method fixed_seed) method(analysis) ///
    estimate(b) se(se) df(df) true(true)
assert _rc==498

siman setup , rep(rep) dgm(dgm_method fixed_seed) method(analysis) ///
    estimate(b) se(se) df(df) true(true) dgmmissingok

siman analyse 

foreach prog in swarm scatter zip lol nes {
	cap noi siman `prog'
}
siman nestloop mean

log close
