{smcl}
{* *! version 1.13.1 25oct2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "Main simsum help page" "simsum"}{...}
{viewerjumpto "Syntax" "siman_lollyplot##syntax"}{...}
{viewerjumpto "Description" "siman_lollyplot##description"}{...}
{viewerjumpto "Examples" "siman_lollyplot##examples"}{...}
{viewerjumpto "Reference" "siman_lollyplot##reference"}{...}
{viewerjumpto "Authors" "siman_lollyplot##authors"}{...}
{title:Title}

{phang}
{bf:siman lollyplot} {hline 2} lollipop plot of performance measures data.


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman lollyplot} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}Available performance measures are listed in {help siman_analyse##perfmeas:performance measures}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Specific options}

{synopt:{opt labf:ormat(string)}}Formats for the marker labels for (i) numeric performance measures (e.g. bias), (ii) percentage performance measures (e.g. coverage), and (iii) count performance measures (e.g. bsims).

{synopt:{opt col:ors(string)}}Colours for the graphs: one per method.

{synopt:{opt ms:ymbol(string)}}Marker symbols for the graphs: one per method, or one for all methods.
	
{synopt:{opt refp:ower(string)}}Reference level for power. Default is 80.

{syntab:Calculation options}

{synopt:{opt l:evel(#)}}Level for confidence intervals. Default is the current level (see {help level}).

{synopt:{opt logit}}Calculates confidence intervals for power and coverage on the logit scale. This is only important with small numbers of repetitions: it ensures that confidence intervals lie between 0 and 100.

{syntab:General graph options}

{synopt:{opt bygr:aphoptions(string)}}Graph options which need to be placed within the {cmd:by()} option.

{synopt:{it:graph_options}}Most of the valid options for {help scatter:scatter} are available.{p_end}

{syntab:Advanced graph options}

{synopt:{opt pause}}Pauses before drawing each graph, allowing the user to retrieve and edit each graph command before running it. 
Requires {help pause} to be on.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman lollyplot} draws a lollipop plot of performance measures data.  
Each panel shows the estimated values of one performance measure with one data generating mechanism for all methods.
Monte Carlo confidence intervals are represented via parentheses (a visual cue due to the usual presentation of 
intervals as two numbers within parentheses).
The graph shows several performance measures (as rows of panels) and several data generating mechanisms (as columns).
One graph is drawn for each target.

{pstd}For more background, see {help siman_lollyplot##reference:Morris et al, 2019}.

{pstd}The user can select a subset of performance measures to be graphed using the 
performance measures listed in {help siman_analyse##perfmeas:performance measures}.
If no performance measures are specified, then graphs will be drawn for {help siman_analyse##bias:bias}, {help siman_analyse##empse:empse} and {help siman_analyse##cover:coverage}; 
except that if {cmd:true()} was not specified in {help siman setup}, then graphs will be drawn for {help siman_analyse##mean:mean}, {help siman_analyse##empse:empse} and {help siman_analyse##relerror:relerror}.

{pstd}
The user can specify {it:if} within the {cmd:siman lollyplot} syntax. If they do not, but have already specified 
an {it:if} during {help siman_analyse:siman analyse}, then the {it:if} from {help siman_analyse:siman analyse} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
Please note that {help siman_setup:siman setup} and {help siman_analyse:siman analyse} need to be run first before {bf:siman lollyplot}.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} siman lollyplot, scheme(economist) title("New title")

{pstd} siman lollyplot modelse power cover

{marker reference}{...}
{title:Reference}

{pstd}
Morris TP, White IR, Crowther MJ. Using simulation studies to evaluate statistical methods. Statistics in Medicine. 2019; 38: 2074– 2102. 
{browse "https://doi.org/10.1002/sim.8086"}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

