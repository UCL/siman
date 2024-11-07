{smcl}
{* *! version 0.4 27nov2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_describe##syntax"}{...}
{viewerjumpto "Description" "siman_describe##description"}{...}
{viewerjumpto "Authors" "siman_describe##authors"}{...}
{title:Title}

{phang}
{bf:siman describe} {hline 2} Describes the status of the simulation data


{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:siman describe} , [ chars sort SAVing(string) ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt c:hars}}lists the contents of characteristics created by {help siman setup}.{p_end}
{synopt:{opt s:ort(varname)}}specified that […].{p_end}
{synopt:{opt sav:ing(filename, replace)}}specifies that […] will be saved to a new dataset.{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman describe} provides a summary of the data previously imported by {bf:{help siman setup}}, and whether estimates data and performance estimates are in the dataset.


{marker examples}{...}
{title:Examples}

{pstd} An example of using siman describe is given. First, we import the estimates data set, which has three data-generating mechanisms (MCAR, MAR, MNAR missing data) and three methods of analysis (Full, CCA, MI) with 1,000 repetitions.

{phang} Load the data set in to {cmd: siman}.{p_end}
{phang}. {stata "use https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta, clear"}

{phang} Run {cmd: siman setup}.{p_end}
{phang}. {stata "quietly siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)"}

{phang} Describe structure using {cmd: siman describe}.{p_end}
{phang}. {stata "siman describe"}



{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

