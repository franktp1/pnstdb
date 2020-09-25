--  $Header: $
--  $Source: $
--  $Revision: $
--  $Date: $
--  $Log: $

--------------------------------------------------------------------------- 
-- 	Script to Loading XML Reference data for CSCI_SM
--------------------------------------------------------------------------- 
	
--CREATE TABLES
\i C:/south/dbms/serv/rc/RCDROP.sql
\i C:/south/dbms/serv/ps/PSDROP.sql
\i C:/south/dbms/serv/rc/RC.sql
\i C:/south/dbms/serv/ps/PS.sql
\i C:/south/dbms/quartz/quarzl.sql

--DROP TABLES AND SEQUENCES AND ADD THEM
\i C:/south/dbms/fillall/rc/drop_tables.sql
-- Create tables
\i C:/south/dbms/fillall/rc/SM_Reference_data_tables.sql
-- Create trigger
\i C:/south/dbms/fillall/rc/SM_RC_TOPOLOGYELEMENT.sequence

--FILL DATA FOR THE TABLES(replace function of pkg and body)
\i C:/south/dbms/fillall/rc/fill_rc_ref_data_log.sql
\i C:/south/dbms/fillall/rc/fill_rc_ref_data.sql
\i C:/south/dbms/fillall/rc/fill_rc_area.sql
\i C:/south/dbms/fillall/rc/fill_rc_topologyment.sql
\i C:/south/dbms/fillall/rc/fill_rc_productdestination.sql
\i C:/south/dbms/fillall/rc/fill_rc_outputpoint.sql
\i C:/south/dbms/fillall/rc/fill_rc_lateral.sql
\i C:/south/dbms/fillall/rc/fill_ps_lutype.sql
\i C:/south/dbms/fillall/rc/fill_ps_handler.sql
--
\i C:/south/dbms/fillall/rc/DistanceGenerator.sql
\i C:/south/dbms/fillall/ps/PSFILL.sql
\i C:/south/dbms/fillall/ps/DEFAULTHANDLERPLANSETTING.sql




-- Create package
--\i C:/south/dbms/fillall/rc/SM_Referencedata.pks

-- Create package body
--\i C:/south/dbms/fillall/rc/SM_Referencedata.pkb

--run the script
--\i C:/south/dbms/fillall/rc/SM_Referencedata.sql--

--commit;
-- Commit everthing
--prompt "Finish loading XML Reference data into SM, Please Verify your data in the database"


