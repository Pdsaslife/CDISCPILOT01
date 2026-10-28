
%global va_host va_userid va_password;

%macro chkparam();
    %if %length(&va_host)<=1 %then %let va_host=%str(hlsrd53au);
    %if %length(&va_userid)<=1 %then %let va_userid = %str(sajune);
    %if %length(&va_password)<=1 %then %let va_password=%str();
%mend chkparam;

%chkparam();

%macro create_authinfo(va_host=%str(hlsrd53au),va_userid=,va_password=);

* Substitute the values that are highlighted and run. You’ll need to rerun this code anytime your password changes to update the .authinfo file. ;

filename pwfile temp; 
proc pwencode in="&va_password" out=pwfile;
run;

filename out "&_SASWS_/.authinfo" permission='A::u::rw-,A::g::---,A::o::---';

data _null_;
  file out; 
  length etlrun_pw $200; 
  infile pwfile truncover; 
  input etlrun_pw; 
  final = "host &va_host..vsp.sas.com port 5570 user &va_userid password " || trim(etlrun_pw);
  call symputx("text",final);
  put final;
run;
%put &text;

%mend create_authinfo;

%create_authinfo(va_host=%str(&va_host),va_userid=%str(&va_userid),va_password=%str(&va_password));


%symdel va_host va_userid va_password/nowarn;