libname temp 'C:\Users\prdesa\Documents\CDISC SDTM Pilot Submission Package\900172\m5\datasets\cdiscpilot01\tabulations\sdtm_va';
proc sort data=temp.dm_dm; by armcd; run;
proc surveyselect data=temp.dm_dm out=key(keep=replicate studyid usubjid) method=srs samprate=0.60 reps=200 seed=32259;
  strata armcd;
run;

data temp.key; length studyid $14 usubjid $13; set key;
  studyid=compress(studyid||"_"||put(replicate,1.));
  usubjid=compress(usubjid||"_"||put(replicate,1.));
  drop replicate;
run;
