/*
run_all_tests.do
siman overarching testing program
IW 19dec2023
*/

global codepath C:\git\siman 

// SETUP FOR ALL USERS
global testpath $codepath\Ella_testing\
adopath ++ $codepath

// add log files for these

do "Testing error messages.do" // run by hand?
do "Testing estimates graphs.do"
do test_siman_widelong_EMZ.do 


// make log files text nomsg

do Testing_IRW_TPM_EMZ.do
do siman_lollyplot_test.do
do siman_nestloop_test.do
do testing_graphs_main.do
do testing_graphs_matrix.do

global codepath
global testpath

di as result "*** SIMAN HAS PASSED ALL THE TESTS ***"
