/**************************************************************************
 Program: create_dm.sas
 Purpose: Create SDTM DM from raw_dm.csv
 Standard: SDTMIG 3.1.2, Amendment 1
 Note: Raw variable names and study constants must be confirmed.
**************************************************************************/

options validvarname=any missing='';

/* Import raw demographics data */
proc import datafile="/mnt/viya-share/data/CDISCPILOT01/raw/raw_dm.csv"
    out=work.raw_dm
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/* Character versions of source variables prevent numeric formatting issues */
data work.dm_pre;
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
    ;

    set work.raw_dm;

    /* Study identifiers */
    STUDYID = "CDISCPILOT01"; /* Confirm exact value in define.pdf */
    DOMAIN  = "DM";

    /*
       Preserve leading zeros. If CTPATNO was imported as numeric,
       replace the format below with the width required by the specification.
    */
    if vtype(CTPATNO) = "N" then
        SUBJID = strip(put(CTPATNO, best.));
    else
        SUBJID = strip(CTPATNO);

    /*
       Confirm exact USUBJID algorithm.
       Context indicates concatenation involving STUDYID/site or investigator/
       subject number, with an example resembling 01-INV-CTPATNO.
    */
    USUBJID = catx("-", STUDYID, strip(INV), SUBJID);

    /* Site identifier */
    SITEID = strip(SITEID);

    /*
       Convert dates to ISO 8601.
       ANYDTDTE is suitable only for complete dates that SAS recognizes.
       Partial dates require explicit character-based conversion logic.
    */
    if not missing(BIRTHDT) then do;
        _birthn = input(strip(BIRTHDT), anydtdte.);
        if not missing(_birthn) then BRTHDTC = put(_birthn, e8601da.);
    end;

    if not missing(CONSENTDT) then do;
        _consentn = input(strip(CONSENTDT), anydtdte.);
        if not missing(_consentn) then RFICDTC = put(_consentn, e8601da.);
    end;

    if not missing(DEATHDT) then do;
        _deathn = input(strip(DEATHDT), anydtdte.);
        if not missing(_deathn) then do;
            DTHDTC = put(_deathn, e8601da.);
            DTHFL  = "Y";
        end;
    end;

    /*
       RFSTDTC and RFENDTC should be populated from their protocol-defined
       sources. Do not automatically equate informed-consent date to RFSTDTC
       unless the study specification explicitly says to do so.
    */
    call missing(RFSTDTC, RFENDTC);

    /* Age: use collected age when available; otherwise derive if permitted */
    if not missing(AGE_RAW) then
        AGE = input(strip(AGE_RAW), best.);
    else if not missing(_birthn) and not missing(_consentn) then
        AGE = floor(yrdif(_birthn, _consentn, "AGE"));

    if not missing(AGE) then AGEU = "YEARS";

    /* Sex controlled terminology */
    select (upcase(strip(SEX_RAW)));
        when ("M", "MALE", "1")   SEX = "M";
        when ("F", "FEMALE", "2") SEX = "F";
        when ("U", "UNKNOWN")     SEX = "U";
        otherwise do;
            SEX = "";
            if not missing(SEX_RAW) then
                put "WARNING: Unmapped SEX value: " SEX_RAW= USUBJID=;
        end;
    end;

    /* Race controlled terminology */
    select (upcase(strip(RACE_RAW)));
        when ("WHITE", "CAUCASIAN")
            RACE = "WHITE";
        when ("BLACK", "AFRICAN AMERICAN",
              "BLACK OR AFRICAN AMERICAN")
            RACE = "BLACK OR AFRICAN AMERICAN";
        when ("ASIAN")
            RACE = "ASIAN";
        when ("AMERICAN INDIAN OR ALASKA NATIVE")
            RACE = "AMERICAN INDIAN OR ALASKA NATIVE";
        when ("NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER")
            RACE = "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER";
        when ("MULTIPLE", "MULTIPLE RACE")
            RACE = "MULTIPLE";
        when ("NOT REPORTED")
            RACE = "NOT REPORTED";
        when ("UNKNOWN")
            RACE = "UNKNOWN";
        otherwise do;
            RACE = "";
            if not missing(RACE_RAW) then
                put "WARNING: Unmapped RACE value: " RACE_RAW= USUBJID=;
        end;
    end;

    /* Ethnicity controlled terminology */
    select (upcase(strip(ETHNIC_RAW)));
        when ("HISPANIC OR LATINO", "HISPANIC", "YES")
            ETHNIC = "HISPANIC OR LATINO";
        when ("NOT HISPANIC OR LATINO", "NOT HISPANIC", "NO")
            ETHNIC = "NOT HISPANIC OR LATINO";
        when ("NOT REPORTED")
            ETHNIC = "NOT REPORTED";
        when ("UNKNOWN")
            ETHNIC = "UNKNOWN";
        otherwise do;
            ETHNIC = "";
            if not missing(ETHNIC_RAW) then
                put "WARNING: Unmapped ETHNIC value: "
                    ETHNIC_RAW= USUBJID=;
        end;
    end;

    /* Planned treatment arm */
    ARMCD = strip(ARMCD_RAW);
    ARM   = strip(ARM_RAW);

    /* Country should be ISO 3166-1 alpha-3 */
    select (upcase(strip(COUNTRY_RAW)));
        when ("US", "USA", "UNITED STATES", "UNITED STATES OF AMERICA")
            COUNTRY = "USA";
        otherwise do;
            COUNTRY = upcase(strip(COUNTRY_RAW));
            if lengthn(COUNTRY) ne 3 and not missing(COUNTRY) then
                put "WARNING: COUNTRY is not a 3-character code: "
                    COUNTRY_RAW= USUBJID=;
        end;
    end;

    drop _: AGE_RAW SEX_RAW RACE_RAW ETHNIC_RAW ARMCD_RAW ARM_RAW COUNTRY_RAW;
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
data sdtm.dm(
    label="Demographics"
);
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