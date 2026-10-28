options validvarname=v7 noquotelenmax;

cas;
caslib _all_ assign;

libname sdtm "/mnt/viya-share/data/CDISCPILOT01/tabulations/sdtm_va";
*libname to_va "//&_SASWS_./toVisualAnalytics";


%macro to_va(a=);

	data public.&a.(promote=Yes);
		set sdtm.&a.;
		run;
%mend to_va;
	 %to_va(a=ae_dm); %to_va(a=ae_flat); %to_va(a=all_flat);%to_va(a=cm_dm);%to_va(a=dm_dm);%to_va(a=edish);%to_va(a=ex_dm);%to_va(a=lb_dm);%to_va(a=lb_dm_ae);%to_va(a=lb_dm_ae_tall);
	 %to_va(a=lb_flat); %to_va(a=mh_dm);%to_va(a=pat_nar);%to_va(a=vs_dm);%to_va(a=vs_dm_ae);%to_va(a=vs_dm_ae_tall);%to_va(a=vs_flat1);%to_va(a=vs_flat2);
