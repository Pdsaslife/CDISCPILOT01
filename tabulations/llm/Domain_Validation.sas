*****************************************
Purpose: Validate the SDTM domain

By: Pritesh Desai

Date: 27JUL2016T1713

Note: 
*******************************************/;


libname sdtm "&_SASWS_/SAS/HLS_Pharma/CDISC_STUDIES/Files/CDISCPILOT01/tabulation/sdtm_datasets";

Title "Missing value for DTHFL, when DTHDTC is populated" ;
   proc print data=sdtm.dm;
      where dthdtc ne "" & dthfl in ("" "N" );
   run;
Footnote "Subject Death Flag (DTHFL) value must equal 'Y', when Date/Time of Death (DTHDTC) is provided" ;

Title ;
Footnote ;
   

Title "Missing value for DTHDTC, when DTHFL is populated";
   proc print data=sdtm.dm;
      where dthfl ne "" & dthdtc in ("");
   run;
Footnote "Date/Time of Death (DTHDTC) should be provided, when subject died (DTHFL=Y)";
Title "";
Footnote "";

Title "AGE\AGE Units is not provided";
   proc print data=sdtm.dm;
      where age = . or ageu = "";
   run;
Footnote "Age (AGE) variable values should be provided, when Date/Time of Birth (BRTHDTC) variable values are populated";
Title "";
Footnote "";
