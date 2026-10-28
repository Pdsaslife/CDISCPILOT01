options validvarname=v7 noquotelenmax;

%let lsaf_source=%str(/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_va);
%let lsaf_target=%str(/toVisualAnalytics);

%LSAF_COPY(
		LSAF_SOURCE=&lsaf_source./dm_dm,
 		LSAF_TARGET=&lsaf_target
 		); 