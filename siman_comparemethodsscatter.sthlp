{smcl}
{* *! version 0.10.1 8aug2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
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
{cmdab:siman comparemethodsscatter} [{it:varlist}] {ifin} 
[{cmd:,}
{it:options}]

{pstd}{it:varlist} may only include {it:estimate}, {it:se} or (with the slower 'combine' method) both.

{pstd}The subcommand {cmd:comparemethodsscatter} may be abbreviated to 3 or more characters or to {cmd:cms}.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and {bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt com:bine}}forces use of the slower 'combine' method: the graph is made by combining individual graphs, potentially showing both estimate and SE. This is the default with 2 or 3 methods.

{synopt:{opt mat:rix}}forces use of the faster 'matrix' method: the graph is made by {help graph matrix}, showing only estimate or SE. This is the default with more than 3 methods.

{synopt:{opt meth:list(string)}}specifies a subgroup of methods, and their order, to be graphed.
For example, in a dataset with methods A, B, C and D, the option {bf: methlist(B D)}, which would plot graphs for B vs. D, the same as using {bf:if method=="B" | method=="D"}. 
But the option {bf: methlist(D B)} would also change the ordering of the graphs.
{it:string} may be a numlist if method is numeric.

{synopt:{opt noeq:uality}}does not draw the line of equality when the combine method is used. The line of equality is never drawn when the matrix method is used.

{synopt:{it:graph_options}}most of the valid options for {help graph combine:graph combine} are available.

{synopt:{opt subgr:aphoptions(string)}}is relevant with the combine method: it changes the format of the constituent scatter graphs.
For example, to use the red plotting symbol with the combine method, use {bf:subgr(mcol(red))}; with the matrix method, use 
{bf:mcol(red)}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman comparemethodsscatter} draws sets of scatter plots comparing the point estimates or standard errors between various methods, where each point represents one repetition. 
The data pairs come from the same repetition 
(i.e. they are estimated in the same simulated dataset) and are compared to the line of equality.  
These graphs help the user to look for correlations between methods and any systematic differences. 
Where more than two methods are compared, a graph of every method versus every other is plotted.

{pstd}
The default graphing approach for 2 or 3 methods, "combine", plots both the estimate {it:and} the standard error. 
The upper triangle displays the estimates, the lower triangle displays the standard errors.  
The default graphing approach for more than 3 methods, "matrix", plots {it:either} the estimate {it:or} the standard error depending on 
which the user specifies, with the default being the estimate if no variables are specified.  The graph larger 
numbers of methods is plotted using the {help graph matrix} command. The default approach can be changed with the {cmd:combine} and {cmd:matrix} options.

{pstd}
If there are many methods in the data set and the user wishes to compare subsets of methods, then this can be 
achieved by using the {bf: methlist()} option.  
Note that the value needs to be entered in {bf: methlist()} and not the label 
(if these are different).  
For example if method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C, then 
{bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)}.  

{pstd}
{help siman setup} needs to be run first before {bf:siman comparemethodsscatter}.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 repetitions named simpaper1.dta available on the {cmd: siman} {browse "https://github.com/UCL/siman/":GitHub repository}.

{pstd}Load the data set in to {cmd:siman}

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{pstd}Default use: produces one graph for each DGM

{phang}. {stata  `"siman comparemethodsscatter"'}

{pstd}Draw only the graph for a specific dgm

{phang}. {stata  `"siman comparemethodsscatter if dgm ==2"'}

{pstd}The same, using the dgm value label

{phang}. {stata  `"siman comparemethodsscatter if dgm =="MAR": dgm"'}

{pstd}Compare only methods 1 ({it:Full}) and 3 ({it:MI}), and change the graph options

{phang}. {stata  `"siman comparemethodsscatter se, methlist(1 3) title("My title") name("cms", replace)"'}

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}
