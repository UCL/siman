*! version 0.1 IRW 21dec2021
* it would be helpful to use findfile to find the help file
* at present you have to give the full path
prog def runhelpfile
syntax using, [skip(string) debug]
cap file close myfile
file open myfile `using', read
file read myfile myline
while !r(eof) {
	if !mi("`debug'") di as input `"Read line: `myline'"'
	local colstart = strpos(`"`myline'"', `"{stata"' ) 
	if `colstart'==0 local myline
	else local myline = substr(`"`myline'"', `colstart'+6, .)
	local colend = strpos(`"`myline'"', `"}"' ) 
	if `colend'==0 local myline
	else local myline = substr(`"`myline'"', 1, `colend'-1)
	local myline `myline'
	local skipit no
	if !mi(`"`myline'"') {
		local cmd = word(`"`myline'"',1)
		foreach skipcmd of local skip {
			if "`cmd'"=="`skipcmd'" local skipit yes
		}
		if "`skipit'"=="yes" {
			di as input `"Skipping command: `myline'"'
		}
		else {
			di as input `"Running command: `myline'"'
			`myline'
		}
	}
	file read myfile myline
}
end
	
