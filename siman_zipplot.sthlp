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
{bf:siman zipplot} {hline 2} Zip plot of the confidence interval coverage for each data-generating mechanism and analysis method in the estimates data.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman zipplot} {ifin}
[{cmd:,}
{it:options}]

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt by(string)}}specifies the nesting of the variables, with the default being {bf:by(dgm method)} if there is only one true value, and
{bf:by(dgm target method)} where there are different true values per target.

{synopt:{opt noncov:eroptions(string)}}graph options for the non-coverers 

{synopt:{opt cov:eroptions(string)}}graph options for the coverers 

{synopt:{opt sca:tteroptions(string)}}graph options for the scatter plot of the point estimates

{synopt:{opt truegr:aphoptions(string)}}graph options for the true value(s)

{synopt:{opt sch:eme(string)}}changes the graph scheme

{synopt:{opt l:evel(cilevel)}}changes the level for the confidence intervals in the zipplot. 
The default is the current system default confidence level.

{synopt:{opt coverl:evel(cilevel)}}changes the level for the confidence interval around the coverage. 
The default is the current system default confidence level.

{synopt:{opt ymin(pct)}}omits the lowest {it:pct}% of the confidence intervals from the zipplot

{synopt:{it:graph_options}}options for {help scatter} that do not go inside its {cmd:by()} option.

{synopt:{opt bygr:aphoptions(string)}}options for {help scatter} that go inside its {cmd:by()} option.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman zipplot} draws a "zip plot"  (see {help siman zipplot##Morris19:Morris et al, 2019})
of the confidence intervals for each data-generating mechanism, target and analysis method in the estimates dataset. 

{pstd}
For each data-generating mechanism and method, the confidence intervals are fractional-centile-ranked. 
This ranking is used for the vertical axis and is plotted against the intervals themselves. Intervals which cover the true value 
are coverers (at the bottom); those which do not cover are called non-coverers (at the top). Both coverers and non-coverers are 
shown on the plot, along with the point estimates.
The zipplot provides a means of understanding any issues with coverage by viewing the confidence intervals directly.  

{pstd}
The overall coverage and its confidence interval (also at the given level) are shown with horizontal lines. 

{pstd}
{help siman setup} must be run first before siman zipplot. 
It must have defined a true variable by {bf:true()}, an estimate variable by {bf:estimate()},
and either a standard error by {bf:se()} or a confidence interval by {bf:lci()} and {bf:uci()}. 


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{pstd}Load the data set in to {cmd: siman}

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{pstd}Simple zipplot

{phang}. {stata  `"siman zipplot"'}

{pstd}Evaluate 50% confidence intervals

{phang}. {stata  `"siman zipplot, level(50)"'}

{pstd}Draw the zipplot split by dgm only

{phang}. {stata  `"siman zipplot, by(dgm)"'}

{pstd}Change the colour scheme, legend and titles in the display

{phang}. {stata  `"siman zipplot, scheme(economist) legend(order(1 "Not covering" 2 "Covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50))"'}

{marker reference}{...}
{title:Reference}
{pstd}

{phang}{marker Morris19}Morris, T. P., White, I. R., & Crowther, M. J. (2019). Using simulation studies to evaluate statistical methods. Statistics in Medicine, 38 (11), 2074-2102. doi:10.1002/sim.8086.
{browse "https://discovery.ucl.ac.uk/id/eprint/10066118/"}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}

