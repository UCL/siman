{smcl}
{* *! version 0.4 27nov2023}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_describe##syntax"}{...}
{viewerjumpto "Data formats" "siman_describe##data"}{...}
{viewerjumpto "Description" "siman_describe##description"}{...}
{viewerjumpto "Authors" "siman_describe##authors"}{...}
{title:Title}

{phang}
{bf:siman describe} {hline 2} Describes the simulation data


{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:siman describe} 
[{cmd:,}
{it:options}]

{pstd}The options are mainly intended for programmers.


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt ch:ars}}lists the characteristics created by {bf:{help siman setup}} and explained {bf:{help siman setup##chars:here}}.{p_end}

{synopt:{opt s:ort}}is used with {opt chars}: it sorts the characteristics alphabetically before listing.{p_end}

{synopt:{opt sav:ing(filename)}}is used with {opt chars}: it saves the characteristics to the file specified.{p_end}
{synoptline}


{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman describe} provides a summary of the data previously imported by {bf:{help siman setup}}, and whether estimates data and performance estimates are in the dataset.


{marker authors}{...}
{title:Authors}

{pstd}Ella Marley-Zagar, MRC Clinical Trials Unit at UCL{break}

{pstd}Ian White, MRC Clinical Trials Unit at UCL{break}
Email: {browse "mailto:ian.white@ucl.ac.uk":Ian White}

{pstd}Tim Morris, MRC Clinical  Trials Unit at UCL, London, UK.{break} 
Email: {browse "mailto:tim.morris@ucl.ac.uk":Tim Morris}

