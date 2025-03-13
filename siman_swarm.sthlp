{smcl}
{* *! version 0.11.4 11mar2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_swarm##syntax"}{...}
{viewerjumpto "Description" "siman_swarm##description"}{...}
{viewerjumpto "Examples" "siman_swarm##examples"}{...}
{viewerjumpto "Authors" "siman_swarm##authors"}{...}
{title:Title}

{phang}
{bf:siman swarm} {hline 2} Swarm plot of estimates data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:siman swarm} [estimate] [se] {ifin}
[{cmd:,}
{it:options}]

{pstd}If neither {cmd:estimate} nor {cmd:se} is specified, this is equivalent to {cmd:siman swarm estimate}. If both are specified, {cmd:siman swarm} will draw a graph for each.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {it:dgm}, {it:target} and 
{it:method}, and not e.g. to {it:repetition}. A warning is issued if this is breached.


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:dgmvars target}{cmd:)}. 
Specifying for example {cmd:by(}{it:target}{cmd:)} will overlay DGMs.
Each panel displays all methods, so do not include {it:method} in {cmd:by()}.

{syntab:Graph options}
{synopt:{opt nomean}}do not add the mean to the graph{p_end}
{synopt:{opt meangr:aphoptions(string)}}options for {help scatter} to be applied to the mean: e.g. {cmd:mcolor()}{p_end}
{synopt:{opt sc:atteroptions(string)}}options for {help scatter} to be applied to the scatterplot: e.g. msymbol(), mcolor(){p_end}
{synopt:{opt bygr:aphoptions(string)}}graph options for the overall graph that need to be within the {it:by} option: e.g. title(), note(), row(), col(){p_end}
{synopt:{opt graphop:tions(string)}}graph options for the overall graph that need to be outside the 
{it:by} option: e.g. xtitle(), ytitle(). This must not include {opt name()}.{p_end}
{synopt:{opt name(string)}}the stub for the graph name, to which "_estimate" or "_se" is appended. Default name is "swarm".{p_end}
{synopt:{it:graph_options}}siman swarm attempts to allocate graph options as {opt scatteroptions()}, {opt bygraphoptions()} or {opt graphoptions()}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman swarm} provides so-called ‘swarm plots’ of the repetition-level estimates and/or standard errors arising from each 
method. The point estimates or SE estimates are on the horizontal dimension, and repetition number on the vertical 
dimension. This enables us to look at the distribution of these estimates. The {cmd: siman swarm} graphs help to inspect 
distributions. While this could be done using a histogram or density plot, graphing repetition number serves two more 
important purposes. First, we are able to spot outliers. Second, we can verify that estimates are not dependent 
across repetitions. For example, in the past this has helped us to spot an issue in which a researcher was accidentally 
adding data from one repetition to data from all previous repetitions, rather than correctly separating data from each repetition.

{pstd}
A mean for each panel is plotted, by default as a vertical pipe. This can be suppressed with the {opt nomean} 
option. For standard error estimates, the mean is calculated as the root-mean of the squared standard errors is plotted (i.e. not 
the simple mean of the standard errors).

{pstd}
{help siman setup} needs to be run before {cmd:siman swarm} can be used.

{pstd}
{cmd:siman swarm} requires at least two methods to compare, so it requires a {it:method} variable in the estimates 
dataset. This must be specified in {help siman setup} using the {cmd:method()} option.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1,000 repetitions 
named simcheck.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang}Load the data set in to {cmd:siman}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

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

