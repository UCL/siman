{smcl}
{* *! version 0.10 18jun2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_scatter##syntax"}{...}
{viewerjumpto "Description" "siman_scatter##description"}{...}
{viewerjumpto "Example" "siman_scatter##examples"}{...}
{viewerjumpto "Authors" "siman_scatter##authors"}{...}
{title:Title}

{phang}
{bf:siman scatter} {hline 2} Scatter plot of standard errors against point estimates.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman scatter} [{it:varlist}] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no variables are specified, then the scatter graph will be drawn for  {it:se vs. estimate}.  Alternatively the user can select {it:se vs estimate} by typing {bf:siman scatter} {it:se estimate}.

{pstd}The {it:if} and {it:in} conditions are usually applied only to {bf:dgm}, {bf:target} and {bf:method}.  If they are applied otherwise, e.g. to {bf:repetition}, a warning is issued.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opt by(varlist)}}specifies the nesting of the variables, with the default being all of {bf:dgm target method} that vary within the selected data.

{syntab:Graph options}

{synopt:{it:graphoptions}}most of the options for {help scatter:twoway scatter} are available.

{synopt:{opt bygr:aphoptions(string)}}graph options for the nesting of the graphs due to the {it:by} option. For example, 

{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman scatter} draws a scatterplot of the point estimate data versus standard error from the estimates data.
The {cmd:siman scatter} plots help the user to see the estimates produced by individual repetitions and are useful for identifying bivariate outliers.

{pstd}
{help siman setup} must be run before {cmd:siman scatter}.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.


{marker example}{...}
{title:Example}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{phang} To plot the scatter graph, first load the data set in to {cmd: siman}.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang}. {stata `"siman scatter"'}

{phang}. {stata `"siman scatter, by(method dgm) ytitle("SE(β)") xtitle("β") scheme(s2mono) bygraphoptions(title("SE vs. point estimate") cols(4) noiyaxes noixaxes holes(2 7 12))"'}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}

{pstd}{helpb siman: Return to main help page for siman}

