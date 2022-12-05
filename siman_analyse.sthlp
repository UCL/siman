{smcl}
{* *! version 0.7 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "simsum (if installed)" "simsum"}{...}
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
{cmdab:siman analyse} [if], [{it:performancemeasures perfonly replace}]


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
As per {help simsum:simsum}.  If none of the following options are specified, then all available performance measures are computed.

{synopt:{opt bsims} } reports the number of simulations with non-missing point estimates.

{synopt:{opt sesims} } reports the number of simulations with non-missing standard errors.

{synopt:{opt bias} } estimates the bias in the point estimates.

{synopt:{opt mean} } the average (mean) of the point estimates.

{synopt:{opt empse} } estimates the empirical standard error -- the standard deviation of the point estimates.

{synopt:{opt relprec} } estimates the relative precision -- the inverse squared ratio of the empirical standard error
 of this method to the empirical standard error of the reference method.  This calculation is 
 slow: omitting it can reduce run time by up to 90%.

{synopt:{opt mse} } estimates the mean squared error.

{synopt:{opt rmse} } estimates the root mean squared error.
 
{synopt:{opt modelse} } estimates the model-based standard error. 

{synopt:{opt ciwidth} } estimates the width of the confidence interval at the specified level.

{synopt:{opt relerror} } estimates the proportional error in the model-based standard error, using the empirical standard error 
as gold standard.

{synopt:{opt cover} } estimates the coverage of nominal confidence intervals at the specified level.

{synopt:{opt power} } estimates the power to reject the null hypothesis that the true parameter is zero, at the specified level.

{marker addopts}{...}
{syntab:Additional options:}

{pstd}
{p_end}
{synopt:{opt perfonly} } the program will automatically append the performance measures data to the estimates data, unless the user specifies 
{it:perfonly} for performance measures only.

{pstd}
{p_end}
{synopt:{opt replace} } if {cmd:siman analyse} has already been run and the user specifies it again then they must use the replace option, 
to replace the existing performance measures in the data set.

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman analyse} takes the imported estimates data from {bf:{help siman_setup:siman setup}} and creates performance measures data using the program {help simsum:simsum}.  By default {cmd:siman analyse}
will append the performance measures to the estimates data set, with the performance measure names listed in the {bf:repetition} column.

{pstd}
Additionally the performance measure code (as listed above) and the dataset (estimates or performance) will be listed for each dataset row.

{pstd}
{cmd:siman analyse} will also calculate Monte-Carlo standard errors (mcses).  MSCEs quantify a measure of the simulation uncertainty.  They provide an estimate of the standard error of the performance measure, as a finite number of 
simulations are used.  For example, for the performance measure bias, the Monte-Carlo standard error would show the uncertainty around the estimate of the bias of all of the estimates over all of the simulations 
(i.e. for all in the estimates data set).

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
Display performance measures only:
{p_end}
{pstd}
{bf:siman analyse, perfonly}
{p_end}

{pstd}
If more than one method, with method labels {it:1,2..k}:
{p_end}
{pstd}
{bf:siman analyse if method==1, replace}
{p_end}

{pstd}
To only calculate the performance measures bias and model-based standard error:
{p_end}
{pstd}
{bf:siman analyse, bias modelse}
{p_end}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


