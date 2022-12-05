{smcl}
{* *! version 0.5 21nov2022}{...}
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


Get started

{p2col:{bf:{help siman_setup:siman setup}}}set up data in the format required by siman, with the user’s raw simulation data (estimates data set)

Utilities

{p2col:{bf:{help siman_reshape:siman reshape}}}convert dataset held in memory from any format in to long-long or long-wide format (i.e. long target-wide method)

Analyses

{p2col:{bf:{help siman_analyse:siman analyse}}}creates performance measures data set from the estimates data set, and can hold both in memory

Descriptive tables and figures

{p2col:{bf:{help siman_describe:siman describe}}}tabulates imported estimates data

{p2col:{bf:{help siman_table:siman table}}}tabulates computed performance measures data

Graphs of results: Estimates data

{p2col:{bf:{help siman_scatter:siman scatter}}}scatter plot

{p2col:{bf:{help siman_comparemethodsscatter:siman comparemethodsscatter}}}scatter compare methods plot

{p2col:{bf:{help siman_swarm:siman swarm}}}swarm plot

{p2col:{bf:{help siman_blandaltman:siman blandaltman}}}bland altman plot

{p2col:{bf:{help siman_zipplot:siman zipplot}}}zipplot plot

Graphs of results: Performance measures data

{p2col:{bf:{help siman_lollyplot:siman lollyplot}}}lollyplot plot

{p2col:{bf:{help siman_nestloop:siman nestloop}}}nestloop plot

{p2col:{bf:{help siman_trellis:siman trellis}}}trellis plot


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman} is a suite of programs for importing estimates data, analysing the results of simulation studies and graphing the data. 


{marker formats}{...}
{title:Data and formats}

{pstd}There will be 2 data set types that siman will use: 

{pstd}{bf:Estimates data set.}
Contains summaries of results from individual repetitions of a simulation experiment.  
Such data may consist of, for example, parameter estimates, standard errors, degrees of freedom, 
confidence intervals, an indicator of rejection of a hypothesis, and more.

{pstd}{bf:Performance measures data set.}
Produced by {bf:{help siman_analyse:siman analyse}}  which calculates performance measures including Monte Carlo error, 
for use with {bf:{help siman_lollyplot:siman lollyplot}}, {bf:{help siman_nestloop:siman nestloop}} and {bf:{help siman_trellis:siman trellis}}.  Please note, this will usually be appended to the estimates data set.

{pstd}Data held in memory from {bf:{help siman_setup:siman setup}} can be reshaped in to either long-long format or long-wide format using {bf:{help siman_reshape:siman reshape}}.

{pstd}For troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}


{pstd} Use res.rda converted into a Stata dataset from {help siman##ruckerschwarzer:Rücker and Schwarzer, 2014}.  The example Stata dataset
is available {browse "https://github.com/UCL/simansuite/tree/main/Ella_testing/nestloop/res.dta":here}.

{phang}. {stata "siman setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)"}

{phang}. {stata "siman scatter, by(k)"}

{phang}. {stata "siman analyse"}

{phang}. {stata `"siman nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")"'}


{title:Details}{marker details}

{pstd}{bf:{help siman_analyse:siman analyse}} requires the additional program {help simsum}.


{title:References}{marker refs}


{phang}{marker Morris++19}Morris TP, White IR, Crowther MJ.
Using simulation studies to evaluate statistical methods.
Statistics in Medicine 2019; 38: 2074-2102.
{browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.8086"}

{phang}{marker ruckerschwarzer}Rücker G, Schwarzer G. 
Presenting simulation results in a nested loop plot. BMC Med Res Methodol 14, 129 (2014). 
{browse "https://doi.org/10.1186/1471-2288-14-129"}


{title:Authors and updates}{marker updates}


{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK. 
Email {browse "mailto:e.marley-zagar@ucl.ac.uk":e.marley-zagar@ucl.ac.uk}.

{pstd}Ian White, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}.


{title:See Also}

{pstd}{help simsum} (if installed)

