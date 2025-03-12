{smcl}
{* *! version 0.11.1 11mar2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "simsum (if installed)" "simsum"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
{viewerjumpto "Syntax" "siman_analyse##syntax"}{...}
{viewerjumpto "Performance measures" "siman_analyse##perfmeas"}{...}
{viewerjumpto "Description" "siman_analyse##description"}{...}
{viewerjumpto "Examples" "siman_analyse##examples"}{...}
{viewerjumpto "Authors" "siman_analyse##authors"}{...}
{title:Title}

{phang}
{bf:siman analyse} {hline 2} Estimates performance from data imported by the {bf:siman suite}, using the program {help simsum:simsum}


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman analyse} [{it:performancemeasures}] [if], [{it:options}]

{pstd} We advise that {opt if} be applied only to variables defining {bf:dgm}, {bf:target} and {bf:method}.


{synoptset 20 tabbed}{...}
{synopthdr:performancemeasures}
{synoptline}
{marker perfmeas}{...}
{pstd}The performance measures are all those offered by {help simsum:simsum}.
If none is specified, then all available performance measures are estimated.

{marker estsims}{synopt:{opt estreps}}the number of repetitions with non-missing point estimates (called {opt bsims} by {help simsum}).{p_end}
{marker sesims}{synopt:{opt sereps} }the number of repetitions with non-missing standard errors (called {opt sesims} by {help simsum}).{p_end}
{marker bias}{synopt:{opt bias} }the bias of the point estimates.{p_end}
{marker pctbias}{synopt:{opt pctbias} }the bias in the point estimates as a percentage of the true value.{p_end}
{marker mean}{synopt:{opt mean} }the average (mean) of the point estimates.{p_end}
{marker empse}{synopt:{opt empse} }the empirical standard error – standard deviation of the point estimates.{p_end}
{marker relprec}{synopt:{opt relprec} }the relative precision 
– the percentage improvement in precision for this analysis method compared with the reference analysis method.
Precision is the inverse square of the empirical standard error. 
This calculation can be slow: omitting it can reduce run time by up to 90%.{p_end}
{marker mse}{synopt:{opt mse} }the mean squared error of the point estimates.{p_end}
{marker rmse}{synopt:{opt rmse} }the root mean squared error of the point estimates.{p_end}
{marker modelse}{synopt:{opt modelse} }the model-based standard error (more precisely, the root-mean of the squared model-based standard errors across repetitions).{p_end}
{marker ciwidth}{synopt:{opt ciwidth} }the mean width of the confidence interval at the specified level.{p_end}
{marker relerror}{synopt:{opt relerror} }the relative error in the model-based standard error, using the empirical standard error as gold standard.{p_end}
{marker cover}{synopt:{opt cover} }the coverage of nominal confidence intervals at the specified level.{p_end}
{marker power}{synopt:{opt power} }the power to reject the null hypothesis that the true parameter is zero, at the specified level.{p_end}
{synoptline}

{synopthdr}
{synoptline}
{marker addopts}{...}

{synopt:{opt perfonly} }deletes the estimates data from memory, and only keeps the performance 
statistics. This precludes subsequent use of descriptive graphs.{p_end}
{synopt:{opt rep:lace} }if {cmd:siman analyse} has already been run and the user specifies it 
again then they must use the replace option, 
to replace the existing performance measures in the data set.{p_end}
{synopt:{opt notab:le} }do not run {help siman table} after estimating the performance measures.{p_end}
{synopt:{opt l:evel(#)}}specifies the confidence level for coverages and powers. The default is 
the system default set by {help level:set level}. This option is passed to {help simsum}.{p_end}
{synopt:{opt ref(method)}}specifies the reference method for calculating relative precisions. This 
option is passed to {help simsum}.{p_end}
{synopt:{it:simsum_options}}any other options for {help simsum}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman analyse} takes the estimates data from {help siman setup} and creates performance statistics for the performance measures specified using the program {help simsum}.  
{cmd:siman analyse} requires that an {bf:estimate} variable has been specified in {cmd:siman setup}.

{pstd}
We use 'the {bf:estimate} variable' etc. to mean the variable specified in the {opt estimate()} of {cmd:siman setup}.

{pstd}
By default, {cmd:siman analyse} appends performance statistics to the estimates data set. 
The performance measure names (e.g. "Non-missing point estimates") are stored as labels for the {bf:rep} variable, 
and their codes (e.g. "estreps") are stored in a new string variable _perfmeascode.
The performance statistics are stored in the {bf:estimate} variable.
A new variable _dataset indicates whether each row is estimates data or performance data.

{pstd}
Monte Carlo standard errors (MSCEs) of the performance statistics are stored in the {bf:se} variable. 
If no {bf:se} variable was specified in {help siman setup}, they are stored in a new variable _se.
MSCEs quantify the simulation uncertainty.
They provide an estimate of the standard error of the performance statistic due to use of a finite number of repetitions.
For example, for the performance measure bias, the Monte Carlo standard error shows the uncertainty around the estimate of the bias.

{pstd}
If the {opt if} option is used, performance statistics are calculated for this subset only, but all estimates data are retained (unless {opt perfonly} is also used).
It follows that subsequent graphs of performance ({cmd:siman lollyplot} and {cmd:siman nestloop}) will therefore be restricted by this {opt if} subset, 
but estimates graphs will not be.

{pstd}
The {bf:labelsof} package (by Ben Jann) is required by {bf:siman analyse}.
It can be installed using {stata ssc install labelsof}.


{marker examples}{...}
{title:Examples}
{pstd}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{pstd}Standard use:

{phang}. {stata "siman analyse"}

{pstd}
Run for method 2 only:

{phang}. {stata "siman analyse if method==2, replace"}

{pstd}Calculate performance for only the performance measures bias and model-based standard error, and discard the estimates data:

{phang}. {stata "siman analyse bias modelse, replace perfonly"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

