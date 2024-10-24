{smcl}
{* *! version 0.9 28nov2023}{...}
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
{bf:siman analyse} {hline 2} Creates performance measures from data imported by the {bf:siman suite}, using the program {help simsum:simsum}


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman analyse} [{it:performancemeasures}] [if], [{it:perfonly replace}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{pstd}
{p_end}

{synopt:{opt if}} can be applied to {bf:dgm}, {bf:target} and {bf:method} only.

{pstd}
{p_end}

{marker perfmeas}{...}
{syntab:Performance measure options:}

{pstd}
As per {help simsum:simsum}.  If none of the following options are specified, then all available performance measures are estimated.

{marker bsims}{synopt:{opt bsims}}the number of repetitions with non-missing point estimates.

{marker sesims}{synopt:{opt sesims} }the number of repetitions with non-missing standard errors.

{marker bias}{synopt:{opt bias} }the bias in the point estimates.

{marker mean}{synopt:{opt mean} }the average (mean) of the point estimates.

{marker empse}{synopt:{opt empse} }the empirical standard error -- the standard deviation of the point estimates.

{marker relprec}{synopt:{opt relprec} }the relative precision 
-- the percentage improvement in precision for this analysis method compared with the reference analysis method.
Precision is the inverse square of the empirical standard error. 
This calculation is slow: omitting it can reduce run time by up to 90%.

{marker mse}{synopt:{opt mse} }the mean squared error.

{marker rmse}{synopt:{opt rmse} }the root mean squared error.
 
{marker modelse}{synopt:{opt modelse} }the model-based standard error - more precisely, the average of the model-based standard errors across repetitions. 

{marker ciwidth}{synopt:{opt ciwidth} }the width of the confidence interval at the specified level.

{marker relerror}{synopt:{opt relerror} }the relative error in the model-based standard error, using the empirical standard error as gold standard.

{marker cover}{synopt:{opt cover} }the coverage of nominal confidence intervals at the specified level.

{marker power}{synopt:{opt power} }the power to reject the null hypothesis that the true parameter is zero, at the specified level.

{marker addopts}{...}
{syntab:Additional options:}

{pstd}
{p_end}
{synopt:{opt perfonly} }the program will automatically append the performance measures data to the estimates data, unless the user specifies 
{it:perfonly} for performance measures only.

{pstd}
{p_end}
{synopt:{opt rep:lace} }if {cmd:siman analyse} has already been run and the user specifies it again then they must use the replace option, 
to replace the existing performance measures in the data set.

{synopt:{it:simsum_options}}Any options for {help simsum}.

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman analyse} takes the imported estimates data from {bf:{help siman_setup:siman setup}} and creates performance measures data using the program {help simsum:simsum}.  By default {cmd:siman analyse}
will append the performance measures to the estimates data set, with the performance measure names listed in the {bf:repetition} column.
{cmd:siman analyse} requires that both {opt est} and {opt se} have been specified in {cmd:siman setup}.

{pstd}
Additionally the performance measure code (as listed above) and the dataset (estimates or performance) will be listed for each dataset row.

{pstd}
If {opt if} is used, performance measures are calculated for this subset only, but all estimates data are retained (unless {opt perfonly} is also used). 
Subsequent performance graphs ({cmd:siman lollyplot} and {cmd:siman nestloop}) will therefore be restricted to the {opt if} subset, 
but estimates graphs will be unrestricted.

{pstd}
{cmd:siman analyse} will also calculate Monte-Carlo standard errors (mcses).  MSCEs quantify a measure of the simulation uncertainty.  They provide an estimate of the standard error of the performance measure, as a finite number of 
repetitions are used.  For example, for the performance measure bias, the Monte-Carlo standard error would show the uncertainty around the estimate of the bias of all of the estimates over all of the repetitions 
(i.e. for all in the estimates data set).

{pstd}
The {bf:labelsof} package (by Ben Jann) is required by {bf:siman analyse}.
It can be installed by {stata ssc install labelsof}.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}
{pstd}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/Ella_testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{pstd}Standard use:

{phang}. {stata "siman analyse"}

{pstd}
Run for method 2 only:

{phang}. {stata "siman analyse if method==2, replace"}

{pstd}To only calculate the performance measures bias and model-based standard error, and discard the estimates data:

{phang}. {stata "siman analyse bias modelse, replace perfonly"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


