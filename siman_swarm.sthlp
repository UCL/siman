{smcl}
{* *! version 1.4 26june2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
{viewerjumpto "Syntax" "siman_swarm##syntax"}{...}
{viewerjumpto "Description" "siman_swarm##description"}{...}
{viewerjumpto "Examples" "siman_swarm##examples"}{...}
{viewerjumpto "Authors" "siman_swarm##authors"}{...}
{title:Title}

{phang}
{bf:siman swarm} {hline 2} Swarm plot of estimates data.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman swarm} [estimate|se] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no estimates data variables are specified, then the swarm graph will be drawn for {it:estimate} only.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if/in}}  The user can specify {it:if} and {it:in} within the {bf:siman swarm} syntax. If they do not, but have already specified 
an {it:if/in} during {help siman_setup:siman setup}, then the {it:if/in} from {help siman_setup:siman setup} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}
{synopt:{opt by(string)}}  specifies the nesting of the variables, with the default being {bf:by(dgm target)} with method on the y-axis. 

{syntab:Graph options}
{pstd}
{p_end}

{pstd}{it:For the siman swarm graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}

{pstd}
{p_end}
{synopt:{opt meanoff}}  to turn off displaying the mean on the swarm graphs

{pstd}
{p_end}
{synopt:{opt meangr:aphoptions(string)}}  graph options for the mean

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}  graph options for the nesting of the graphs due to the {it:by} option

{pstd}
{p_end}
{synopt:{opt graphop:tions(string)}}  graph options for the overall graphical display


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman swarm} draws a swarm plot of the estimates or the standard error data by method, the results of which are from analysing multiple simulated data sets.  The vertical axis is repetition number, to provide some separation between 
the points, with sample means in the middle. The {cmd: siman swarm} graphs help to inspect the distribution and, 
in particular, to look for outliers in the data.

{pstd}
Please note that {help siman_setup:siman setup} needs to be run first before {cmd:siman swarm}.  If the data is not already in long-long format then it will be reshaped to this format to create the graphs 
(see {help siman_reshape:siman reshape} for further details on data 
format types and the reshape command).

{pstd}
{cmd:siman swarm} requires a {bf:method} variable/values in the estimates dataset defined in the {help siman_setup:siman setup} syntax by {bf:method()}. 
 
{pstd}
{cmd:siman swarm} requires at least 2 methods to compare.

{pstd}
The {cmd:labelsof} package (by Ben Jann) is required by siman swarm, which can be installed by clicking: {stata ssc install labelsof}

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang} To plot the scatter graph, first load the data set in to {cmd: siman}.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}. {stata `"siman swarm, meanoff scheme(s1color) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title"))"'}

{phang}. {stata `"siman swarm, scheme(economist) bygraphoptions(title("My swarm plot")) graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm", replace))"'}

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

