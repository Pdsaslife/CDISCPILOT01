# RAM Results
## Based on the define.pdf, raw_dm.csv, blank CRF documents, please generate the specs for SDTM DM domain to convert raw_dm.csv dataset to SDTM DM Domain. Also provide the sample sas code if possible

I can provide a draft specification and SAS template, but not a submission-ready specification because the supplied context does not include the DM section of define.pdf, the columns and sample values from raw_dm.csv, or the relevant blank CRF pages.

The available documentation establishes that:

SDTM IG 3.1.2 with Amendment 1 was used.
USUBJID was derived by concatenating STUDYID, investigator/site information, and CTPATNO. The mapping screenshot indicates a pattern similar to 01-INV-CTPATNO.
Screen-failure subjects were retained in DM but removed from other domains.
Variables were ordered with key variables first, followed by SDTM IG order.
Final datasets were converted to SAS transport format.

# SDTM DM Domain — Variable Specifications

| # | Variable | Label | Type / Length | Proposed Source | Derivation / Mapping Rule | Controlled Terminology |
|---|----------|-------|---------------|-----------------|---------------------------|------------------------|
| 1 | STUDYID | Study Identifier | Char 20 | Assigned | Constant from define.pdf, tentatively CDISCPILOT01 | — |
| 2 | DOMAIN | Domain Abbreviation | Char 2 | Assigned | "DM" | DM |
| 3 | USUBJID | Unique Subject Identifier | Char 40 | INV, CTPATNO | Concatenate study/site/investigator identifier and subject number according to Define.xml; context indicates a pattern such as 01-INV-CTPATNO | — |
| 4 | SUBJID | Subject Identifier for the Study | Char 20 | CTPATNO | Character representation of the subject number; preserve leading zeros as specified | — |
| 5 | RFSTDTC | Subject Reference Start Date/Time | Char 19 | Confirm from CRF/source | Convert the protocol-defined reference start date to ISO 8601. This may require another source such as exposure or disposition data. | ISO 8601 |
| 6 | RFENDTC | Subject Reference End Date/Time | Char 19 | Confirm from CRF/source | Convert the protocol-defined reference end date to ISO 8601. This may require another source domain. | ISO 8601 |
| 7 | RFXSTDTC* | Date/Time of First Study Treatment | Char 19 | First treatment/exposure | Earliest study-treatment start date. Usually derived from EX rather than demographics. | ISO 8601 |
| 8 | RFXENDTC* | Date/Time of Last Study Treatment | Char 19 | Last treatment/exposure | Latest study-treatment end date. Usually derived from EX rather than demographics. | ISO 8601 |
| 9 | RFICDTC* | Date/Time of Informed Consent | Char 19 | Consent date | Convert to ISO 8601 without imputing missing components unless specifications explicitly require it. | ISO 8601 |
| 10 | RFPENDTC* | Date/Time of End of Participation | Char 19 | Disposition/end date | Convert to ISO 8601. | ISO 8601 |
| 11 | DTHDTC | Date/Time of Death | Char 19 | Death date | Convert to ISO 8601; leave blank if subject did not die. | ISO 8601 |
| 12 | DTHFL | Subject Death Flag | Char 1 | Death status/date | "Y" when death is documented; otherwise blank. | Y |
| 13 | SITEID | Study Site Identifier | Char 10 | SITEID or INV | Map the sponsor-assigned site identifier. Do not substitute investigator name unless Define specifies this. | — |
| 14 | INVID* | Investigator Identifier | Char 20 | INV | Map only if present and required by the Define. | — |
| 15 | INVNAM* | Investigator Name | Char 100 | Investigator name | Map only if included in the Define and permitted under de-identification rules. | — |
| 16 | BRTHDTC | Date/Time of Birth | Char 10 | Birth date | Convert to ISO 8601. Preserve partial dates if collected; apply de-identification rules documented for the submission. | ISO 8601 |
| 17 | AGE | Age | Numeric 8 | Collected age or birth/reference dates | Prefer collected age if defined that way. Otherwise derive as completed years at the protocol-defined reference date. | — |
| 18 | AGEU | Age Units | Char 5 | Assigned/collected | Usually "YEARS" when AGE is populated. | AGEU |
| 19 | SEX | Sex | Char 1 | Sex | Map raw values to SDTM terminology, normally M, F, U, or UNDIFFERENTIATED where applicable to the IG version. | SEX |
| 20 | RACE | Race | Char 60 | Race | Map to SDTM controlled terminology. Use MULTIPLE when specified and place individual races in SUPPDM if required by the implementation approach. | RACE |
| 21 | ETHNIC | Ethnicity | Char 40 | Ethnicity | Map to controlled terminology such as HISPANIC OR LATINO, NOT HISPANIC OR LATINO, UNKNOWN, or NOT REPORTED. | ETHNIC |
| 22 | ARMCD | Planned Arm Code | Char 20 | Randomization/treatment assignment | Map to the arm code defined in TA. Screen failures or unassigned subjects may be assigned according to the study specification. | Study-defined |
| 23 | ARM | Description of Planned Arm | Char 200 | Randomization/treatment assignment | Decode ARMCD using the trial-arm metadata. | Study-defined |
| 24 | ACTARMCD* | Actual Arm Code | Char 20 | Actual treatment | Populate if required by this Define version and available from treatment data. | Study-defined |
| 25 | ACTARM* | Description of Actual Arm | Char 200 | Actual treatment | Decode ACTARMCD. | Study-defined |
| 26 | COUNTRY | Country | Char 3 | Site country | Use ISO 3166-1 alpha-3 country code, e.g. USA. | ISO country code |
| 27 | DMDTC* | Date/Time of Collection | Char 19 | Demographics collection date | Convert to ISO 8601 if present in the Define. | ISO 8601 |
| 28 | DMDY* | Study Day of Collection | Numeric 8 | DMDTC, RFSTDTC | If DMDTC ≥ RFSTDTC, DMDY = DMDTC − RFSTDTC + 1; otherwise DMDY = DMDTC − RFSTDTC. No study day zero. | — |

*Variables marked with an asterisk are supplementary/permissible and should only be populated when required by the De
# * Include only when present in the study’s DM metadata.

## Subject inclusion
DM should contain one record per subject represented in the submission. Based on the supplied documentation:

Retain screen failures in DM.
Remove screen failures from other domains where required.
Do not create multiple DM records for one USUBJID.

# 2. Example value mappings
These mappings must be checked against the raw values.

These mappings must be checked against the raw values.

| Raw value | SDTM variable | SDTM value |
|-----------|---------------|------------|
| Male, MALE, 1 | SEX | M |
| Female, FEMALE, 2 | SEX | F |
| Caucasian, White | RACE | WHITE |
| Black, African American | RACE | BLACK OR AFRICAN AMERICAN |
| Asian | RACE | ASIAN |
| Yes for Hispanic ethnicity | ETHNIC | HISPANIC OR LATINO |
| No for Hispanic ethnicity | ETHNIC | NOT HISPANIC OR LATINO |
| United States | COUNTRY | USA |

Do not silently map unexpected values. Produce a mapping exception report for manual review.

# 3. Sample SAS program
This example assumes raw variables named INV, CTPATNO, SITEID, BIRTHDT, SEX, RACE, ETHNIC, ARMCD, ARM, COUNTRY, CONSENTDT, and DEATHDT. Adjust these after inspecting raw_dm.csv.

#

/**************************************************************************
 Program: create_dm.sas
 Purpose: Create SDTM DM from raw_dm.csv
 Standard: SDTMIG 3.1.2, Amendment 1
 Note: Raw variable names and study constants must be confirmed.
**************************************************************************/
#
options validvarname=upcase missing='';
#
/* Import raw demographics data */
proc import datafile="&rawpath./raw_dm.csv"
    out=work.raw_dm
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;
#
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
#
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

# 4. Required checks before finalization
1. Obtain the exact DM variable list, labels, lengths, origins, comments, and order from define.pdf.
2. Compare every raw_dm.csv column with the annotated CRF.
3. Confirm the exact STUDYID and USUBJID algorithm, especially whether the prefix is 01, the full study ID, or site/investigator ID.
4. Confirm which date defines RFSTDTC and which date defines RFENDTC.
5. Do not derive treatment variables solely from demographics if EX or randomization data are required.
6. Preserve partial ISO dates; do not impute unknown month/day values for SDTM unless specifically documented.
7. Reconcile AGE against birth date and the study-defined age reference date.
8. Validate controlled terminology against the terminology version used by the pilot submission.
9. Ensure screen failures remain in DM with arm values handled according to the study specification.
10. Run structural and terminology validation, along with independent QC against the approved mapping specification.


