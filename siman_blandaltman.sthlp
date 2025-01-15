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
{bf:siman blandaltman} {hline 2} Bland–Altman plot comparing point estimates or standard errors for pairs of methods.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:siman blandaltman} [estimate|se] {ifin}
[{cmd:,}
{it:options}]

{pstd}If no variables are specified, then the {bf: blandaltman} graph will be drawn for {it:estimates} only.  Alternatively the user can select {it:se} or {it:estimate se}.

{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{pstd}
{p_end}
{synopt:{opt if/in}} The user can specify {help if} and/or {help in} within the siman
blandaltman syntax. If they do not, but specified {ifin} conditions during {help siman setup},
these will be inherited from {help siman setup}. The {bf:if} option should only be applied to
{bf:dgm} and {bf:target}, use the {bf: methlist()} option to subset on method. The {help if}
condition is not allowed on {bf:repetition} and an error message will be issued if the user tries to do so.{p_end}
{synopt:{opt by(string)}} specifies the nesting of the variables, only {bf:by(dgm)}
is allowed for {cmd: siman blandaltman} for example when dgm is defined by more than one
variable. The user is able to use the {it:if} statement to filter on target, and {bf: methlist()} for method.{p_end}
{synopt:{opt name(string)}} the stub for the graph name, to which "_#_estimate" or "_#_se"
is appended (depending on whether {cmd:siman blandaltman estimate} or {cmd:siman blandaltman se} has been used). Default stub is "blandaltman".{p_end}

{syntab:Graph options}

{pstd}{it:Note: For the siman blandaltman graph user-inputted options, most of the valid options for {help scatter:scatter} are available.}

{pstd}
{p_end}
{synopt:{opt bygr:aphoptions(string)}}graph options for the nesting of the graphs due to the {it:by} option.{p_end}
{synopt:{opt m:ethlist(string)}}to display the graphs only for a subgroup of methods, these can be specified in {bf: methlist()}. For example, in a dataset with methods A, B, C and D if the user would like to compare 
methods A and C, they would enter {bf: methlist(A C)}, which would plot graphs for the difference C - A.
Note that the value needs to be entered in to {bf: methlist()} and not its label 
(if these are different). For example, if method is a numeric labelled variable with values 1, 2, 3 and corresponding labels A, B, and C, then 
{bf: methlist(1 2)} would need to be entered instead of {bf: methlist(A B)} (note siman blandaltman will use the labels). The {bf: methlist()} option needs to be specified to subset on methods, 
using <= and >= will not work. The components of {bf: methlist()}  need to be written out in full, for example {bf: methlist(1 2 3 4)} and not as a numlist such as {bf: methlist(1/4)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman blandaltman} draws a Bland–Altman plots comparing estimates and/or standard error data from different methods.
The plot is of the difference between two methods versus the mean the two methods. It is assumed that data are paired in that they come from the same repetition,
i.e. they were estimated using the same simulated dataset.
Where there are more than two methods in the data set, for example if methods A B and C are specified by {opt methlist(A B C)}, the first method, A, will be taken 
as the reference, and the {bf:siman blandaltman} plots will be created for method B versus method A and method C versus method A.

{pstd}
{help siman setup} needs to be run before {bf:siman blandaltman} can be run.

{pstd}
For further troubleshooting and limitations, see {help siman setup##limitations:troubleshooting and limitations}.

{marker examples}{...}
{title:Examples}

{pstd} An example estimates data set with 3 dgms (MCAR, MAR, MNAR) and 3 methods (Full, CCA, MI) with 1,000 repetitions named simpaper1.dta available on the {cmd: siman} GitHub repository {browse "https://github.com/UCL/siman/":here}.

{pstd} To plot the Bland-Altman graph, first load the data set in to {cmd: siman}.

{phang}. {stata  "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang}. {stata  "siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{pstd} To display the Bland-Altman graphs by a specific dgm {it:MCAR}, where dgm is defined by more than one variable:

{phang}. {stata  `"siman blandaltman if dgm ==1"'}

{pstd} Or alternatively, to subset based on the dgm value label:

{phang}. {stata  `"siman blandaltman if dgm =="MCAR": dgm"'}

{pstd} To display Bland-Altman graphs for the standard errors with the difference of methods 3 ({it:MI}) - 1 ({it:Full}) only, and changing the graph options:

{phang}. {stata  `"siman blandaltman se, methlist(1 3) bygraphoptions(title("My Bland-Altman plot")) ytitle("test y-title") xtitle("test x-title") name("blandaltman", replace)"'}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

