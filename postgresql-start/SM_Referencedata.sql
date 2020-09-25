/* Formatted on 2005/10/20 16:13 (Formatter Plus v4.8.5) */


DROP SEQUENCE SEQ_PSHANDLER;
--Add sequences
CREATE SEQUENCE SEQ_PSHANDLER increment by 1 nocache start with 1 minvalue 1 maxvalue 99999999 cycle;

ACCEPT xml_dir char prompt 'Enter the path of the directory where the topology data is located: ';
--Create the Direcotry Object in database, 
CREATE OR REPLACE DIRECTORY REFERENCE_DIR AS '&xml_dir';

DECLARE


xml_dir  	 			    CONSTANT  VARCHAR2(30)       := 'C:\app\ibm\refdata';
BEGIN
   
   DELETE FROM rc_area;
   
   DELETE FROM rc_topologyelement;
   
   DELETE FROM rc_productdestination;
   
   DELETE FROM rc_outputpoint;
   
   DELETE FROM rc_lateral;
   
   DELETE FROM rc_sortermapping;
   
   COMMIT;
   
 --Contents of this file get inserted into the table
 --RC_AREA on installation
 --This file was generated on 29/08/2007 10:59:27

INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (11, 'Zuid', 'Z', '1');
INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (1, 'West', 'W', '1');
INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (2, 'D-pier', 'D', '1');
INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (3, 'T2', 'C', '1');
INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (4, 'E-pier', 'E', '1');
INSERT INTO RC_AREA(OID, NAME, OSOCIDENTIFICATION, CONTROLLED) VALUES (5, 'BackBone', 'B', '1');

COMMIT;


 
   --Create the Direcotry Object in database, 
 
  --grant to the privilege to public, but we can restrict which role has the privilege
  EXECUTE IMMEDIATE 
 'GRANT READ ON DIRECTORY REFERENCE_DIR TO PUBLIC';
	 
COMMIT;
  

   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'southTopo.xml'
                    );
 				
  sm_referencedata.process_source(11);
  --updated for bb
   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'westTopo.xml'
                    );
  sm_referencedata.process_source(1);
   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'dpierTopo.xml'
                    );
  sm_referencedata.process_source(2);
   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'centralTopo.xml'
                    );
  sm_referencedata.process_source(3);
   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'eastTopo.xml'
                    );
  sm_referencedata.process_source(4);
   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'bbTopo.xml'
                    );
  sm_referencedata.process_source(5);
--added for handlers

   sm_referencedata.read_file
                    (i_srcdir       => 'REFERENCE_DIR',
                     i_srcfile      => 'SystemConfig.xml'
                    );
  
  sm_referencedata.process_handlers();
  sm_referencedata.process_lu_type();

 EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (   'Error while calling procedure.'
                            || CHR (10)
                            || SQLERRM
                           );
 END;
 /
