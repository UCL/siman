{smcl}
{* *! version 1.5 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_trellis##syntax"}{...}
{viewerjumpto "Description" "siman_trellis##description"}{...}
{viewerjumpto "Examples" "siman_trellis##examples"}{...}
{viewerjumpto "Authors" "siman_trellis##authors"}{...}
{title:Title}

{phang}
{bf:siman trellis} {hline 2} Trellis plot for performance measures data.


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman trellis} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}If no performance measures are specified, then the trellis graph will be drawn for {it:all} performance measures in the data set.  Alternatively the user can select a subset of performance measures to be graphed using the 
performance measures listed {help siman_trellis##perfmeas:below}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if}}  The user can specify {it:if} within the siman trellis syntax. If they do not, but have already specified 
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

{pstd}{it:For the siman trellis graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs by data generating mechanism.

{marker description}{...}
{title:Description}

{pstd}
{cmd:siman trellis} draws a plot of performance measures data.  It is a graphical presentation of method performance per data generating mechanism ({bf:dgm}) for each true value. There is one line drawn per {bf:method}, and a different panel for 
each dgm level.  The true value of beta is on the horizontal axis and the estimated performance measure on the vertical axis.

{pstd}
{cmd:siman trellis} is intended for datasets that have more than 1 {bf:true} value.  

{pstd}
{bf:true} must be a {bf:variable} in the dataset for {cmd:siman trellis}, and should be listed in both the {bf:dgm()} and the {bf:true()}
options in {help siman setup:siman setup}.

{pstd}
Please note that {help siman_setup:siman setup} and {help siman_analyse:siman analyse} need to be run first before {bf:siman trellis}.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.


{marker examples}{...}
{title:Examples}

{pstd} siman trellis, scheme(economist) title("New title")

{pstd} siman trellis modelse power cover

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

{p}{helpb siman: Return to main help page for siman}

