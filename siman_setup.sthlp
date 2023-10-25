{smcl}
{* *! version 0.6.4 19sep2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{vieweralsosee "labelsof (if installed)" "labelsof"}{...}
{viewerjumpto "Input data formats" "siman_setup##data"}{...}
{viewerjumpto "Syntax" "siman_setup##syntax"}{...}
{viewerjumpto "Description" "siman_setup##description"}{...}
{viewerjumpto "Output data format" "siman_setup##outputdata"}{...}
{viewerjumpto "Troubleshooting and limitations" "siman_setup##limitations"}{...}
{viewerjumpto "Examples" "siman_setup##examples"}{...}
{viewerjumpto "Authors" "siman_setup##authors"}{...}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:siman setup} - Prepare data for siman suite}{p_end}
{p2colreset}{...}

{marker data}{...}
{title:Input data formats}

{pstd}
The input data for {cmd:siman setup} is an estimates data set.  This contains the results from analysing multiple simulated data sets, with data relating to different statistics for each simulated data set.  Each row in the estimates data set 
relates to one simulation, labelled here as repetition ({bf:rep}).
  
{pstd}Input data can be in any of these formats:

{pstd}
(1) long-long format (i.e. long targets, long methods),

{pstd}
(2) wide-wide format (i.e. wide targets, wide methods),

{pstd}
(3) long-wide format (i.e. long targets, wide methods),

{pstd}
(4) wide-long format (i.e. wide targets, long methods).

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
{it:Note {cmd: rep} is to be numeric variable only}.


{pstd}
Options for data in long-long input format (data format 1):

{pstd}
{opt dgm(varlist)}
{opt tar:get(varname)}
{opt meth:od(varname)}
{opt est:imate(varname)}
{opt se(varname)}
{opt df(varname)}
{opt lci(varname)}
{opt uci(varname)}
{opt true(#|varname)}
clear

{pstd}
Options for data in wide-wide input format (data format 2):

{pstd}
{opt dgm(varlist)}
{opt tar:get(values)}
{opt meth:od(values)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt true(#|stub_varname)}
{opt ord:er(varname)}
clear

{pstd}
Options for data in long-wide input format (data format 3):

{pstd}
{opt dgm(varlist)}
{opt tar:get(varname)}
{opt meth:od(values)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt true(#|stub_varname)}
clear

{pstd}
Options for data in wide-long input format (data format 4):

{pstd}
{opt dgm(varlist)}
{opt tar:get(values)}
{opt meth:od(varname)}
{opt est:imate(stub_varname)}
{opt se(stub_varname)}
{opt df(stub_varname)}
{opt lci(stub_varname)}
{opt uci(stub_varname)}
{opt true(#|stub_varname)}
clear
 
 
{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt dgm(varlist)}}data generating mechanism.{p_end}
{synopt:{opt tar:get(varname|values)}}the target variable name or values.{p_end}
{synopt:{opt meth:od(varname|values)}}the method variable name or values.{p_end}
{synopt:{opt est:imate(varname|stub_varname)}}the estimate variable name or the name of its stub if in wide format.{p_end}
{synopt:{opt se(varname|stub_varname)}}the standard error variable name or the name of its stub if in wide format.{p_end}
{synopt:{opt df(varname|stub_varname)}}the degrees of freedom variable name or the name of its stub if in wide format.{p_end}
{synopt:{opt lci(varname|stub_varname)}}the lower confidence interval variable name or the name of its stub if in wide format.{p_end}
{synopt:{opt uci(varname|stub_varname)}}the upper confidence interval variable name or the name of its stub if in wide format.{p_end}
{synopt:{opt true(#|varname|stub_varname)}}the true value, or variable name or the name of its stub if in wide format. A number/numeric variable only.{p_end}
{synopt:{opt ord:er(varname)}}if in wide-wide format, this must be either {it:target} or {it:method}, 
denoting that either the target stub is first or the method stub is first in the variable names.{p_end}
{synopt:{opt clear}}to clear the existing data held in memory.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:siman setup} takes the user’s raw simulation data (estimates data set) and puts it in the format required by {bf:siman}. 

{pstd}
The raw simulation data set must include a numeric variable, {opt rep(varname)}, which indexes the repetitions of the simulation experiment.  
Other variables of interest such as 
data generating mechanism ({opt dgm}), {opt target}, {opt method}, {opt estimate}, standard error ({opt se}) are typically specified.
{cmd:siman setup} allows multiple data generating mechanisms, multiple targets and multiple analysis methods. 
 
{pstd}
Four data set formats are permitted by the siman suite as detailed {help siman_setup##data:above}.
{cmd:siman setup} automatically reshapes wide-wide data (i.e. wide targets, wide
methods) or wide-long format data (i.e. wide targets, long methods) into long-wide
format. Therefore the two output data formats of {cmd:siman setup} are long-long (option
1) and long-wide (option 3) as shown in more detail {help siman_setup##outputdata:below}.

{pstd}
{cmd:siman setup} checks the data, reformats it
and attaches characteristics to the data set: these characteristics are read by every other {bf:siman} command.  The {bf:siman} estimates data set is held in memory.
An auto-summary output available for the user to confirm the data set up (using  {bf:{help siman_describe:siman describe}}). 

{pstd}
The {bf:labelsof} package (by Ben Jann) is required by {bf:siman setup}, which can be installed by clicking: {stata ssc install labelsof} 

{marker outputdata}
{title:Output data format}

{pstd}
Estimates data will be converted by {cmd:siman setup} to be {it:long-long} or {it:long-wide}, examples of which are 
shown below. Note that {it:rep} indexes the repetition number, {it:dgm} denotes the data-generating 
mechanism to which a method was applied, {it:target} sets out what quantity the analysis is trying to 
estimate and {it:method} denotes the method used to produce the estimates.

           {it:Long-long} format
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

           {it:Long-wide} format
        {c TLC}{hline 53}{c TRC}
        {c |} {it:rep  dgm  target  estimateA  seA  estimateB  seB   } {c |}
        {c |}{hline 53}{c |}
        {c |}   1    1   beta    .1433    .0774   .2338  .1104    {c |}
        {c |}   1    1   gamma   .0517    .0810   .1375  .1167    {c |}
        {c |}   1    2   beta    .1135    .0946   .1543  .1400    {c |}
        {c |}   1    2   gamma   .0597    .0935   .1588  .1347    {c |}
	{c |}   2    1   beta    .1509    .0768   .0784  .1087    {c |}
        {c |}   2    1   gamma   .0297    .0738   .1310  .1116    {c |}
        {c |}   2    2   beta    .1337    .0928   .1541  .1324    {c |}
        {c |}   2    2   gamma   .0343    .0852   .1513  .1289    {c |}
        {c BLC}{hline 53}{c BRC}


{marker limitations}{...}
{title:Troubleshooting and limitations}
{pstd}

{pstd}There can be no other variables in the data set other than those specified in {cmd:siman setup}.

{pstd}Abbreviations should not be used for variable names and value labels in {cmd:siman setup}.

{pstd}The variable {bf:dgm} needs to be in numerical format (string labels allowed), with integer values.  If {bf:dgm} is a string variable then {cmd:siman setup} will encode it to be numeric.  If {bf:dgm} has non-integer values, then {bf:dgm} 
should be re-formatted by the user so that it has integer values with non-integer labels.

{pstd}If the method variable is missing, then {cmd:siman setup} will create a variable {bf:_methodvar} in the dataset with a value of 1 in order that all the other {bf: siman} programs can run.

{pstd}No special characters are allowed in the labels of the variables, as these are not allowed in Stata graphs.  No spaces in the variable labels are allowed either, to enable reshaping to {it:longwide} format and back again (required 
internally for some of the graphs).  For example, if the data is in {it:longlong} format the estimate variable is {it:b} 
and the method variable has labels {it: Complete case} and {it:Complete data}, then when reshaped to {it:longwide} format 
the variable names would become {it:bComplete case} and {it:bComplete data} which is not permitted by Stata.  
The method labels would therefore need to be {it:Complete_case} and {it:Complete_data}.

{pstd} Dgm can not contain missing values.

{pstd}If the user would like to specify a different name for any of the graphs using the graph options, the new name is not permitted to contain the word 'name' (e.g. name("testname") would not be allowed).

{pstd}
Note that {bf:true} must be a {bf:variable} in the dataset for {bf:{help siman nestloop:siman nestloop}}, and should be listed in both the {bf:dgm()} and the {bf:true()} options in {cmd:siman setup} before running these graphs, with the 
{cmd:true} variable being listed before the {cmd:dgm} variable in the {bf:dgm()} option.

{pstd}{bf:{help siman_reshape:siman reshape}} can only reshape a maximum of 10 variables, due to {help reshape} only allowing
10 elements in the i() syntax. This can be mitigated by creating a group identifier.

{pstd}For example, instead of:

{phang} {stata "reshape wide est , i(rep scenario dgm severity CTE switchproportion treateffect switcherprog sfunccomp estimand perfmeascode) j(method 1 2)"}

{pstd}use:

{phang} {stata "egen i = group(rep scenario dgm severity CTE switchproportion treateffect switcherprog sfunccomp estimand perfmeascode)"}

{phang} {stata "reshape wide est , i(i) j(method 1 2)"}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
The following dataset will be used: 
{browse "https://github.com/UCL/siman/tree/master/Ella_testing/data/simlongESTPM_longE_longM.dta":longlong_dataset}

{pstd} 
This is a dataset in long-long format (format 1) containing the variables repetition (rep), dgm, 2 targets (contained in a variable called 
estimand, with labels {it:beta} and {it:gamma}) and 2 methods (with labels {it:1} and {it:2}), the estimate (est), standard error (se) and true variable.  {cmd:siman setup} is entered as follows:


{pstd}{bf:Data in format 1} (long-long: long target, long method):

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/Ella_testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)"}


{pstd}Alternatively, to show the data in wide-wide format (format 2) the following example dataset will be used:
{browse "https://github.com/UCL/siman/tree/master/Ella_testing/data/simlongESTPM_wideE_wideM4.dta":widewide_dataset}


{pstd}{bf:Data in format 2} (wide-wide: wide target, wide method):

{phang}. {stata "clear all"}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/Ella_testing/data/simlongESTPM_wideE_wideM4.dta, clear"}

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)"}

{phang}Note that the variable names are {bf:estA_beta} etc and so the method values need to be inputted with the separator underscores in {bf:method()}.  
This could also be done with {bf:target(beta_ gamma_) method(A B)}.

{phang}The method labels appear before the target labels in the wide-wide dataset so {cmd:order(method)} is entered.

{phang} Also note that the dataset is auto-reshaped to long-wide format by {cmd:siman setup}.


{pstd}Now to illustrate the original input data in format 3 (long-wide), the long-long data set 
({browse "https://github.com/UCL/siman/tree/master/Ella_testing/data/simlongESTPM_longE_longM.dta":longlong_dataset})
will be reshaped before {cmd:siman setup} is run.


{pstd}{bf:Data in format 3} (long-wide: long target, wide method):

{phang}. {stata "clear all"}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/Ella_testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "reshape wide est se, i(rep dgm estimand true) j(method)"}

{phang}Now the input data is in long-wide format.

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(estimand) method(1 2) estimate(est) se(se) true(true)"}


{pstd}
Finally, to illustrate the original input data in format 4 (wide-long), the long-long data set ({browse "https://github.com/UCL/siman/tree/master/Ella_testing/data/simlongESTPM_longE_longM.dta":longlong_dataset})
will be reshaped before {cmd: siman setup} is run.


{pstd}{bf:Data in format 4} (wide-long: wide target, long method ):

{phang}. {stata "clear all"}

{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/Ella_testing/data/simlongESTPM_longE_longM.dta, clear"}

{phang}. {stata "reshape wide est se, i(rep dgm method true) j(estimand) string"}

{phang}Now the input data is in wide-long format, so {cmd: siman setup} will be as follows.

{phang}. {stata "siman setup, rep(rep) dgm(dgm) target(beta gamma) method(method) estimate(est) se(se) true(true)"}

{phang}Note this dataset is auto-reshaped to long-wide format by {cmd: siman setup}. 

{phang}Also note that the session has to be cleared before each new dataset is loaded, to remove the previous characteristics created by {cmd: siman setup}.

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}



