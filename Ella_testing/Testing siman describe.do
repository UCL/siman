* Testing siman outputs (siman_describe table)

cd N:\My_files\siman\Ian_example\

log using testing_simandescribe.log, replace


* Format 1: Long-long
***********************
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide  
siman_reshape, longlong                   


use long_long_formats\simlongESTPM_longE_longM1.dta, clear
siman_setup, rep(repit) dgm(d) target(estim) method(meth) estimate(est_data) se(se_data) 
siman_reshape, longwide  
siman_reshape, longlong

use long_long_formats\estimates.dta, clear
siman_setup, rep(idrep) dgm(dgm) method(method) estimate(theta) se(se)  
siman_reshape, longwide  
siman_reshape, longlong

* no estimate data
use long_long_formats\simlongESTPM_longE_longM_noest.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) true(true)


* Format 2: Wide-wide
***********************
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method)   
siman_reshape, longlong                              

use wide_wide_formats\simlongESTPM_wideE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong


use wide_wide_formats\simlongESTPM_wideE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(1 2) estimate(est) se(se) true(true) order(target) 
siman_reshape, longlong                


use wide_wide_formats\simlongESTPM_wideE_wideM3.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(target) 
siman_reshape, longlong  


use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method) 
siman_reshape, longlong     


use wide_wide_formats\simlongESTPM_wideE_wideM5.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) p(p) df(df) true(true) order(method) 
siman_reshape, longlong    


* Format 3: Long-wide
***********************
use long_wide_formats\simlongESTPM_longE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est) se(se) true(true) 
siman_reshape, longlong  


use long_wide_formats\simlongESTPM_longE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est_) se(se_) true(true)  
siman_reshape, longlong    
siman_reshape, longwide                  


use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true)  
siman_reshape, longlong     


* Format 4: Wide-long
***********************

use wide_long_formats\simlongESTPM_longM_wideE.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(method) estimate(est) se(se) true(true)  
siman_reshape, longlong

use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true)  
siman_reshape, longlong                      
siman_reshape, longwide

use wide_long_formats\simlongESTPM_longM_wideE2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(1 2) method(method) estimate(est) se(se) true(true)  
siman_reshape, longlong                   

log close