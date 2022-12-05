{smcl}
{* *! version 1.2 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_scatter##syntax"}{...}
{viewerjumpto "Description" "siman_scatter##description"}{...}
{viewerjumpto "Example" "siman_scatter##examples"}{...}
{viewerjumpto "Authors" "siman_scatter##authors"}{...}
{title:Title}

{phang}
{bf:siman scatter} {hline 2} Scatter plot of point estimate versus standard error data.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman scatter} [estimate|se] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no variables are specified, then the scatter graph will be drawn for {it:estimate vs se}.  Alternatively the user can select {it:se vs estimate}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if/in}}  The user can specify {it:if} and {it:in} within the siman scatter syntax. If they do not, but have already specified 
an {it:if/in} during {help siman_setup:siman setup}, then the {it:if/in} from {help siman_setup:siman setup} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}
{synopt:{opt by(string)}}  specifies the nesting of the variables, with the default being {bf:by(dgm target method)}

{syntab:Graph options}
{pstd}
{p_end}

{pstd}{it:For the siman scatter graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs due to the {it:by} option


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman scatter} draws a scatter plot of the point estimates data versus the standard error data, the results of which are 
from analysing multiple simulated data sets with data relating to different statistics (e.g. point estimate) 
for each simulated data set.  The {cmd:siman scatter} plots help the user to look for bivariate outliers.

{pstd}
Please note that {help siman_setup:siman setup} needs to be run first before siman scatter.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.


{marker example}{...}
{title:Example}

{pstd}siman scatter, ytitle("test y-title") xtitle("test x-title") scheme(s2mono) by(dgm) bygraphoptions(title("main-title")) 

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

{pstd}{helpb siman: Return to main help page for siman}


