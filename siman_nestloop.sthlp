{smcl}
{* *! version 1.8.2 17aug2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_nestloop##syntax"}{...}
{viewerjumpto "Description" "siman_nestloop##description"}{...}
{viewerjumpto "Example" "siman_nestloop##example"}{...}
{viewerjumpto "References" "siman_nestloop##references"}{...}
{viewerjumpto "Authors" "siman_nestloop##authors"}{...}
{title:Title}

{phang}
{bf:siman nestloop} {hline 2} Nested loop plot of performance measures data.

{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman nestloop} [{it:performancemeasures}] [if]
[{cmd:,}
{it:options}]

{pstd}Available performance measures are listed in {help siman_analyse##perfmeas:performance measures}.

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main graph options}

{synopt:{opt dgmo:rder(string)}}order of data generating mechanisms for the nested loop plot. A negative sign in front of the variable name 
will display its values on the graph in descending order.{p_end}
{synopt:{opt stag:ger(#)}}horizontally staggers the main graphs for different methods.  Default # is 0. Try {cmd:stagger(0.05)} to make the lines more distinct.{p_end}
{synopt:{opt c:onnect(string)}}controls how the main graph and legend/descriptor graph are connected. Default is connect(J) which shows each performance measure value as a horizontal line with vertical joins (as described by Rucker and Schwarzer). An alternative is connect(L) which shows each performance measure value at a point with diagonal joins.{p_end}
{synopt:{opt noref:line}}prevents display of reference lines at controls the width(s) of the legend/descriptor graph.{p_end}

{syntab:Descriptor graph options}

{synopt:{opt dgsi:ze(#)}} defines the vertical size of the legend/descriptor graph, as a fraction of the whole vertical axis.  Default # is 0.35.{p_end}
{synopt:{opt dgga:p(#)}} defines the vertical size of the gap between the main graph and the legend/descriptor graph, as a fraction of the whole vertical axis.  Default # is 0.{p_end}
{synopt:{opt dgin:nergap(#)}} controls the vertical spacing between the  legend/descriptor graphs.  Default # is 3.{p_end}
{synopt:{opt dgco:lor(string)}} controls the colour(s) for the legend/descriptor graphs and their labels. Default is gs4.{p_end}
{synopt:{opt dgpa:ttern(string)}} controls the pattern(s) for descriptor graph. Deafult is solid.{p_end}
{synopt:{opt dgla:bsize(string)}} controls the size of the legend/descriptor graph labels. Default is vsmall.{p_end}
{synopt:{opt dgst:yle(string)}} controls the style(s) of the legend/descriptor graph.{p_end}
{synopt:{opt dglw:idth(string)}} controls the width(s) of the legend/descriptor graph.{p_end}

{syntab:Other graph options}

{synopt:{it:graph_options}}Most of the valid options for {help line:line} are available.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:siman nestloop} draws a nested loop plot of performance measures data.
One graph is drawn for each combination of target and performance measure.
Each graph presents the simulation results for all data generating mechanisms and all methods in one plot. 

{pstd}
The performance measure is split by method and is stacked according to the levels of the data generating mechanisms along the horizontal axis. 
The “nested-loop plot” loops through nested data-generating mechanisms and plots results for different methods on top of each other in a full factorial design.

{pstd}The user can select a subset of performance measures to be graphed using the 
performance measures listed in {help siman_analyse##perfmeas:performance measures}.
If no performance measures are specified, then graphs will be drawn for bias, empse (empirical standard error) and coverage; 
except that if {cmd:true()} was not specified in {help siman setup}, then graphs will be drawn for mean, empse and relerror (relative error in the model standard error).

{pstd}The user can specify {it:if} within the siman nestloop syntax. If they do not, but have already specified 
an {it:if} during {help siman analyse}, then the {it:if} from {help siman analyse} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
We recommend to sort the simulation dataset in such a way that the simulation parameter with the largest influence on the criterion 
of interest is considered first, and so forth.  Further guidance can be found in {help siman_nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}.

{pstd}
{help siman_setup:siman setup} and {help siman analyse} need to be run first before {bf:siman nestloop}.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker example}{...}
{title:Example}

{pstd} Re-creating the nestloop plot in Figure 2 from {help siman_nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}, found {browse "https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/1471-2288-14-129#Sec23":here}.
 
{pstd} Use res.rda converted into a Stata dataset from {help siman_nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}, which can be
found {browse "https://github.com/UCL/simansuite/tree/main/Ella_testing/nestloop/res.dta":here}.

{phang}. {stata "siman setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)"}

{phang}. {stata "siman analyse"}

{phang}. {stata `"siman nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")"'}

{marker references}{...}
{title:References}

{phang}{marker ruckerschwarzer}Rücker G, Schwarzer G. 
Presenting simulation results in a nested loop plot. BMC Med Res Methodol 14, 129 (2014). 
{browse "doi:10.1186/1471-2288-14-129"}

{phang}Latimer N, White I, Tilling K, Siebert U. 
Improved two-stage estimation to adjust for treatment switching in randomised trials: 
g-estimation to address time-dependent confounding. Statistical Methods in Medical Research. 2020;29(10):2900-2918. 
{browse "doi:10.1177/0962280220912524"}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

{pstd}{helpb siman: Return to main help page for siman}

