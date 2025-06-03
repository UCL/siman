{smcl}
{* *! version 0.11.1 11 Apr 2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_import##syntax"}{...}
{viewerjumpto "Description" "siman_import##description"}{...}
{viewerjumpto "Examples" "siman_import##examples"}{...}
{title:Title}
{phang}
{bf:siman import} {hline 2} Import performance measures data for use in siman

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:siman import}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required }
{synopt:{opt p:erf(varname)}}string variable containing the names of the performance 
measure. The performance measure names must be taken from those listed in {help simsum##pm_options:help simsum}.{p_end}
{synopt:{opt est:imate(varname)}}numeric variable containing the values of the performance measures.{p_end}
{syntab:Optional}
{synopt:{opt d:gm(varlist)}}variable(s) defining the data generating mechanism. {p_end}
{synopt:{opt ta:rget(varname)}}variable defining the target or estimand. {p_end}
{synopt:{opt m:ethod(varname)}}variable defining the method of analysis.{p_end}
{synopt:{opt se(varname)}}numeric variable containing the Monte Carlo standard errors of the performance measures.{p_end}
{synopt:{opt tr:ue(varname)}}numeric variable containing the true values.{p_end}
{synopt:{opt l:evel(#)}}specifies the confidence level at which any coverages and powers have been calculated. By default,
{cmd:siman import} assumes they were calculated at
the system default level set by {help level:set level}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}{cmd:siman import} is a utility to import a dataset of performance estimates that have already 
been calculated, allowing the user to draw graphs 
by {help siman lollyplot} and {help siman nestloop}. Most users will not need this command
and will instead use {help siman setup} to set up their estimates dataset.

{pstd}{help nestloop} offers an alternative way to draw a nestloop
plot from a dataset of performance estimates.


{marker examples}{...}
{title:Examples}

{pstd}We demonstrate importing the data of {help nestloop##ruckerschwarzer:Rücker and Schwarzer (2014)}. This
requires some data reformatting to get the data into the long-long format required by {cmd:siman import}.

{pstd}Read data and identify variable types (DGM variables, method names, performance measure names).

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/res.dta, clear"}{p_end}
{phang}. {stata "local dgmvars theta tau2 k pc rho"}{p_end}
{phang}. {stata "local methodvals fem rem mh peto g2 limf limr peters expect trimfill sfem srem"}{p_end}
{phang}. {stata "local pmvals exp mse cov bias var2"}{p_end}

{pstd}Reshape long-long

{phang}. {stata "reshape long `pmvals', i(`dgmvars') j(method) string"}{p_end}
{phang}. {stata "rename (`pmvals') (est=)"}{p_end}
{phang}. {stata "reshape long est, i(`dgmvars' method) j(_perfmeascode) string"}{p_end}

{pstd}Extract target and performance measures

{phang}. {stata `"gen target = cond(_perfmeascode=="var2",2,1)"'}{p_end}
{phang}. {stata `"replace _perfmeascode = "cover" if _perfmeascode=="cov""'}{p_end}
{phang}. {stata `"replace _perfmeascode = "mean" if inlist(_perfmeascode, "exp", "var2")"'}{p_end}

{pstd}Import into {cmd:siman}

{phang}. {stata "siman import, dgm(theta tau2 k pc rho) target(target) method(method) estimate(est) perf(_perfmeascode)"}{p_end}

{pstd}Now use the {cmd:siman} suite to tabulate some results and draw a nested loop plot

{phang}. {stata "siman table if theta==1 & tau2==0 & k==5 & pc==2 & rho==3, column(_perfmeas target)"}{p_end}
{phang}. {stata `"siman nes mean if target==1 & inlist(method,"peto","g2")"'}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK.{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL, London, UK.{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

