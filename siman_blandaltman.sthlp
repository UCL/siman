{smcl}
{* *! version 0.10 24jul2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_blandaltman##syntax"}{...}
{viewerjumpto "Description" "siman_blandaltman##description"}{...}
{viewerjumpto "Examples" "siman_blandaltman##examples"}{...}
{viewerjumpto "Authors" "siman_blandaltman##authors"}{...}
{viewerjumpto "See also" "siman_blandaltman##seealso"}{...}
{title:Title}

{phang}
{bf:siman blandaltman} {hline 2} Bland-Altman plot comparing methods of estimates or standard error data.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman blandaltman} [{it:varlist}] {ifin}
[{cmd:,}
{it:options}]

{pstd}{it:varlist} may include {it:estimate} (the default), {it:se} or both.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:method}{cmd:)}, with one graph per DGM and target.
Specifying for example {cmd:by(}{it:target method}{cmd:)} will combine the different targets into the same graph.
Do not exclude {it:method} from the {cmd:by()} option.

{syntab:Graph options}

{synopt:{it:graph_options}}options for {help scatter} that do not go inside its {cmd:by()} option.

{synopt:{opt bygr:aphoptions(string)}}options for {help scatter} that go inside its {cmd:by()} option.

{synopt:{opt m:ethlist(string)}}display the graphs for a subgroup of methods.  
For example, in a dataset with methods A, B, C and D, if the user would like to compare 
methods A and C, they would enter {bf: methlist(A C)}, which would plot graphs for the difference C - A.
Note that the value needs to be entered in to {bf: methlist()} and not the label 
(if these are different).  For example if method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C, then 
{bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)}.  The {bf: methlist()} option needs to be specified to subset on methods, 
using <= and >= will not work.  The components of {bf: methlist()}  need to be written out in full, for example {bf: methlist(1 2 3 4)} and not
{bf: methlist(1/4)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman blandaltman} draws a {help siman_blandaltman##reference:Bland-Altman plot} comparing estimates and/or standard error data from different methods.  The Bland-Altman plot shows the difference of the estimate compared to the mean of the estimate (or likewise for 
the standard error) with a selected method as the comparator.  
The plots show the limits of agreement, that is, a plot of the difference versus the mean of each method 
compared with a comparator.  If there are more than 2 methods in the data set, for example methods A B and C, then the first method will be taken 
as the reference, and the {bf:siman blandaltman} plots will be created for method B - method A and method C - method A.  

{pstd}
{help siman setup} needs to be run first before {bf:siman blandaltman}.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{pstd}Load the data set in to {cmd: siman}.

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{pstd}Draw the Bland-Altman graph for a specific dgm {it:MCAR}

{phang}. {stata  `"siman blandaltman if dgm==1"'}

{pstd}The same, using the dgm value label

{phang}. {stata  `"siman blandaltman if dgm=="MCAR": dgm"'}

{pstd}Draw the Bland-Altman graphs to compare the standard errors between methods 1 ({it:Full}) and 3 ({it:MI}), changing the graph options

{phang}. {stata  `"siman blandaltman se, methlist(1 3) bygraphoptions(title("My Bland-Altman plot")) ytitle("test y-title") xtitle("test x-title") name("blandaltman", replace)"'}


{marker reference}{...}
{title:Reference}

{pstd}
Bland JM, Altman DG. Statistical methods for assessing agreement between two methods of clinical measurement. Lancet 1986;327:307-310. 
{browse "https://doi.org/10.1016/S0140-6736(86)90837-8"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}
