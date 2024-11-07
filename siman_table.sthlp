{smcl}
{* *! version 0.5 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_table##syntax"}{...}
{viewerjumpto "Description" "siman_table##description"}{...}
{viewerjumpto "Authors" "siman_table##authors"}{...}
{title:Title}

{phang}
{bf:siman table} {hline 2} Tabulates the performance measures data created by {bf:{help siman analyse}}


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman table} [{it:performancemeasures}] [if], [column({it:varname})]

{pstd}{it:performancemeasures} are the names of {help siman analyse##perfmeas:measures} for which performance has been calculated by {help siman analyse}. If not specified, performance is estimated for all measures that can be.

{pstd}
{opt if} should be applied to {bf:dgm}, {bf:target} and/or {bf:method} only.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:olumn(varname)}}specifies which factors are placed in the columns.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman table} uses the inbuilt Stata program {help tabdisp:tabdisp} to provide a summary of the performance measures created by {bf:{help siman analyse}}.
The output table lists the estimand(s) split by dgms, targets, methods and performance measures.

{pstd}
If {opt column()} is not specified, the column variable is decided as follows.
If there is more than one method, then method is placed in the columns.
Otherwise, if there is more than one target, target is placed in the columns.
Otherwise, the first dgm variable is placed in the columns.
All the other variables are then placed in the rows.
However, if this leaves more than four ariables in thge rows, {cmd:siman table} exits with error.

{pstd}
Where there are 2 entries per row in the table, the first entry is the performance measure value, 
and the second is the Monte Carlo Standard Error (MCSE).  
MSCEs quantify the simulation uncertainty.  
They provide an estimate of the standard error of the performance estimate, as a finite number of repetitions are used.  
For example, for the performance measure bias, the Monte-Carlo standard error shows the uncertainty around the estimate of the bias.

{pstd}
{cmd:siman table} is called automatically by {bf:{help siman analyse}}, 
but can also be called on its own once the performance measures data 
has been created by the {bf:siman} suite.


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}



