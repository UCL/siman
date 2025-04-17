{smcl}
{* *! version 0.10 18jun2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_scatter##syntax"}{...}
{viewerjumpto "Description" "siman_scatter##description"}{...}
{viewerjumpto "Examples" "siman_scatter##examples"}{...}
{viewerjumpto "Authors" "siman_scatter##authors"}{...}
{title:Title}

{phang}
{bf:siman scatter} {hline 2} Scatter plot of standard errors against point estimates


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman sca:tter} [{it:varlist}] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no variables are specified, the scatterplot will be drawn for  {it:se vs. estimate}. Alternatively
the user can select {it:estimate vs. se} by typing {bf:siman scatter} {it:estimate se}.

{pstd}The {it:if} and {it:in} conditions are usually applied only to {bf:dgm}, {bf:target} and 
{bf:method}. If they are applied otherwise, e.g. to {bf:repetition}, a warning is issued.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:dgmvars target method}{cmd:)}. 
Specifying for example {cmd:by(}{it:target method}{cmd:)} will overlay DGMs.

{syntab:Graph options}
{synopt:{it:graph_options}}options for {help scatter} that do not go inside the {cmd:by()} option.{p_end}
{synopt:{opt bygr:aphoptions(string)}}options for {help scatter} that go inside the {cmd:by()} option.{p_end}

{syntab:Saving options}
{synopt:{opt sav:ing}{it:(name[}{cmd:, replace}{it:])}}saves the graph to disk in Stata’s .gph format.
The graph name is {it:name}.{p_end}
{synopt:{opt exp:ort}{it:(filetype[}{cmd:, replace}{it:])}}exports the graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. The exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman scatter} draws a scatter plot of the standard errors versus point estimates, typically separating out the DGMs, targets and methods. 
Each observation represents one repetition.
The {cmd:siman scatter} plots help the user to look for bivariate outliers.

{pstd}
{help siman setup} must be run before {cmd:siman scatter}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) 
with 1000 repetitions named simcheck.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang}Load the data set in to {cmd:siman}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

{phang}Plot the default scatter plot.

{phang}. {stata `"siman scatter"'}

{phang}Customise the scatter plot.

{phang}. {stata `"siman scatter, ytitle("test y-title") xtitle("test x-title") scheme(s2mono) by(dgm) bygraphoptions(title("main-title"))"'}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}


{p}{helpb siman: Return to main help page for siman}

