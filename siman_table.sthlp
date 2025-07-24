{smcl}
{* *! version 1.0 24jul2025}{...}
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
{synopt:{opt c:olumn(varlist)}}specifies factor(s) (i.e. which of {it:dgmvars}, {it:target}, {it:method} and {bf:_performancemeasure}) 
to be placed in the columns. Default is target and method. The
rightmost factor will be fastest-changing in the table. Only two variables may be specified when {help tabdisp} is used to create the table.{p_end}
{synopt:{opt r:ow(varlist)}}specifies factor(s) (i.e. which of {it:dgmvars}, {it:target}, {it:method} and {bf:_performancemeasure})
to be placed in the rows. Default is performance measure. The
rightmost factor will be fastest-changing in the table.{p_end}
{synopt:{opt nomc:se}}omit Monte Carlo standard errors from the table.{p_end}
{synopt:{opt mcci}}add Monte Carlo confidence intervals to the table.{p_end}
{synopt:{opt mcl:evel(#)}}specifies the level for Monte Carlo confidence intervals. Default is as explained in {help level}.{p_end}
{synopt:{opt tabd:isp}}use {help tabdisp} to create the table: this is the default, and required, in Stata versions < 17.{p_end}
{synopt:{opt tabl:e}}use {help table} to create the table: this is the default in Stata versions 17+.{p_end}
{synopt:{it:table options}}many options for {help tabdisp}, e.g. {cmd:stubwidth(20)}, or {help table}, e.g. {cmd:nformat(%6.3f)}.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman table} displays the performance statistics produced by {bf:{help siman analyse}}.
The output table lists the estimand(s) split by dgms, targets, methods and performance measures.
If you are running Stata 17 or higher, the default is to use {help table}.
Otherwise, the default is to use {help tabdisp}.

{pstd}
Usually, there are two entries per row in the table: the first entry is the
performance statistic and the second is its Monte Carlo Standard Error (MCSE).  
MSCEs quantify the simulation uncertainty. They provide an estimate of the
standard error of the performance statistic, due to a finite number of
repetitions. For example, for the performance measure bias, the Monte Carlo 
standard error shows the uncertainty around the estimated bias.

{pstd}
Both {help siman setup} and {help siman analyse} need to be run before {bf:siman table} can be used.

{pstd}
{cmd:siman table} is called automatically by {help siman analyse} but can
be recalled once the performance statistics have been created by
{help siman analyse}.

{pstd}For examples, see {bf:{help siman analyse##examples:siman analyse}}.


{marker examples}{...}
{title:Examples}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{phang}. {stata "siman analyse"}

{pstd}Standard use:

{phang}. {stata "siman table"}

{pstd}The table is quite long. We could shorten it by selecting just three performance measures:

{phang}. {stata "siman table bias empse modelse"}

{pstd}We could choose to display 90% Monte Carlo confidence intervals:

{phang}. {stata "siman table bias empse cover, nomcse mcci mclevel(90)"}

{pstd}We could rearrange the table rows and columns:

{phang}. {stata "siman table bias empse modelse, col(estimand _p) row(dgm method)"}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL, London, UK.{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL, London, UK.{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}


{title:See Also}

{p}{helpb siman: Return to main help page for siman}

