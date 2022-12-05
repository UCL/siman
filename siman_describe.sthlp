{smcl}
{* *! version 0.3 20dec2021}{...}
{vieweralsosee "Main siman help page" "siman"}{...}
{viewerjumpto "Syntax" "siman_describe##syntax"}{...}
{viewerjumpto "Data formats" "siman_describe##data"}{...}
{viewerjumpto "Description" "siman_describe##description"}{...}
{viewerjumpto "Authors" "siman_describe##authors"}{...}
{title:Title}

{phang}
{bf:siman describe} {hline 2} Describes the data import from {bf:{help siman_setup:siman setup}}


{marker syntax}{...}
{title:Syntax}

{phang}
{cmd:siman describe} 

{phang}
This will use the [if] and [in] conditions from {bf:{help siman_setup:siman setup}} if specified.

{p2colreset}{...}
{p 4 6 2}

{marker data}{...}
{title:Data formats}

{pstd}
Data can be either in:

{pstd}
(1) long-long format (i.e. long targets, long methods)

{pstd}
(2) wide-wide format

{pstd}
(3) long-wide format (i.e. long targets, wide methods), or

{pstd}
(4) wide-long format (i.e. wide targets, long methods).


{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:siman describe} provides a summary of the data imported by {bf:{help siman_setup:siman setup}}.  The table gives an overview of the 
dataset so the user can check everything is as expected. It will list the data format as format ({it:n} : {it:x} {it:y}) where {it:n} is 
the data format type (see {help siman_describe##data:above}), {it:x} is the target format and {it:y} is the method format.  
{cmd:siman describe} will either list format 1 (long-long) or format 3 (long-wide), as if the import data 
is originally format 2 (wide-wide) or format 4 (wide-long) it will be autoreshaped by {bf:{help siman_setup:siman setup}} 
(and internally {bf:{help siman_reshape:siman reshape}}) to format 3 (long-wide).

{pstd}
For clarity the resulting {bf:target} and {bf:method} format will also be listed, along with the number of and values of {bf:target(s)} and {bf:method(s)}.
The number of {bf:dgm(s)}/number of variables that {bf:dgm} is defined by and the total number of {bf:dgm} levels will be displayed.

{pstd}
{cmd:siman describe} will also list the {bf:estimate}, {bf:se}, {bf:df}, {bf:ci}, {bf:p} and {bf:true} variable names if applicable, and whether estimates are contained in the dataset.  

{pstd}
{cmd:siman describe} will be called automatically by {bf:{help siman_setup:siman setup}}, but can also be called on it's own once the data has been imported by the {bf:siman suite}.

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

