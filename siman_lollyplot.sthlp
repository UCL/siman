{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "Main simsum help page" "simsum"}{...}
{viewerjumpto "Syntax" "siman_lollyplot##syntax"}{...}
{viewerjumpto "Description" "siman_lollyplot##description"}{...}
{viewerjumpto "Examples" "siman_lollyplot##examples"}{...}
{viewerjumpto "Reference" "siman_lollyplot##reference"}{...}
{viewerjumpto "Authors" "siman_lollyplot##authors"}{...}
{title:Title}

{phang}
{bf:siman lollyplot} {hline 2} Lollipop plot of performance measures data


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman lol:lyplot} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}{it:performancemeasures} are any performance measures that have been calculated by {help siman analyse}. See {help siman analyse##perfmeas:performance measures}.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Specific graph options}
{synopt:{opt labf:ormat(string)}}defines formats for the marker labels for (i) numeric performance measures (e.g. bias), (ii) percentage performance measures (e.g. coverage), and (iii) count performance measures (e.g. estreps). 
Alternatively, {cmd:labformat(none)} removes the marker labels.{p_end}
{synopt:{opt col:ors(string)}}specifies colours for the graphs: one per method.{p_end}
{synopt:{opt ms:ymbol(string)}}specifies marker symbols for the graphs: one per method, or one for all methods.{p_end}
{synopt:{opt refp:ower(string)}}draws a reference line for power. Default is no reference line for power.{p_end}
{synopt:{opt methleg:end}{cmd:(item|title)}}includes the name of the method variable in each legend item or as the legend title. The default is neither.{p_end}
{synopt:{opt dgms:how}}shows in the top title the values of any DGM variables that are constant within the 'if' condition. The default is not to show them.{p_end}
{synopt:{opt dgmti:tle}{cmd:(on|off)}}controls whether the top title shows the names of the DGM variables.
The default is {cmd:dgmtitle(on)} with one DGM variable and {cmd:dgmtitle(off)} with more than one DGM variable.{p_end}
{syntab:Calculation options}
{synopt:{opt mcl:evel(#)}}sets the level for Monte Carlo confidence intervals. Default is the current level (taken from c(level); see {help level}).{p_end}
{synopt:{opt logit}}calculates Monte Carlo confidence intervals for power and coverage on the logit scale. This
ensures that Monte Carlo confidence intervals lie between 0 and 100 (typically only important with small numbers
of repetitions).{p_end}

{syntab:General graph options}
{synopt:{opt bygr:aphoptions(string)}}graph options which need to be placed within the {help by_option:by} option of {help graph twoway}.{p_end}
{synopt:{it:graph_options}}most of the valid options for {help scatter:scatter} are available. However,
do not use the {help by_option:by} option, as this is called automatically.{p_end}

{syntab:Saving options}
{synopt:{opt name}({it:namestub}[{cmd:, replace}])}stub for graph name, to which (if there are more than one 
target) "_" and the target name are appended. Default is "lollyplot".{p_end}
{synopt:{opt sav:ing}({it:namestub}[{cmd:, replace}])}saves each graph to disk in Stata format. The
graph name is {it:namestub}, to which (if there are more than one 
target) "_" and the target name are appended. Default is "lollyplot".{p_end}
{synopt:{opt exp:ort}({it:filetype}[{cmd:, replace}])}exports each graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. Each exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synopt:{opt pause}}pauses before drawing each graph, if {help pause} is on. The user can 
press F9 to view the graph command, and may edit it to create more customised graphs.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman lollyplot} draws a so-called lollipop plot of performance statistics.
Each panel shows the estimated performance for different methods. Panels are separated for each performance measure and data-generating mechanism.
Monte Carlo confidence intervals are represented via parentheses (a visual cue due to the typical presentation of intervals as two numbers within parentheses).
The graph shows several performance measures (as rows of panels) and several data generating mechanisms (as columns).
One graph is drawn for each target.

{pstd}For more background, see {help siman lollyplot##reference:Morris et al, 2019}.

{pstd}The user can select a subset of performance measures to be graphed using the 
performance measures listed in {help siman analyse##perfmeas:performance measures}.
If no performance measures are specified, then graphs will be drawn for {help siman analyse##bias:bias}, 
{help siman analyse##empse:empse} and {help siman analyse##cover:coverage}; 
an exception is if {cmd:true()} was not specified in {help siman setup}, then graphs will be drawn for 
{help siman analyse##mean:mean}, {help siman analyse##empse:empse} and {help siman analyse##relerror:relerror};
and that if there is no {bf:se} variable, then {help siman analyse##cover:coverage} or {help siman analyse##relerror:relerror} is dropped.

{pstd} Reference lines are drawn for performance measures where this is appropriate: e.g. at 0 for bias, but not for empirical SE.

{pstd}
The user can specify {it:if} within the {cmd:siman lollyplot} syntax. 
The {it:if} condition must only apply to {bf:dgm}, {bf:target} and/or {bf:method}.  
If the {it:if} condition is applied to other variables, an error "no observations" is likely.

{pstd}
Both {help siman setup} and {help siman analyse} need to be run before {bf:siman lollyplot} can be used.

{pstd}
If {cmd:siman lollyplot} fails with the error "Too many sersets", try again after typing {cmd:serset clear}.


{marker examples}{...}
{title:Examples}

{pstd} Load and set up the data and compute performance measures

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata  siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)}

{phang}. {stata  siman analyse}

{pstd}Default lollyplot graphs

{phang}. {stata  siman lollyplot}

{pstd}Tailored lollyplot graphs: 
here we select which performance measures are displayed, draw the graph for only one estimand, and round the labels for modelse to 3 decimal places

{phang}. {stata  siman lollyplot modelse power cover if estimand=="beta", labf(%6.3f)}

{pstd}Save lollyplot graphs to disk: this command names the graphs as mylolly_beta and mylolly_gamma
(for the two targets beta and gamma). It saves them to disk in Stata format as
mylolly_beta.gph and mylolly_gamma.gph, and exports them in JPEG format as
mylolly_beta.jpg and mylolly_gamma.jpg.

{phang}. {stata siman lollyplot, name(mylolly) saving(mylolly) export(jpg)}


{marker reference}{...}
{title:Reference}

{phang}{marker Morris19}Morris TP, White IR, Crowther MJ. Using simulation studies
to evaluate statistical methods. Statistics in Medicine 2019; 38: 2074–2102.
{browse "https://doi.org/10.1002/sim.8086":doi:10.1002/sim.8086"}


{marker authors}{...}
{title:Authors}

{pstd}See {help siman##updates:main help page for siman}.


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

