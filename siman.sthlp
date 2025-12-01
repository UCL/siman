{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "simsum (if installed)" "simsum"}{...}
{viewerjumpto "Syntax" "siman##syntax"}{...}
{viewerjumpto "Description" "siman##description"}{...}
{viewerjumpto "Data and formats" "siman##formats"}{...}
{viewerjumpto "Examples" "siman##examples"}{...}
{viewerjumpto "Details" "siman##details"}{...}
{viewerjumpto "References" "siman##refs"}{...}
{viewerjumpto "Authors and updates" "siman##updates"}{...}
{title:Title}

{phang}
{bf:siman} {hline 2} Suite of commands for analysing the results of simulation studies and producing graphs


{title:Syntax}{marker syntax}
{p2colset 9 29 29 0}{...}

{pstd}Get started

{p2col:{bf:{help siman setup}}}set up data in the format required by siman, using the user’s raw simulation data (so-called ‘estimates data set’)

{p2col:{bf:{help siman describe}}}provides a summary table of the estimates data imported by {help siman setup}

{pstd}Descriptive graphs of results using estimates data

{p2col:{bf:{help siman scatter}}}scatter plot of standard error against point estimate

{p2col:{bf:{help siman comparemethodsscatter}}}scatter plot of point estimates and/or standard errors obtained 
from different methods when multiple methods have been applied to the same simulated data sets

{p2col:{bf:{help siman swarm}}}swarm plot of estimates or the standard errors, for different methods, by data-generating mechanisms

{p2col:{bf:{help siman blandaltman}}}Bland–Altman plot of difference between methods vs. mean of methods, for point estimates or standard errors

{p2col:{bf:{help siman zipplot}}}zip plot showing confidence intervals for each data-generating mechanism and analysis method

{pstd}Analyses to estimate performance

{p2col:{bf:{help siman analyse}}}creates performance statistics data set from the estimates data set, and can hold both in memory

{pstd}Graphs and tables of performance statistics

{p2col:{bf:{help siman table}}}tabulates performance statistics

{p2col:{bf:{help siman lollyplot}}}lollyplot of performance statistics with Monte Carlo confidence intervals

{p2col:{bf:{help siman nestloop}}}nested-loop plot of performance statistics the results of a (factorial) simulation study

{pstd}Utilities

{p2col:{bf:siman which}}reports the version number and date for each siman subcommand

{p2col:{bf:{help siman import}}}imports a user's dataset of performance statistics, bypassing {help siman setup} and {help siman analyse}

{pstd}Subcommands may be abbreviated to 3 or more characters, and {cmd:comparemethodsscatter} may be abbreviated to {cmd:cms}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman} is a suite of programs for the analysis of simulation studies, importing estimates data, 
analysing the results of simulation studies and graphing the data. 

{pstd}The typical workflow is either
{cmd:siman setup} → descriptive graphs, or {cmd:siman setup} → {siman_analyse} → tables and graphs of performance.


{marker formats}{...}
{title:Data and formats}

{pstd}There are two data set types that {cmd:siman} uses: 

{pstd}{bf:Estimates data set.}{p_end}
{pstd}Contains summaries of results from individual repetitions of a simulation experiment. 
Such data may consist of, for example, parameter estimates, standard errors, degrees of freedom, 
confidence intervals, an indicator of rejection of a hypothesis, and more.

{pstd}{bf:Performance statistics data set.}{p_end}
{pstd}Contains performance statistics, including Monte Carlo error, for performance measures of interest 
(computed by {bf:{help siman analyse}}). These can be visualised with {bf:{help siman lollyplot}} and 
{bf:{help siman nestloop}}. Note that the performance data set will usually be appended to the estimates data set.

{pstd}For troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with three data-generating mechanisms (MCAR, MAR, MNAR missing data) 
and three methods of analysis (Full, CCA, MI) with 1,000 repetitions is available on the {cmd: siman} 
GitHub repository {browse "https://github.com/UCL/siman/":here}, named simcheck.dta.

{phang} To plot the estimates data graphs, first load the data set in to {cmd: siman}.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

{phang}. {stata "siman scatter"}

{phang}. {stata "siman swarm"}

{phang}. {stata "siman comparemethodsscatter if dgm == 3"}

{phang}. {stata "siman blandaltman if dgm == 3"}

{phang}. {stata "siman zipplot"}

{pstd} Calculate all available performance statistics and Monte Carlo error:

{phang}. {stata "siman analyse"}

{phang}. {stata "siman lollyplot"}

{phang}. {stata "siman nestloop"}


{title:Details}{marker details}

{pstd}{bf:{help siman analyse}} requires the additional program {help simsum}.


{title:References}{marker refs}

{phang}{marker Morris19}Morris TP, White IR, Crowther MJ. Using simulation studies
to evaluate statistical methods. Statistics in Medicine 2019; 38: 2074–2102.
{browse "https://doi.org/10.1002/sim.8086":doi:10.1002/sim.8086}


{title:Authors and updates}{marker updates}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK.

{pstd}Ian White, MRC Clinical Trials Unit at UCL, London, UK.{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, Statistical Methodology, Novartis Pharmaceuticals UK Ltd., London, UK.{break}
Email: {browse "mailto:tim.morris@novartis.com":Tim Morris}

{pstd}Updates can be obtained from {browse "https://github.com/UCL/siman"} or installed directly using {stata "net from https://raw.githubusercontent.com/UCL/siman/master/"}.


{title:Acknowledgements}{marker acknowledgements}

{pstd}This work was funded by the Medical Research Council (grant MC_UU_00004/09).

{pstd}We gratefully acknowledge the following people who have tested and provided 
feedback on {cmd:siman}: Jan Ditzen, Jingyi Xuan, Kara Louise Royle, Matthew Smith, 
Tra My Pham, Nick Latimer, Matteo Quartagno.


{title:See Also}

{pstd}{help simsum} (installed with siman)
{pstd}{help nestloop} (installed with siman)

