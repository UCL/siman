{smcl}
{* *! version 0.11.1 21oct2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "Main simsum help page" "simsum"}{...}
{viewerjumpto "Syntax" "siman_lollyplot##syntax"}{...}
{viewerjumpto "Description" "siman_lollyplot##description"}{...}
{viewerjumpto "Examples" "siman_lollyplot##examples"}{...}
{viewerjumpto "Reference" "siman_lollyplot##reference"}{...}
{viewerjumpto "Authors" "siman_lollyplot##authors"}{...}
{title:Title}

{phang}
{bf:siman lollyplot} {hline 2} Lollipop plot of performance measures data.


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman lollyplot} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}{it:performancemeasures} are any performance measures that have been calculated by {help siman analyse}. See {help siman analyse##perfmeas:performance measures}.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Specific graph options}

{synopt:{opt labf:ormat(string)}}defines formats for the marker labels for (i) numeric performance measures (e.g. bias), (ii) percentage performance measures (e.g. coverage), and (iii) count performance measures (e.g. estreps). 
Alternatively, {cmd:labformat(none)} removes the marker labels.

{synopt:{opt col:ors(string)}}specifies colours for the graphs: one per method.

{synopt:{opt ms:ymbol(string)}}specifies marker symbols for the graphs: one per method, or one for all methods.
	
{synopt:{opt refp:ower(string)}}draws a reference line for power. Default is no reference line for power.

{synopt:{opt methleg:end}{cmd:(item|title)}}includes the name of the method variable in each legend item or as the legend title. The default is neither.{p_end}

{synopt:{opt dgms:how}}shows in the top title the values of any DGM variables that are constant within the 'if' condition. The default is not to show them.{p_end}

{synopt:{opt dgmti:tle}{cmd:(on|off)}}controls whether the top title shows the names of the DGM variables.
The default is {cmd:dgmtitle(on)} with one DGM variable and {cmd:dgmtitle(off)} with more than one DGM variable.{p_end}

{syntab:Calculation options}

{synopt:{opt l:evel(#)}}sets the level for confidence intervals. Default is the current level (see {help level}).

{synopt:{opt logit}}calculates confidence intervals for power and coverage on the logit scale. This is only important with small numbers of repetitions: it ensures that confidence intervals lie between 0 and 100.

{syntab:General graph options}

{synopt:{opt bygr:aphoptions(string)}}graph options which need to be placed within the {cmd:by()} option.{p_end}

{synopt:{opt name(string)}}stub for graph name, to which "_" and the target name are appended.{p_end}

{synopt:{it:graph_options}}most of the valid options for {help twoway} are available.{p_end}

{syntab:Advanced graph options}

{synopt:{opt pause}}pauses before drawing each graph, allowing the user to retrieve and edit each graph command before running it. 
Requires {help pause} to be on.

{syntab:Saving options}

{synopt:{opt sav:ing}{it:(namestub[}{cmd:, replace}{it:])}}saves each graph to disk in Stata format. 
The graph name is {it:namestub} with the target name appended.{p_end}

{synopt:{opt exp:ort}{it:(format[}{cmd:, replace}{it:])}}exports each graph to disk in non-Stata format. 
{cmd:saving()} must also be specified, and the file name is the same as for {cmd:saving()} with the appropriate filetype.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman lollyplot} draws a lollipop plot of performance measures data.  
Each panel shows the estimated values of one performance measure with one data generating mechanism for all methods.
Monte Carlo confidence intervals are represented via parentheses (a visual cue due to the usual presentation of 
intervals as two numbers within parentheses).
The graph shows several performance measures (as rows of panels) and several data generating mechanisms (as columns).
One graph is drawn for each target.

{pstd}For more background, see {help siman lollyplot##reference:Morris et al, 2019}.

{pstd}The user can select a subset of performance measures to be graphed using the 
performance measures listed in {help siman analyse##perfmeas:performance measures}.
If no performance measures are specified, then graphs will be drawn for {help siman analyse##bias:bias}, {help siman analyse##empse:empse} and {help siman analyse##cover:coverage}; 
except that if {cmd:true()} was not specified in {help siman setup}, then graphs will be drawn for {help siman analyse##mean:mean}, {help siman analyse##empse:empse} and {help siman analyse##relerror:relerror};
and that if there is no {bf:se} variable, then {help siman analyse##cover:coverage} or {help siman analyse##relerror:relerror} is dropped.

{pstd}
The user can specify {it:if} within the {cmd:siman lollyplot} syntax. 
The {it:if} condition must only apply to {bf:dgm}, {bf:target} and {bf:method}.  
If the {it:if} condition is applied to other variables, an error "no observations" is likely.

{pstd}
Please note that {help siman setup} and {help siman analyse} need to be run first before {bf:siman lollyplot}.

{pstd}
If {cmd:siman lollyplot} fails with the error "Too many sersets", try again after typing {cmd:serset clear}.


{marker examples}{...}
{title:Examples}

{pstd} Load and set up the data and compute performance measures

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata  siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)}

{phang}. {stata  siman analyse, notable}

{pstd}Default lollyplot graphs

{phang}. {stata  siman lollyplot}

{pstd}Tailored lollyplot graphs: 
here we select which performance measures are displayed, draw the graph for only one estimand, and round the labels for modelse to 3 decimal places

{phang}. {stata  siman lollyplot modelse power cover if estimand=="beta", labf(%6.3f)}


{marker reference}{...}
{title:Reference}

{pstd}
Morris TP, White IR, Crowther MJ. Using simulation studies to evaluate statistical methods. Statistics in Medicine. 2019; 38: 2074–2102. 
{browse "https://doi.org/10.1002/sim.8086"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}
