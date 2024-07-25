{smcl}
{* *! version 1.6 03oct2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
{viewerjumpto "Syntax" "siman_comparemethodsscatter##syntax"}{...}
{viewerjumpto "Description" "siman_comparemethodsscatter##description"}{...}
{viewerjumpto "Examples" "siman_comparemethodsscatter##examples"}{...}
{viewerjumpto "Authors" "siman_comparemethodsscatter##authors"}{...}
{viewerjumpto "See also" "siman_comparemethodsscatter##seealso"}{...}
{title:Title}

{phang}
{bf:siman comparemethodsscatter} {hline 2} Scatter plot comparing estimates and/or standard error data for different methods.


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman comparemethodsscatter} [estimate] [se] {ifin} 
[{cmd:,}
{it:options}]

{pstd}The scatter graph will be drawn for estimate {it:and} se if and only if the number of methods is <= 3.  Alternatively the user can select estimate {it:or} se for more than 3 methods.

{pstd}The subcommand {cmd:comparemethodsscatter} may be abbreviated to 3 or more characters or to {cmd:cms}.

{pstd}
The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not to {bf:repetition}. A warning is issued if this is breached.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{syntab:Graph options}

{synopt:{opt com:bine(string)}}forces use of the 'combine' method: the graph is made by combining individual graphs, potentially showing both estimate and SE. This is the default for 2 or 3 methods.

{synopt:{opt mat:rix(string)}}forces use of the 'matrix' method: the graph is made by {help graph matrix}, showing only estimate or SE. This is the default for more than 3 methods.

{synopt:{opt meth:list(string)}}specifies a subgroup of methods, and their order, to be graphed.
For example, in a dataset with methods A, B, C and D, the option {bf: methlist(B D)}, which would plot graphs for B vs. D, the same as using {bf:if method=="B" | method=="D"}. 
But the option {bf: methlist(D B)} would also change the ordering of the graphs.

{synopt:{opt noeq:uality}}does not draw the line of equality when the combine method is used. The line of equality is never drawn when the matrix method is used.

{synopt:{it:graph_options}}most of the valid options for {help graph combine:graph combine} are available.

{synopt:{opt subgr:aphoptions(string)}}to change the format of the constituent scatter graphs, which are drawn if and only if the combine method is used.
Therefore, for example, if the user wishes to use the red plotting symbol, with the combine method then {bf:subgr(mcol(red))} must be used, with the matrix method then 
{bf:mcol(red)} must be used.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman comparemethodsscatter} draws sets of scatter plots comparing the point estimates data or standard error data for various methods, where each point represents one repetition. The data pairs come from the same repetition 
(ie. they are estimated in the same simulated dataset) and are compared to the line of equality.  
These graphs help the user to look for correlations between methods and any systematic differences. Where more
than two methods are compared, a graph of every method versus every other is plotted.

{pstd}
For up to 3 methods (inclusive), {bf:siman comparemethodsscatter} will plot both the estimate {it:and} the standard error. 
The upper triangle will display the estimate data, the lower triangle will display the standard error data.  
For more than 3 methods, {bf:siman comparemethodsscatter} will plot either the estimate {it:or} the standard error depending on 
which the user specifies, with the default being estimate if no variables are specified.  The graph for the larger 
number of methods is plotted using the {help graph matrix:graph matrix} command. 

{pstd}
If there are many methods in the data set and the user wishes to compare subsets of methods, then this can be 
achieved by using the {bf: methlist()} option.  Please note however that if your data has underscores, for example 
wide-wide data where the method and target are both in the variable name such as 
estA_beta estA_gamma estB_beta estB_gamma estC_beta estC_gamma, then in {help siman_setup:siman setup}, you 
would have specified {bf:method(A_ B_ C_)}.
However if you would then like to graph a subset of methods A and B with {bf:siman comparemethodsscatter} then you would 
enter {bf:methlist(A B)} [not {bf: methlist(A_ B_)}].  

{pstd}
Note also that the value needs to be entered in to {bf: methlist()} and not the label 
(if these are different).  For example if instead method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C, then 
{bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)}.  The {bf: methlist()} option needs to be specified to subset on methods, 
using <= and >= will not work.  The components of {bf: methlist()}  need to be written out in full, for example {bf: methlist(1 2 3 4)} and not
{bf: methlist(1/4)}.

{pstd}
The graphs are split out by dgm (one graph per dgm) and they compare the methods to each other.  Therefore the only 
other option to split the graphs with the {bf:by} option is by target, so the {bf:by(varlist)} option will only allow {bf:by(target)}.

{pstd}
The {bf:labelsof} package (by Ben Jann) is required by {bf:siman comparemethodsscatter}, which can be installed by clicking: {stata ssc install labelsof}

{pstd}
Please note that {help siman_setup:siman setup} needs to be run first before {bf:siman comparemethodsscatter}.

{pstd}
For further troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{pstd} To plot the {bf: comparemethodsscatter (cms)} graph, first load the data set in to {cmd: siman}.

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{pstd} To display the {bf: cms} graphs by a specific dgm {it:MAR}, where dgm is defined by more than one variable:

{phang}. {stata  `"siman comparemethodsscatter if dgm ==2"'}

{pstd} Or alternatively, to subset based on the dgm value label:

{phang}. {stata  `"siman comparemethodsscatter if dgm =="MAR": dgm"'}

{pstd} To display {bf: cms} graphs for the standard errors with the difference of methods 3 ({it:MI}) - 1 ({it:Full}) only, and changing the graph options:

{phang}. {stata  `"siman comparemethodsscatter se, methlist(1 3) title("My title") name("cms", replace)"'}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

{marker seealso}{...}
{title:See Also}

{pstd}{help labelsof} (if installed)


{pstd}{helpb siman: Return to main help page for siman}

