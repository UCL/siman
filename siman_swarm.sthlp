{smcl}
{* *! version 0.10 19jul2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
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

{pstd}If {cmd:estimate|se} is not specified, then the swarm graph is drawn for {cmd:estimate} only.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:dgmvars target}{cmd:)}. 
Specifying for example {cmd:by(}{it:target}{cmd:)} will overlay DGMs.
Each panel displays all methods, so do not include {it:method} in {cmd:by()}.

{syntab:Graph options}

{synopt:{opt nomean}}do not add the mean to the graph

{synopt:{opt meangr:aphoptions(string)}}options for {help scatter} to be applied to the mean: e.g. mcolor()

{synopt:{opt sc:atteroptions(string)}}options for {help scatter} to be applied to the scatterplot: e.g. msymbol(), moclor()

{synopt:{opt bygr:aphoptions(string)}}graph options for the overall graph that need to be within the {it:by} option: e.g. title(), note(), row(), col()

{synopt:{opt graphop:tions(string)}}graph options for the overall graph that need to be outside the {it:by} option: e.g. xtitle(), ytitle(). This must not include {opt name()}.

{synopt:{opt name(string)}}the stub for the graph name, to which is appended "_estimate" or "_se". Default is "simanswarm"

{synopt:{it:graph_options}}siman swarm attempts to allocate graph options as {opt scatteroptions()}, {opt phoptions()} or {opt graphoptions()}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman swarm} draws a swarm plot of the estimates or the standard errors by method.
The vertical axis is repetition number, to provide some separation between 
the points, with sample means in the middle. 
The {cmd: siman swarm} graphs help to inspect the distribution and, 
in particular, to look for outliers in the data.

{pstd}
{help siman setup} needs to be run first before {cmd:siman swarm}.

{pstd}
{cmd:siman swarm} requires a {bf:method} variable/values in the estimates dataset defined in the {help siman setup} syntax by {bf:method()}. 
 
{pstd}
{cmd:siman swarm} requires at least 2 methods to compare.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang}Load the data set in to {cmd:siman}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}Plot the swarm graph (showing various options)

{phang}. {stata `"siman swarm, nomean scheme(s1color) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title"))"'}

{phang}. {stata `"siman swarm, scheme(economist) row(1) name("swarm", replace)"'}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}
