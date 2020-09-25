
------------------------------------------------------------------------------
-- 	Script to build tables, sequences and comments for PNST South
------------------------------------------------------------------------------


--  $Header: /t5/deploy/dbms/smps/rc/RC.sql@@/main/7 2005-05-11 09:08:22 GMT $
--  $Source: /t5/deploy/dbms/smps/rc/RC.sql $
--  $Revision: /main/7 $
--  $Date: 2005-05-11 09:08:22 GMT $
--  $Log: RC.sql $
--   /main/7 2005-05-11 09:08:22 GMT nl49825
--      decouple constraints from table creation
--------------------------------------------------------------------------- 
--	System:  T5 Heathrow 
--	for Vanderlande Industries
--	IBM Global Services, the Netherlands
--
--	Version:  <to be filled in by TeamConnection
-- 	Script to build tables, sequences and constraints for CSCI RC
--------------------------------------------------------------------------- 



--@rc/RCDROP

--prompt "About to create RC tables"

-- Create tables in right order
-- TOPOLOGY

-- Table area to contain the area's defined in the BCT2 systsem. 
CREATE TABLE RC_AREA ( 
  OID                 NUMERIC(20)    NOT NULL, 
  NAME                VARCHAR(25)  NOT NULL, 
  OSOCIDENTIFICATION  VARCHAR(6)   NOT NULL,
  CONTROLLED	      NUMERIC(1)     NOT NULL ) ; 

comment on table RC_AREA is 'Table of T5 Areas';
comment on column RC_AREA.OID is 'Unique identifier of the AREA in the T5 system.';
comment on column RC_AREA.OSOCIDENTIFICATION is 'OSOC Identification of the AREA ';
comment on column RC_AREA.CONTROLLED is 'Boolean to check whether the Area is controlled by the T5 system.';

-- Table to create the mapping between sorters and productdestinations. 
CREATE TABLE RC_SORTERMAPPING ( 
  TOPOLOGYELEMENTOID     NUMERIC(20)    NOT NULL, 
  PRODUCTDESTINATIONOID  NUMERIC(20)    NOT NULL ) ; 

comment on table RC_SORTERMAPPING is 'Table of the mapping between productdestinations and sorters.';
comment on column RC_SORTERMAPPING.TOPOLOGYELEMENTOID is 'TOPOLOGYELEMENT.OID of the sorter';
comment on column RC_SORTERMAPPING.PRODUCTDESTINATIONOID is 'PRODUCTDESTINATION.OID of the productsdestination. ';

-- Table to store laterals and the lateral in the same street.
CREATE TABLE RC_LATERAL ( 
  OID                      NUMERIC(20)    NOT NULL, 
  LATERALSTREETLATERALOID  NUMERIC(20), 
  LANE                     VARCHAR(20),
  LATERALTYPE              NUMERIC(20)           DEFAULT 1                     NOT NULL ) 
  ; 

comment on table RC_LATERAL is 'Table to the Laterals';
comment on column RC_LATERAL.OID is 'Unique identifier of the Lateral';
comment on column RC_LATERAL.LATERALSTREETLATERALOID is 'OID of the neighbouring Lateral';

-- Table to store output points
CREATE TABLE RC_OUTPUTPOINT ( 
  OID             NUMERIC(20)   NOT NULL, 
  MAXNROFSDG      INTEGER       DEFAULT -1 NOT NULL, 
  MAXOUTPUTRATE   INTEGER       DEFAULT NULL,
  SERVICEDSTANDS  VARCHAR(25) ) ;


-- Table to store the product destinations
CREATE TABLE RC_PRODUCTDESTINATION ( 
  OID                       NUMERIC(20)   NOT NULL, 
  SENDSTATECHANGE2AODB      NUMERIC(20)   NOT NULL) ;

comment on table RC_PRODUCTDESTINATION is 'Table of the Productdestinations'; 
comment on column RC_PRODUCTDESTINATION.OID is 'Unique identifier of the productdestination';

-- Table to store the product destinations
CREATE TABLE RC_ROUTINGDESTINATION ( 
  OID     NUMERIC(20)   	 NOT NULL ) ; 

comment on table RC_ROUTINGDESTINATION is 'Table for all routingdestination';
comment on column RC_ROUTINGDESTINATION.OID is 'Unique identifier of the Routingdestination.';

-- Table for each topology element. 
CREATE TABLE RC_TOPOLOGYELEMENT ( 
  OID                 NUMERIC(20)    NOT NULL, 
  AREAOID             NUMERIC(20)    NOT NULL, 
--  PUBLICID            NUMERIC(20)    NOT NULL, 
  OSOCIDENTIFICATION  VARCHAR(64)   NOT NULL, 
  NAME                VARCHAR(64)  NOT NULL, 
  CLASSTYPE           VARCHAR(25)  NOT NULL ) ;

comment on table RC_TOPOLOGYELEMENT is 'Table topologyelement';
comment on column RC_TOPOLOGYELEMENT.OID is 'Unique identifer of the topologyelemenet.';
comment on column RC_TOPOLOGYELEMENT.AREAOID is 'Area in which the topologyelement is situated.'; 
-- comment on column RC_TOPOLOGYELEMENT.PUBLICID is 'Id to be used by external parties.'; 
comment on column RC_TOPOLOGYELEMENT.OSOCIDENTIFICATION is 'OSOC Identification of the Elelemnt in the BCT2 system.';
comment on column RC_TOPOLOGYELEMENT.NAME is 'Name of the topologyelement.';
comment on column RC_TOPOLOGYELEMENT.CLASSTYPE is 'Type column fot TOPLINK to identify the SUB-class of the topologyelement.';


-- Table to store the distances between the topologyelements,
CREATE TABLE RC_TOPOLOGYDISTANCE ( 
  FORROUTINGDESTINATIONOID       NUMERIC(20)   	 NOT NULL, 
  TOROUTINGDESTINATIONOID        NUMERIC(20)  	 NOT NULL, 
  DISTANCE                       NUMERIC(20)  	 NOT NULL ) ; 



-- Table to store the remapping of topology element.


CREATE TABLE RC_LOGICALMAINTENANCESEGMENT (
  OID			NUMERIC(20),
  OBJECTNR			VARCHAR(50),
  TECHNICALNR		VARCHAR(50),
  DESCRIPTION		VARCHAR(1024) ) ;

CREATE TABLE RC_MAINTENANCESEGMTOPELT (
   LOGICALMAINTENANCESEGMENTOID	NUMERIC(20),
   TOPOLOGYELEMENTOID		NUMERIC(20)) ;

-- Table STAND to contain the Stand's name and the delay time to the Reclaim.
CREATE TABLE RC_STAND ( 
  OID                 NUMERIC(20)    NOT NULL, 
  NAME                VARCHAR(4)   NOT NULL,
  TIMEDELAY           INTEGER 
  ) ; 

comment on table RC_STAND is 'Table of T5 stands';
comment on column RC_STAND.OID is 'Unique identifier of the Stands in the T5 system.';
comment on column RC_STAND.NAME is 'The name of the stand, four chars. ';
comment on column RC_STAND.TIMEDELAY is 'The time needed from the stand to the reclaim belt.';

-- Table RC_FLIGHT_RANGE_MAPPING to contain the mapping between flightnumber and range
create table RC_FLIGHT_RANGE_MAPPING (
   FLIGHTNUMBER			VARCHAR(8)    NOT NULL,
   RANGE			VARCHAR(1)    NOT NULL  
) ;

comment on table RC_FLIGHT_RANGE_MAPPING is 'A table hosts the mapping of flight range';
comment on column RC_FLIGHT_RANGE_MAPPING.FLIGHTNUMBER is 'Flight number with prefix+suffix, like <BA 1234 >';
comment on column RC_FLIGHT_RANGE_MAPPING.RANGE is 'Range value in the system with values <L,S,D,X>';

-- Create new table RC_RESOURCESETTINGS.
CREATE TABLE RC_RESOURCESETTINGS
(
  OID                 NUMERIC(20)                NOT NULL,
  RESOURCESERVICE     VARCHAR(100 ),
  TOPOLOGYELEMENTOID  NUMERIC(20)                NOT NULL
)
;
comment on column rc_resourcesettings.oid is 'the oid of the table';
comment on column rc_resourcesettings.resourceservice is 'the type of the resource service';
comment on column rc_resourcesettings.topologyelementoid is 'the forign key of the table';



--Add constraints
--@rc/RCCONSTRAINTS
--prompt "About to create RC constraints"

-- Add primary key constraints
alter table RC_AREA  
  ADD constraint RC_AREA_PK primary key  ( OID ) ; 

alter table RC_SORTERMAPPING 
  ADD constraint RC_SORTERMAPPING_PK primary key ( TOPOLOGYELEMENTOID, PRODUCTDESTINATIONOID ) ; 

alter table RC_LATERAL  
  ADD constraint RC_LATERAL_PK primary key ( OID ) ; 

alter table RC_OUTPUTPOINT  
  ADD constraint RC_OUTPUTPOINT_PK primary key ( OID );

alter table RC_PRODUCTDESTINATION  
  ADD constraint RC_PRODUCTDESTINATION_PK primary key ( OID ) ;

alter table RC_ROUTINGDESTINATION  
  ADD constraint RC_ROUTINGDESTINATION_PK primary key ( OID ) ; 
 
alter table RC_TOPOLOGYELEMENT  
  ADD constraint RC_TOPOLOGYELEMENT_PK primary key ( OID ) ;

alter table RC_TOPOLOGYDISTANCE  
  ADD constraint RC_TOPOLOGYDISTANCE_PK primary key ( FORROUTINGDESTINATIONOID, TOROUTINGDESTINATIONOID) ; 


alter table RC_LOGICALMAINTENANCESEGMENT 
   ADD constraint RC_LOGICALMAINTSEGM_PK primary key (OID) ;

alter table RC_MAINTENANCESEGMTOPELT 
     ADD constraint  RC_MAINTENANCESEGMTOPELT_PK primary key (LOGICALMAINTENANCESEGMENTOID,TOPOLOGYELEMENTOID) ;

alter table RC_STAND 
  ADD constraint RC_STAND_PK primary key  ( OID ) ; 
  
alter table RC_FLIGHT_RANGE_MAPPING
  ADD constraint RC_FLIGHT_RANGE_MAPPING_PK primary key (FLIGHTNUMBER) ;

ALTER TABLE RC_RESOURCESETTINGS 
  ADD constraint PK_OS_RESOURCESETTINGS primary key (OID);


-- Add foreign key constraints to table LATERAL
ALTER TABLE RC_LATERAL ADD  CONSTRAINT RC_LATERAL_FK1
 FOREIGN KEY (LATERALSTREETLATERALOID) 
 REFERENCES RC_LATERAL (OID) 
 ON DELETE CASCADE;

ALTER TABLE RC_LATERAL ADD  CONSTRAINT RC_LATERAL_FK2
 FOREIGN KEY (OID) 
 REFERENCES RC_PRODUCTDESTINATION (OID) 
 ON DELETE CASCADE;

-- Add foreign key constraints to table SORTERMAPPING
ALTER TABLE RC_SORTERMAPPING ADD  CONSTRAINT RC_SORTERMAPPING_FK1
 FOREIGN KEY (PRODUCTDESTINATIONOID) 
 REFERENCES RC_PRODUCTDESTINATION (OID) 
 ON DELETE CASCADE;

ALTER TABLE RC_SORTERMAPPING ADD  CONSTRAINT RC_SORTERMAPPING_FK2
 FOREIGN KEY (TOPOLOGYELEMENTOID) 
 REFERENCES RC_TOPOLOGYELEMENT (OID) 
 ON DELETE CASCADE;

-- Add foreign key constraints to table TOPOLOGYELEMENT
ALTER TABLE RC_TOPOLOGYELEMENT ADD  CONSTRAINT RC_TOPOLOGYELEMENT_FK1
 FOREIGN KEY (AREAOID) 
 REFERENCES RC_AREA (OID) 
 ON DELETE CASCADE;

ALTER TABLE RC_MAINTENANCESEGMTOPELT ADD CONSTRAINT RC_MAINTSEGMTOPELT_FK1 
 FOREIGN KEY(LOGICALMAINTENANCESEGMENTOID)
 REFERENCES RC_LOGICALMAINTENANCESEGMENT (OID)
 on delete cascade;

ALTER TABLE RC_MAINTENANCESEGMTOPELT ADD CONSTRAINT RC_MAINTSEGMTOPELT_FK2
 FOREIGN KEY(TOPOLOGYELEMENTOID)
 REFERENCES RC_TOPOLOGYELEMENT (OID)
 on delete cascade; 

-- Add foreign key constraints to table RC_RESOURCESETTINGS.
ALTER TABLE RC_RESOURCESETTINGS ADD 
  CONSTRAINT FK_OS_RESOURCESETTINGS FOREIGN KEY (TOPOLOGYELEMENTOID) 
    REFERENCES RC_TOPOLOGYELEMENT (OID);

--prompt "About to create RC sequences"

--Add sequences
CREATE SEQUENCE SEQ_LOGICALMAINTENANCESEGMENT increment by 1 cache 1 start with 51 minvalue 1 maxvalue 99999999 cycle;
CREATE SEQUENCE SEQ_STAND increment by 1 cache 1 start with 51 minvalue 1 maxvalue 99999999 cycle;
CREATE SEQUENCE SEQ_RCRESOURCESETTINGS increment by 1 cache 1 start with 51 minvalue 1 maxvalue 99999999 cycle;



