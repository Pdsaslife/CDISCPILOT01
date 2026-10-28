/**************************************************************************     
Program: raw_to_sdtm_dm_fixed.sas                                               
Purpose: Create SDTM DM from raw_dm.csv                                         
Standard: SDTMIG 3.1.2, Amendment 1                                             
Based on: raw_to_sdtm_dm.sas (original left unchanged)                          
                                                                                
Fixes versus the original:                                                      
 1. SDTM libref was never assigned -> assigned here to a new folder             
    (use_case/sdtm_out) so existing SDTM data is not overwritten.               
 2. Raw variable names did not match raw_dm.csv (CTPATNO, INV, BIRTHDT,         
    CONSENTDT, DEATHDT, AGE_RAW, ETHNIC_RAW, ARM_RAW, COUNTRY_RAW ...).         
    Now mapped to the real columns: SUBJID, SITEID, BRTHDAT_RAW,                
    ICDAT_RAW, SEX_RAW, RACE_RAW.                                               
 3. SITEID/SUBJID were imported as numeric (leading zeros lost) and then        
    conflicted with the character target variables. The CSV is now read         
    with a data step so both stay character.                                    
 4. put(SITEID, best.) was invalid on a character variable ($BEST error).       
 5. Raw dates are already SAS dates; ANYDTDTE parsing removed.                  
 6. RACE_RAW holds 2-letter codes; code mapping added. Unconfirmed codes        
    are NOT mapped silently - they are written to work.dm_exceptions.           
 7. Variables with no source in raw_dm.csv (ETHNIC, ARMCD, ARM, COUNTRY,        
    DTHDTC, DTHFL, RFSTDTC, RFENDTC) are left missing, not invented.            
**************************************************************************/     
                                                                                
options validvarname=any missing='';                                            
                                                                                
%let rawpath = /mnt/viya-share/data/CDISCPILOT01/raw;                           
%let outroot = /mnt/viya-share/data/CDISCPILOT01/use_case;                      
%let outpath = &outroot./sdtm_out;                                              
                                                                                
/* Output library (new folder; does not touch tabulations/sdtm) */              
data _null_;                                                                    
  length rc $256;                                                               
  if not fileexist("&outpath.") then rc = dcreate("sdtm_out", "&outroot.");     
run;                                                                            
libname sdtm "&outpath.";                                                       
                                                                                
/* Read raw demographics. SITEID/SUBJID read as character to keep zeros */      
data work.raw_dm;                                                               
  infile "&rawpath./raw_dm.csv" dsd missover firstobs=2 lrecl=32767;            
  length STUDYID $12 SITEID $10 SUBJID $20 USUBJID_RAW $40                      
         FIRSTINIT MIDINIT LASTINIT $1 SEX_RAW $1 RACE_RAW $2;                  
  input STUDYID $ SITEID $ SUBJID $ USUBJID_RAW $                               
        FIRSTINIT $ MIDINIT $ LASTINIT $                                        
        BRTHDAT_RAW :mmddyy10. SEX_RAW $ RACE_RAW $                             
        VISIT1DAT_RAW :mmddyy10. ICDAT_RAW :mmddyy10.                           
        YEARSEDU_RAW                                                            
        SMOKE_INFO_NOT_OBTAINED :$1.                                            
        ALCOHOL_INFO_NOT_OBTAINED :$1.                                          
        CAFFEINE_INFO_NOT_OBTAINED :$1.;                                        
  format BRTHDAT_RAW VISIT1DAT_RAW ICDAT_RAW yymmdd10.;                         
run;                                                                            
                                                                                
data work.dm_pre(drop=VARIABLE RAW_VALUE)                                       
     work.dm_exceptions(keep=USUBJID VARIABLE RAW_VALUE);                       
  length                                                                        
    STUDYID  $20                                                                
    DOMAIN   $2                                                                 
    USUBJID  $40                                                                
    SUBJID   $20                                                                
    RFSTDTC  $19                                                                
    RFENDTC  $19                                                                
    RFICDTC  $19                                                                
    DTHDTC   $19                                                                
    DTHFL    $1                                                                 
    SITEID   $10                                                                
    BRTHDTC  $10                                                                
    AGE       8                                                                 
    AGEU     $5                                                                 
    SEX      $20                                                                
    RACE     $60                                                                
    ETHNIC   $40                                                                
    ARMCD    $20                                                                
    ARM      $200                                                               
    COUNTRY  $3                                                                 
    VARIABLE $8                                                                 
    RAW_VALUE $60                                                               
  ;                                                                             
                                                                                
  set work.raw_dm;                                                              
                                                                                
  /* Study identifiers */                                                       
  STUDYID = "CDISCPILOT01"; /* Confirm exact value in define.pdf */             
  DOMAIN  = "DM";                                                               
                                                                                
  /* Subject and site identifiers (kept as character, zeros preserved) */       
  SUBJID = strip(SUBJID);                                                       
  SITEID = strip(SITEID);                                                       
                                                                                
  /* USUBJID = STUDYID-SITEID-SUBJID; cross-checked to the raw USUBJID */       
  USUBJID = catx("-", STUDYID, SITEID, SUBJID);                                 
  if USUBJID ne strip(USUBJID_RAW) then                                         
    put "WARNING: Derived USUBJID differs from raw USUBJID: "                   
        USUBJID= USUBJID_RAW=;                                                  
                                                                                
  /* Dates are already SAS dates -> ISO 8601 */                                 
  if not missing(BRTHDAT_RAW) then BRTHDTC = put(BRTHDAT_RAW, e8601da.);        
  if not missing(ICDAT_RAW)   then RFICDTC = put(ICDAT_RAW,   e8601da.);        
                                                                                
  /*                                                                            
  RFSTDTC and RFENDTC need a protocol-defined source (e.g. EX/DS).              
  Not available in raw_dm.csv; consent date is NOT used as a substitute.        
  Death information is not collected in raw_dm.csv.                             
  */                                                                            
  call missing(RFSTDTC, RFENDTC, DTHDTC, DTHFL);                                
                                                                                
  /* Age: no collected age in raw data, so derive as completed years at         
     informed consent (confirm reference date against the Define) */            
  if not missing(BRTHDAT_RAW) and not missing(ICDAT_RAW) then do;               
    AGE  = floor(yrdif(BRTHDAT_RAW, ICDAT_RAW, "AGE"));                         
    AGEU = "YEARS";                                                             
  end;                                                                          
                                                                                
  /* Sex controlled terminology */                                              
  select (upcase(strip(SEX_RAW)));                                              
    when ("M", "MALE", "1")   SEX = "M";                                        
    when ("F", "FEMALE", "2") SEX = "F";                                        
    when ("U", "UNKNOWN")     SEX = "U";                                        
    otherwise do;                                                               
      SEX = "";                                                                 
      if not missing(SEX_RAW) then do;                                          
        put "WARNING: Unmapped SEX value: " SEX_RAW= USUBJID=;                  
        VARIABLE = "SEX"; RAW_VALUE = SEX_RAW; output work.dm_exceptions;       
      end;                                                                      
    end;                                                                        
  end;                                                                          
                                                                                
  /* Race: raw data uses 2-letter codes. Only unambiguous codes mapped;         
     EA, HP and O need confirmation against the CRF/Define. */                  
  select (upcase(strip(RACE_RAW)));                                             
    when ("CA", "WHITE", "CAUCASIAN")                                           
      RACE = "WHITE";                                                           
    when ("AF", "BLACK", "AFRICAN AMERICAN", "BLACK OR AFRICAN AMERICAN")       
      RACE = "BLACK OR AFRICAN AMERICAN";                                       
    when ("AS", "ASIAN")                                                        
      RACE = "ASIAN";                                                           
    otherwise do;                                                               
      RACE = "";                                                                
      if not missing(RACE_RAW) then do;                                         
        put "WARNING: Unmapped RACE value: " RACE_RAW= USUBJID=;                
        VARIABLE = "RACE"; RAW_VALUE = RACE_RAW; output work.dm_exceptions;     
      end;                                                                      
    end;                                                                        
  end;                                                                          
                                                                                
  /* ETHNIC, ARMCD, ARM, COUNTRY: no source columns in raw_dm.csv.              
     Left missing; populate from the correct source (e.g. randomization,        
     site/country listing) once identified. */                                  
  call missing(ETHNIC, ARMCD, ARM, COUNTRY);                                    
                                                                                
  output work.dm_pre;                                                           
run;                                                                            
                                                                                
/* Check uniqueness: one DM record per subject */                               
proc sort data=work.dm_pre                                                      
          out=work.dm_sorted                                                    
          nodupkey                                                              
          dupout=work.dm_duplicates;                                            
  by STUDYID USUBJID;                                                           
run;                                                                            
                                                                                
data _null_;                                                                    
  if 0 then set work.dm_duplicates nobs=nobs;                                   
  if nobs > 0 then                                                              
    put "ERROR: Duplicate USUBJID records found in DM. Count=" nobs;            
  stop;                                                                         
run;                                                                            
                                                                                
/* Final variable order */                                                      
data sdtm.dm(label="Demographics");                                             
  retain                                                                        
    STUDYID DOMAIN USUBJID SUBJID                                               
    RFSTDTC RFENDTC RFICDTC                                                     
    DTHDTC DTHFL                                                                
    SITEID                                                                      
    BRTHDTC AGE AGEU SEX RACE ETHNIC                                            
    ARMCD ARM COUNTRY                                                           
  ;                                                                             
  set work.dm_sorted;                                                           
  keep                                                                          
    STUDYID DOMAIN USUBJID SUBJID                                               
    RFSTDTC RFENDTC RFICDTC                                                     
    DTHDTC DTHFL                                                                
    SITEID                                                                      
    BRTHDTC AGE AGEU SEX RACE ETHNIC                                            
    ARMCD ARM COUNTRY                                                           
  ;                                                                             
run;                                                                            
                                                                                
/* Basic validation */                                                          
proc sort data=sdtm.dm;                                                         
  by STUDYID USUBJID;                                                           
run;                                                                            
                                                                                
proc freq data=sdtm.dm;                                                         
  tables SEX RACE ETHNIC ARMCD COUNTRY DTHFL / missing;                         
run;                                                                            
                                                                                
proc contents data=sdtm.dm varnum;                                              
run;                                                                            
                                                                                
/* Mapping exception report for manual review */                                
title "Mapping exceptions - manual review required";                            
proc print data=work.dm_exceptions noobs;                                       
run;                                                                            
title;                                                                          
