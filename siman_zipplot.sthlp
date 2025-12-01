{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_zipplot##syntax"}{...}
{viewerjumpto "Description" "siman_zipplot##description"}{...}
{viewerjumpto "Examples" "siman_zipplot##examples"}{...}
{viewerjumpto "Reference" "siman_zipplot##reference"}{...}
{viewerjumpto "Authors" "siman_zipplot##authors"}{...}
{title:Title}

{phang}
{bf:siman zipplot} {hline 2} zip plot of confidence interval coverage for each data-generating 
mechanism, target and analysis method in the estimates data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman zip:plot} {ifin}
[{cmd:,}
{it:options}]

{pstd}Any {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and 
{bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:dgmvars target method}{cmd:)}. 
Specifying for example {cmd:by(}{it:target method}{cmd:)} will overlay DGMs.
We advise against using this option.

{syntab:Graph options}
{synopt:{opt noncov:eroptions(string)}}graph options for intervals that do not cover the true value {p_end}
{synopt:{opt cov:eroptions(string)}}graph options for intervals that cover the true value {p_end}
{synopt:{opt sca:tteroptions(string)}}graph options for the scatter plot of the point estimates{p_end}
{synopt:{opt truegr:aphoptions(string)}}graph options for the true value(s){p_end}
{synopt:{opt l:evel(#)}}changes the level for the confidence intervals calculated for the zip 
plot. # is any number between 10.00 and 99.99 (see {help level}). The 
default is the current system default confidence level. However,
if the user specified {opt lci()} and {opt uci()} in {cmd:siman setup}, 
then this option only changes how the confidence intervals are described in the zip plot.{p_end}
{synopt:{opt coverl:evel(#)}}changes the level for the Monte Carlo confidence interval around the 
coverage. # is any number between 10.00 and 99.99 (see {help level}). The 
default is the current system default confidence level.{p_end}
{synopt:{opt ymin(pct)}}omits the lowest {it:pct}% of the confidence intervals from the zip plot{p_end}
{synopt:{opt bygr:aphoptions(string)}}options for {help twoway} that go inside its {cmd:by()} option.{p_end}

{syntab:Saving options}
{synopt:{opt name}({it:name}[{cmd:, replace}])}the graph name. Default {it:name} is "zipplot".{p_end}
{synopt:{opt sav:ing}({it:name}[{cmd:, replace}])}saves the graph to disk in Stata’s .gph format.
Default {it:name} is "zipplot".{p_end}
{synopt:{opt exp:ort}({it:filetype}[{cmd:, replace}])}exports the graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. The exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synopt:{opt pause}}pauses before drawing the graph, if {help pause} is on. The user can 
press F9 to view the graph command, and may edit it to create a more customised graph.{p_end}
{synoptline}

{pstd} Note: {bf:level()} sets the nominal confidence level for the plotted intervals, whereas {bf:coverlevel()} specifies
the level to use for confidence limits around the achieved coverage.

{marker description}{...}
{title:Description}

{pstd}
{cmd:siman zipplot} draws a so-called "zip plot" (see {help siman zipplot##Morris19:Morris et al, 2019}) of the confidence intervals for
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
The overall coverage and its confidence interval (also at the given level) are shown with horizontal lines. 

{pstd}
{help siman setup} must be run before {cmd:siman zipplot} can be used. It
must have defined a true variable by {bf:true()}, an estimate variable by {bf:estimate()}, and
either a standard error by {bf:se()} or a confidence interval by {bf:lci()} and {bf:uci()}. 


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set, named simcheck.dta, available on the
{cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here},
contains results for three dgms (MCAR, MAR, MNAR) and three methods (Full, CCA, MI)
with 1,000 repetitions.

{pstd}Load the data set in to {cmd: siman}

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata  "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

{pstd}Simple zip plot

{phang}. {stata  `"siman zipplot"'}

{pstd}Evaluate 50% confidence intervals

{phang}. {stata  `"siman zipplot, level(50)"'}

{pstd}Draw the zip plot split by dgm only

{phang}. {stata  `"siman zipplot, by(dgm)"'}

{pstd}Change the colour scheme, legend and titles in the display

{phang}. {stata  `"siman zipplot, scheme(economist) legend(order(1 "Not covering" 2 "Covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50))"'}

{marker reference}{...}
{title:Reference}
{pstd}

{phang}{marker Morris19}Morris TP, White IR, Crowther MJ. Using simulation studies
to evaluate statistical methods. Statistics in Medicine 2019; 38: 2074–2102.
{browse "https://doi.org/10.1002/sim.8086":doi:10.1002/sim.8086"}


{marker authors}{...}
{title:Authors}

{pstd}See {help siman##updates:main help page for siman}.


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

