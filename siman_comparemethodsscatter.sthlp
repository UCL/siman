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
{bf:siman comparemethodsscatter} {hline 2} Scatter plot comparing estimates and/or standard error data for different methods


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman com:paremethodsscatter} [{cmd:estimate}] [{cmd:se}] {ifin} 
[{cmd:,}
{it:options}]

{pstd}If neither {cmd:estimate} nor {cmd:se} is specified, then {cmd:estimate} is assumed. If 
both are specified, then the estimates are compared in the top-right triangle and the SEs are compared in the
bottom triangle, provided the combine method is used (see below).

{pstd}The subcommand {cmd:comparemethodsscatter} may be abbreviated to three or more characters (e.g. {cmd:com}) or to {cmd:cms}.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and 
{bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt com:bine}}forces use of the slower "combine" method: the graph is made by combining 
individual graphs, potentially showing both estimate and SE. This is the default with 2 or 3 methods.{p_end}
{synopt:{opt mat:rix}}forces use of the faster "matrix" method: the graph is made by {help graph matrix}, 
showing only estimate or SE. This is the default with more than 3 methods.{p_end}
{synopt:{opt coll:apse(varlist)}}collapses the graphs over the specified variables.
By default, one graph is drawn per DGM and target. 
For example, in a setting with DGM defined by {cmd:dgmvar1 dgmvar2} and target defined by {cmd:targetvar}, 
specifying {cmd:collapse(dgmvar1)} would draw one graph for each value of {cmd:dgmvar2} and {cmd:target},
overlaying estimates or standard errors for different values of {cmd:dgmvar1}.{p_end}

{syntab:Graph options}
{synopt:{opt meth:list(string)}}specifies a subgroup of methods, and their order, to be graphed.
For example, in a dataset with methods A, B, C and D, the option {cmd:methlist(B D)}, which would plot 
graphs for B vs. D, the same as using {cmd:if method=="B" | method=="D"};
but the option {cmd:methlist(D B)} would also change the ordering of the graphs.
{it:string} may be a numlist if method is numeric.{p_end}
{synopt:{opt noeq:uality}}does not draw the line of equality when the combine method is used. The line of equality 
is never drawn when the matrix method is used.{p_end}
{synopt:{it:graph_options}}most options for {help graph combine:graph combine} are available.{p_end}
{synopt:{opt subgr:aphoptions(string)}}to change the format of the constituent scatter graphs, which are drawn
if and only if the "combine" method is used. For example, to use the red plotting symbol with the "combine" method,
use {bf:subgr(mcol(red))}; with the matrix method, use {bf:mcol(red)}.{p_end}

{syntab:Saving options}
{synopt:{opt name(string)}}the stub for the graph name, to which "_#" is appended, where # is the group number. Default is "cms".{p_end}
{synopt:{opt sav:ing}{it:(namestub[}{cmd:, replace}{it:])}}saves each graph to disk in Stata’s .gph format.
The graph name is {it:namestub} with "_#" appended, where # is the group number.{p_end}
{synopt:{opt exp:ort}{it:(filetype[}{cmd:, replace}{it:])}}exports each graph to disk in non-Stata format. 
{cmd:saving()} must also be specified. Each exported file name is the same as for {cmd:saving()} with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{cmd:siman comparemethodsscatter} draws sets of scatter plots comparing the point estimates (or standard errors) 
for various methods, where each point represents one repetition. It is assumed that data are paired in that they come from the same repetition,
i.e. they were estimated using the same simulated dataset, and are compared to the line of equality.
These graphs help the user to look for correlations between methods and any systematic differences.
Where more than two methods are compared, a graph comparing each pair of methods is plotted.

{pstd}
The default graphing approach for two or three methods, "combine", plots both the estimate {it:and} the standard error.
The upper triangle displays the estimates, the lower triangle displays the standard errors.  
The default graphing approach for more than 3 methods, "matrix", 
plots {it:either} the estimate {it:or} the standard error depending on 
which the user specifies, with the default being estimate if no variables are specified. The 
graph for the larger number of methods is plotted using the {help graph matrix} command. The 
default approach can be changed with the {cmd:combine} and {cmd:matrix} options.

{pstd}
If there are many methods in the data set and the user wishes to compare subsets of methods,
this can be achieved using the {bf: methlist()} option.  
Note that the value and not the label needs to be entered in {bf: methlist()} 
(if these are different).
For example if method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C,
then {bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)}.  

{pstd}
{help siman setup} needs to be run before {bf:siman comparemethodsscatter} can be used.


{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 DGMs (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1000 
repetitions named simcheck.dta available on the {cmd: siman} {browse "https://github.com/UCL/siman/":GitHub repository}.

{pstd}Load the data set in to {cmd:siman}

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata  "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

{pstd}Default use: produces one graph for each DGM

{phang}. {stata  `"siman comparemethodsscatter"'}

{pstd}Draw only the graph for a specific dgm

{phang}. {stata  "siman comparemethodsscatter if dgm ==2"}

{pstd} Or alternatively, to subset based on the dgm value {bf:label}:

{phang}. {stata  `"siman comparemethodsscatter if dgm =="MAR":dgm"'}

{pstd}Compare only methods 1 ({it:Full}) and 3 ({it:MI}), and change the graph options

{phang}. {stata  `"siman comparemethodsscatter se, methlist(1 3) title("My title") name("cms", replace)"'}

{pstd}Save graphs in Stata and pdf formats: file names will be mycms_#.gph and mycms_#.pdf for #=1,2,3

{phang}. {stata  `"siman comparemethodsscatter, saving(mycms, replace) export(pdf, replace)"'}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}

