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

libname sdtm "//&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_datasets";
libname sdtm_va "//&_SASWS_/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_va"; 
 
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
		%chk_data(a=ae);	%chk_data(a=qs);
		*%chk_data(a=eg);	%chk_data(a=sc);
		%chk_data(a=lb);	%chk_data(a=se);
		%chk_data(a=vs);	%chk_data(a=sv);
		%chk_data(a=cm);	%chk_data(a=ds);
		%chk_data(a=mh);	
		%chk_data(a=ex);	
/*---------------------------------------------------*/

proc freq data=dm;
	tables review_flag*review_text /list;
	run;

*********Build data for Patient narrrative***************;
data pat_nar;
	set dm ae /*eg*/ lb vs cm mh ex ds qs sc se sv ;
	by usubjid;
	run;

************************** Add BASE & CHG to BDS dataset *************************************************************************************;

%macro BaseVar(a=);

	data &a._base(keep=usubjid &a.testcd base);
		 set &a.(where=(upcase(&a.blfl)='Y'));
		 by usubjid;
		 rename &a.stresn=base;
		 run;

	*Chk if we have any duplicates during screening visit;

	proc sort data=&a._base dupout=chk_&a._base nodupkey;
		 by usubjid &a.testcd;
		 run;
	proc sort data=&a.; by usubjid &a.testcd visitnum; run;
		
	data &a.;
		 merge &a.(in=a) &a._base(in=b);
		 by usubjid &a.testcd;
		 if a;
		 if &a.stresn ne . & base ne . then chg = &a.stresn-base; 

		 if chg not in (. 0) & base not in (. 0) then pchg=chg/base * 100;

		 *Keep usubjid &a.testcd visitnum &a.dtc &a.blfl base &a.stresn chg pchg ;
		 run;
%mend BaseVar;
	 %BaseVar(a=lb);
	 %BaseVar(a=vs);
	 *%BaseVar(a=eg);

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
	
%macro xx_dm(a=);
	data &a._dm;
		merge &a.(in=a) dm_dm(in=b);
		by usubjid;
		if a;

		%if %upcase(&a.)=AE %then 
		%do;
			if length(substr(aestdtc, 1,10)) = 10 then aestdt=input(substr(aestdtc, 1,10), yymmdd10.);
	 		if length(substr(aeendtc, 1,10)) = 10 then aeendt=input(substr(aeendtc, 1,10), yymmdd10.);
	 		format aestdt aeendt date9. ;
		%end;
		%if %upcase(&a.)=CM %then 
		%do;
	 		if length(compress(cmstdtc)) = 10 then cmstdt=input(substr(compress(cmstdtc), 1,10), yymmdd10.);
	 		if length(compress(cmendtc)) = 10 then cmendt=input(substr(compress(cmendtc), 1,10), yymmdd10.);
	 		format cmstdt cmendt date9. ;			
		%end;
		%if %upcase(&a.)=LB or %upcase(&a.)=VS or %upcase(&a.)=EG %then
		%do;
			if length(substr(&a.dtc, 1,10)) = 10 then &a.dt=input(substr(&a.dtc, 1,10), yymmdd10.);
			format &a.dt date9.;
		%end;

		run;
%mend xx_dm;
	%xx_dm(a=ae);
	%xx_dm(a=cm);
	%xx_dm(a=lb);
	%xx_dm(a=vs);
	%xx_dm(a=mh);
	%xx_dm(a=ex);
	*%xx_dm(a=eg);


***************************************************** START PROCESSING FOR LBFLAT **************************************************************;

*---------------------------------------------;
*Sort & Transpose dataset LB for Key variables;
*---------------------------------------------;

%macro Lbflat(var=, prefix=);

*Chk whether var is c or n;
	data _null_;
		set lb;
		call symput('NY', vtype(&var.));
		run;
	%put NY=&NY;

*Sort;
	proc sort data=lb(/*where=(index(upcase(lbnam), 'LOCAL') = 0)*/) out=&var.1 dupout=chk_&var. nodupkey;
		%if &NY.=N %then 
		%do;
			where &var. ne .; 
		%end;
		%else 
		%do;
			where &var. ne '';
		%end; 
		by usubjid visitnum visit lbdtc lbtestcd &var.; 
		run;

*transpose;	
	proc transpose data=&var.1 out=&var.2 %if &prefix. ne %then %do; prefix=&prefix. %end; ; 
		by usubjid visitnum visit lbdtc /*lbrefid*/ ;
		var &var.;
		id lbtestcd;
		run;

%mend lbflat;
	 %lbflat(var=lbstresn, prefix=lbstresn_);
	 %lbflat(var=lbstnrlo, prefix=lbstnrlo_);
	 %lbflat(var=lbstnrhi, prefix=lbstnrhi_);

*---------------------------------------------;
*---Merge all the desired information---------;
*---------------------------------------------;

*Create Dummy information then merge this subset with all the other information;
	
Data lb_dummy;
	 Merge Lbstresn2 /*Lbstresu2*/ Lbstnrlo2 lbstnrhi2;
	 keep usubjid visitnum visit lbdtc /*lbrefid*/;
	 run;
proc sort data=lb_dummy nodupkey;
	 by usubjid visitnum visit lbdtc /*lbrefid*/;
	 run;
		 
Data LbFlat(drop=_name_ _label_);
	Merge lb_Dummy(in=a) Lbstresn2(in=b) /*Lbstresu2(in=c)*/ Lbstnrlo2(in=d) lbstnrhi2(in=e);
 	by usubjid visitnum visit lbdtc /*lbrefid*/;
 	if a;
		date=SUBSTR(upcase(lbdtc),1,10); *DO NOT DELETE THIS VARIABLE;
	if length(substr(lbdtc, 1,10)) = 10 then lbdt=input(substr(lbdtc, 1,10), yymmdd10.);
	format lbdt date9.;
 	run;

**************************************************** START PROCESSING FOR VSFLAT ****************************************************;

*---------------------------------------------;
*Sort & Transpose dataset LB for Key variables;
*---------------------------------------------;

%macro vsflat(var=, prefix=);

*Chk whether var is c or n;
	data _null_;
		set vs;
		call symput('NY', vtype(&var.));
		run;
	%put NY=&NY;

*Sort;
	proc sort data=vs out=&var.1 dupout=chk_&var. nodupkey;
		%if &NY.=N %then 
		%do;
			where &var. ne .; 
		%end;
		%else 
		%do;
			where &var. ne '';
		%end; 
		by usubjid visitnum vstptnum visit vstpt vsdtc vstestcd &var.; 
		run;

*transpose;	
	proc transpose data=&var.1 out=&var.2 prefix=&prefix. ; by  usubjid visitnum visit vstptnum vstpt vsdtc ;var &var.;id vstestcd;run;

%mend vsflat;
	 %vsflat(var=vsstresn, prefix=vsstresn_);
	 *%vsflat(var=vsstresu, prefix=u_);

*---------------------------------------------;
*---Merge all the desired information---------;
*---------------------------------------------;
		 
Data VsFlat1(drop=_name_ _label_);
	 set vsstresn2(in=b) ;
	 by usubjid visitnum visit vstptnum vstpt vsdtc;
	 *if a;
	 date=SUBSTR(upcase(vsdtc),1,10); *DO NOT DELETE THIS VARIABLE;
	 if length(substr(vsdtc, 1,10)) = 10 then vsdt=input(substr(vsdtc, 1,10), yymmdd10.);
	 format vsdt date9.;;
	 run;	

*********************;
****START VAFLAT2****;
*********************;

*Pre process VS again;

%macro vsflat(var=, prefix=);

data vs_pre;
	set vs;

	length new_vstest $55. ;

	if vstpt ne '' then New_vstest=compress(vstestcd||'_'||vstptnum);
	else new_vstest=compress(vstestcd||'_'||visitnum);

	if upcase(visit)='BASELINE' & vstpt ne '' then new_vstest=compress(new_vstest||'_B');

	date=SUBSTR(upcase(vsdtc),1,10);

	run;

*Chk whether var is c or n;
	data _null_;
		set vs_pre;
		call symput('NY', vtype(&var.));
		run;
	%put NY=&NY;

*Sort;
	proc sort data=vs_pre out=&var.1 dupout=chk_&var. nodupkey;
		%if &NY.=N %then 
		%do;
			where &var. ne .; 
		%end;
		%else 
		%do;
			where &var. ne '';
		%end; 
		by usubjid visitnum visit date new_vstest &var.; 
		run;

*transpose;	
	proc transpose data=&var.1 out=&var.2 prefix=&prefix. ; by  usubjid visitnum visit date  ;var &var.;id new_vstest;run;

%mend vsflat;
	 %vsflat(var=vsstresn, prefix=vsstresn_);

*Get screening records for all the visits as PRE/POST are not collected;
data vs_post(drop=_name_ _label_);
	set Vsstresn2;
	by  usubjid visitnum visit date;

	array a(11) a1-a11;
	array SCREENING(11) vsstresn_DIABP_815_B 
					    vsstresn_DIABP_816_B
						vsstresn_DIABP_817_B
						vsstresn_PULSE_815_B 
					    vsstresn_PULSE_816_B
						vsstresn_PULSE_817_B
						vsstresn_SYSBP_815_B 
					    vsstresn_SYSBP_816_B
						vsstresn_SYSBP_817_B
						vsstresn_TEMP_3 
					    vsstresn_WEIGHT_3;
	do i = 1 to 11;
		retain a1-a11;

		if first.usubjid then a(i)=.;

		if SCREENING(i) ne . then a(i)=SCREENING(i);

		if SCREENING(i)=. then SCREENING(i)=a(i);

		drop a: i;
	end;

	run;

data vsFlat2;
	set vs_post;
	by usubjid visitnum visit date;
	if length(substr(date, 1,10)) = 10 then vsdt=input(substr(date, 1,10), yymmdd10.);
	format vsdt date9.;;
	run;

*********************;
****END VAFLAT2******;
*********************;


***************************************************** START PROCESSING FOR EGFLAT ****************************************************;

*---------------------------------------------;
*Sort & Transpose dataset LB for Key variables;
*---------------------------------------------;

*EGTESTCD=INTP is not included as it is character value;

%macro EGflat(var=, prefix=);

*Chk whether var is c or n;
	data _null_;
		set eg;
		call symput('NY', vtype(&var.));
		run;
	%put NY=&NY;

*Sort;
	proc sort data=eg out=&var.1 dupout=chk_&var. nodupkey;
		%if &NY.=N %then 
		%do;
			where &var. ne .; 
		%end;
		%else 
		%do;
			where &var. ne '';
		%end; 
		by usubjid visitnum visit egdtc egtestcd &var.; 
		run;

*transpose;	
	proc transpose data=&var.1 out=&var.2 prefix=&prefix. ; by  usubjid visitnum visit egdtc ;var &var.;id egtestcd;run;

%mend egflat;
	 *%egflat(var=egstresn, prefix=egstresn_);
	

*---------------------------------------------;
*---Get all the desired information---------;
*---------------------------------------------;

/*Data EgFlat(drop=_name_ _label_);*/
/*	 set egstresn2(in=a);*/
/*	 by usubjid visitnum visit egdtc;*/
/*	 if a;*/
/*	 date=SUBSTR(upcase(egdtc),1,10); *DO NOT DELETE THIS VARIABLE;*/
/*	 if length(substr(egdtc, 1,10)) = 10 then egdt=input(substr(egdtc, 1,10), yymmdd10.);*/
/*	 format egdt date9.;*/
/*	 run;	*/

************************************************* Create AE Flat dataset ****************************************************;

*get AE Overall dataset;
	proc sort data=ae out=ae1 nodupkey;
		by usubjid aestdtc aeendtc aedecod descending aesev;
		run;

	data ae2;
		set ae1;
		by usubjid aestdtc aeendtc aedecod descending aesev;

		length max_aesev $20. max_aeser $1. ; 

		retain total_ae 0 mild mod sev aeser_n aeser_y .;

		if first.usubjid then total_ae=1;
						else total_ae+1;

		if upcase(aesev)='MILD' then mild=1;
		if upcase(aesev)='MODERATE' then mod=1;
		if upcase(aesev)='SEVERE' then sev=1;

		if upcase(aeser)='N' then aeser_n=1;
		if upcase(aeser)='Y' then aeser_y=1;

		if last.usubjid;

		if sev=1 then max_aesev='SEVERE';
		else if sev=. & mod=1 then max_aesev='MODERATE';
		else if sev=. & mod=. & mild=1 then max_aesev='MILD';
		
		if aeser_y=1 then max_aeser='Y';
					 else max_aeser='N';

		keep studyid domain usubjid total_ae max_aesev max_aeser;
		run;

	data AE_Overall;
		 set AE2;
		 by usubjid;
		 run;

*Get AE Current dataset;

	*Create Dummy visit;
	data dummyvisit;
		 set lbflat(keep=usubjid visitnum visit date) vsflat1(keep=usubjid visitnum visit date) /*egflat(keep=usubjid visitnum visit date)*/;
		 numdate=input(date, yymmdd10.);
		 format numdate date9. ;
		 run;
	proc sort data=dummyvisit nodupkey; by usubjid numdate visitnum visit; run;

	data dummyvisit1;
		set dummyvisit;
		by usubjid numdate visitnum visit ;
		retain start;
		if first.usubjid then start=numdate;
		if last.usubjid;

		rename numdate=end;

		drop visit visitnum date;

		format start date9. ;

		run;

	data dummyvisit2;
		set dummyvisit1;
		by usubjid;
		do numdate=start to end;
			output;
		end;
		format numdate date9. ;

		drop start end;
		run;
	proc sort data=dummyvisit2; by usubjid numdate; run;
	proc sort data=dummyvisit;  by usubjid numdate; run;

	data dummyvisit3;
		merge dummyvisit(in=a) dummyvisit2(in=b);
		by usubjid numdate;
		if b;

		length _visit $20. ;

		retain _visit _visitnum;

		if first.usubjid then do; _visit=''; _visitnum=.; end;
		if visit ne '' then _visit=visit;
		if visitnum ne . then _visitnum=visitnum;

		if visit='' then visit=_visit;
		if visitnum=. then visitnum=_visitnum;

		drop date _visit _visitnum ;

		run;
	proc sort data=dummyvisit3 nodupkey; by usubjid numdate; run;

	data ae12;
		set ae1;
		if length(compress(aestdtc)) ge 10;
			numdate= input(substr(aestdtc,1,10), yymmdd10. );

		format numdate date9.;
		run;
	proc sort data=ae12; by usubjid numdate; run;


	data ae13;
		merge ae12(in=a) dummyvisit3(in=b);
		by usubjid numdate ;
		if a;
		run;
	proc sort data=ae13;
		by usubjid visitnum numdate aestdtc aeendtc aedecod descending aesev;
		run;

	data ae14;
		set ae13;
		by usubjid visitnum numdate aestdtc aeendtc aedecod descending aesev;

		length current_max_aesev $20. current_max_aeser $1. ;

		retain current_total_ae 0 mild mod sev aeser_y .;

		if first.usubjid then current_total_ae=1;
						 else current_total_ae+1;

		if upcase(aesev)='MILD' then mild=1;
		if upcase(aesev)='MODERATE' then mod=1;
		if upcase(aesev)='SEVERE' then sev=1;

		if upcase(aeser)='Y' then aeser_y=1;

		if last.visitnum;
			
		if sev=1 then current_max_aesev='SEVERE';
		else if sev=. & mod=1 then current_max_aesev='MODERATE';
		else if sev=. & mod=. & mild=1 then current_max_aesev='MILD';
		
		if aeser_y=1 then current_max_aeser='Y';
					 else current_max_aeser='N';

		keep studyid domain usubjid visitnum visit numdate current_total_ae current_max_aesev current_max_aeser;

		run;
	
	data ae_current;
		set ae14;
		by usubjid visitnum;
		run;

*Get AE FLAT dataset;
	data aeflat;
		merge ae_current(in=a) ae_overall(in=b);
		by usubjid;
		if a & b;

		if visitnum ne . ;

		rename numdate=aenumdate;
		run;

************************************* MERGE DM_DM Information to AE LB, VS & EG Flat*********************************************;

%macro xx_flat(a=, b=);

	data &a._flat&b.;
		 merge &a.flat&b.(in=a) dm_dm(in=b);
		 by usubjid;
		 if a;
		 run;

%mend xx_flat;
	 %xx_flat(a=lb);
	 %xx_flat(a=vs, b=1);
	 %xx_flat(a=vs, b=2);
	 *%xx_flat(a=eg);
	 %xx_flat(a=ae);


************************************************* Create DM large ****************************************************;

*Create dummy information based on information present in LB EG VS ;
*This is a three step process a) Get all visitnum b) create visitnum information in DM c) create visitnum information in AE;

*a) Get all Visitnum info;
data visitnum1;
	 set lbflat vsflat1 /*egflat*/;
	 by usubjid visitnum;
	 keep visitnum;
	 run;
proc sort data=visitnum1 out=visitnum2 nodupkey;
	 by visitnum;
	 run;

proc sql; select count(visitnum) into :visitnum from visitnum2; quit;
%put visitnum=&visitnum;

%macro large(datain=, dataout=);

	*b & c Create visitnum info in DM & AEFLAT;
	data &dataout.;
		set &datain.;
		by usubjid;
			do i = 1 to &visitnum. ;
					 if i=1 then visitnum=1;
				else if i=2 then visitnum=1.1;
				else if i=3 then visitnum=1.2;
				else if i=4 then visitnum=1.3;
				else if i=5 then visitnum=2;
				else if i=6 then visitnum=3;
				else if i=7 then visitnum=3.1;
				else if i=8 then visitnum=3.5;
				else if i=9 then visitnum=4;
				else if i=10 then visitnum=4.1;
				else if i=11 then visitnum=4.2;
				else if i=12 then visitnum=5;
				else if i=13 then visitnum=5.1;

				else if i=14 then visitnum=6;
				else if i=15 then visitnum=6.1;
				else if i=16 then visitnum=7;
				else if i=17 then visitnum=7.1;
				else if i=18 then visitnum=8;
				else if i=19 then visitnum=8.2;
				else if i=20 then visitnum=9;
				else if i=21 then visitnum=9.2;
				else if i=22 then visitnum=9.3;
				else if i=23 then visitnum=10;
				else if i=24 then visitnum=11;
				else if i=25 then visitnum=12;

				else if i=26 then visitnum=12.1;
				else if i=27 then visitnum=13;
				else if i=28 then visitnum=13.1;
				else if i=29 then visitnum=201;

				output;
			end;

		drop i;
		run;
    
	proc sort data=&dataout.; by usubjid visitnum; run;
%mend large;
	 %large(datain=dm_dm, dataout=dmlarge);

************************************************* CREATE Large Files ****************************************************;
proc sort data=lb ; 	by usubjid visitnum; run;
proc sort data=vs ; 	by usubjid visitnum; run;
proc sort data=dmlarge; by usubjid visitnum; run;
proc sort data=aeflat;  by usubjid visitnum; run;
/*proc sort data=eg ; 	by usubjid visitnum visit egdtc egtestcd egstresn egseq; run;*/


%macro xx_dm_ae(xx=);

	data &xx._dm_Ae;
		merge &xx.(in=a) dmlarge(in=b) aeflat(in=c);
		by usubjid visitnum;
		if a;

		if length(substr(&xx.dtc, 1,10)) = 10 then &xx.dt=input(substr(&xx.dtc, 1,10), yymmdd10.);
		format &xx.dt date9.;

		run;
%mend xx_dm_ae;
	%xx_dm_ae(xx=vs);
	*%xx_dm_ae(xx=eg);
	%xx_dm_ae(xx=lb);

************************************************* CREATE Tall BDS & TALL AE Datasets ***************************************;
%macro xx_dm_ae_tall(xx=);
	proc sort data=&xx._dm_ae (where=(&xx.dt ne .)) out=&xx._tall1(keep=usubjid &xx.dt) nodupkey;
		 by usubjid &xx.dt;
		 run;

	data &xx._tall2;
		set &xx._tall1;
		by usubjid &xx.dt;

		retain start .;
		if first.usubjid then start=&xx.dt;
		if last.usubjid;

		format start date9.;

		rename &xx.dt=end;

		run;

	 data &xx._tall3;
	 	set &xx._tall2;
		
		do &xx.dt=start to end;
			output;
		end;
		format &xx.dt date9. ;
		run;
	proc sort data=&xx._tall3; by usubjid &xx.dt; run;
	proc sort data=&xx._dm_ae; by usubjid &xx.dt; run;

	data &xx._tall4;
		 merge &xx._tall3(in=a) &xx._dm_ae(in=b);
		 by usubjid &xx.dt;
		 if a;
		 drop start end;
		 run;
	proc sort data=&xx._tall4;
		 by usubjid &xx.dt visitnum visit &xx.testcd;
		 run;

	proc sql;
		create table &xx._dm_ae_tall(where= (&xx.testcd ne '' or subjid ne '' or total_Ae ne . or aedecod ne '')) as 
		select a.*, b.aeacn, b.aebodsys, b.aedecod, b.aeendtc, b.aeendy, b.aeout,
					b.aerel, b.aeser as _aeser, b.aeseq, b.aeser, b.aesev, b.aestdtc, b.aestdy, b.aeterm,
					b.numdate format=date9. as allaedt
					,case
						when length(substr(aestdtc, 1,10)) = 10 then input(substr(aestdtc, 1,10), yymmdd10.)
						else .
					end format=date9. as aestdt
					,case
						when length(substr(aeendtc, 1,10)) = 10 then input(substr(aeendtc, 1,10), yymmdd10.)
						else .
					end format=date9. as aeendt
 
		from &xx._tall4 a left join ae13 b 
		on (a.usubjid=b.usubjid) & (a.&xx.dt=b.numdate )
		order by usubjid, &xx.dt, visitnum, visit, &xx.testcd; 
		quit;
%mend xx_dm_ae_tall;
	%xx_dm_ae_tall(xx=vs);
	*%xx_dm_ae_tall(xx=eg);
	%xx_dm_ae_tall(xx=lb);

************************************************* CREATE AllFLAT Files ****************************************************;
proc sort data=lbflat nodupkey;  by usubjid visitnum visit ; run;
proc sort data=vsflat2 nodupkey; by usubjid visitnum visit ; run;
/*proc sort data=egflat nodupkey;	by usubjid visitnum visit ; run;*/

data all_flat;
	merge dmlarge(in=a) lbflat(in=b) /*egflat(in=c)*/ vsflat2(in=d) aeflat(in=e);
	by usubjid visitnum;
	if a;
	drop date;
	run;

************************************************* END PROCESSING FOR AllFLAT dataset ****************************************************;

**********************************************************Create EDISH data *************************************************************;
*Get subjects startdate & enddate;
proc sort data=ex_dm;by usubjid exstdy exendy;run;
data ex_first; set ex_dm; by usubjid exstdy exendy; if first.usubjid; if exstdy ge 1; keep usubjid exstdy exendy exstdtc exendtc; run;
data ex_last; set ex_dm; by usubjid exstdy exendy; if last.usubjid; if exstdy ge 1; rename exstdy=_exstdy exendy=_exendy exstdtc=_exstdtc exendtc=_exendtc ; 
			  keep usubjid exstdy exendy exstdtc exendtc; run;
data edish1;
	 merge dm_dm(in=a) ex_first ex_last;
	 by usubjid;
	 if a;
	 exendtc=_exendtc;
	 if exendtc='' then exendtc=_exstdtc;

	 if exendy=_exendy;
	 if exendy=. then exendy=_exstdy;

	 drop _: ;
	 run;

	data lbflat_e;
		set lbflat;

		rename  	lbstresn_ALT=ALT
							   		lbstresn_ALP=ALP
							   		lbstresn_AST=AST
							   		lbstresn_bili=BILI

							   		lbstnrlo_ALT=ALT_lo
							   		lbstnrlo_ALP=ALP_lo
							   		lbstnrlo_AST=AST_lo
							   		lbstnrlo_bili=BILI_lo


							   		lbstnrhi_ALT=ALT_hi
							   		lbstnrhi_ALP=ALP_hi
							   		lbstnrhi_AST=AST_hi
							   		lbstnrhi_bili=BILI_hi 
			;
	
		keep usubjid visitnum lbdtc lbdt lbstresn_ALT lbstresn_ALP lbstresn_AST lbstresn_bili
							   			 lbstnrlo_ALT lbstnrlo_ALP lbstnrlo_AST lbstnrlo_bili
							   			 lbstnrhi_ALT lbstnrhi_ALP lbstnrhi_AST lbstnrhi_bili ;
							
	run;
	proc sort data=lbflat_e;
		by usubjid visitnum lbdtc;
		run;	

data edish;
	 merge lbflat_e(in=a) edish1(in=b);
	 by usubjid;
	 if a & b;
	 run;
*------------------------------------;
*Get All dataset in sdtm_va Library;
proc sql;
	create table sdtm_va.all_flat as select * from all_flat;

	create table sdtm_va.ae_flat  as select * from ae_flat;
	create table sdtm_va.lb_flat  as select * from lb_flat;
	create table sdtm_va.vs_flat1 as select * from vs_flat1;
	create table sdtm_va.vs_flat2 as select * from vs_flat2;
/*	create table sdtm_va.eg_flat  as select * from eg_flat;*/

	create table sdtm_va.vs_dm_ae as select * from vs_dm_ae;
	create table sdtm_va.lb_dm_ae as select * from lb_dm_ae;
/*	create table sdtm_va.eg_dm_ae as select * from eg_dm_ae;*/

	create table sdtm_va.vs_dm_ae_tall as select * from vs_dm_ae_tall;
	create table sdtm_va.lb_dm_ae_tall as select * from lb_dm_ae_tall;
/*	create table sdtm_va.eg_dm_ae_tall as select * from eg_dm_ae_tall;*/

	create table sdtm_va.dm_dm as select * from dm_dm;
	create table sdtm_va.ae_dm as select * from ae_dm;
	create table sdtm_va.cm_dm as select * from cm_dm;
	create table sdtm_va.mh_dm as select * from mh_dm;
	create table sdtm_va.ex_dm as select * from ex_dm;
	create table sdtm_va.lb_dm as select * from lb_dm;
	create table sdtm_va.vs_dm as select * from vs_dm;
/*	create table sdtm_va.eg_dm as select * from eg_dm;*/

	create table sdtm_va.pat_nar as select * from pat_nar;
	create table sdtm_va.edish as select * from edish;

quit;







	 
	
