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

{pstd}{it:performancemeasures} are the names of {help siman analyse##perfmeas:measures} for which performance has been calculated by {help siman analyse}. If not specified, performance is calculated for all measures that can be.

{pstd}
{opt if} should only be applied to variables defining {bf:dgm}, {bf:target} and/or {bf:method} from siman setup.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:olumn(varname)}}specifies which factors are placed in the columns.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman table} uses Stata’s {help tabdisp:tabdisp} to provide a summary of the performance statistics produced by {bf:{help siman analyse}}.
The output table lists the estimand(s) split by dgms, targets, methods and performance measures.

{pstd}
If {opt column()} is not specified, the column variable is decided as
follows. With more than one method, method is placed in the columns. Otherwise,
if there is more than one target, target is placed in the columns. Otherwise,
the first dgm variable is placed in the columns. All other variables are then
placed in the rows. However, if this leaves more than four ariables in the
rows, {cmd:siman table} exits with error.

{pstd}
Where there are two entries per row in the table, the first entry is the
performance statistic and the second is its Monte Carlo Standard Error (MCSE).  
MSCEs quantify the simulation uncertainty. They provide an estimate of the
standard error of the performance statistic, due to a finite number of
repetitions. For example, for the performance measure bias, the Monte-Carlo standard error shows the uncertainty around estimated bias.

{pstd}
{cmd:siman table} is called automatically by {help siman analyse} but can
be recalled once the performance statistics have been created by
{help siman analyse}.


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{pstd}{helpb siman: Return to main help page for siman}

