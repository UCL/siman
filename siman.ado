*! version 0.1 28nov2022
prog def siman
/*
adapted from network.ado
IW 17sep2019
*/
version 13
syntax [anything] [if] [in], [which *]

// LOAD SAVED SIMAN PARAMETERS
foreach thing in `_dta[siman_allthings]' {
	local `thing' : char _dta[siman_`thing']
}

// Known siman subcommands
* subcmds requiring data not to be set
local subcmds0 setup 
* subcmds requiring data to be set
local subcmds1 describe analyse table reshape lollyplot zipplot comparemethodsscatter blandaltman swarm scatter nestloop trellis
* subcmds not minding whether data are set
local subcmds2 
* all known subcommands
local subcmds `subcmds0' `subcmds1' `subcmds'

// check a subcommand is given
if mi("`anything'") {
	di as error "Syntax: siman <subcommand>"
	exit 198
}

// "which" option
if "`anything'"=="which" {
	which siman
	foreach subcmd of local subcmds {
		cap noi which siman_`subcmd'
	}
	exit
}

// Parse current subcommand
gettoken subcmd rest : anything

// Identify abbreviations of known subcommands
if length("`subcmd'")>=3 {
	foreach thing in `subcmds' {
		if strpos("`thing'","`subcmd'")==1 {
			local subcmd `thing'
			local knowncmd 1
		}
	}
}

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
	
if mi(`"`options'"') siman_`subcmd' `rest' `if' `in'
else                 siman_`subcmd' `rest' `if' `in', `options'
end
