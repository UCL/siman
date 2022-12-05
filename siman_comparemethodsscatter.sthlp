{smcl}
{* *! version 1.4 21nov2022}{...}
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
{cmdab:siman comparemethodsscatter} [estimate|se] {ifin} 
[{cmd:,}
{it:options}]

{pstd}The scatter graph will be drawn for estimate {it:and} se if the number of methods is <= 3.  Alternatively the user can select estimate {it:or} se for more than 3 methods.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{pstd}
{p_end}
{synopt:{opt if/in}}  The user can specify {bf:if} and {bf:in} within the {bf:siman comparemethodsscatter} syntax. If these are not specified, but have already been used earlier in {help siman_setup:siman setup}, 
then the {bf:if/in} from {help siman_setup:siman setup} will be used.
The {bf:if} option will only apply to {bf:dgm}, {bf:target} and {bf:method}.  The {bf:if} option is not allowed to be used on 
{bf:repetition} and an error message will be issued if the user tries to do so.

{pstd}
{p_end}
{synopt:{opt by(string)}}  specifies the nesting of the variables.  Only {bf: by(target)} is allowed for {cmd: siman comparemethodsscatter}.

{syntab:Graph options}
{pstd}
{p_end}

{pstd}{it:For the siman comparemethodsscatter graph user-inputted options, most of the valid options for {help graph combine:graph combine} are available.}
{p_end}
{pstd} Additionally, if the user would like to change the appearance of the constituent graphs, {cmd: subgraphoptions()} can be used.
{p_end}

{pstd}
{p_end}
{synopt:{opt subgr:aphoptions(string)}} to change the format of the constituent scatter graphs.

{pstd}
{p_end}
{synopt:{opt m:ethlist(string)}}  if the user would like to display the graphs for a subgroup of methods, these methods can be specified in {bf: methlist()}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman comparemethodsscatter} draws sets of scatter plots comparing the point estimates data or standard error data for various methods, where each point represents one repetition. The data pairs come from the same repetition (ie. they are estimated in the same simulated dataset) and are compared to the line of equality.  These graphs help the user to look for correlations between methods and any systematic differences. Where more
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

{pstd}To display the graph in the economist colour scheme:

{pstd}siman comparemethodsscatter, scheme(economist)  

{pstd}For a dataset containing methods 1-9, to compare methods 1, 3, 8 and 9 for standard error only, and to display the graphs by target:

{pstd}siman comparemethodsscatter se, methlist(1 3 8 9) by(target)  

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

