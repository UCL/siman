{smcl}
{* *! version 1.2 21nov2022}{...}
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

{pstd}If no performance measures are specified, then the nestloop graph will be drawn for {it:all} performance measures in the data set.  Alternatively the user can select a subset of performance measures to be graphed using the 
performance measures listed {help siman_nestloop##perfmeas:below}.

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{pstd}
{p_end}

{synopt:{opt if}}  The user can specify {it:if} within the siman nestloop syntax. If they do not, but have already specified 
an {it:if} during {help siman_analyse:siman analyse}, then the {it:if} from {help siman_analyse:siman analyse} will be used.
The {it:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {it:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}

{marker perfmeas}{...}
{syntab:Performance measure options:}

{pstd}
See {help siman_analyse##perfmeas:performance measures} as per {help siman_analyse:siman analyse} and {help simsum:simsum}.
{p_end}

{pstd}
{p_end}
{syntab:Options}

{synopt:{opt dgmo:rder(string)}}order of data generating mechanisms for the nested loop plot. A negative sign infront of the variable name 
will display it's values on the graph in descending order.{p_end}
{synopt:{opt c:onnect(string)}}connecting option for main graph and descriptor graph.{p_end}
{synopt:{opt stag:ger(#)}}stagger option for main graph.  Default # is 0.{p_end}
{synopt:{opt fracl:egend(#)}}controls sizing for legend.  Default # is 0.35.{p_end}
{synopt:{opt fracg:ap(#)}}controls sizing for gap in legend.  Default # is 0.{p_end}
{synopt:{opt legendg:ap(#)}}controls sizing for descriptor graph.  Default # is 3.{p_end}
{synopt:{opt legendc:olor(string)}}controls colours for descriptor graph.{p_end}
{synopt:{opt legendp:attern(string)}}controls pattern for descriptor graph.{p_end}
{synopt:{opt legends:ize(string)}}controls size of descriptor graph.{p_end}
{synopt:{opt legendsty:le(string)}}controls style of descriptor graph.{p_end}
{synopt:{opt legendw:idth(string)}}controls width of descriptor graph.{p_end}

{pstd}
{p_end}
{pstd}{it:For the siman nestloop graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}

{marker description}{...}
{title:Description}

{pstd}
{cmd:siman nestloop} draws a nested loop plot of performance measures data.

{pstd}
The nested loop plot presents all simulation results in one plot.  The performance measure is split by method and is stacked according to the levels of the data generating mechanisms along the horizontal axis. The “nested-loop plot” 
loops through nested data-generating mechanisms and plots results for different methods on top of each other in a full factorial design.

{pstd}
We recommend to sort the simulation dataset in such a way that the simulation parameter with the largest influence on the criterion 
of interest is considered first, and so forth.  Further guidance can be found in {help siman_nestloop##ruckerschwarzer:Rücker and Schwarzer, 2014}.

{pstd}
{bf:true} must be a {bf:variable} in the dataset for {cmd:siman nestloop}, and should be listed in both the {bf:dgm()} and the {bf:true()}
options in {help siman setup:siman setup}.

{pstd}
Please note that {help siman_setup:siman setup} and {help siman_analyse:siman analyse} need to be run first before {bf:siman nestloop}.

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

