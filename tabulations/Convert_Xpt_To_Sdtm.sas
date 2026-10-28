libname sdtm "//&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_datasets";


%macro xpt(a=);

	libname sdtm_xpt xport "//&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm\&a..xpt";
	data sdtm.&a.;
		set sdtm_xpt.&a.;
		run;
%mend xpt;
	 %xpt(a=ae);%xpt(a=cm);%xpt(a=dm);%xpt(a=ds);%xpt(a=ex);%xpt(a=lb);%xpt(a=mh);%xpt(a=qs);%xpt(a=relrec);%xpt(a=sc);%xpt(a=se);%xpt(a=sv);%xpt(a=vs);
	 %xpt(a=ta);%xpt(a=te);%xpt(a=ti);%xpt(a=ts);%xpt(a=tv);
	 %xpt(a=suppae);%xpt(a=suppdm);%xpt(a=suppds);%xpt(a=supplb);



