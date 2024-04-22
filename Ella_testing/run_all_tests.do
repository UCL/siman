/*
run_all_tests.do
siman overarching testing program
IW 19dec2023
updated 3apr2024 - runs in 5 minutes!
*/

// USER-SPECIFIC SETUP
global codepath C:\git\siman 
if "$user" == "tpm" global codepath /Users/timothymorris/Documents/GitHub/siman

// SETUP FOR ALL USERS
global testpath $codepath/Ella_testing
adopath ++ $codepath
cd $testpath

// RUN ALL TESTS
do test_siman_widelong_EMZ.do // quick test from wide-long: <1 minute
do siman_lollyplot_test.do    // test lollyplot: ~1 minute
do siman_nestloop_test.do     // test nestloop: ~1 minute
do testing_graphs_matrix.do   // test setup from all formats and var types: ~1 minute
do Testing_IRW_TPM_EMZ.do     // various graph tests: 2 minutes
do testing_graphs_main.do     // test graphs from all formats and var types: 2 minutes
* do "Testing estimates graphs.do" // 50 minutes

// ALSO 
// run "Testing error messages.do" by hand to check error messages

di as result "*** SIMAN HAS PASSED ALL THE TESTS ***"
