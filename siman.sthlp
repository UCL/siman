{smcl}
{* *! version 0.11 11oct2024}{...}
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

{p2col:{bf:{help siman setup}}}Sets up the user’s raw simulation data (estimates data set) in the format required by siman

{pstd}Analyses

{p2col:{bf:{help siman analyse}}}Creates a performance measures data set from the estimates data set, and can hold both in memory

{pstd}Descriptive tables and figures

{p2col:{bf:{help siman describe}}}Describes the simulation data

{p2col:{bf:{help siman table}}}Tabulates the computed performance measures data

{pstd}Graphs of estimates data

{p2col:{bf:{help siman swarm}}}Swarm plot: plots the estimates or the standard errors against method

{p2col:{bf:{help siman scatter}}}Scatter plot: plots the estimates versus their standard errors

{p2col:{bf:{help siman comparemethodsscatter}}}Scatter compare methods plot: compares estimates and/or standard errors between methods on a set of scatterplots

{p2col:{bf:{help siman blandaltman}}}Bland-Altman plot: compares estimates between methods 
by plotting the difference of the estimates against the mean of the estimates (or similarly for the  standard errors), with a selected method as the comparator

{p2col:{bf:{help siman zipplot}}}Zip plot: shows all of the confidence intervals for each data-generating mechanism and analysis method

{pstd}Graphs of performance measures data

{p2col:{bf:{help siman lollyplot}}}Lollypop plot: compares various performance measure estimates between methods, with Monte Carlo 95% confidence intervals 

{p2col:{bf:{help siman nestloop}}}Nested loop plot: compares a single performance measure between methods across a complex set of data generating mechanisms (e.g. a full factorial simulation study)

{pstd}Utilities

{p2col:{bf:siman which}}report the version number and date for each {cmd:siman} subcommand

{pstd}Subcommands may be abbreviated to 3 or more characters, and {cmd:comparemethodsscatter} may be abbreviated to {cmd:cms}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman} is a suite of programs for importing estimates data, analysing the results of simulation studies and graphing the data. 


{marker formats}{...}
{title:Data and formats}

{pstd}{cmd:siman} uses 2 data set types.

{pstd}An {bf:estimates data set} contains summaries of results from individual repetitions of a simulation experiment.
Such data may consist of, for example, parameter estimates, standard errors, degrees of freedom, 
confidence intervals, p-values, and more.
They typically arise from multiple data generating mechanisms (DGMs) and multiple methods of analysis, and relate to multiple targets or estimands.
They are read in by {bf:{help siman setup}}.

{pstd}A {bf:performance measures data set}
is produced by {bf:{help siman analyse}} which calculates performance measures including Monte Carlo error, 
for use with {bf:{help siman table}}, {bf:{help siman lollyplot}} and {bf:{help siman nestloop}}.  
The performance measures data sety is usually appended to the estimates data set.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang} Open the data set and set it up in {cmd:siman}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}Plot some descriptive graphs of the estimates data

{phang}. {stata "siman swarm"}

{phang}. {stata "siman scatter"}

{phang}. {stata "siman comparemethodsscatter if dgm == 3"}

{phang}. {stata "siman blandaltman if dgm == 3"}

{phang}. {stata "siman zipplot"}

{pstd}Create and graph performance measures

{phang}. {stata "siman analyse"}

{phang}. {stata "siman lollyplot, bygr(legend(pos(3)))"}


{title:Details}{marker details}

{pstd}{bf:{help siman analyse}} requires the additional program {bf:{help simsum}}.


{title:References}{marker refs}

{phang}{marker Morris++19}Morris TP, White IR, Crowther MJ.
Using simulation studies to evaluate statistical methods.
Statistics in Medicine 2019; 38: 2074-2102.
{browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.8086"}


{title:Acknowledgements}{marker acks}

{phang}We thank the following colleagues for their help in testing the {cmd:siman} suite:{break}
Jingyi Xuan (UCL),
Kara-Louise Royle (University of Leeds),
Matthew Smith (LSHTM),
Jan Ditzen (Free University of Bozen-Bolzano).


{title:Authors and updates}{marker updates}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK. 

{pstd}Ian White, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}.


{title:See Also}

{pstd}{help simsum} (if installed)

