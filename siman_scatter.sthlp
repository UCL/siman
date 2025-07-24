{smcl}
{* *! version 1.0 24jul2025}{...}
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
{cmdab:siman sca:tter} [{cmd:se}|{cmd:estimate}] {ifin}
[{cmd:,}
{it:options}]

{pstd}By default, standard error is plotted on the y-axis with point estimate on the x-axis. 
If {cmd:estimate} is specified, this is reversed.

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
{synopt:{opt name}({it:name}[{cmd:, replace}])}the graph name. Default {it:name} is "scatter".{p_end}
{synopt:{opt sav:ing}({it:name}[{cmd:, replace}])}saves the graph to disk in Stata’s .gph format.
Default {it:name} is "scatter".{p_end}
{synopt:{opt exp:ort}({it:filetype}[{cmd:, replace}])}exports the graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. The exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synopt:{opt pause}}pauses before drawing the graph, if {help pause} is on. The user can 
press F9 to view the graph command, and may edit it to create a more customised graph.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman scatter} draws a scatter plot of the standard errors versus point estimates, typically separating out the DGMs, targets and methods. 
Each observation represents one repetition.
The {cmd:siman scatter} plots help the user to look for bivariate outliers.

{pstd}
{help siman setup} needs to be run before {cmd:siman scatter} can be used.


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

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK.{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL, London, UK.{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{title:See Also}

{p}{helpb siman: Return to main help page for siman}
