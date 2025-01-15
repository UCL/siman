{smcl}
{* *! version 0.10 19jul2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_zipplot##syntax"}{...}
{viewerjumpto "Description" "siman_zipplot##description"}{...}
{viewerjumpto "Examples" "siman_zipplot##examples"}{...}
{viewerjumpto "Reference" "siman_zipplot##reference"}{...}
{viewerjumpto "Authors" "siman_zipplot##authors"}{...}
{title:Title}

{phang}
{bf:siman zipplot} {hline 2} zip plot of confidence interval coverage for each data-generating mechanism, target and analysis method in the estimates data.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman zipplot} {ifin}
[{cmd:,}
{it:options}]

{pstd}Any {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not to {bf:repetition}. A warning is issued if this is breached.

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(string)}}  specifies the nesting of the variables, with the default being {bf:by(dgm method)} if there is only one true value, and
{bf:by(dgm target method)} where there are different true values per target.{p_end}
{syntab:Graph options}
{pstd}{it:Note: most of the valid options for {help scatter:scatter} are available for {cmd:siman zipplot}.}{p_end}
{synopt:{opt noncov:eroptions(string)}}  graph options for the non-coverers{p_end}
{synopt:{opt cov:eroptions(string)}}  graph options for the coverers{p_end}
{synopt:{opt sca:tteroptions(string)}} graph options for the scatter plot of the point estimates{p_end}
{synopt:{opt truegr:aphoptions(string)}}  graph options for the true value(s){p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs due to the {it:by} option{p_end}
{synopt:{opt sch:eme(string)}}  to change the graph scheme{p_end}
{synopt:{opt l:evel(cilevel)}}  changes the level for confidence intervals{p_end}
{synopt:{opt ymin(pct)}}  omits the lowest {it:pct}% of the confidence intervals from the zipplot{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman zipplot} draws a so-called "zip plot" of the confidence intervals for
each data-generating mechanism, target and analysis method in the estimates
dataset. 95% (or other level) confidence intervals for individual repetitions are plotted
according to whether or not they cover the true value, along with a Monte Carlo
confidence interval for percent coverage. For coverage (or type I error),
true θ is used for the null value.

{pstd}
For each data-generating mechanism and method, the confidence intervals are ranked
and displayed as a fractional-centile (see {help siman zipplot##Morris19:Morris et al., 2019)}. This
ranking is used for the vertical axis and is plotted against the
intervals themselves. Intervals that cover the true value are ‘coverers’ (at the bottom);
intervals which do not are called ‘non-coverers’ (at the top). Both coverers and
non-coverers are shown on the plot, along with the point estimates. The zip plot
provides a means of understanding any issues with coverage by viewing the confidence
intervals directly.  

{pstd}
{help siman setup} must be run first before siman zipplot. 
It must have defined a true variable by {bf:true()}, an estimate variable by {bf:estimate()},
and either a standard error by {bf:se()} or a confidence interval by {bf:lci()} and {bf:uci()}. 


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set, named simpaper1.dta, available on the
{cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here},
contains results for three dgms (MCAR, MAR, MNAR) and three methods (Full, CCA, MI)
with 1,000 repetitions.

{pstd} To plot the zipplot, first load the data in to {cmd: siman} and run {cmd: siman setup}.

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}. {stata  `"siman zipplot"'}

{pstd} To plot the graphs split by dgm only:

{phang}. {stata  `"siman zipplot, by(dgm)"'}

{pstd} To change the colour scheme, legend and titles in the display:

{phang}. {stata  `"siman zipplot, scheme(economist) legend(order(1 "Not covering" 2 "Covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50))"'}

{marker reference}{...}
{title:Reference}
{pstd}

{phang}{marker Morris19}Morris TP, White IR, Crowther MJ. Using simulation studies
to evaluate statistical methods. Statistics in Medicine 2019; 38: 2074–2102.
{browse "https://doi.org/10.1002/sim.8086":doi:10.1002/sim.8086"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

