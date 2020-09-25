--------------------------------------------------------------------------- 
-- 	Script to DROP TABLE IF EXISTSs, constraints and sequences for PNST South
--------------------------------------------------------------------------- 

--prompt "About to drop PS tables"

-- DROP TABLE IF EXISTSs, constraints and sequences
DROP TABLE IF EXISTS PS_RECURRINGEVENT CASCADE;
DROP TABLE IF EXISTS PS_CONTAINERUSEAGERULE CASCADE;
DROP TABLE IF EXISTS PS_OUTBOUNDAREAASSIGNMENTRULE CASCADE;
DROP TABLE IF EXISTS PS_GROUPOFFLIGHTS CASCADE;
DROP TABLE IF EXISTS PS_TPSECTION CASCADE;
DROP TABLE IF EXISTS PS_TPSECTION_PRODUCTDEST CASCADE;
DROP TABLE IF EXISTS PS_LOGICALPRODUCT CASCADE;
DROP TABLE IF EXISTS PS_LOGICALPRODUCTDESTINATION CASCADE;
DROP TABLE IF EXISTS PS_LOGICALPRODUCT_LOGICALPD CASCADE;
DROP TABLE IF EXISTS PS_OPENCLOSETIMERULE CASCADE;
DROP TABLE IF EXISTS PS_TACTICALBAGGAGEPLAN CASCADE;
DROP TABLE IF EXISTS PS_TPDAY CASCADE;
DROP TABLE IF EXISTS PS_TPFLIGHT CASCADE;
DROP TABLE IF EXISTS PS_TPSDG CASCADE;
DROP TABLE IF EXISTS PS_TPALLOC CASCADE;
DROP TABLE IF EXISTS PS_BAGGAGEHANDLERPLAN CASCADE;
DROP TABLE IF EXISTS PS_BHPFLIGHTRULE CASCADE;
DROP TABLE IF EXISTS PS_BHPPRODUCTDESTINATIONMAP CASCADE;
DROP TABLE IF EXISTS PNST_ARRIVALBREAKRULE CASCADE;
DROP TABLE IF EXISTS PS_BATCHRULE CASCADE;
DROP TABLE IF EXISTS PS_TCRULE CASCADE;
DROP TABLE IF EXISTS PS_LONGTERMMAINTENANCE CASCADE;
DROP TABLE IF EXISTS PS_HANDLER CASCADE;
DROP TABLE IF EXISTS PS_TPSDGDEST CASCADE;
-- BATOS (quxr)
DROP TABLE IF EXISTS PS_CAPACITYPARAMETERSRULE CASCADE;
DROP TABLE IF EXISTS PS_INPUTPROFILE CASCADE;
DROP TABLE IF EXISTS PS_INPUTPROFILEPERIOD CASCADE;
-- BATOS end(quxr)
DROP TABLE IF EXISTS PS_LOCKINFO CASCADE;
DROP TABLE IF EXISTS PS_STT CASCADE;
DROP TABLE IF EXISTS PS_STT_INFO CASCADE;
DROP TABLE IF EXISTS PS_STT_REQUEST CASCADE;
DROP TABLE IF EXISTS PS_HRFDEFINITION CASCADE;
DROP TABLE IF EXISTS PS_INBOUNDAREAASSIGNMENTRULE CASCADE;
DROP TABLE IF EXISTS PS_INBOUNDAREAASSIGNMENT CASCADE;
-- new for BackBone
DROP TABLE IF EXISTS PS_OUTBOUNDAREAASSIGNMENTPLAN CASCADE;
DROP TABLE IF EXISTS PS_BUFFERGROUPRULE CASCADE;
DROP TABLE IF EXISTS PS_TLRULE CASCADE;
DROP TABLE IF EXISTS PS_LUTYPE CASCADE;


--prompt "About to drop PS sequences"
DROP SEQUENCE IF EXISTS SEQ_PSRECURRINGEVENT CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSCONTAINERUSEAGERULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSOUTAREAASSIGNMENTRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSBAGGAGEHANDLERPLANRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSGROUPOFFLIGHTS CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPSECTION CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSLOGICALPRODUCT CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSLOGICALPRODUCTDEST CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTACTICALBAGGAGEPLAN CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPDAY CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPFLIGHT CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPSDG CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPALLOC CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSOPENCLOSETIMERULE CASCADE;

DROP SEQUENCE IF EXISTS SEQ_PSBAGGAGEHANDLERPLAN CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSBHPFLIGHTRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSBHPPRODUCTDESTINATIONMAP CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PNSTARRIVALBREAKRULE CASCADE;

DROP SEQUENCE IF EXISTS SEQ_PSTCRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSBATCHRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSLONGTERMMAINTENANCE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSHANDLER CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTPSDGDEST CASCADE;

DROP SEQUENCE IF EXISTS SEQ_PSCAPACITYPARAMETERSRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSINPUTPROFILE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSINPUTPROFILEPERIOD CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSLOCKINFO CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSSTT CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSSTTINFO CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSSTTREQUEST CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSHRFDEFINITION CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSINAREAASSIGNMENTRULE CASCADE;
-- new for BackBone
DROP SEQUENCE IF EXISTS SEQ_OAP CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSBUFFERGROUPRULE CASCADE;
DROP SEQUENCE IF EXISTS SEQ_PSTLRULE CASCADE;