{smcl}
{* *! version 1.4 21nov2022}{...}
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

{pstd}If no performance measures are specified, then the lolliplot graph will be drawn for {it:all} performance measures in the data set.  Alternatively the user can select a subset of performance measures to be graphed using the 
performance measures listed {help siman_lollyplot##perfmeas:below}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if}}  The user can specify {it:if} within the siman lollyplot syntax. If they do not, but have already specified 
an {it:if} during {help siman_analyse:siman analyse}, then the {it:if} from {help siman_analyse:siman analyse} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}

{marker perfmeas}{...}
{syntab:Performance measure options:}

{pstd}
See {help siman_analyse##perfmeas:performance measures} as per {help siman_analyse:siman analyse} and {help simsum:simsum}.
{p_end}

{syntab:Graph options:}
{pstd}
{p_end}

{pstd}
{p_end}
{synopt:{opt gr:aphoptions(string)}}  graph options for the constituent performance measure graphs.

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs.

{pstd}{it:For the siman lollyplot graph user-inputted options, most of the valid options for {help graph combine:graph combine} are available.}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman lollyplot} draws a lollipop plot of performance measures data.  It is a graphical presentation of estimated performance where different performance measures are stacked vertically; for each performance measure, the results for each 
method occupy one row; results for different methods are arranged across the two columns. Monte Carlo 95% confidence intervals are represented via parentheses (a visual cue due to the usual presentation of 
intervals as two numbers within parentheses) (see {help siman_lollyplot##reference:Morris et al, 2019}).

{pstd}
The graphs will be produced by {bf:dgm}, with one point/line drawn per {bf:method}.

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

 Morris, TP, White, IR, Crowther, MJ. Using simulation studies to evaluate statistical methods. Statistics in Medicine. 2019; 38: 2074– 2102. 
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

