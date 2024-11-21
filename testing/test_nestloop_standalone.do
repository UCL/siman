/*
Test file for stand-alone nestloop.ado
test_nestloop_standalone.do
IW 21nov2024
*/

pda

use $testpath/data/res.dta, clear
drop v1
order theta rho pc tau2 k 
reshape long exp mse cov bias var2, i(theta rho pc tau2 k) j(method) string
* draw nestloop for 9 methods and 4*3*4*4*4 dgms
nestloop exp, descriptors(theta rho pc tau2 k) method(method) true(theta) legend(row(2)) dgsize(.25)
