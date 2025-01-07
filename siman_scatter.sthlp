{smcl}
{* *! version 0.10 18jun2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_scatter##syntax"}{...}
{viewerjumpto "Description" "siman_scatter##description"}{...}
{viewerjumpto "Example" "siman_scatter##examples"}{...}
{viewerjumpto "Authors" "siman_scatter##authors"}{...}
{title:Title}

{phang}
{bf:siman scatter} {hline 2} Scatter plot of point estimate versus standard error data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman scatter} [{it:varlist}] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no variables are specified, then the scatter graph is drawn for {it:estimate vs se}.  Alternatively the user can select {it:se vs estimate} by typing {bf:siman scatter} {it:se estimate}.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:dgmvars target method}{cmd:)}. 
Specifying for example {cmd:by(}{it:target method}{cmd:)} will overlay DGMs.

{syntab:Graph options}
{synopt:{it:graph_options}}options for {help scatter} that do not go inside the {cmd:by()} option.{p_end}
{synopt:{opt bygr:aphoptions(string)}}options for {help scatter} that go inside the {cmd:by()} option.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman scatter} draws a scatter plot of the point estimates versus their standard errors, typically separating out the DGMs, targets and methods. 
Each observation represents one repetition.
The {cmd:siman scatter} plots help the user to look for bivariate outliers.

{pstd}
{help siman setup} needs to be run first before {cmd:siman scatter}.


{marker example}{...}
{title:Example}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang}Load the data set in to {cmd:siman}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}Plot the default scatter plot.

{phang}. {stata `"siman scatter"'}

{phang}Customise the scatter plot.

{phang}. {stata `"siman scatter, ytitle("test y-title") xtitle("test x-title") scheme(s2mono) by(dgm) bygraphoptions(title("main-title"))"'}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}
