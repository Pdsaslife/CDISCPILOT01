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

*Variables marked with an asterisk are supplementary/permissible and should only be populated when required by the Define and available from source data.*
