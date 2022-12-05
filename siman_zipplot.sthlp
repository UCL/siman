{smcl}
{* *! version 1.3 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
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

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if/in}}  The user can specify {it:if} and {it:in} within the siman zipplot syntax. If they do not, but have already specified 
an {it:if/in} during {help siman_setup:siman setup}, then the {it:if/in} from {help siman_setup:siman setup} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}
{synopt:{opt by(string)}}  specifies the nesting of the variables, with the default being {bf:by(dgm method)} if there is only one true value, and
{bf:by(dgm target method)} where there are different true values per target.

{syntab:Graph options}
{pstd}
{p_end}

{pstd}{it:For the siman zipplot graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}


{pstd}
{p_end}
{synopt:{opt noncov:eroptions(string)}}  graph options for the non-coverers 

{pstd}
{p_end}
{synopt:{opt cov:eroptions(string)}}  graph options for the coverers 

{pstd}
{p_end}
{synopt:{opt sca:tteroptions(string)}} graph options for the scatter plot of the point estimates

{pstd}
{p_end}
{synopt:{opt truegr:aphoptions(string)}}  graph options for the true value(s)

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs due to the {it:by} option

{pstd}
{p_end}
{synopt:{opt sch:eme(string)}}  to change the graph scheme


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman zipplot} draws a "zip plot" plot of the confidence interval coverage for each data-generating mechanism 
and analysis method in the estimates dataset. Both Monte Carlo 
confidence intervals for percent coverage and 95% confidence intervals for individual repetitions are shown. For coverage 
(or type I error), true θ is used for the null value.

{pstd}
For each data-generating mechanism and method, the confidence intervals are fractional-centile-ranked (see {help siman_zipplot##Morris19:Morris et al., 2019)}. 
This ranking is used for the vertical axis and is plotted against the intervals themselves. Intervals which cover the true value 
are coverers (at the bottom); those which do not cover are called non-coverers (at the top). Both coverers and non-coverers are 
shown on the plot, along with the point estimates.
The zipplot provides a means of understanding any issues with coverage by viewing the confidence intervals directly.  

{pstd}
Please note that {help siman_setup:siman setup} needs to be run first before siman zipplot.

{pstd}
The {cmd:labelsof} package (by Ben Jann) is required by siman swarm, which can be installed by clicking: {stata ssc install labelsof}

{pstd}
siman zipplot requires a true variable in the estimates dataset defined in the {help siman_setup:siman setup} syntax by {bf:true()}. 

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.
 

{marker examples}{...}
{title:Examples}

{pstd}To plot the graphs split by dgm only:

{pstd}siman zipplot, by(dgm)

{pstd}To change the colour scheme, legend and titles in the display:

{pstd}siman zipplot, scheme(scheme(economist)) legend(order(4 "Covering" 3 "Not covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) ///
noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6))

{marker reference}{...}
{title:Reference}
{pstd}

{phang}{marker Morris19}Morris, T. P., White, I. R., & Crowther, M. J. (2019). Using simulation studies to evaluate statistical methods. Statistics in Medicine, 38 (11), 2074-2102. doi:10.1002/sim.8086.
{browse "https://discovery.ucl.ac.uk/id/eprint/10066118/"}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

{pstd}{helpb siman: Return to main help page for siman}

{title:See Also}

{pstd}{help labelsof} (if installed)

