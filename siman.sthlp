{smcl}
{* *! version 0.1  4May2018}{...}
{vieweralsosee "simulate" "help simulate"}{...}
{vieweralsosee "post" "help post"}{...}
{viewerjumpto "Description" "sim##description"}{...}
{viewerjumpto "Components" "sim##components"}{...}

{title:Title}

{phang}
{bf:siman} {hline 2} Commands for the analysis and visual exploration of simulation results


{marker description}{...}
{title:Description}

{pstd}
The {cmd:siman} suite of commands handles the analysis of
'estimates' data as output by simulation studies.

{pstd}
An 'estimates dataset' (see Morris, White and Crowther)
refers to a dataset containing summaries of results
from individual repetitions of a simulation experiment.
Such data may consist of, for example, parameter
estimates, standard errors, degrees of freedom, an
indicator of rejection of a hypothesis, and more.


{title:Components}{marker components}

Setting up

{col 4}{bf:{help siman_set:siman set}}{...}
{col 24}declare data as simulation results in preparation for analysis

Graphics based on estimates data

{col 4}{bf:{help siman_swarm:siman swarm}}{...}
{col 24}swarm plot of individual estimates or of model standard errors

{col 4}{bf:{help siman_scatter:siman scatter {it:type}}}{...}
{col 24}scatter plots of simulation results, where {it:type} is one of:

{col 8}{bf:{help siman_scatter:modse est}}{...}
{col 28}plot of the model standard error against estimate

{col 8}{bf:{help siman_scatter:ests method}}{...}
{col 28}matrix of estimates comparing methods within a repetition

{col 8}{bf:{help siman_scatter:bland-altman}}{...}
{col 28}

{col 4}{bf:{help siman_zipplot:zipplot}}{...}
{col 24}

Analysis of simulation results to estimate performance measures including Monte Carlo error

{col 4}{bf:{help siman_simsum:siman sum}}{...}
{col 24}functions using simsum, but will be developed.

Graphics based on simulation results

{col 4}{bf:{help siman_lollyplot:lollyplot}}{...}
{col 30}

{col 4}{bf:{help siman_nestloop:nestloop}}{...}
{col 30}


{title:Data formats}
{pstd}

Estimates data are expected to appear in one of the following formats:
long, wide, or longsep (described below). Note that 'rep' indexes the 
repetition number, 'dgm' denotes the data-generating mechanism to which 
a method was applied, and 'method' denotes the method used to produce 
the estimates.

           Format {it:long}
        {c TLC}{hline 38}{c TRC}
        {c |} {it:rep  dgm  method  estimate    se  df} {c |}
        {c |}{hline 38}{c |}
        {c |}   1    1       a     .7067 .1465  98 {c |}
        {c |}   1    1       b     .7124 .1411  99 {c |}
        {c |}   1    2       a     .3485 .1599 798 {c |}
        {c |}   1    2       b     .4287 .1358 799 {c |}
        {c |}   2    1       a     .6495 .1522  98 {c |}
        {c |}   2    1       b     .5604 .1169  99 {c |}
        {c |}   2    2       a     .4321 .1263 798 {c |}
        {c |}   2    2       b     .4922 .1179 799 {c |}
        {c BLC}{hline 38}{c BRC}

           Format {it:wide}
        {c TLC}{hline 63}{c TRC}
        {c |} {it:rep  dgm  method  estimatea   sea  dfa  estimateb    seb  dfb} {c |}
        {c |}{hline 63}{c |}
        {c |}   1    1       a     .7067  .1465   98      .7124  .1411   99 {c |}
        {c |}   1    2       a     .3485  .1599  798      .4287  .1358  799 {c |}
        {c |}   2    1       a     .6495  .1522   98      .5604  .1169   99 {c |}
        {c |}   2    2       a     .4321  .1263  798      .4922  .1179  799 {c |}
        {c BLC}{hline 63}{c BRC}

           Format {it:longsep}
           File {it:dgm1}
        {c TLC}{hline 33}{c TRC}
        {c |} {it:rep  method  estimate    se  df} {c |}
        {c |}{hline 33}{c |}
        {c |}   1       a     .7067 .1465  98 {c |}
        {c |}   1       b     .7124 .1411  99 {c |}
        {c |}   2       a     .6495 .1522  98 {c |}
        {c |}   2       b     .5604 .1169  99 {c |}
        {c BLC}{hline 33}{c BRC}
           File {it:dgm2}
        {c TLC}{hline 33}{c TRC}
        {c |} {it:rep  method  estimate    se  df} {c |}
        {c |}{hline 33}{c |}
        {c |}   1       a     .3485 .1599 798 {c |}
        {c |}   1       b     .4287 .1358 799 {c |}
        {c |}   2       a     .4321 .1263 798 {c |}
        {c |}   2       b     .4922 .1179 799 {c |}
        {c BLC}{hline 33}{c BRC}



{title:References}

{pstd}
Morris TP, White IR, Crowther MJ. Using simulation studies to evaluate statistical methods. https://arxiv.org/abs/1712.03198

{pstd}
White IR. simsum: Analyses of simulation studies including monte carlo error. {it: The Stata Journal}, 10(3):369-385, 2010.

{pstd}
Rucker G, Schwarzer G. Presenting simulation results in a nested loop plot. {it:BMC Medical Research Methodology}, 14(1):129+, 2014.


{title:Authors}

{pstd}
Tim Morris, MRC Clinical Trials Unit at UCL, London UK
{break}
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}
{break}
Twitter: {browse "https://twitter.com/tmorris_mrc":@tmorris_mrc}

{pstd}
Ian White, MRC Clinical Trials Unit at UCL, London UK
{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}


{title:Also see}

    {helpb simulate}
    {helpb post}
    {helpb simsum} (if installed)
{break}