*****************************************
Purpose: Validate the Study Domain

By: Pritesh Desai

Date: 27JUL2016T2000

Note: 
*******************************************/;


libname sdtm "&_SASWS_/SAS/HLS_Pharma/CDISC_STUDIES/Files/CDISCPILOT01/tabulation/sdtm_datasets";

PROC CONTENTS DATA=sdtm._ALL_ memtype=data OUT=ALL(keep=libname memname) NOPRINT; RUN;
	
proc sort data=all out=all nodupkey;
	by libname memname;
run;


%macro table(d=);
	
	proc sql noprint; select count(*) into :OBSCOUNT from all where upcase(memname) = "&d."; quit;

	%put Count=&OBSCOUNT.;
	
	%if 	%eval(&OBSCOUNT.+ 0 ) < 1 %then 
		%do ;
			proc sql noprint; select memname into :memname separated by " | " from all ; quit;		

	
			data miss_domain;
				length missing_domain $25 out_of_domain $200;
				missing_domain="&d.";
				out_of_domain=compress("&memname.");
				run;
					
			Title "Missing &d. Dataset" ;
			Footnote "&d. Domain dataset must be included in every submission" ;
			proc print data=miss_domain; run;
			
			
			
			Title ;
			Footnote ;

		%end; 
 
			

%mend table;
	%table(d=DM);%table(d=TS);%table(d=DS);%table(d=EX);%table(d=AE);%table(d=LB);
	%table(d=VS);%table(d=SE);%table(d=TA);%table(d=TE);%table(d=MB);

   
