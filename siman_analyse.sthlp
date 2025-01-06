{smcl}
{* *! version 0.11 18dec2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "simsum (if installed)" "simsum"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
{viewerjumpto "Syntax" "siman_analyse##syntax"}{...}
{viewerjumpto "Description" "siman_analyse##description"}{...}
{viewerjumpto "Performance measures" "siman_analyse##perfmeas"}{...}
{viewerjumpto "Examples" "siman_analyse##examples"}{...}
{viewerjumpto "Authors" "siman_analyse##authors"}{...}
{title:Title}

{phang}
{bf:siman analyse} {hline 2} Estimates performance measures from simulation estimates data


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman analyse} [{it:performancemeasures}] [if], [{it:options}]

{pstd}{it:performancemeasures} are described {help siman analyse##perfmeas:below}.

{pstd}The {it:if} condition should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt perf:only} }include only performance measures in the output data set. 
By default it contains the performance measures and the estimates data.{p_end}
{synopt:{opt rep:lace} }replace any performance measures that have already been calculated.
This is needed if the user has previously run {cmd:siman analyse}.{p_end}
{synopt:{opt notab:le}}do not output the table of calculated performance measures.{p_end}
{synopt:{it:simsum_options}}any options for {help simsum}, e.g. {cmd:ref()} to specify the reference method for calculating relative precision.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman analyse} takes the estimates data from {help siman setup} and creates performance measures data using the program {help simsum}.  
{cmd:siman analyse} requires that the {bf:estimate} variable has been specified in {cmd:siman setup}.
(We use 'the {bf:estimate} variable' etc. to mean the variable specified in the {opt estimate()} of {cmd:siman setup}.)

{pstd}
By default, {cmd:siman analyse} appends the performance measures to the estimates data set. 
The performance measure names (e.g. "Non-missing point estimates") are stored as labels for the {bf:rep} variable, and their codes (e.g. "estreps") are stored in a new string variable _perfmeascode.
The performance estimates are stored in the {bf:estimate} variable.
A new variable _dataset indicates whether each row is estimates data or performance data.

{pstd}
Monte Carlo standard errors (MSCEs) of the performance estimates are stored in the {bf:se} variable. 
If no {bf:se} variable was specified in {cmd:siman setup}, then they are stored in a new variable _se.
MSCEs quantify the simulation uncertainty.  
They provide an estimate of the standard error of the performance estimate, as a finite number of repetitions are used.
For example, for the performance measure bias, the Monte Carlo standard error shows the uncertainty around the estimate of the bias.

{pstd}
If {opt if} is used, performance measures are calculated for this subset only, but all estimates data are retained (unless {opt perfonly} is also used). 
Subsequent performance graphs ({cmd:siman lollyplot} and {cmd:siman nestloop}) will therefore be restricted to the {opt if} subset, 
but estimates graphs will be unrestricted.

{pstd}
The {bf:labelsof} package (by Ben Jann) is required by {bf:siman analyse}.
It can be installed by {stata ssc install labelsof}.


{marker perfmeas}{...}
{title:Performance measures}

{pstd}The available performance measures (listed below) are all the performance measures calculated by {help simsum##pm_options:simsum}.  
If no performance measures are specified, then all available performance measures are estimated.

{synoptset 12 tabbed}{...}
{marker estsims}{synopt:{opt estreps}}the number of repetitions with non-missing point estimates (called {opt bsims} by {help simsum}).

{marker sesims}{synopt:{opt sereps} }the number of repetitions with non-missing standard errors (called {opt sesims} by {help simsum}).

{marker bias}{synopt:{opt bias} }the bias of the point estimates.

{marker pctbias}{synopt:{opt pctbias} }the bias in the point estimates as a percentage of the true value.

{marker mean}{synopt:{opt mean} }the average (mean) of the point estimates.

{marker empse}{synopt:{opt empse} }the empirical standard error -- the standard deviation of the point estimates.

{marker relprec}{synopt:{opt relprec} }the relative precision 
-- the percentage improvement in precision for this analysis method compared with the reference analysis method.
Precision is the inverse square of the empirical standard error. 

{marker mse}{synopt:{opt mse} }the mean squared error of the point estimates.

{marker rmse}{synopt:{opt rmse} }the root mean squared error of the point estimates.
 
{marker modelse}{synopt:{opt modelse} }the model-based standard error - more precisely, the average of the model-based standard errors across repetitions. 

{marker ciwidth}{synopt:{opt ciwidth} }the width of the confidence interval at the specified level.

{marker relerror}{synopt:{opt relerror} }the relative error in the model-based standard error, using the empirical standard error as gold standard.

{marker cover}{synopt:{opt cover} }the coverage of nominal confidence intervals at the specified level.

{marker power}{synopt:{opt power} }the power to reject the null hypothesis that the true parameter is zero, at the specified level.


{marker examples}{...}
{title:Examples}
{pstd}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{pstd}Standard use:

{phang}. {stata "siman analyse"}

{pstd}After {cmd:siman setup}, run siman analyse, but don't print the default table and instead print a customised table:

{phang}. {stata "siman analyse, notable"}

{phang}. {stata `"siman table if estimand=="beta", column(dgm method)"'}

{pstd}Calculate only the performance measures bias and model-based standard error, and discard the estimates data:

{phang}. {stata "siman analyse bias modelse, replace perfonly"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK.{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL, London, UK.{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


