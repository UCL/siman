{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_nestloop##syntax"}{...}
{viewerjumpto "Description" "siman_nestloop##description"}{...}
{viewerjumpto "Examples" "siman_nestloop##examples"}{...}
{viewerjumpto "References" "siman_nestloop##references"}{...}
{viewerjumpto "Authors" "siman_nestloop##authors"}{...}
{title:Title}

{phang}
{bf:siman nestloop} {hline 2} Nested loop plot of performance statistics


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman nes:tloop} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}{it:performancemeasures} are any measures for which performance has been calculated by 
{help siman analyse}. See {help siman analyse##perfmeas:performance measures}.

{pstd}The {it:if} condition should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to 
{bf:repetition}. A warning is issued if this is breached.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options controlling the main graph}
{synopt:{opt dgmo:rder(string)}}defines the order of data generating mechanism (DGM) variables for the nested-loop 
plot. The right-most variable is fastest-changing. A 
negative sign in front of the variable name 
will sort its values on the graph in descending order.{p_end}
{synopt:{opt stag:ger(#)}}horizontally staggers the lines for different methods.  Default # is 0. Try 
{cmd:stagger(0.05)} to make overlapping lines more distinct.{p_end}
{synopt:{opt c:onnect(string)}}controls how the main graph and descriptor graph are connected. 
Default is {cmd:connect(stairstep)}, which shows each performance statistic as a horizontal line with 
vertical joins (as described by {help siman nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}). 
An alternative is {cmd:connect(ascending)}, which connects performance statistics with diagonal lines.{p_end}
{synopt:{opt noref:line}}suppresses display of reference lines for certain performance measures 
(coverage, bias, relprec and relerror).{p_end}

{syntab:Options controlling the descriptor graph}
{synopt:{opt dgsi:ze(#)}}defines the vertical size of the descriptor graph, as a fraction of the 
whole vertical axis.  Default # is 0.35.{p_end}
{synopt:{opt dgga:p(#)}}defines the vertical size of the gap between the main graph and the descriptor 
graph, as a fraction of the whole vertical axis.  Default # is 0.{p_end}
{synopt:{opt dgin:nergap(#)}}controls the vertical spacing between the  descriptor graphs.  Default # is 3.{p_end}
{synopt:{opt dgco:lor(string)}}controls the colour(s) for the descriptor graphs and their labels. Default is gs4.{p_end}
{synopt:{opt dgpa:ttern(string)}}controls the pattern(s) for descriptor graph. Default is solid.{p_end}
{synopt:{opt dgla:bsize(string)}}controls the size of the descriptor graph labels. Default is vsmall.{p_end}
{synopt:{opt dgst:yle(string)}}controls the style(s) of the descriptor graph.{p_end}
{synopt:{opt dglw:idth(string)}}controls the line width(s) of the descriptor graph.{p_end}
{synopt:{opt dgre:verse}}reverses the order of the descriptor graphs, so that the slowest-changing 
(left-most) DGM variable is shown at the top. By default, the slowest-changing DGM variable is shown 
at the bottom.{p_end}

{syntab:Other graph options}
{synopt:{opt methleg:end}{cmd:(item|title)}}includes the name of the method variable in each legend 
item or as the legend title. The default is neither.{p_end}
{synopt:{opt scena:riolabel}}labels the horizontal axis with scenario numbers. 
The default is an unlabelled axis, since the descriptor graphs describe the scenarios.{p_end}
{synopt:{it:graph_options}}Most of the valid options for {help line:line} are available.
We find the following especially useful: {cmd:ylabel()} to stop the y-labels extending to the descriptor graph; 
{cmd:legend()} to arrange legends in a single row or column, e.g.
{cmd:legend(pos(6) row(1))} or {cmd:legend(pos(3) col(1))}.{p_end}

{syntab:Saving options}
{synopt:{opt name}({it:namestub}[{cmd:, replace}])}the stub for the graph name, to which "_", the target name, 
"_" and the performance measure are appended. Default is "nestloop". For example, 
with two targets, beta and gamma, and two performance measures, bias and relerror, default graph 
names would be "nestloop_beta_bias", "nestloop_gamma_bias", "nestloop_beta_relerror" and "nestloop_gamma_relerror".{p_end}
{synopt:{opt sav:ing}({it:namestub}[{cmd:, replace}])}saves each graph to disk in Stata’s .gph format.
The graph name is {it:namestub}, to which "_", the target name, 
"_" and the performance measure are appended. Default is "nestloop". {p_end}
{synopt:{opt exp:ort}({it:filetype}[{cmd:, replace}])}exports each graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. Each exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synopt:{opt pause}}pauses before drawing each graph, if {help pause} is on. The user can 
press F9 to view the graph command, and may edit it to create more customised graphs.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman nestloop} draws a nested-loop plot of performance statistics ({help siman nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}). One
graph is drawn for each combination of target and performance measure. Each
graph presents the simulation results for all data-generating mechanisms and all methods in one plot. 

{pstd}
The performance measure is split by method and is stacked according to the levels of the data 
generating mechanisms along the horizontal
axis. The nested-loop plot loops through nested data-generating mechanisms and plots results 
for different methods on top of each other in a full factorial design.

{pstd}The user can select a set of performance measures to be graphed from those listed in 
{help siman analyse##perfmeas:performance measures}.
If no performance measures are specified, then the default choice is {help siman analyse##bias:bias};
however, if {cmd:true()} was not specified in {help siman setup}, graphs will be drawn for 
{help siman analyse##mean:mean}.

{pstd}
The user can specify {it:if} within the {cmd:siman nestloop} syntax. The
{it:if} condition should only apply to {bf:dgm}, {bf:target} and {bf:method}; if
the condition is applied to other variables, an error "no observations" is likely.

{pstd}
We recommend to sort the simulation dataset in such a way that the simulation parameter with the largest influence on the criterion 
of interest is considered first, and so forth.  Further guidance can be found in {help siman nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}.

{pstd}
Both {help siman setup} and {help siman analyse} need to be run before {bf:siman nestloop} can be used.


{marker examples}{...}
{title:Examples}

{pstd}Read and set up data

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/extendedtestdata.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)"}

{phang}. {stata "siman analyse"}

{pstd}Simple use of nestloop, focusing on one performance measure (% error in model-based standard error)

{phang}. {stata "siman nestloop relerror"}

{pstd}Focus on one estimand

{phang}. {stata `"siman nestloop relerror if estimand=="effect""'}

{pstd}Tailor the graph appearance

{phang}. {stata `"siman nestloop relerror if estimand=="effect", dgmorder(beta pmiss -mech) stagger(0.04) lcol(black red blue) title(Estimand: effect) xlab(none) norefline legend(row(1)) ytitle(% error in model-based SE) note("")"'}

{pstd}Tailor the descriptor graph appearance

{phang}. {stata `"siman nestloop relerror if estimand=="effect", dgsize(.4) dggap(.1) dgcol(green orange purple) dgpatt(dash solid =) dglabsize(medium) dglwidth(*2)"'}

{pstd}Save nested loop graphs to disk. This 
command will create 2 files for each of 3 estimands: my_effect_relerror.gph,
my_effect_relerror.pdf,
my_mean0_relerror.gph, 
my_mean0_relerror.pdf, 
my_mean1_relerror.gph, and 
my_mean1_relerror.pdf.

{phang}. {stata `"siman nestloop relerror, saving(my) export(pdf)"'}


{marker references}{...}
{title:References}

{phang}{marker ruckerschwarzer}Rücker G, Schwarzer G. Presenting
simulation results in a nested loop plot. BMC Medical Research Methodology. 2014;14:129.
{browse "https://doi.org/10.1186/1471-2288-14-129":doi:10.1186/1471-2288-14-129}

{phang}Latimer N, White I, Tilling K, Siebert U. Improved two-stage estimation
to adjust for treatment switching in randomised trials: g-estimation to address
time-dependent confounding. Statistical Methods in Medical Research. 2020;29(10):2900–2918.
{browse "https://doi.org/10.1177/0962280220912524":doi:10.1177/0962280220912524}


{marker authors}{...}
{title:Authors}

{pstd}See {help siman##updates:main help page for siman}.


{title:See Also}

{pstd}{help nestloop} (standalone command for nested loop plots, installed with siman)

{p}{helpb siman: Return to main help page for siman}

