/*
run_all_tests.do
siman overarching testing program
IW 19dec2023
updated 3apr2024 - runs in 5 minutes!
11jun2024 - new test_setup programs
18-19jun2024 - add test_scatter, test_swarm, test_zipplot
24jul2024 - rename test_lollyplot & test_nestloop, add test_bland
25jul2024 - add test_cms. Tests apart from last take ~16 mins.
26jul2024 - removed "Testing estimates graphs.do", as it's slow (50 minutes) and found nothing once other tests ran successfully
*/

// USER-SPECIFIC SETUP
global codepath C:\git\siman 
if "$user"=="Ian" {
	global codepath C:\ian\git\siman 
	adopath ++ c:\ian\git\simsum\package
}
if "$user" == "tpm" & c(os)=="Windows" {
	global codepath c:\git\simsum\package
}
if "$user" == "tpm" & c(os)=="MacOSX" {
	global codepath /Users/timothymorris/Documents/GitHub/siman
}

// SETUP FOR ALL USERS
global testpath $codepath/Ella_testing
adopath ++ $codepath
cd $testpath

// RUN ALL TESTS
local testfiles ///
	/// test setup and analyse - all <= 1 minute
	test_setup_dgm			/// test all formats of DGM
	test_setup_target		/// test all formats of target
	test_setup_method		/// test all formats of method
	test_siman_widelong_EMZ /// from wide-long
	testing_graphs_matrix   /// from all formats and var types
	/// test graphs command by command
	test_scatter test_swarm test_zipplot test_lollyplot test_nestloop test_bland test_cms ///
	/// test graphs in mixed ways
	Testing_IRW_TPM_EMZ     /// various graph tests: 2 minutes
	testing_graphs_main     // test graphs from all formats and var types: 2 minutes
	

foreach testfile of local testfiles {
	cap noi do "`testfile'.do"
	if _rc {
		di as error upper("siman failed in program `testfile'.do")
		cap log close
		exit 498
	}
}

// ALSO 
// run "Testing error messages.do" by hand to check error messages

di as result "*** SIMAN HAS PASSED ALL THE TESTS ***"
