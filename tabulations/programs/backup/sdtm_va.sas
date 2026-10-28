/***********************************************************************************************************************
Purpose: Create a Large & Flat dataset for LB VS EG AE CM for VA 6.2

Date: 08/7/13

By SAS PGM  : Pritesh Desai
Statistician: Mike Henderson

I/P: SDTM dataset DM AE LB VS EG CM

Note:
		VS  o	Make VS_Flat1  still multiple records for tpt (pre & post dose)  only value (n) and hi & lo  not units
			o	Make VS_Flat2  one record per subject
		LB  o	Make LB_Flat  one record per subject and visitnum  - use SDTM column name as prefix  dont keep unit
		EG  o	Make EG_Flat  one record per subject and visitnum  only rows with n  dont keep unit
		DM  o	Keep as is
		VS+DM+AE Summary (see below)
		EG+DM+AE Summary (see below)
		LB+DM+AE Summary (see below)
		LB_Flat+DM+EG_Flat+VS_Flat2+
			o	AE Summary using AE
					Two parts
					1	Overall
							o	Total_AE
							o	Max_AESEV
							o	Max_AESER
					2	Up to current visit date
							o	Current_Total_AE
							o	Current_Max_AESEV
							o	Current_Max_AESER

1	Create a DM_DM that merges the LAT, LONG, and ISONAME from mapsgfk.world_cities by averaging LAT and LONG
		o	Ensure that all DM.COUNTRY values are represented by ISOALPHA3
		o	This will allow geocoding of data from all datasets even in reporting
2	Create new versions of the SDTM that include the DM data so that they get the geocoding and arm info
		o	LB_DM o	AE_DM o	VS_DM o	EG_DM o	CM_DM
3	Let the new DM with geocoding carry through all other derived flat and combo files

O/P	Load list: DM_DM 	LB_DM AE_DM VS_DM EG_DM CM_DM AE_FLAT ALL_FLAT EG_DM_AE
			 EG_FLAT 	LB_DM_AE 	LB_FLAT  VS_DM_AE VS_FLAT1 	VS_FLAT2

***************************************************************************************************************************/
options validvarname=v7 noquotelenmax;

libname sdtm "&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_datasets";
libname sdtm_va "&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_va"; 
 
 %macro big_loop(count=);
 
 
/*---------------------------------------------------*/
		/*PLEASE DO NOT DELETE THIS PIECE*/
		/*IT IS USED FOR VALIDATION PURPOSE*/

		%macro chk_data(a=);

			data &a.;
				set sdtm.&a.;
				length mod_user $100. mod_comments $5000. mod_Recorded_Added $3. mod_Comments_approved $3. mod_date $15. mod_orig_rec 3.;
				length review_flag 3. review_text $200. ;
				label 
					mod_user				='Name'
					mod_comments			='Add records for comments'
					mod_recorded_Added		='Yes/No Flag(for new record)'
					mod_comments_approved	='Yes/No Flag(for approved record)'
					mod_date				='Today date & time'
					mod_orig_rec			='Original record(use 0 and 1)'
					review_flag			='Demographic review flag number'
					review_text			='Demographic review flag description'
				 ;
				 mod_user='';
				 mod_comments='';
				 mod_recorded_Added='';
				 mod_comments_approved='';
				 mod_date='';
				 mod_orig_rec=0;
				 review_flag=0;
				 review_text='No issues found';
				 
				*where usubjid='770MS405/901-005';	
				*Create Issues in Demographic;
				%if &a.=dm %then
				%do;
				  %if &count = 1 %then %do;
				  	if usubjid = '01-701-1211' then dthdtc='';
					if usubjid = '01-704-1445' then dthfl='';
					if usubjid = '01-715-1319' then age=122 ;
					if usubjid = '01-715-1085' then arm='';
					if usubjid = '01-718-1371' then age=10 ;
					if usubjid = '01-701-1188' then sex='';
					if usubjid = '01-708-1013' then ageu='MONTHS';
					if usubjid = '01-709-1238' and upcase(armcd) ne 'SCRNFAIL' then RFSTDTC='';
					if usubjid = '01-707-1037' then RFSTDTC='2013';
					if usubjid = '01-710-1002' then SEX='';
				  %end;
				  %else %if &count = 2 %then %do;
				  	*if usubjid = '01-701-1211' then dthdtc='';
					*if usubjid = '01-704-1445' then dthfl='';
					if usubjid = '01-715-1319' then age=122 ;
					if usubjid = '01-715-1085' then arm='';
					if usubjid = '01-718-1371' then age=10 ;
					if usubjid = '01-701-1188' then sex='';
					if usubjid = '01-708-1013' then ageu='MONTHS';
					if usubjid = '01-709-1238' and upcase(armcd) ne 'SCRNFAIL' then RFSTDTC='';
					if usubjid = '01-707-1037' then RFSTDTC='2013';
					if usubjid = '01-710-1002' then SEX='';
				  %end;
				  %else %if &count = 3 %then %do;
				  	*if usubjid = '01-701-1211' then dthdtc='';
					*if usubjid = '01-704-1445' then dthfl='';
					*if usubjid = '01-715-1319' then age=122 ;
					*if usubjid = '01-715-1085' then arm='';
					if usubjid = '01-718-1371' then age=10 ;
					if usubjid = '01-701-1188' then sex='';
					if usubjid = '01-708-1013' then ageu='MONTHS';
					if usubjid = '01-709-1238' and upcase(armcd) ne 'SCRNFAIL' then RFSTDTC='';
					if usubjid = '01-707-1037' then RFSTDTC='2013';
					if usubjid = '01-710-1002' then SEX='';
				  %end;
				  %else %if &count = 4 %then %do;
				  	*if usubjid = '01-701-1211' then dthdtc='';
					*if usubjid = '01-704-1445' then dthfl='';
					*if usubjid = '01-715-1319' then age=122 ;
					*if usubjid = '01-715-1085' then arm='';
					*if usubjid = '01-718-1371' then age=10 ;
					*if usubjid = '01-701-1188' then sex='';
					if usubjid = '01-708-1013' then ageu='MONTHS';
					if usubjid = '01-709-1238' and upcase(armcd) ne 'SCRNFAIL' then RFSTDTC='';
					if usubjid = '01-707-1037' then RFSTDTC='2013';
					if usubjid = '01-710-1002' then SEX='';
				  %end;
				  %else %if &count = 5 %then %do;
				  	*if usubjid = '01-701-1211' then dthdtc='';
					*if usubjid = '01-704-1445' then dthfl='';
					*if usubjid = '01-715-1319' then age=122 ;
					*if usubjid = '01-715-1085' then arm='';
					*if usubjid = '01-718-1371' then age=10 ;
					*if usubjid = '01-701-1188' then sex='';
					*if usubjid = '01-708-1013' then ageu='MONTHS';
					*if usubjid = '01-709-1238' and upcase(armcd) ne 'SCRNFAIL' then RFSTDTC='';
					*if usubjid = '01-707-1037' then RFSTDTC='2013';
					*if usubjid = '01-710-1002' then SEX='';
				  %end;

			  
													
				%end;
				*Create review_flag and review_text in demogrpahic;
				%if &a.=dm %then
				%do;
					if dthfl ne '' and dthdtc ='' 		then do; review_flag=1; review_text='If Deathflag is not blank then Death date cannont be blank'; end;
					if dthdtc ne '' and dthfl ='' 		then do; review_flag=2; review_text='If Death Date is not blank than Death date cannot be blank'; end;
					if age gt 120 						then do; review_flag=3; review_text='Age cannot be greater than 120 Years'; end;
					if age le 10 						then do; review_flag=4; review_text='Per Alzheimer Study Age cannot be less than 50 years'; end;
					if arm = '' 						then do; review_flag=5; review_text='Description of planned arm cannot be blank'; end;
					if sex = '' 						then do; review_flag=6; review_text='Gender cannot be blank' ; end ;
					if compress(ageu) ne 'YEARS'			then do; review_flag=7; review_text='Age units must be in Years' ; end;
					if armcd ne 'Scrnfail' & RFSTDTC='' 	then do; review_flag=8; review_text='Reference start date cannot be blank for randmoized subjects';end;
					if compress(armcd) ne 'Scrnfail' & compress(length(rfstdtc)) le 8 then do; review_flag=9; review_text='Reference start date cannot have partial values'; end;
													
				%end;				
				run;
				
			proc sort data=&a.;
				 by usubjid ;
				 run;

		%mend chk_data;
		%chk_data(a=dm);	

/*---------------------------------------------------*/

/* proc freq data=dm; */
/* 	tables review_flag*review_text /list; */
/* 	run; */

************************** LAT, LONG, and ISONAME from mapsgfk.world_cities by averaging LAT and LONG*******************************************;
proc sql;
	 create table world_cities as
	 select isoname, long, lat, isoalpha3,
			mean(long) as avg_long,
			mean(lat) as avg_lat
	 from mapsgfk.world_cities
	 group by isoname
	 order by isoname;
	quit;

proc sort data=world_cities out=country(drop=long lat rename=(avg_long=long avg_lat=lat)) nodupkey; by isoalpha3; run;

************************** Create xx_DM files to create flat files ****************************************************************************;

proc sql; 
	create table dm_dm(drop=isoalpha3) as 
	select *
		   ,input(scan(rfstdtc,1,'T'), yymmdd10.) as rfstdt format=date9.
		   ,input(scan(rfendtc,1,'T'), yymmdd10.) as rfendt format=date9.
	from dm  left join country on dm.country=country.isoalpha3 
	order by usubjid;  
	quit;

	
	
	%let count=%eval(&count * 50);
	
	%put <<&count>>;
	
	data dm_dm;
    *set dm_dm(obs=&count);
       set dm_dm;
    run;
    
    proc freq data=dm_dm; 
	tables review_flag*review_text /list;
	run;
	
	data sdtm_va.dm_dm;
    set dm_dm;
    run;

%mend big_loop;

%macro test;
	
	%do i = 1 %to 5;
	  %big_loop(count=&i);
	  data _null_;
	    call sleep(3,1);
	  run;
    %end;
	
%mend test;

%test;
	
