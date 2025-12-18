*!  version 1.1		18dec2025
*  version 1.1		18dec2025	resubmit to SJ
*  version 1.0		24jul2025	submit to SJ
/*
Undocumented utility to clear all characteristics set by -siman-
IW 27mar2025
*/
prog def siman_unset
local allthings : char _dta[siman_allthings]
foreach thing in `allthings' {
    char _dta[siman_`thing']
}
end
