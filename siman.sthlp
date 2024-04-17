{smcl}
{* *! version 0.5 14aug2023}{...}
{* version 0.4 21nov2022}{...}
{* version 0.3 13dec2021}{...}
{* version 0.2 23June2020}{...}  
{* version 0.1 04June2020}{...}
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
{p2colset 5 25 25 0}{...}


{p}Get started

{p2col:{bf:{help siman_setup:siman setup}}}set up data in the format required by siman, with the user’s raw simulation data (estimates data set)

{p}Analyses

{p2col:{bf:{help siman_analyse:siman analyse}}}creates performance measures data set from the estimates data set, and can hold both in memory

{p}Descriptive tables and figures

{p2col:{bf:{help siman_describe:siman describe}}}tabulates imported estimates data

{p2col:{bf:{help siman_table:siman table}}}tabulates computed performance measures data

{p}Graphs of results: Estimates data

{p2col:{bf:{help siman_scatter:siman scatter}}}scatter plot: plots the estimate versus the standard error

{p2col:{bf:{help siman_comparemethodsscatter:siman comparemethodsscatter}}}scatter compare methods plot: comparison of estimates and standard errors between methods for each repetition

{p2col:{bf:{help siman_swarm:siman swarm}}}swarm plot: either the estimates or the standard error data by method

{p2col:{bf:{help siman_blandaltman:siman blandaltman}}}bland altman plot: shows the difference of the estimate compared to the mean of the estimate (or likewise for the  standard error) with a selected method as the comparator

{p2col:{bf:{help siman_zipplot:siman zipplot}}}zipplot plot: shows all of the confidence intervals for each data-generating mechanism and analysis method

{p}Graphs of results: Performance measures data

{p2col:{bf:{help siman_lollyplot:siman lollyplot}}}lollyplot plot: shows the performance for measures of interest with monte Carlo 95% confidence intervals 

{p2col:{bf:{help siman_nestloop:siman nestloop}}}nestloop plot: plots the results of a full factorial simulation study

{p}Utilities

{p2col:{bf:siman which}}report the version number and date for each siman subcommand

{p}Subcommands may be abbreviated to 3 or more characters, and {cmd:comparemethodsscatter} may be abbreviated to {cmd:cms}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman} is a suite of programs for importing estimates data, analysing the results of simulation studies and graphing the data. 


{marker formats}{...}
{title:Data and formats}

{pstd}There are 2 data set types that siman uses: 

{pstd}{bf:Estimates data set.}
Contains summaries of results from individual repetitions of a simulation experiment.  
Such data may consist of, for example, parameter estimates, standard errors, degrees of freedom, 
confidence intervals, an indicator of rejection of a hypothesis, and more.

{pstd}{bf:Performance measures data set.}
Produced by {bf:{help siman_analyse:siman analyse}}  which calculates performance measures including Monte Carlo error, 
for use with {bf:{help siman_lollyplot:siman lollyplot}} and {bf:{help siman_nestloop:siman nestloop}}.  Please note, this will usually be appended to the estimates data set.

{pstd}For troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang} To plot the estimates data graphs, first load the data set in to {cmd: siman}.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}. {stata "siman scatter"}

{phang}. {stata "siman swarm"}

{phang}. {stata "siman comparemethodsscatter if dgm == 3"}

{phang}. {stata "siman blandaltman if dgm == 3"}

{phang}. {stata "siman zipplot"}

{pstd} Then create performance measures:

{phang}. {stata "siman analyse"}


{title:Details}{marker details}

{pstd}{bf:{help siman_analyse:siman analyse}} requires the additional program {help simsum}.


{title:References}{marker refs}


{phang}{marker Morris++19}Morris TP, White IR, Crowther MJ.
Using simulation studies to evaluate statistical methods.
Statistics in Medicine 2019; 38: 2074-2102.
{browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.8086"}


{title:Authors and updates}{marker updates}


{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK. 
Email {browse "mailto:e.marley-zagar@ucl.ac.uk":e.marley-zagar@ucl.ac.uk}.

{pstd}Ian White, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}.


{title:See Also}

{pstd}{help simsum} (if installed)

