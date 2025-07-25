{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "siman" "siman"}{...}
{viewerjumpto "Syntax" "nestloop##syntax"}{...}
{viewerjumpto "Description" "nestloop##description"}{...}
{viewerjumpto "Examples" "nestloop##examples"}{...}
{viewerjumpto "References" "nestloop##references"}{...}
{viewerjumpto "Authors" "nestloop##authors"}{...}
{title:Title}

{phang}
{bf:nestloop} {hline 2} Nested loop plot of performance statistics


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:nestloop} {it:varname} [{help if}]
[{cmd:,}
{opt desc:riptors(evarlist)}
{opt meth:od(varname)}
{it:options}]

{pstd} The variable {it:varname} (a performance statistic) will be plotted against the descriptors, with a line for each value of the method variable.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options specific to this stand-alone program}

{synopt:{opt desc:riptors(evarlist)}}defines the descriptor variables for the nested loop plot.
A negative sign in front of the variable name will display its values on the graph in descending order.{p_end}
{synopt:{opt meth:od(varname)}}defines the method variable. 
One line will be drawn for each value of this variable (unless any are excluded through {help if} conditions).{p_end}
{synopt:{opt true(#|varname)}}gives the value # or variable to be used as a reference line in the background.{p_end}
{synopt:{opt trueopt:ions(string)}}controls the appearance of the reference line.

{syntab:Options shared with siman nestloop}

{synopt:{it:options}}are any options for {help siman nestloop} except {cmd:dgmorder()} and {cmd:export()}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:nestloop} draws a nested loop plot of performance statistics ({help nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}).
This is a standalone program. See {help siman nestloop} for a description of the nested loop plot, and how to use it within the siman suite.


{marker examples}{...}
{title:Examples}

{pstd}Read and set up data

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/res.dta, clear"}

{pstd}Reshape into format required by nestloop

{phang}. {stata "drop v1"}

{phang}. {stata "reshape long exp mse cov bias var2, i(theta rho pc tau2 k) j(method) string"}

{pstd}Draw nested loop plot of exp for 9 methods and 4*3*4*4*4 DGMs (exp is the mean point estimate for each method and DGM)

{phang}. {stata "nestloop exp, descriptors(theta rho pc tau2 k) method(method) true(theta) legend(row(2)) dgsize(.25)"}


{marker references}{...}
{title:References}

{phang}{marker ruckerschwarzer}Rücker G, Schwarzer G. 
Presenting simulation results in a nested loop plot. BMC Med Res Methodol 14, 129 (2014). 
{browse "https://doi.org/10.1186/1471-2288-14-129":doi:10.1186/1471-2288-14-129}


{marker authors}{...}
{title:Authors}

{pstd}See {help siman##updates:main help page for siman}.


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

