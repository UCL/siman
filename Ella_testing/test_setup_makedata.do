/* 
TEST SIMAN SETUP: CREATE DATA FOR OTHER PROGRAMS
IW 11jun2024
DATA STRUCTURE
	D = beta (3, integer) pmiss (2, integer) mech (2, string)
	E - estimand (3, string)
	M - method (3, string)
*/

pda

use $testpath/data/extendedtestdata.dta, clear
* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
gen truevalue = beta if estimand == "effect"
replace truevalue = 1 if estimand == "mean0"
replace truevalue = 1 + beta if estimand == "mean1"
order beta pmiss
save c:\temp\extendedtestdata, replace
