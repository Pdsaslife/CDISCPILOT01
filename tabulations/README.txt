/************************************************************************************************************************************
							FOR INTERNAL PURPOSE ONLY
	 						-------------------------

Purpose		:Convert SDTM data to VA data

Created	By	:Pritesh Desai

Datetime  	:08/07/2013T10:00

Input data	:SDTM/ADaM Pilot Project from 
		 http://www.cdisc.org/sdtm-adam-pilot-project(User ID:  SASinstitute Password:  Sasi01)
		 New - Updated Version of Pilot Submission Package (2013)

Output data	:VA SDTM FLAT DATASET

Location        :\\vfiler06.unx.sas.com\hlsse\_Pharma\CDISC SDTM Pilot Submission Package\900172\m5\datasets\cdiscpilot01\tabulations
                 -Readme.txt--(INSTRUCTION) 
		 -sdtm--(Original folder from CDISC)
		 -sdtm_datasets--(SDTM datasets converted from XPT files in sdtm folder)
		 -sdtm_va--(VA SDTM Flat dataset)
		 -Convert_Xpt_To_Sdtm.sas--(pgm to conver XPT to SAS dataset ***Read Note section)
		 -Sdtm_VA.sas--(pgm to convert SDTM to VA Flat dataset ***Read Note section)

Note		: Similar effort was done for custom VA demo by Ed Phillips, Mike Henderson.
                  Custom code was written for this effort & same custom code is used to 
		  convert SDTM data to VA SDTM Flat Datasets

		:Note for Analyst
			-There is no EG Domain 

			-Check VS domain, visit information is extensive. 
			 Variable VSTPTNUM is used everywhere instead of VSTPT

			-Running the code for shared server is slow, running things on local
			 will drastically improve the speed
			
			-If directly running the code from server Analyst will have to change SAS pgm, update the 
			 libname statement to "\\vfiler06.unx.sas.com\hlsse\_Pharma\CDISC SDTM Pilot Submission Package"



****************************************************************************************************************************************/