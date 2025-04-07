*!	version 0.11.2	15jan2025
*!	Type -siman which- to see versions of siman's subprograms
* version 0.10 25jul2024  IW parsing doesn't break -siman cms se- or -siman anal,repl-
* version 0.9  14jun2024  IW remove reshape
* version 0.3  08aug2023  EMZ allow analyze spelling
* version 0.2  27mar2023
* version 0.1  28nov2022
program define siman
/*
adapted from network.ado
IW 17sep2019
*/
version 15
gettoken subcmd 0 : 0, parse(" ,")
if "`subcmd'"=="cms" local subcmd comparemethodsscatter
if "`subcmd'"=="comparemethodscatter" local subcmd comparemethodsscatter
syntax [anything] [if] [in], [which *]

// LOAD SAVED SIMAN PARAMETERS
foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
}

// Known siman subcommands
* subcmds requiring data not to be set
local subcmds0 setup 
* subcmds requiring data to be set
local subcmds1 describe analyse analyze table scatter comparemethodsscatter swarm blandaltman zipplot lollyplot nestloop
* subcmds not minding whether data are set
local subcmds2 
* all known subcommands
local subcmds `subcmds0' `subcmds1' `subcmds'

// check a subcommand is given
if mi("`subcmd'") {
	di as error "Syntax: siman <subcommand>"
	exit 198
}

// "which" option
if inlist("`subcmd'", "which", "whic", "whi") {
	which siman
	foreach subcmd of local subcmds {
		if "`subcmd'"=="analyze" continue
		cap noi which siman_`subcmd'
	}
	exit
}

// Identify abbreviations of known subcommands
if length("`subcmd'")>=3 {
	foreach thing in `subcmds' {
		if strpos("`thing'","`subcmd'")==1 {
			local subcmd `thing'
			local knowncmd 1
		}
	}
}

* Allow analyze spelling
if "`subcmd'" == "analyze" local subcmd "analyse"

// Check it's a valid subcommand
cap which siman_`subcmd'
if _rc {
	di as error "`subcmd' is not a valid siman subcommand"
	if length("`subcmd'")<3 di as error "Minimum abbreviation length is 3"
	exit 198
}

// For known commands, check data correctly unset/set
local type0 : list subcmd in subcmds0
if `type0' & !mi("`allthings'") {
	di as error "Data are already in siman format"
	exit 459
}
local type1 : list subcmd in subcmds1
if `type1' & mi("`allthings'") {
	di as error "Data are not in siman format: use siman setup"
	exit 459
}
	
siman_`subcmd' `0'
end
