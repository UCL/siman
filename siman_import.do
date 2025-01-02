/* 
Demonstration of siman import
The easy way: expect the user to convert the data to long
IW 28oct2024
*/

prog drop _all

use "C:\ian\git\siman\testing\data\res.dta", clear
l if theta==1 & tau2==0 & k==5 & pc==2 & rho==3

local dgmvars theta tau2 k pc rho
local methodvals fem rem mh peto g2 limf limr peters expect trimfill sfem srem // not needed
local pmtarg exp mse cov bias var2 // combines target and PM, I think

* reshape long-long
reshape long `pmtarg', i(`dgmvars') j(method) string
rename (`pmtarg') (est=)
reshape long est, i(`dgmvars' method) j(_perfmeascode) string

* extract target and PM
gen target = cond(_perfmeascode=="var2",2,1)
replace _perfmeascode = "cover" if _perfmeascode=="cov"
replace _perfmeascode = "mean" if inlist(_perfmeascode, "exp", "var2")

* import
siman_import, dgm(theta tau2 k pc rho) target(target) method(method) estimate(est) perf(_perfmeascode)

* has it worked?
siman des

siman table if theta==1 & tau2==0 & k==5 & pc==2 & rho==3, column(_perfmeas target)

siman nes mean if target==1 & inlist(method,"peto" ,"g2")
