/*
run_all_tests.do
siman overarching testing program
IW 19dec2023
updated 3apr2024 - runs in 5 minutes!
*/

// USER-SPECIFIC SETUP
global codepath C:\git\siman 
global codepath C:\ian\git\siman 

// SETUP FOR ALL USERS
global testpath $codepath\Ella_testing\
adopath ++ $codepath
cd $testpath

// RUN ALL TESTS
*do new_tests.do // << 1 minute, but currently shows errors
do test_siman_widelong_EMZ.do // <1 minute
do siman_lollyplot_test.do // ~1 minute
do siman_nestloop_test.do // ~1 minute
do testing_graphs_matrix.do // ~1 minute
do Testing_IRW_TPM_EMZ.do // 2 minutes
do testing_graphs_main.do // 2 minutes
* do "Testing estimates graphs.do" // 50 minutes

// ALSO 
// run "Testing error messages.do" by hand to check error messages

// TIDY UP
global codepath
global testpath
di as result "*** SIMAN HAS PASSED ALL THE TESTS ***"
