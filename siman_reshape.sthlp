{smcl}
{* *! version 0.4 21nov2022}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_reshape##syntax"}{...}
{viewerjumpto "Description" "siman_reshape##description"}{...}
{viewerjumpto "Authors" "siman_reshape##authors"}{...}
{title:Title}

{phang}
{bf:siman reshape} {hline 2} Reshapes data in the siman suite

{marker syntax}{...}
{title:Syntax}

{phang}
Input data can be either reshaped to long-long format (i.e. long targets, long methods) or long-wide format (i.e. long targets, wide methods) using:

{phang}
siman reshape, longlong

{phang}
siman reshape, longwide


{marker description}{...}
{title:Description}
{pstd}
{p_end}

{pstd}
siman reshape takes the data imported from {bf:{help siman_setup:siman setup}} and either reshapes it in to long-long format or long-wide format.
Please note that {bf:{help siman_setup:siman setup}} will automatically reshape wide-target data (i.e. wide targets, wide methods) or wide-long format data
(i.e. wide targets, long methods) into long-wide format.  The reshaped data set is held in memory.
There is also an auto-summary output available for the user to confirm the data set up (using  {bf:{help siman_describe:siman describe}}).

{pstd}
For troubleshooting and limitations, see {help siman_setup##limitations:troubleshooting and limitations}.

{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:e.marley-zagar@ucl.ac.uk":Ella Marley-Zagar}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

{pstd}{helpb siman: Return to main help page for siman}


