CREATE OR REPLACE PACKAGE sm_referencedata
IS
   PROCEDURE process_source(areaOID in number);

   PROCEDURE read_file (i_srcdir IN VARCHAR2, i_srcfile IN VARCHAR2);

   PROCEDURE process_handlers;

   PROCEDURE process_lu_type;
END sm_referencedata;
/
