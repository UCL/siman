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
21oct2024 - removed all "which" lines so that log files can show no change
28oct2024 - test files renamed to make more sense
12mar2025 - it's grown, now takes ~18 minutes
22sep2025 - all file names are in quotes, and all outside help files are local
*/

// USER-SPECIFIC SETUP
global codepath C:\git\siman 
if "$user"=="Ian" {
	global codepath C:\ian\git\siman 
	adopath ++ c:\ian\git\simsum\package
}
else if "$user" == "tpm" & c(os)=="Windows" {
	global codepath c:\git\simsum\package
}
else if "$user" == "tpm" & c(os)=="MacOSX" {
	global codepath /Users/timothymorris/Documents/GitHub/siman
}
else di as error "Warning: user not identified"

// SETUP FOR ALL USERS
global testpath $codepath/testing
adopath ++ $codepath
cd $testpath
prog drop _all

// RUN ALL TESTS
local testfiles ///
	/// test setup and analyse - all <= 1 minute
	test_setup_dgm			/// test all formats of DGM
	test_setup_target		/// test all formats of target
	test_setup_method		/// test all formats of method
	test_ci					/// test handling of CIs
	test_import				/// test import program
	test_error_messages		/// error messages
	test_siman_widelong 	/// from wide-long
	test_all_inputs			/// from all formats and var types
	/// test graphs command by command
	test_scatter test_swarm test_zipplot test_lollyplot test_nestloop test_bland test_cms test_table ///
	/// test graphs in mixed ways
	test_graphs_mixed	    /// various graph tests: 2 minutes
	test_graphs_main     	/// test graphs from all formats and var types: 2 minutes
	test_graph_names		/// test name() saving() and export() options for all graphs: 2 mins
	test_helpfiles			/// help files only: very fast
	test_unset				// very fast

foreach testfile of local testfiles {
	cd $testpath
	cap noi do "`testfile'.do"
	if _rc {
		di as error upper("siman failed in program `testfile'.do")
		cap log close
		exit 498
	}
}

// ALSO 
// run "view_graphs.do" by hand to check graphs look right

di as result "*** SIMAN HAS PASSED ALL THE TESTS ***"
