*!  version 1.0		24jul2025
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
