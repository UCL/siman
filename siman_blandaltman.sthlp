{smcl}
{* *! version 1.0 24jul2025}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_blandaltman##syntax"}{...}
{viewerjumpto "Description" "siman_blandaltman##description"}{...}
{viewerjumpto "Examples" "siman_blandaltman##examples"}{...}
{viewerjumpto "Authors" "siman_blandaltman##authors"}{...}
{title:Title}

{phang}
{bf:siman blandaltman} {hline 2} Bland–Altman plot comparing point estimates or standard errors for pairs of methods.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman bla:ndaltman} [{cmd:estimate}] [{cmd:se}] {ifin}
[{cmd:,}
{it:options}]

{pstd}If neither {cmd:estimate} nor {cmd:se} is specified, this is equivalent to {cmd:siman blandaltman estimate}. If both are specified, {cmd:siman blandaltman} will draw a graph for each.

{pstd}The {it:if} and {it:in} conditions should usually apply only to {bf:dgm}, {bf:target} and 
{bf:method}, and not e.g. to {bf:repetition}. A warning is issued if this is breached.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt by(varlist)}}specifies the variable(s) defining the scatterplot panels. 
The default is to draw the graph {cmd:by(}{it:method}{cmd:)}, with one graph per DGM and target.
Specifying for example {cmd:by(}{it:target method}{cmd:)} will combine the different targets into the same graph.
Do not exclude {it:method} from the {cmd:by()} option.

{syntab:Graph options}
{synopt:{it:graph_options}}options for {help scatter} that do not go inside its {cmd:by()} option.{p_end}
{synopt:{opt bygr:aphoptions(string)}}options for {help scatter} that go inside its {cmd:by()} option.{p_end}
{synopt:{opt m:ethlist(string)}}display the graphs for a subgroup of methods.  
For example, in a dataset with methods A, B, C and D, if the user would like to compare 
methods A and C, they would enter {bf: methlist(A C)}, which would plot graphs for the difference C - A.
Note that the value needs to be entered in to {bf: methlist()} and not the label 
(if these are different).  For example if method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C, then 
{bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)}.  The {bf: methlist()} option needs to be specified to subset on methods, 
using <= and >= will not work.  The components of {bf: methlist()}  need to be written out in full, for example {bf: methlist(1 2 3 4)} and not
{bf: methlist(1/4)}.{p_end}

{syntab:Saving options}
{synopt:{opt name}({it:namestub}[{cmd:, replace}])}the stub for the graph name, to which "_#_estimate" or "_#_se" is appended, 
where # is the group number. Default is "blandaltman".{p_end}
{synopt:{opt sav:ing}{it:(namestub[}{cmd:, replace}{it:])}}saves each graph to disk in Stata’s .gph 
format. The graph name is {it:namestub} with "_#_estimate" or "_#_se" appended, where # is the group number. Default is "blandaltman".{p_end}
{synopt:{opt exp:ort}({it:filetype}[{cmd:, replace}])}exports each graph to disk in non-Stata 
format. {cmd:saving()} must also be specified. Each exported file name is the same as for {cmd:saving()} 
with the appropriate 
filetype, which must be one of the suffices listed in {help graph export}.{p_end}
{synopt:{opt pause}}pauses before drawing each graph, if {help pause} is on. The user can 
press F9 to view the graph command, and may edit it to create more customised graphs.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman blandaltman} draws a {help siman_blandaltman##reference:Bland-Altman plot} comparing estimates 
and/or standard error data from different methods.  The Bland-Altman plot shows the difference of the 
estimate compared to the mean of the estimate (or likewise for 
the standard error) with a selected method as the comparator.  
The plots show the limits of agreement, that is, a plot of the difference versus the mean of each method 
compared with a comparator.  If there are more than 2 methods in the data set, for example methods A B and C, then the first method will be taken 
as the reference, and the {bf:siman blandaltman} plots will be created for method B - method A and method C - method A.  

{pstd}
{help siman setup} needs to be run before {bf:siman blandaltman} can be used.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1,000 
repetitions named simcheck.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{pstd}Load the data set in to {cmd: siman}.

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simcheck.dta, clear"}

{phang}. {stata  "siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)"}

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

{pstd}See {help siman##updates:main help page for siman}.


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

