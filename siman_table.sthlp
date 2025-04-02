{smcl}
{* *! version 0.5 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_table##syntax"}{...}
{viewerjumpto "Description" "siman_table##description"}{...}
{viewerjumpto "Examples" "siman_table##examples"}{...}
{viewerjumpto "Authors" "siman_table##authors"}{...}
{title:Title}

{phang}
{bf:siman table} {hline 2} Tabulates the performance measures data previously computed by {bf:{help siman analyse}}


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:siman tab:le} [{it:performancemeasures}] [if], [{it:options}]

{pstd}{it:performancemeasures} are the names of {help siman analyse##perfmeas:measures} 
for which performance has been calculated by {help siman analyse}. If not specified, 
performance is displayed for all available measures.

{pstd}
{opt if} must only be applied to variables defining {bf:dgm}, {bf:target} and/or {bf:method} from siman setup.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:olumn(varname)}}specifies one or two factors (i.e. which of {bf:dgm}, {bf:target} and/or {bf:method}) 
to be placed in the columns.{p_end}
{synopt:{opt nomc:se}}omit Monte Carlo standard errors from the table.{p_end}
{synopt:{opt mcci}}add Monte Carlo confidence intervals to the table.{p_end}
{synopt:{opt l:evel(#)}}specifies the level for Monte Carlo confidence intervals. Default is as explained in {help level}.{p_end}
{synopt:{it:tabdisp_options}}many options for {help tabdisp}, e.g. {cmd:stubwidth(20)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman table} uses Stata’s {help tabdisp:tabdisp} to provide a summary 
of the performance statistics produced by {bf:{help siman analyse}}.
The output table lists the estimand(s) split by dgms, targets, methods and performance measures.

{pstd}
If {opt column()} is not specified, the column variable is decided as
follows. With more than one method, method is placed in the columns. Otherwise,
if there is more than one target, target is placed in the columns. Otherwise,
the first dgm variable is placed in the columns. All other variables are then
placed in the rows. However, if this leaves more than four ariables in the
rows, {cmd:siman table} exits with error.

{pstd}
Usually, there are two entries per row in the table: the first entry is the
performance statistic and the second is its Monte Carlo Standard Error (MCSE).  
MSCEs quantify the simulation uncertainty. They provide an estimate of the
standard error of the performance statistic, due to a finite number of
repetitions. For example, for the performance measure bias, the Monte Carlo 
standard error shows the uncertainty around the estimated bias.

{pstd}
{cmd:siman table} is called automatically by {help siman analyse} but can
be recalled once the performance statistics have been created by
{help siman analyse}.

{pstd}For examples, see {bf:{help siman analyse##examples:siman analyse}}.


{marker examples}{...}
{title:Examples}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{phang}. {stata "siman analyse, notable"}

{pstd}Standard use:

{phang}. {stata "siman table"}

{pstd}The table is too long and narrow. Improve it by putting estimand as well 
as method in the columns, and showing results for only dgm 1:

{phang}. {stata "siman table if dgm==1, column(estimand method)"}

{pstd}Or shorten it by omitting Monte Carlo standard errors and giving more space for the names of the performance measures:

{phang}. {stata "siman table, column(estimand method) nomcse stubwidth(20)"}



{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{p}{helpb siman: Return to main help page for siman}

