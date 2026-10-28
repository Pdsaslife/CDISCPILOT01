
%global job_path sleep_time run_count;

%macro chkParam();
    %if %length(&job_path)<=1 %then %let job_path = %str(/Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/programs/sdtm_va.job);
    %if %length(&sleep_time)<=1 %then %let sleep_time = %str(3);
    %if %length(&run_count)<=0 %then %let run_count=%str(3);
%mend chkParam;

%chkParam();

%macro run_sdtm_va(job_path=, sleep_time=, run_count=);
    
  %let rs_job_path=%sysfunc(tranwrd(&job_path,&_sasws_,%str())); 
 
   * Iterate loop - run_count times;
   %do i = 1 %to &run_count;
   
     %lsaf_getjobparameters(lsaf_path=%str(&rs_job_path.), sas_dsname=work.sddGetJobParameters);
  
     data sddGetJobParameters;
       set sddGetJobParameters;
       length value $2000;
       value=strip(defaultValue);
      
       *if name="sleep" then value=trim("&sleep_time");
       if name="count" then value=trim("&i");
     run;
 
     proc print data=sddGetJobParameters;
     run;
  
     %lsaf_submitjob(lsaf_path=%str(&rs_job_path.), sas_dsname=sddGetJobParameters);
     %put _lsafJobSubmissionId_=&_lsafJobSubmissionId_;
       
     %TryAgain:    
         data _null_;
           call sleep(500,.01); * 5 seconds;
         run;
    
     %lsaf_getsubmissionstatus(lsaf_jobsubmission_id=&_lsafJobSubmissionId_);
     %put _lsafJobSubmissionStatus_= &_lsafJobSubmissionStatus_;
        
     %put %index(&_lsafJobSubmissionStatus_,%STR(COMPLETED));
     %if (%index(&_lsafJobSubmissionStatus_,%STR(COMPLETED))<=0) %then %goto TryAgain;
     
     data _null_;
        call sleep(&sleep_time,1); * seconds;
     run;
   %end;
    
%mend run_sdtm_va;

%run_sdtm_va(job_path=&job_path, sleep_time=&sleep_time, run_count=&run_count);

%symdel job_path sleep_time run_count/ nowarn;
