%macro copyToFolder(srcFile,outFile);
/* these IN and OUT filerefs can point to anything */
filename in "&srcFile"; 
filename out "&outFile" permission='A::u::rw-,A::g::rw-,A::o::rw-';
 
/* copy the file byte-for-byte  */
data _null_;
  length filein 8 fileid 8;
  filein = fopen('in','I',1,'B');
  fileid = fopen('out','O',1,'B');
  rec = '20'x;
  do while(fread(filein)=0);
     rc = fget(filein,rec,1);
     rc = fput(fileid, rec);
     rc =fwrite(fileid);
  end;
  rc = fclose(filein);
  rc = fclose(fileid);
run;
 
filename in clear;
filename out clear;

%mend copyToFolder;

%copyToFolder(	&_SASWS_//Clinical Development/VA_Data_Exchange/CDISCPILOT01/tabulations/sdtm_va/dm_dm.sas7bdat,
			&_SASWS_/toVisualAnalytics/dm_dm.sas7bdat
			);