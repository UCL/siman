* Testing siman setup, siman describe, siman reshape, siman analyse with siman table on various estimates data sets in different formats
* 08/06/2020
* Ella Marley-Zagar

clear all
prog drop _all

cd N:\My_files\siman\Ian_example\

log using test_file_for_siman_data_progs.log, replace

          
* Format 1: Long-long
***********************
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)

gen dgm_new = "1"
replace dgm_new = "2" if dgm == 2
siman_setup, rep(rep) dgm(dgm_new) target(estimand) method(method) estimate(est) se(se) true(true)
* error message as required
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong                   
siman_analyse
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_analyse, perfonly

* check that note about mcse's in siman table is not present if no mcses are reported
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)                   
siman_analyse
replace se = .
siman_table
* note is not displayed as required

* check 'if' option
* setup
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup if dgm==1, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup if estimand=="beta", rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
* analyse
siman_analyse
* the 'if' carries through from setup, with siman table using that also as required.

* check specifying a different 'if' for analyse
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup if dgm==1, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
siman_analyse if estimand=="beta"
* siman table uses the analyse 'if' too as required (i.e. dgm=1 AND estimand=beta)
* trying a different 'if' for siman table
siman_table if method==1
* yes, adds the additional criteria of method=1 to siman table as required (e.g. dgm=1 AND estimand=beta AND method=1).

* try to use an 'if' condition on rep (not allowed) in siman analyse
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup if rep==1, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
/*
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
siman_analyse if rep==1
* obtain the error message "The 'if' option can not be applied to 'rep' in siman_analyse." as required
*/

* check 'in' option
* setup
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup in 1/100, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup in 1/20, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) clear
* analyse
siman_analyse
* the 'in' carries through from setup, with siman table using that also as required.

* check siman_analyse works for specified performance measures
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)                   
siman_analyse bias empse

* missing target
* creating a data set that has long method and missing target
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong   


* missing method
* creating a data set that has long target and missing method
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop method
bysort rep dgm estimand: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) target(estimand) estimate(est) se(se) true(true)
* siman_reshape, longwide 
*gives error message as expected, as can not reshape targets to wide format.
              
* more datasets
use long_long_formats\simlongESTPM_longE_longM1.dta, clear
siman_setup, rep(repit) dgm(d) target(estim) method(meth) estimate(est_data) se(se_data)
siman_reshape, longwide
siman_reshape, longlong 
siman_analyse                             
use long_long_formats\simlongESTPM_longE_longM1.dta, clear
siman_setup, rep(repit) dgm(d) target(estim) method(meth) estimate(est_data) se(se_data)
siman_analyse, perfonly

use long_long_formats\estimates.dta, clear
siman_setup, rep(idrep) dgm(dgm) method(method) estimate(theta) se(se)
siman_reshape, longwide
siman_reshape, longlong 
siman_analyse  
siman_reshape, longwide                     
use long_long_formats\estimates.dta, clear
siman_setup, rep(idrep) dgm(dgm) method(method) estimate(theta) se(se)
siman_analyse, perfonly


* Ian's example in his testing file (missing target)
use long_long_formats\estimates.dta, clear
drop conv error
reshape wide theta se, i(idrep dgm) j(method)
siman setup, rep(idrep) dgm(dgm) method(1 2 3) est(theta) se(se) 
* is ok

* Different true values per target
use long_long_formats\simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong 

* no estimate data
use long_long_formats\simlongESTPM_longE_longM_noest.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) true(true)

* testing CIs
use long_long_formats\estimates.dta, clear
gen float lci = theta + (se*invnorm(.025))
gen float uci = theta + (se*invnorm(.975))
siman setup, rep(idrep) dgm(dgm) method(method) est(theta) se(se) lci(lci) uci(uci)
siman_reshape, longwide
siman_reshape, longlong 


* Format 2: Wide-wide
***********************
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method)   
siman_reshape, longlong
siman_reshape, longwide                
siman_reshape, longlong  
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method)    
siman_analyse                                                           
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong
siman_analyse, perfonly

* numeric true
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
drop true
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(0.5) order(method)   
siman_reshape, longlong
siman_reshape, longwide                
siman_reshape, longlong 
siman_analyse 

* missing target
* creating a data set that has wide method and missing target
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method)  
drop target
bysort rep dgm: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
* this is now like long-wide format with missing target
siman_setup, rep(rep) dgm(dgm) method(1 2) estimate(est) se(se) true(true)  
siman_reshape, longlong 
siman_reshape, longwide

* missing method
* creating a data set that has wide target and missing method
use wide_wide_formats\simlongESTPM_wideE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) true(true) order(method) 
siman_reshape, longlong 
drop method
bysort rep dgm target: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
reshape wide est se, i(rep dgm true) j(target) string
* this is now like wide-long format with missing method
siman_setup, rep(rep) dgm(dgm) target(beta gamma) estimate(est) se(se) true(true)  
* auto reshapes to long-long as required                                    
* siman_reshape, longwide
* gives error message as expected, as can not reshape targets to wide format

use wide_wide_formats\simlongESTPM_wideE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong 
siman_analyse
use wide_wide_formats\simlongESTPM_wideE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong
siman_analyse, perfonly

use wide_wide_formats\simlongESTPM_wideE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(1 2) estimate(est) se(se) true(true) order(target)
siman_reshape, longlong                    
siman_analyse
use wide_wide_formats\simlongESTPM_wideE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(1 2) estimate(est) se(se) true(true) order(target)
siman_reshape, longlong
siman_analyse,perfonly

use wide_wide_formats\simlongESTPM_wideE_wideM3.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(target)
siman_reshape, longlong
siman_analyse              
use wide_wide_formats\simlongESTPM_wideE_wideM3.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(target)
siman_reshape, longlong
siman_analyse, perfonly

* numeric true
use wide_wide_formats\simlongESTPM_wideE_wideM3.dta, clear
drop true
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(0.5) order(target)
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong
siman_analyse

use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong                
siman_analyse               
use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong
siman_analyse, perfonly

* try with different order of method variables for the following requirement:  When target or method is wide and the user has specified values in the syntax statement, 
* the order that the user has specified these values in will be preserved.  For example if the method variable takes the string values A, B, C and is in wide format, 
* we would expect the user to enter method(A B C).  However if they enter method(C B A) then this order will be shown in the output data from siman.
use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
* re-order data
order rep dgm true estB_beta seB_beta estA_beta seA_beta estB_gamma seB_gamma estA_gamma seA_gamma
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(B_ A_) estimate(est) se(se) true(true) order(method)
* method order preserved, as required.
* However if we then do:
siman_reshape, longlong
* method is listed as A then B in long format, even though the reshape command is internally specifying the values 'B A' to reshape on i.e.
* reshape long est se, i(rep dgm target) j(method "B A") string
* I can't find a way of getting Stata to list the long method values in a different order.

* try the above with a different order of target
use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
* re-order data
order rep dgm true estA_gamma seA_gamma estB_gamma seB_gamma estA_beta seA_beta estB_beta seB_beta
siman_setup, rep(rep) dgm(dgm) target(gamma beta) method(A_ B_) estimate(est) se(se) true(true) order(method)
* same issue as with method above, when target is auto-reshaped to long by siman-setup the order reverts to beta gamma in the data set.

use wide_wide_formats\simlongESTPM_wideE_wideM5.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) p(p) df(df) true(true) order(method)
siman_reshape, longlong     
siman_reshape, longwide  
siman_reshape, longlong 
siman_analyse                
use wide_wide_formats\simlongESTPM_wideE_wideM5.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1_ 2_) estimate(est) se(se) p(p) df(df) true(true) order(method)
siman_reshape, longlong
siman_analyse, perfonly

clear all
prog drop _all
* Different true values for targets
use wide_wide_formats\simlongESTPM_wideE_wideM1.dta, clear
drop true
gen true1beta = 0
gen true1gamma = 0.5
gen true2beta = 0
gen true2gamma = 0.5
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(method)
siman_reshape, longlong
siman_reshape, longwide


use wide_wide_formats\simlongESTPM_wideE_wideM2.dta, clear
drop true
gen truebeta_1 = 0
gen truegamma_1 = 0.5
gen truebeta_2 = 0
gen truegamma_2 = 0.5
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(1 2) estimate(est) se(se) true(true) order(target)
siman_reshape, longlong
siman_reshape, longwide


* testing CIs
* order = method
use long_long_formats\simlongESTPM_longE_longM1.dta, clear
gen float lci = est_data + (se_data*invnorm(.025))
gen float uci = est_data + (se_data*invnorm(.975))
reshape wide est_data se_data lci uci, i(repit d estim) j(meth) 
reshape wide est_data1 est_data2 se_data1 se_data2 lci1 lci2 uci1 uci2, i(repit d) j(estim) string
siman_setup, rep(repit) dgm(d) target(beta gamma) method(1 2) estimate(est_data) se(se_data) lci(lci) uci(uci) order(method)
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong 

* order = target
use long_long_formats\simlongESTPM_longE_longM1.dta, clear
gen float lci = est_data + (se_data*invnorm(.025))
gen float uci = est_data + (se_data*invnorm(.975))
reshape wide est_data se_data lci uci, i(repit d meth) j(estim) string
reshape wide est_databeta est_datagamma se_databeta se_datagamma lcibeta lcigamma ucibeta ucigamma, i(repit d) j(meth)
siman_setup, rep(repit) dgm(d) target(beta gamma) method(1 2) estimate(est_data) se(se_data) lci(lci) uci(uci) order(target)
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong


* Format 3: Long-wide
***********************
use long_wide_formats\simlongESTPM_longE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est) se(se) true(true)  
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong
use long_wide_formats\simlongESTPM_longE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est) se(se) true(true)  
siman_analyse
use long_wide_formats\simlongESTPM_longE_wideM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est) se(se) true(true)  
siman_analyse, perfonly

use long_wide_formats\simlongESTPM_longE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est_) se(se_) true(true)  
siman_reshape, longlong 
siman_analyse

use long_wide_formats\simlongESTPM_longE_wideM1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est_) se(se_) true(true)
siman_analyse, perfonly  
* siman_analyse, replace
* Error message as required: There are no estimates data in the data set.  Please re-load data and use siman_setup to import data.

use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true)   
siman_reshape, longlong                                                            
siman_analyse                                                                             
use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true)
siman_analyse, perfonly

* missing target
use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
drop estimand
bysort rep dgm true: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
* this is now like long-wide format with missing target  
siman_setup, rep(rep) dgm(dgm) method(A B) estimate(est) se(se) true(true)  
siman_reshape, longlong 
siman_reshape, longwide 

* missing method
use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true)   
siman_reshape, longlong 
drop method
bysort rep dgm estimand: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
* this is now like long-long format with missing method
siman_setup, rep(rep) dgm(dgm) target(estimand) estimate(est) se(se) true(true) 
* auto reshapes to long-long as required
* siman_reshape, longwide 
* gives error message as expected, as can not reshape targets to wide format

* Different true values for targets
use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
replace true=0.5 if estimand=="1"
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true)
siman_reshape, longlong
siman_reshape, longwide


* testing CIs
use long_wide_formats\simlongESTPM_longE_wideM2.dta, clear
reshape long est se, i(rep dgm estimand true) j(method A B) string
gen float lci = est + (se*invnorm(.025))
gen float uci = est + (se*invnorm(.975))
reshape wide est se lci uci, i(rep dgm estimand true) j(method) string
siman_setup, rep(rep) dgm(dgm) target(estimand) method(A B) estimate(est) se(se) true(true) lci(lci) uci(uci)
siman_analyse
* NB cover is calculated (Tim's comment, thought is wasn't)
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong


* Format 4: Wide-long
***********************
clear all
prog drop _all
use wide_long_formats\simlongESTPM_longM_wideE.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(method) estimate(est) se(se) true(true)  
siman_reshape, longlong  
siman_reshape, longwide
siman_reshape, longlong 
use wide_long_formats\simlongESTPM_longM_wideE.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta_ gamma_) method(method) estimate(est) se(se) true(true) 
siman_analyse


use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true)  
siman_reshape, longlong 
siman_analyse  

use wide_long_formats\simlongESTPM_longM_wideE2.dta, clear
siman_setup, rep(rep) dgm(dgm) target(1 2) method(method) estimate(est) se(se) true(true)  
siman_reshape, longlong  
siman_analyse 


* missing target
use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true) 
drop target
bysort rep dgm: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) method(1 2) estimate(est_) se(se_) true(true) 
siman reshape, longlong
siman reshape, longwide                                                      


* missing method
use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
drop method
bysort rep dgm: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi      
* this is now like wide-long format with missing method           
siman_setup, rep(rep) dgm(dgm) target(beta gamma) estimate(est_) se(se_) true(true) 
* auto reshapes to long-long as required
* siman_reshape, longwide
* gives error message as expected, as can not reshape targets to wide format


* Different true values
use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
drop true
gen true_beta=0
gen true_gamma=0.5
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true_) 
siman_reshape, longlong
siman_reshape, longwide


* testing CIs
use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
reshape long est_ se_, i(rep dgm method true) j(target) string
gen float lowerci = est_ + (se_*invnorm(.025))
gen float upperci = est_ + (se_*invnorm(.975))
reshape wide est_ se_ lowerci upperci, i(rep dgm method true) j(target) string
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true) lci(lowerci) uci(upperci)
siman_reshape, longlong
siman_reshape, longwide
siman_reshape, longlong
siman_analyse

use wide_long_formats\simlongESTPM_longM_wideE1.dta, clear
reshape long est_ se_, i(rep dgm method true) j(target) string
gen float lowerci = est_ + (se_*invnorm(.025))
gen float upperci = est_ + (se_*invnorm(.975))
reshape wide est_ se_ lowerci upperci, i(rep dgm method true) j(target) string
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est_) se(se_) true(true) lci(lowerci) uci(upperci)
siman_analyse


* Other checks
*****************

* Other scenarios
* Missing target AND method
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop estimand method
* siman_setup, rep(rep) dgm(dgm) estimate(est) se(se) true(true)
* error message as required: "Need either target or method variable/values specified otherwise siman setup can not determine the data format."

* checking mutliple records per rep error messages
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop method dgm
* siman_setup, rep(rep) target(estimand) estimate(est) se(se) true(true)
* error message as required: "Multiple records per rep.  Please specify method/dgm values."
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop method
* siman_setup, rep(rep) dgm(dgm) target(estimand) estimate(est) se(se) true(true)
* error message as required: "Multiple records per rep.  Please specify method values."
* NB. haven't checked the error messages for wide data as would involve having a wide data set with more than one record per rep per estimand.  Can't use
* existing data sets and reshape as records not unique within estimand so reshape command won't work.
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop estimand dgm
* siman_setup, rep(rep) method(method) estimate(est) se(se) true(true)
* error message as required: "Multiple records per rep.  Please specify target/dgm values."
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop estimand
* siman_setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
* error message as required: "Multiple records per rep.  Please specify target values."

* no data loaded
clear all
* siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
* gives error message "no variables defined (error in option rep())" which I think is ok
clear all
prog drop _all
* missing dgm
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop dgm
bysort rep estimand method: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi 
siman_setup, rep(rep) target(estimand) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong   


* missing estimate
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop est
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong

* missing se
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop se
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) true(true)
siman_reshape, longwide
siman_reshape, longlong

* removed simsumv2.ado from my directory and tried running siman_analyse:
/*
siman_analyse
gives: simsum.ado needs to be installed to run siman_analyse.
*/ 
* error message as required

* check that siman describe can read rep if it's numbers but in string format.
use long_long_formats\simlongESTPM_longE_longM.dta, clear
tostring(rep), gen(rep_new)
drop rep
siman_setup, rep(rep_new) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_analyse
* ok

* check siman_setup error message works if clear option not specified
use long_long_formats\simlongESTPM_longE_longM.dta, clear
* siman_setup if dgm==1, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
* error message given as required: "Data will be deleted, please use clear option to confirm."

* Testing user error such as entering siman setup, rep(rep) dgm(dgm) target(estimand) method(1) …  or siman setup, rep(rep) dgm(dgm) target(beta) method(method)..
* i.e. if the user has only put in 1 value for method/target then the user is implying that method/target is long and the variable name should be entered instead.
use long_long_formats\simlongESTPM_longE_longM.dta, clear
* siman_setup, rep(rep) dgm(dgm) target(estimand) method(1) estimate(est) se(se) true(true)
* error message as required: Please either put the  method variable name in siman_setup method() for long format, or the method values for wide format
* siman_setup, rep(rep) dgm(dgm) target(beta) method(method) estimate(est) se(se) true(true)
* error message as required: Please either put the target variable name in siman_setup target() for long format, or the target values for wide format

* checking siman_analyse being run twice without 'replace' option produces correct error message  
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)                  
siman_analyse
* siman_analyse
* error message as required: "There are already performance measures in the dataset.  If you would like to replace these, please use the 'replace' option"

* checking siman_analyse being run twice with 'replace' option is ok
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)                  
siman_analyse
siman_analyse, replace

* check error message if both 'method' and 'estimatemethod' are in the dataset
use long_long_formats\simlongESTPM_longE_longM.dta, clear
* just for testing
rename se estmethod
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) 
* warning message as required: Both variables method and estmethod are contained in the dataset.  Please take care when specifying the method and estimate variables in the siman setup syntax"

* check what happens if data goes from longwide to longlong and back again if have est_1 and est1 in dataset
use long_wide_formats\simlongESTPM_longE_wideM1.dta, clear
gen est1 = est_1 + 0.05
siman_setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est_) se(se_) true(true)  
siman_reshape, longlong 
siman_reshape, longwide
* siman reshape overwrites the existing est1 variable.  Is this what we want?  


* Other data formats to test performance meausres graphs provided by Ian/Tim
**********************************************************************************

use from_Tim_trellis\n500type1.dta, clear
*append using \\ad.ucl.ac.uk\home1\rmjlem1\DesktopSettings\Desktop\from_Tim_trellis\n500type2.dta
*use \\ad.ucl.ac.uk\home1\rmjlem1\DesktopSettings\Desktop\from_Tim_trellis\n500type2.dta, clear
* there are 12 methods so just keep a few for the example
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
gen dgm = 0
replace dgm = 1 if mechanism == "marw"
replace dgm = 2 if mechanism == "mcar"
label define dgmlabelvalues 0 "mars" 1 "marw" 2 "mcar"
label values dgm dgmlabelvalues
drop mechanism
siman_setup, rep(repno) dgm(beta dgm) method(method) estimate(b) se(se) df(df) true(beta)
siman_analyse


use siman_nestloop\masterresultsv2.dta, clear
keep scenariov2 severity CTE switch* treat* sfun*
merge using long_long_formats\simlongESTPM_longE_longM.dta
drop _merge scenariov2
siman_setup, rep(rep) dgm(dgm severity CTE switchproportion treateffect switcherprog sfunccomp) target(estimand) method(method) estimate(est) se(se) true(true)
* I won't run siman_analyse as it's already a performance measures data set.


use long_long_formats\estimates.dta, clear
siman_setup, rep(idrep) dgm(dgm) method(method) estimate(theta) se(se)
siman_reshape, longwide
siman_reshape, longlong


use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_reshape, longwide
siman_reshape, longlong


* importing Nick Latimers data set example with dgm descriptors.  It is a perfomance measures data set so have to make it like an estimates measures data set for siman setup
use siman_nestloop\masterresultsv2.dta, clear
keep noxoper noxopermcse ittper ittpermcse scenariov2 severity CTE switch* treateffect sfunccomp
rename scenariov2 scen
gen rep = 1
rename noxoper pernoxo
rename noxopermcse permcsenoxo
rename ittper peritt
rename ittpermcse permcseitt
siman_setup, rep(rep) dgm(scen severity CTE switchproportion switcherprog treateffect sfunccomp) method(noxo itt) estimate(per) se(permcse) 
* I won't run siman_analyse as it's already a performance measures data set.

* Combinations of #methods and #targets for testing matrix
************************************************************

* Numeric methods
*******************
cd N:\My_files\siman\Ian_example\
use bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm = 1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
tempfile origdata
save `origdata', replace
* 2 methods, true variable
drop if method>2
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 3 methods, true variable
use `origdata', clear
drop if method>3
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* > 3 methods, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 2 methods, true value
use `origdata', clear
drop if method>2
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* 3 methods, true value
use `origdata', clear
drop if method>3
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* > 3 methods, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong


* String methods
*******************
clear all
cd N:\My_files\siman\Ian_example\
use bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm=1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
drop if method>4
gen method_string = "A"
replace method_string = "B" if method == 2
replace method_string = "C" if method == 3
replace method_string = "D" if method == 4
drop method
rename method_string method
tempfile origdata
save `origdata', replace
* 2 methods, true variable
drop if method == "C" | method == "D"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 3 methods, true variable
use `origdata', clear
drop if  method == "D"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* > 3 methods, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 2 methods, true value
use `origdata', clear
drop if method == "C" | method == "D"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* 3 methods, true value
use `origdata', clear
drop if  method == "D"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* > 3 methods, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong


* Numeric targets
*******************
cd N:\My_files\siman\Ian_example\
use bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm = 1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
gen method_new = "A" if target == "beta"
replace method_new = "B" if target == "gamma"
drop target 
rename method target
rename method_new method
tempfile origdata
save `origdata', replace
* 2 targets, true variable
use `origdata', clear
drop if  target > 2
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 3 targets, true variable
use `origdata', clear
drop if target > 3
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* > 3 targets, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 2 targets, true value
use `origdata', clear
drop if  target > 2
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* 3 targets, true value
use `origdata', clear
drop if target > 3
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* > 3 targets, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong

  
* String targets
*******************
cd N:\My_files\siman\Ian_example\
use bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm = 1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
gen targetnew="A" if method ==1
replace targetnew="B" if method ==2
replace targetnew="C" if method ==3
replace targetnew="D" if method ==4
replace targetnew="E" if method ==5
replace targetnew="F" if method ==6
replace targetnew="G" if method ==7
replace targetnew="H" if method ==8
replace targetnew="I" if method ==9
replace targetnew="J" if method ==10
gen methodnew= 1 if target == "beta"
replace methodnew=2 if target == "gamma"
drop method target
rename methodnew method
rename targetnew target
tempfile origdata
save `origdata', replace
* 2 targets, true variable
use `origdata', clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 3 targets, true variable
use `origdata', clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* > 3 targets, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman reshape, longwide
siman reshape, longlong
* 2 targets, true value
use `origdata', clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* 3 targets, true value
use `origdata', clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong
* > 3 targets, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman reshape, longwide
siman reshape, longlong



log close


* TO DO: ALL
**************


* add to: list which characteristics change in reshape incl auto ones
* Siman errors: separate checking file like artbin?
* Future: simsum use mata, big collapse function could speed things up. Self-threading code: calc variance as a function.  If user specifies something that uses variance, call subroutine.  If not, doesn’t.



*************************************************************************************************************************************************************************



*********
* Notes
*********

* Underscores are removed so if have est_1 then reshape long-long back to long-wide the variable will then be est1.

* Note that if true varies by target (but not by method), then when reshaping from wide-wide to long-wide, you will have more than one true variable (truemethod1 truemethod2 etc) that are
* identical.  I haven't taken the action to delete any and just rename as 'true' because I feel this is for the user to do so if they wish.

* true has to either be 1 variable in long format (e.g. "true") or have the same format as the est, se variables etc (so if there is est1_beta ..est2_gamma then true would also need to be in the dataset as true1_beta ... true2_gamma).

* If there is more than 1 dgm, the user needs to have put the main dgm variable (containing numerical values) at the start of the dgm varlist in siman setup for it to work.

* I haven't included summary statistics in siman_describe output e.g. min, max, mean as will make table too large and unreadable, the reader can use Stata -summarize- if required.

* From the coding plan for wide-wide format: 'If method and target exist and the user does not specify their values then the program will issue an error message stating “multiple records per rep.  Please specify method and target values for 
* wide format.”'  However I don't know how to do this, as I won't know what their method and target variables/values are called so I can't sort by rep, method and target to see if there are indeed multiple records per rep.
* This also applies for the following in the coding plan (long-wide): 'If the user does not specify the method values then the program will issue an error message stating “multiple records per rep per target.  Please specify method values for wide format.”'
* I have done error checking on multiple records per rep as best I can.

* Need either a method or target otherwise siman setup will not be able to determine the data format (longlong/widewide/longwide are based on target/method combinations).

* From the coding plan for wide format we have the following requirement:  When target or method is wide and the user has specified values in the syntax statement, 
* the order that the user has specified these values in will be preserved.  For example if the method variable takes the string values A, B, C and is in wide format, 
* we would expect the user to enter method(A B C).  However if they enter method(C B A) then this order will be shown in the output data from siman.  Siman_setup does 
* preserve the order of the data values in long-wide format (e.g. method B A instead of A B), but when siman_reshape, longlong is called then method is listed as A then B, 
* even though the reshape command is internally specifying the values 'B A' to reshape on i.e.
* reshape long est se, i(rep dgm target) j(method "B A") string
* I can't find a way of getting Stata to list the long method values in a different order.
* Also if you want siman to actually internally re-order the variables then this could be very complicated as you might, say have a dataset with variables in the following order:
* rep dgm estA_beta seA_beta pe estB_beta seB_beta be run estA_gamma seA_gamma datano estB_gamma seB_gamma true
* so for this you would put method(A_ B_) into siman_setup.  If you wanted siman to rearrange the data so that when auto-transformed to long-wide you have B then A listed by typing method(B_ A_) instead to obtain:
* rep dgm target estB seB pe estA seA be run datano true 
* instead of 
* rep dgm target estA seA pe estB seB be run datano true 
* then it would be difficult to preserve the original order of the other variables and slot them in and around the reshaped re-ordered est* and se* variables. It seems to me that
* the user should import the data set in the order they require in to siman_setup, and siman_setup will then preserve this order.


* I think that the variable true needs some consideration, as in the coding plan we have 'if the true value is different for different estimands then the program will issue the following error message: “Input data format is not applicable if the true value is different for different estimands.” 
* However I believe Tim would like to allow the user to have true_beta and true_gamma etc in wide-wide format, which I have coded to allow.

* Not allowing 'if' and 'in' for siman describe as it is meant to describe the imported data (from siman setup), it does not change the data.  It doesn't make sense to then allow siman_describe to describe a subset of something other than what the data is.  If the user wants a different
* subset of the data they should import this via siman setup.

* We have the following under siman_analyse in the coding plan document: 
 /* "For the [if] option to work, a macro list of estimates data set variables and a macro of performance measures will be stored.  Then if the 
 user calls ‘if’, the program will determine whether the user is filtering by an estimates data set variable or a performance measure and will
 restrict the data set to rep<0 or >0 accordingly for the filter. After the [if] has been applied to the estimates or performance measures data set, the other unchanged data set will be appended back to the restricted data set.
 For example, if the user is applying the statement ‘if se<0.5’, the siman program would filter the data set to rep>0, restrict the data to cases where se<0.5 and 
 then append the unchanged performance data set back to the filtered estimates data set. The replace option will overwrite the existing performance measures in the data set.  If the user has created new/additional performance 
 measures but has not specified ‘replace’, an error message will be issued stating “performance measures already exist in the data set, data will not be replaced unless ‘replace’ option is specified.”*/
* However siman_analyse CREATES the performance measures, there aren't any in the data set before you call siman_analyse.  So saying -siman_analyse if cover>95- doesn't make sense as cover doesn't exist yet.  Also we say in the coding plan
* that we want to apply the condition -by `dgm' `target' `method': assert `touse'==`touse'[_n-1] if _n>1- which fails if you want to do, for exmaple, -siman_analyse if se<0.5- so I kindly need clarification on what is required for the siman analyse 'if' condition
* if it is different to what is already coded.

* If for example the dataset has: estcc estmi cc mi, and the user wanted cc and mi in long format then they would have to create 1 method variable with levels cc and mi. If they wanted wide format then they should put the est stub as est and method(cc mi) in the syntax.

* I will add the above conditions to the helpfiles once we have the final versions, as some of the above might change subject to further discussions.

*******************************
* Responses to initial testing
*******************************

* Tim: "I see that `siman_setup` immediately sets the variable specified by `rep()` to be `%43g`": I don't think is does, it reads in the varname and keeps the variable format 
*        as per the input estimates data (see example with rep as a string, siman setup keeps it that way).  I have now changed siman analyse to format rep as %43g within 
*        `siman_analyse` as per Tim's suggestion.
* Tim: "Should `siman setup` be opinionated about datatypes? I would usually want the `rep` variable as `int` (or `long` if more than 32k repetitions) but perhaps I'm unnecessarily fussy.":  I believe siman setup keeps the rep variable as
*       per the input dataset (see comment above).
* Ian: siman reshape loses value labels for method on -siman res, longwide- : not sure about this because wouldn't it anyway?  Being rehaped so method labels are used in variable names.
* Tim siman_describe: For variables that are not input, perhaps change "N/A" to "." (up to you).  I prefer N/A personally as . is not really visible in the table.
* Tim siman_analyse: For the example with CIs, `siman_analyse` didn't return coverage. I think it should, shouldn't it?  It does when there is a true value in the dataset, it doesn't for examples where there isn't.
* Ian testing notes: should true() also be an option to siman ana? I'm not sure?  True is passed through simsum in siman_analyse if it is in the dataset, and is not passed otherwise.


************************************
* Further questions to ask Ian/Tim
************************************

* Should siman_describe have original and new formats listed, or is this too messy and over-complicated?

* siman reshape doesn't like j(target valtarget).  Code is not needing it (at the moment!)

* if est and se are missing, siman analyse doesn't work as there is no varlist.  What else would simsum run on?

* When dgm has more than one variable, should the number of dgms in the output table be the total number of dgms in the data set, or the levels of the numerical dgm.  For example masterresultsv2.dta, there
* are 7 dgm variables, but the main dgm numerical variable has levels 1 and 2.  So should number of dgms be 7 or 2?  (currently it's 2). 
