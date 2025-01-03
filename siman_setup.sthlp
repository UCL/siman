{smcl}
{* *! version 0.11 14oct2024}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Input data formats" "siman_setup##data"}{...}
{viewerjumpto "Syntax" "siman_setup##syntax"}{...}
{viewerjumpto "Description" "siman_setup##description"}{...}
{viewerjumpto "Output data format" "siman_setup##outputdata"}{...}
{viewerjumpto "Troubleshooting and limitations" "siman_setup##limitations"}{...}
{viewerjumpto "Examples" "siman_setup##examples"}{...}
{viewerjumpto "Characteristics stored" "siman_setup##chars"}{...}
{viewerjumpto "Authors" "siman_setup##authors"}{...}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:siman setup} - Prepare data for siman suite}{p_end}
{p2colreset}{...}


{marker data}{...}
{title:Input data formats}

{pstd}
The input data for {cmd:siman setup} is an estimates data set.  
This contains the results from analysing multiple simulated data sets, each one termed a repetition ({bf:rep}).
Each result relates to one simulation combination of data generating method ({bf:dgm}), {bf:target} and {bf:method}.
  
{pstd}The input data can be in any of these formats:

{pstd}
(1) long-long format (long targets, long methods): one record per repetition, target and method.

{pstd}
(2) long-wide format (long targets, wide methods): one record per repetition and target.

{pstd}
(3) wide-long format (wide targets, long methods): one record per repetition and method.

{pstd}
(4) wide-wide format (wide targets, wide methods): one record per repetition.


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmdab:siman setup}
{ifin}
{cmd:,}
{opt r:ep(varname)}
[{cmd:}
{it:options}
]

{pstd}
Options for input data in long-long format (data format 1):

{pmore}
{opt tar:get(varname)}
{opt meth:od(varname)}
{opt est:imate(varname)}
{opt se(varname)}
{opt df(varname)}
{opt lci(varname)}
{opt uci(varname)}
{opt p(varname)}
{opt true(#|varname)}

{pstd}
Options for input data in long-wide format (data format 2):

{pmore}
{opt tar:get(varname)}
{opt meth:od(values)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt p(stub_varname)}
{opt true(#|stub_varname)}
{opt sep(string)}

{pstd}
Options for input data in wide-long format (data format 3):

{pmore}
{opt tar:get(values)}
{opt meth:od(varname)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt p(stub_varname)}
{opt true(#|stub_varname)}
{opt sep(string)}

{pstd}
Options for input data in wide-wide format (data format 4):

{pmore}
{opt tar:get(values)}
{opt meth:od(values)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt p(stub_varname)}
{opt true(#|stub_varname)}
{opt ord:er(varname)}
{opt sep(string)}

{pstd}
In each format, at least one of {opt estimate()} and {opt se()} is required.

{pstd}
Options for data in any input format:

{pmore}
{opt dgm(varlist)}
{opt clear}
{opt dgmmi:ssingok}

 
{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt r:ep(varname)}}numeric variable identifying repetitions: required. {p_end}
{synopt:{opt dgm(varlist)}}variable(s) identifying the data generating mechanism. {p_end}
{synopt:{opt tar:get(varname|values)}}the target variable name (data formats 1/3) or values (data formats 2/4). {p_end}
{synopt:{opt meth:od(varname|values)}}the method variable name (data formats 1/4) or values (data formats 2/3). {p_end}
{synopt:{opt est:imate(varname|stub_varname)}}the estimate variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt se(varname|stub_varname)}}the standard error variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt df(varname|stub_varname)}}the degrees of freedom variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt lci(varname|stub_varname)}}the lower confidence interval variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt uci(varname|stub_varname)}}the upper confidence interval variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt p(varname|stub_varname)}}the P-value variable name (data format 1) or the name of its stub (data formats 2-4). {p_end}
{synopt:{opt true(#|varname|stub_varname)}}the true value of each target, given as a number, as the variable name (data format 1/3), or as the name of its stub (data formats 2/4). 
The true value should be the same for all methods: this is assumed in data formats 2/3 and must be true in data formats 1/4. {p_end}
{synopt:{opt ord:er(varname)}}only needed in wide-wide format: this must be either {it:target} or {it:method}, 
denoting that either the target stub is first or the method stub is first in the variable names. {p_end}
{synopt:{opt clear}}clears the existing data held in memory: only needed with {cmd:if} or {cmd:in} conditions. {p_end}
{synopt:{opt sep(string)}}a separator within wide-format variable names. 
For example, if variables est_beta and est_gamma hold the estimates for targets  beta and gamma, you could code {cmd:estimate(est) sep(_) target(beta gamma)} instead of {cmd:estimate(est) target(_beta _gamma)}. {p_end}
{synopt:{opt dgmmi:ssingok}}the dgm variables may contain missing values. {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman setup} takes the user’s raw simulation data (estimates data set) and puts it in the format required by {cmd:siman}. 

{pstd}
The raw simulation data set must include a numeric variable, {opt rep(varname)}, which indexes the repetitions of the simulation experiment.  
Other variables of interest that are typically specified to describe the repetition are
one or more variables identifying the data generating mechanism ({opt dgm});
the {opt target} which identifies the different quantities that can be estimated in the analysis; and
the {opt method} which identifies the different methods of analysis.
Results of the analysis typically include the {opt estimate} and its standard error ({opt se}).
 
{pstd}
Four data set formats are permitted by the siman suite as detailed {help siman setup##data:above}.
{cmd:siman setup} automatically reshapes the data into long-long format. 

{pstd}
{cmd:siman setup} checks the data, reformats it if necessary,
and attaches characteristics to the data set: these characteristics are read by every other {bf:siman} command.  
The {bf:siman} estimates data set is held in memory.
A summary of the data setup is printed, and can be repeated using  {bf:{help siman describe}}. 


{marker outputdata}{...}
{title:Output data format}

{pstd}
Estimates data are converted by {cmd:siman setup} to be {it:long-long}. 
The example below shows two repetitions in a simulation experiment with two data-generating mechanisms (labelled 1, 2),
two targets (beta, gamma), and two methods of analysis (A, B).

        {c TLC}{hline 42}{c TRC}
        {c |} {it:rep  dgm  target method  estimate  se   } {c |}
        {c |}{hline 42}{c |}
        {c |}   1    1   beta    A     .1433   .0774   {c |}
        {c |}   1    1   beta    B     .2338   .1104   {c |}
        {c |}   1    1   gamma   A     .0517   .0810   {c |}
        {c |}   1    1   gamma   B     .1375   .1167   {c |}
        {c |}   1    2   beta    A     .1135   .0946   {c |}
        {c |}   1    2   beta    B     .1543   .1400   {c |}
        {c |}   1    2   gamma   A     .0597   .0935   {c |}
        {c |}   1    2   gamma   B     .1588   .1347   {c |}
        {c |}   2    1   beta    A     .1509   .0768   {c |}
        {c |}   2    1   beta    B     .0784   .1087   {c |} 
        {c |}   2    1   gamma   A     .0297   .0738   {c |}
        {c |}   2    1   gamma   B     .1310   .1116   {c |}
        {c |}   2    2   beta    A     .1337   .0928   {c |}
        {c |}   2    2   beta    B     .1541   .1324   {c |}
        {c |}   2    2   gamma   A     .0343   .0852   {c |}
        {c |}   2    2   gamma   B     .1513   .1289   {c |}
        {c BLC}{hline 42}{c BRC}


{marker limitations}{...}
{title:Troubleshooting and limitations}

{pstd}If the method variable is not specified, then {cmd:siman setup} creates a variable {bf:_method} in the dataset with a value of 1 in order that all the other {bf: siman} programs can run.

{pstd}Selecting on dgm variables with non-integer values can cause problems. 
For example, {cmd:siman scatter if pmiss==0.2} may show no observations.
We recommend {cmd:siman scatter if float(pmiss)==float(0.2)} to be safe.

{pstd}'Estimates' data containing just p-values are not currently allowed.


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
We will use an estimates dataset in different formats.
It contains 1000 repetitions (variable rep = 1-1000) for each of two dgms (variable dgm = 1/2).
Targets {it:beta} and {it:gamma} and methods {it:1} and {it:2} appear differently in different formats, as do the estimate, standard error and true value.

{pstd}{bf:Data in format 1} (long-long: long target, long method).
Each feature is stored as a variable: targets (estimand), methods (method), estimate (est), standard error (se) and true value (true).  

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}

{pstd}{bf:Data in format 2} (long-wide: long target, wide method). 
Here the target is the variable estimand but methods are wide, e.g. est_1 is the estimate for method 1. 
Note the underscore separating est and method in the variable name: we remove it by the {cmd:sep(_)} option.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_wideM1.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(1 2) sep(_) estimate(est) se(se) true(true)"}

{pstd}{bf:Data in format 3} (wide-long: wide target, long method). 
Here the method is the variable method but the targets are wide, e.g. estbeta is the estimate of beta.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_wideE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est) se(se) true(true)"}

{pstd}{bf:Data in format 4} (wide-wide: wide target, wide method).
Here there is one set of variables for each target and method: e.g. est1beta is the estimate for method 1 and target beta. 
The methods appear before the targets in the variable names, so {cmd:order(method)} is needed.
There is a single variable true because in these data its value is constant.

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_wideE_wideM1.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(beta gamma) method(1 2) estimate(est) se(se) true(true) order(method)"}

{phang}Note that whatever the input format, the output dataset is in long-long format. 


{marker chars}{...}
{title:Characteristics stored by siman setup}

{pstd}Each characteristic {cmd:{it:char}} in the list below is stored as characteristic {cmd:_dta[siman_{it:char}]}.
The characteristics can be viewed using {cmd:siman describe, chars}.

{synoptset 20 tabbed}{...}
{pstd}DGMs{p_end}
{synopt:{opt dgm}}Variables defining the DGM. Values: varlist or empty. {p_end}
{synopt:{opt ndgmvars}}Number of dgm variables. Values: integers. {p_end}
{synopt:{opt dgmmissingok}}Whether missing values are allowed in dgmvars. Values: "missing" or empty. {p_end}

{pstd}Targets{p_end}
{synopt:{opt target}}Variable name for targets. Values: varname or empty. {p_end}
{synopt:{opt numtarget}}Number of targets. Values: integer. {p_end}
{synopt:{opt targetnature}}Nature of target variable: 0=numeric unlabelled, 1=numeric labelled, 2=string. Values: ./0/1/2. {p_end}
{synopt:{opt valtarget}}Names of targets, using value labels if they exist. {p_end}

{pstd}Methods{p_end}
{synopt:{opt method}}Variable name for method. Values: varname. {p_end}
{synopt:{opt nummethod}}Number of methods. Values: integer. {p_end}
{synopt:{opt methodnature}}Nature of method variable: 0=numeric unlabelled, 1=numeric labelled, 2=string. Values: ./0/1/2. {p_end}
{synopt:{opt valmethod}}Names of methods, using value labels if they exist. {p_end}
{synopt:{opt methodcreated}}Dummy for method being a variable _method created by siman setup. Values: 0/1. {p_end}

{pstd}Estimates{p_end}
{synopt:{opt estimate}}variable or stub containing estimate. {p_end}
{synopt:{opt se}}variable or stub containing standard error. {p_end}
{synopt:{opt df}}degrees of freedom for the standard error: variable or number. {p_end}
{synopt:{opt lci}}variable or stub containing lower confidence limit. {p_end}
{synopt:{opt p}}variable or stub containing p-value. {p_end}
{synopt:{opt rep}}variable containing the replicate identifier. {p_end}
{synopt:{opt uci}}variable or stub containing upper confidence limit. {p_end}

{pstd}True values{p_end}
{synopt:{opt true}}Variable name for true values. Values: varname. {p_end}

{pstd}Data formats{p_end}
{synopt:{opt setuprun}}is set to 1 when siman setup is run. Values: always 1. {p_end}

{pstd}Characteristics created by {help siman analyse}{p_end}
{synopt:{opt analyserun}}is set to 1 when siman analyse is run. Values: missing or 1. {p_end}
{synopt:{opt secreated}}is a dummy for the SE variable having been created by siman analyse 
to hold Monte Carlo standard errors. Values: missing or 1. {p_end}


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}



