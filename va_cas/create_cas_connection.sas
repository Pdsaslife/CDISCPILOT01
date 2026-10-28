
options msglevel=i;
options cashost="hlsrd53au.vsp.sas.com" casport=5570;
/*Start a CAS session named myses and specify the personal caslib, Casuser, as the active caslib.*/
cas myses authinfo="&_SASWS_/.authinfo" sessopts=(caslib=casuser);
/*If you have not already done so, use the CAS LIBNAME statement to create a CAS engine libref.*/
libname mycas cas;
/*Specify _ALL_ ASSIGN in the CASLIB statement to assign SAS librefs to existing caslibs. Assigning SAS librefs to caslibs enables you to see caslib
  names in the Libraries pane */
caslib _ALL_ assign;



/*Use PROC CASUTIL to load the Sashelp.Cars data set to CAS. This creates an
  in-memory CAS table named Cars. The OUTCASLIB= option loads the CAS
  table to the CASUSER caslib.*/
proc casutil outcaslib='public'; 
 load data=sashelp.cars casout="cars";
quit;

/* Specify a CAS table as the output data using the CAS engine libref */
data mycas.cars / sessref=myses;
   set sashelp.cars;
   put 'The DATA step is running in ' _nthreads_ 'threads';
run;

libname local "&_sasws_/SAS/Files/Utilities/va_cas";

data local.cars;
  set mycas.cars;
run;

%macro loadsaveit(name=);
 proc casutil;
 load data=sashelp.&name
 outcaslib='casuser'
 replace;
 save casdata="&name" replace;
run; quit;
%mend loadsaveit;
%loadsaveit(name=cars);

*<CAS code here>;

Proc Cas;
  session mysession;
  tableinfo result=r;
  print r;
run;

   
cas myses terminate;
