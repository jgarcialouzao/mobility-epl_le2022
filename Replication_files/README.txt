
*********************************************************************************************************************


This document contains detailed information to replicate the results of the paper
"Workers' Job Mobility in Response to Severance Pay Generosity" by Jose Garcia-Louzao


************** DATA ACCESS ******************************

This research uses anonymized administrative data from the Muestra Continua de Vidas Laborales con Datos Fiscales (MCVL) with the permission of Spain's Dirección General de Ordenación de la Seguridad Social.
Unfortunately, the data is not publicly available. Therefore, we will provide information about the application process together with the files needed to replicate the results.

Full information of the MCVL can be found from https://www.seg-social.es/wps/portal/wss/internet/EstadisticasPresupuestosEstudios/Estadisticas/EST211

The application process to obtain MCVL data requires the completion of several forms (in Spanish) that are available from https://www.seg-social.es/wps/wcm/connect/wss/a5e35e4b-7622-4b6a-9205-1129c8b6d95e/FormMCVL20220124c.pdf?MOD=AJPERES
The forms ask for the researcher(s) and project information, as well as the version of the MCVL and the required years. 
There are two versions of the MCVL, with and without fiscal data. This research requires access to the version with fiscal data (con Datos Fiscales in Spanish).
Once the forms have been completed and signed, they should be sent to mcvl.dgoss-sscc@seg-social.es

The Social Security administration evaluates the request and, if positive, the data are shared with the researchers.

************** DATA ACCESS PROCESSING & RESULTS ******************************

After having access to the data, replication of the results ask for running a series of Stata routines that are included in the Master_File.do

It is important that all directories are set up as indicated in the do.files to ensure the smooth process of the routines. 
