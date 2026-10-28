
libname sdtm_od "/mnt/viya-share/data/CDISCPILOT01/tabulations/sdtm_va";

libname sdtm_ud "/mnt/viya-share/data/CDISCPILOT01/tabulations/sdtm_from_va";

data sub_set;
	set sdtm_ud.dm_dm_fixed;
	where review_flag ne 0;
run;

ods pdf file = "/mnt/viya-share/data/CDISCPILOT01/tabulations/programs/comparison_report_SDTM_plus_differences.pdf";
proc compare base=sdtm_od.dm_dm compare=sub_set briefsummary; * out=t_compare OUTNOEQUAL;
   var sex;
   with sex;
run;

ods pdf close;