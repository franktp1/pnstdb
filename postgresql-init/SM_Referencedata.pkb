CREATE OR REPLACE PACKAGE BODY sm_referencedata
IS
   -- the number of logging lines in the temporary RC_REF_DATA_LOG table
   g_log_line                       NUMBER (10)             := 1;
   --The XML Reference Data
   g_dom_doc                        DBMS_XMLDOM.domdocument;
   --The SM topology enrichement data
   g_dom_topo_en_doc                DBMS_XMLDOM.domdocument;
   -- The maximum number of characters on a single line
   g_con_maxlinelen        CONSTANT NUMBER                  := 4000;
   --The reference Data XML file nodes
   g_document_node                  DBMS_XMLDOM.domnode;
   --The SM topology enrichement data XML nodes
   g_document_topo_en_node          DBMS_XMLDOM.domnode;
   --allowed types of the type
   --based on the version 11 DTD, the station_type attribute was renamed to type
   /*****************************************************************
      Appendix A - Allowed ClassTypes

   Lateral, ManualEncoding, TransferIn
   TimeCritical, SpecialHandling, Optop_In, ReclaimOut, Carousel
   Screening, ESLateral
   *********************************************************************/
   c_allowed_station_el_xpath       VARCHAR2 (500)
      := '//station[@type="ReclaimOut"
	  or @type="HeadOfStand"
	  or @type="Lateral"
	  or @type="ManualEncoding"
	  or @type="TransferIn"
	  or @type="SpecialHandling"
	  or @type="Optop_In"
	  or @type="TimeCritical"
	  or @type="Store"
	  or @type="Relabel"
	  or @type="Carousel"
	  or @type="Screening"
	  or @type="ESLateral" ]';
   --not allowed class types
   c_not_allowed_station_el_xpath   VARCHAR2 (500)
      := '//station[@type="L4_Out"
	  or @type="OOG_Out"
	  or @type="HBS_1_2"
    or @type="HBS_3"
	  or @type="VolumeScan"
	  or @type="AutoScan"
    or @type="CheckIn"
	  or @type="SC_Out"]';
   --station to retrive the bidirectional_destination_reversed_id
   c_station_el_xpath               VARCHAR2 (20)           := '//station';
   --SM topology Enrichment node Topology and attritbute Area
   c_topology_el_xpath              VARCHAR2 (20)           := '//Topology';
   c_area_at_xpath                  VARCHAR2 (10)           := '@Area';
   --the ID attribute of the station element
   c_id_at_xpath                    VARCHAR2 (20)    := '@logical_station_id';
   --the end_user_id attribute of the station element
   --based on the version 11 DTD, the user_id attribute was renamed to
   --end_user_id
   c_station_user_id_at_xpath       VARCHAR2 (20)           := '@end_user_id';
   --the station_type attribute of the station element
   --based on the version 11 DTD, the station_type attribute was renamed to type
   c_station_type_at_xpath          VARCHAR2 (20)           := '@type';
   --the maximum_release_rate attribute of the station element
   c_station_rate_at_xpath          VARCHAR2 (40)  := '@maximum_release_rate';
   --the ind_lateral_stillage attribute of the statation element.
   c_station_ils_at_xpath           VARCHAR2 (30)  := '@ind_lateral_stillage';
   --the serviced_stand_id1 attribute of the statation element.
   c_station_ss_id1                 VARCHAR2 (30)    := '@serviced_stand_id1';
   --the serviced_stand_id2 attribute of the statation element.
   c_station_ss_id2                 VARCHAR2 (30)    := '@serviced_stand_id2';
   --the maximum_number_SDG attribute of the statation element.
   c_station_maxnrofsdg_at_xpath    VARCHAR2 (30)    := '@maximum_number_SDG';
   --the bidirectional_destination_reversed_id attribute of the statation element.
   c_station_bdri_at_xpath          VARCHAR2 (50)
                                  := '@bidirectional_destination_reversed_id';
   --the classtype's values
   c_sorter_string                  VARCHAR2 (10)           := 'sorter';
   c_lateral_string                 VARCHAR2 (10)           := 'lateral';
   c_capital_lateral_string         VARCHAR2 (10)           := 'Lateral';
   c_carousel_string        VARCHAR2 (10)           := 'carousel';
   c_capital_carousel_string        VARCHAR2 (10)           := 'Carousel';
   c_headofstand_string             VARCHAR2 (20)           := 'headofstand';
   c_timecriticalout_string         VARCHAR2 (20)           := 'timecritical';
   c_specialhandling_string         VARCHAR2 (20)        := 'specialhandling';
   c_optop_in_string                VARCHAR2 (20)           := 'optop_in';
   c_itviout_string                 VARCHAR2 (10)           := 'itviout';
   c_screening_string       VARCHAR2 (30)      := 'screening';
   c_eslateral_string       VARCHAR2 (30)      := 'eSLateral';
   /*********************************************************
    * another way to realize the searching for the allowed type
   ********************************************************
   TYPE allowedclasstypes IS VARRAY (10) OF VARCHAR2 (20);

   classtypes                   allowedclasstypes
      := allowedclasstypes (
                            'ReclaimOut',
                            'Lateral',
                            'ManualEncoding',
                            'TransferIn',
                            'SpecialHandling',
                            'Optop_In',
                            'TimeCriticalOut',
             'Relabel','Carousel','Screening','ESLateral'
                           );
   ****************************************************************/

   --The following constants can be used for parsing static data - LUTypes.
   c_lutype_xpath          CONSTANT NVARCHAR2 (42)
                              := 'project_definition//LoadUnitList//LoadUnit';
   c_lu_type_xpath         CONSTANT NVARCHAR2 (6)           := 'LUType';
   c_min_bags_xpath        CONSTANT NVARCHAR2 (7)           := 'MinBags';
   --The following constants can be used for parsing static data - Handlers.
   c_handler_xpath         CONSTANT NVARCHAR2 (42)
                                := 'project_definition//HandlerList//Handler';
   c_handler_id_xpath      CONSTANT NVARCHAR2 (10)           := 'HandlerID';

   /*****************************************************************
   This function logs the warnings, exceptions and information.
   It is read into temporary table 'RC_REF_DATA_LOG'.
   *****************************************************************/
   PROCEDURE log_msg (i_msg VARCHAR2)
   IS
   BEGIN
      INSERT INTO rc_ref_data_log
           VALUES (g_log_line, i_msg);

      g_log_line := g_log_line + 1;
      COMMIT;
   END log_msg;

   /*****************************************************************
   This function reads in the file representing the reference data.
   It is read into temporary table 'RC_REF_DATA'.
   *****************************************************************/
   PROCEDURE read_file (i_srcdir IN VARCHAR2, i_srcfile IN VARCHAR2)
   IS
      input     CLOB;
      v_file    UTL_FILE.file_type;
      v_line    VARCHAR2 (8000)    := 'initial';
      l_count   NUMBER (20)        := 1;
   BEGIN
      log_msg ('Start of load for referencedata.');

      DELETE FROM rc_ref_data;

      DBMS_LOB.createtemporary (input, TRUE);
      v_file := UTL_FILE.fopen (i_srcdir, i_srcfile, 'r', g_con_maxlinelen);

      -- read in the file line by line
      WHILE (v_line IS NOT NULL)
      LOOP
         BEGIN
            UTL_FILE.get_line (v_file, v_line, g_con_maxlinelen);
            DBMS_LOB.writeappend (lob_loc      => input,
                                  amount       => LENGTH (v_line),
                                  buffer       => v_line
                                 );
            l_count := l_count + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;
      END LOOP;

      UTL_FILE.fclose (v_file);

      -- read in the entire xml structure.
      INSERT INTO rc_ref_data
           VALUES (0, input);

      DBMS_LOB.freetemporary (input);
      UTL_FILE.fclose_all;
      COMMIT;
      log_msg ('End of load for referencedata, ' || l_count || ' lines.');
   END read_file;

   /*****************************************************************
   This function gets the message from the table, and puts it in a
   variable.
   *****************************************************************/
   PROCEDURE prepare_message
   IS
      --SM reference data CLOB
      l_sm_clob_message   CLOB;
      --XMLParser to parse the CLOB, if we put the DTD declaration
      --in the beginning of the XML file, oracle SYS.XMLTYPE(CLOB)can't transform
      --the XML document well.
      v_parser            DBMS_XMLPARSER.parser;
   BEGIN
      -- The clob of the xml messages is present in temporary table rc_ref_data with id 0.
      SELECT xml_input
        INTO l_sm_clob_message
        FROM rc_ref_data rda
       WHERE ID = 0;

      --new parser
      v_parser := DBMS_XMLPARSER.newparser;
      --set the validation mode to false,don't validate the XML file.
      DBMS_XMLPARSER.setvalidationmode (v_parser, FALSE);
      --parse xml clob
      DBMS_XMLPARSER.parseclob (v_parser, l_sm_clob_message);
      --create document
      g_dom_doc := DBMS_XMLPARSER.getdocument (v_parser);
      g_document_node := DBMS_XMLDOM.makenode (g_dom_doc);
      log_msg ('The reference XML nodes is ready...');
      --This Delete command for debug purpose
      --DELETE FROM rc_ref_data_log;
      g_log_line := 1;
   END prepare_message;

   /*****************************************************************
   This function extracts the physical destinations from the reference data
   and creates the SM tables in the datamodel.
   *****************************************************************/
   PROCEDURE create_tables(areaOID_p in number)
   IS
      l_nodelist              DBMS_XMLDOM.domnodelist;
      l_node                  DBMS_XMLDOM.domnode;
      l_nr_nodes              NUMBER (20);
      l_sm_nodelist           DBMS_XMLDOM.domnodelist;
      l_sm_node               DBMS_XMLDOM.domnode;
      l_nr_node_nodes         NUMBER (20);
      l_station_type          VARCHAR2 (30);
      --classtype TimeCriticalOut must not occur
      --in rc_topologyelement.classtype
      l_station_type_no_tco   VARCHAR2 (30);
      l_lower_station_type    VARCHAR2 (30);
      l_station_id            VARCHAR2 (20);
      --the RC_TOPOLOGYELEMENT.OID field
      l_station_oid           VARCHAR2 (20);
      --the RC_TOPOLOGYELEMENT.OID position of the
      --statation.bidirectional_destination_reversed_id
      l_station_position      VARCHAR2 (20);
      l_station_user_id       VARCHAR2 (30);
      l_station_rate          VARCHAR2 (30);
      --RC_OUTPUTPOINT's SERVICEDSTANDS field
      l_station_ss            VARCHAR2 (30);
      --statation.serviced_stand_id1
      l_station_ss_id1        VARCHAR2 (30);
      --statation.serviced_stand_id2
      l_station_ss_id2        VARCHAR2 (30);
      --RC_LATERAL's LATERALTYPE field,statation.ind_lateral_stillage
      l_station_ils           VARCHAR2 (30);
      --RC_OUTPUTPOINT's MAXNROFSDG field,station.maximum_number_SDG
      l_maxnrofsdg            VARCHAR2 (30);
      --RC_LATERAL's LATERALSTREETLATERALOID field,
      --statation.bidirectional_destination_reversed_id
      l_station_bdri          VARCHAR2 (10);
      --temp value to contain the l_station_bdri
      l_station_bdri_temp     VARCHAR2 (10);
      l_destination_type      VARCHAR2 (5);
      --Constant character 1,2,3,4
      c_1_char       CONSTANT CHAR (1)                := '1';
      c_2_char       CONSTANT CHAR (1)                := '2';
      c_3_char       CONSTANT CHAR (1)                := '3';
      c_4_char       CONSTANT CHAR (1)                := '4';
      count_topologyelement   NUMBER (20);
      l_station_type_new        VARCHAR2 (20);
   BEGIN
      log_msg ('enter the create tables procedure');
      --select all the nodes elements
      l_nodelist :=
         DBMS_XSLPROCESSOR.selectnodes (g_document_node,
                                        c_allowed_station_el_xpath
                                       );
      --log_msg ('pass the long parse');
      l_nr_nodes := DBMS_XMLDOM.getlength (l_nodelist);
      log_msg ('Total of allowed station nodes in input  .. = ' || l_nr_nodes);

      FOR i IN 0 .. (l_nr_nodes - 1)
      LOOP
         l_node := DBMS_XMLDOM.item (l_nodelist, i);
         --the atrribute id of element satation
         DBMS_XSLPROCESSOR.valueof (l_node, c_id_at_xpath, l_station_id);

         --log_msg ('the station ID is' || '  ' || l_station_id);
         IF l_station_id IS NULL
         THEN
            DBMS_XSLPROCESSOR.valueof (l_node, '@id', l_station_id);
         END IF;

         SELECT COUNT (*)
           INTO count_topologyelement
           FROM rc_topologyelement
          WHERE rc_topologyelement.areaoid=areaOID_p and rc_topologyelement.osocidentification = l_station_id ;

         -- start if for count_topologyelement
         IF count_topologyelement = 0
         THEN
            --the atrribute station_type of element station
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_type_at_xpath,
                                       l_station_type
                                      );
            --Transform it to lowver case and compare it later
            l_lower_station_type := LOWER (l_station_type);

            --classtype TimeCriticalOut must not occur
            --in rc_topologyelement.classtype, replace it using lateral
            IF c_timecriticalout_string = l_lower_station_type
            THEN
               l_station_type := c_capital_carousel_string;
            END IF;

            IF c_specialhandling_string = l_lower_station_type
            THEN
               l_station_type := c_capital_carousel_string;
            END IF;

            --the atrribute end_user_id of element station
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       --'@end_user_id',
                                       c_station_user_id_at_xpath,
                                       l_station_user_id
                                      );
            --the atrribute maximum_release_rate of element station
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_rate_at_xpath,
                                       l_station_rate
                                      );
            --the atrribute statation.serviced_stand_id1 of element station
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_ss_id1,
                                       l_station_ss_id1
                                      );
            --the atrribute statation.serviced_stand_id2 of element station
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_ss_id2,
                                       l_station_ss_id2
                                      );

            --if both are empty the value will be ampty,
            --if  only one is filled take that one ,
            --if  both are filled, take both (seperated by a comma)
            IF l_station_ss_id1 IS NULL AND l_station_ss_id2 IS NULL
            THEN
               l_station_ss := l_station_ss_id1 || l_station_ss_id2;
            ELSIF l_station_ss_id1 IS NULL AND l_station_ss_id2 IS NOT NULL
            THEN
               l_station_ss := l_station_ss_id2;
            ELSIF l_station_ss_id1 IS NOT NULL AND l_station_ss_id2 IS NULL
            THEN
               l_station_ss := l_station_ss_id1;
            ELSE
               l_station_ss := l_station_ss_id1 || ',' || l_station_ss_id2;
            END IF;

            --the atrribute ind_lateral_stillage of element station
            /******************************************************
             *Due This version IFAT_HLC_Build1_Phase2_Reference_Data.xml
             *still doesn't have this attribute. this vlaue will return
             *null.
            ********************************************************/
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_ils_at_xpath,
                                       l_station_ils
                                      );
            --RC_OUTPUTPOINT's MAXNROFSDG field,station.maximum_number_SDG
            DBMS_XSLPROCESSOR.valueof (l_node,
                                       c_station_maxnrofsdg_at_xpath,
                                       l_maxnrofsdg
                                      );

            /*********************************************************************
            --Inset into the table with the following vlaues:
            **AREAOID**Using the station.id  check in file  TopoSMEnrichment
            -- IF found, areaOID to be used. not found in this file,
            -- use areaoid 4 (noncontrolled)  and generate an errormessage
            **OSOCIDENTIFICATION** station.id
            **NAME** station.end_user_id
            **OSOCIDENTIFICATION** station.type

            For the **OID**, will be automatically generated by sequence seq_topologyelementoid
            ************************************************************************/
            --it's required that the user_id is not null in database,
            -- you default the name to the concatenation of the classtype
            -- with the osocidentication (Eg. you would get then names like
            --  "ManualEncoding-178" instead of "")

			IF SUBSTR(l_station_id,0,3) = 'EDS' THEN 
			  l_station_type_new := 'Screening';	
			ELSE
				l_station_type_new := l_station_type;	
			END IF;
			
						if l_station_type_new <> 'HBS_3' then
			
            IF l_station_user_id IS NULL
            THEN
               INSERT INTO rc_topologyelement
                           (OID, areaoid,
                            osocidentification, NAME, classtype
                           )
                    VALUES (seq_topologyelementoid.NEXTVAL, areaOID_p,
                            l_station_id, l_station_id, l_station_type_new
                           );
            ELSE
               INSERT INTO rc_topologyelement
                           (OID, areaoid,
                            osocidentification, NAME, classtype
                           )
                    VALUES (seq_topologyelementoid.NEXTVAL, areaOID_p,
                            l_station_id, l_station_id, l_station_type_new
                           );
            END IF;

            /***************************************************
              if station.type not is "sorter"
              create rc_productdestination (using the mapping document)
            ****************************************************/

            --oid is the same value as rc_topologyelement if exists
            --(seq_topologyelementoid.CURRVAL)
            --For the field sendstatechange2aodb,
            --there is no information in the SMEnrichment.txt,
            --assign all to values to default 0.
            IF c_sorter_string != l_lower_station_type
            THEN
               INSERT INTO rc_productdestination
                           (OID, sendstatechange2aodb
                           )
                    VALUES (seq_topologyelementoid.CURRVAL, 0
                           );
            END IF;

            /*********************************************************
              if  classtype is Lateral, HeadOfStand, ItviOut
              create rc_outputpoint  (using the mapping document)
              if the classtype is timecriticalout, we also create a row in the RC_OUTPUTPOINT table and
               set the  RC_OUTPUTPOINT.MAXNROFSDG to -1?  (OK)
            **************************************************************/
            --oid is the same value as rc_topologyelement if exists(seq_topologyelementoid.CURRVAL)

            --For rc_outputpoint.maxnrofsdg use  station.maximum_number_of_sdg. Default : 3 for Lateral, -1 for HeadofStand and TimeCriticalOut-- for maxoutputrate l_station_rate
            --  for servicedstands l_station_ss
            IF l_maxnrofsdg IS NULL
            THEN
               IF    c_headofstand_string = l_lower_station_type
                  OR c_timecriticalout_string = l_lower_station_type
               THEN
                  l_maxnrofsdg := -1;
               ELSE
                  l_maxnrofsdg := 3;
               END IF;
            END IF;

            IF    c_lateral_string = l_lower_station_type
               OR c_headofstand_string = l_lower_station_type
               OR c_itviout_string = l_lower_station_type
               OR c_timecriticalout_string = l_lower_station_type
               OR c_specialhandling_string = l_lower_station_type
               OR c_optop_in_string = l_lower_station_type
               OR c_carousel_string = l_lower_station_type
            THEN
               INSERT INTO rc_outputpoint
                           (OID, maxnrofsdg,
                            maxoutputrate, servicedstands
                           )
                    VALUES (seq_topologyelementoid.CURRVAL, l_maxnrofsdg,
                            l_station_rate, l_station_ss
                           );
            END IF;

            -- For  GT1,GT2,GT,3,GT4  set the Lane to GT-Lane-A
            --and for GT5.GT6,GT7,GT8 set the lane to GT-Lane-B
            --apply this same logic to all laterals...
            --so GR4 -> GR-Lane-A  ,  RC7 -> RC-Lane-B   etc. etc.
            --lane names will only be filled for laterals
            --NOT being headofstand (type 2)
            IF    SUBSTR (l_station_user_id, -1) = c_1_char
               OR SUBSTR (l_station_user_id, -1) = c_2_char
               OR SUBSTR (l_station_user_id, -1) = c_3_char
               OR SUBSTR (l_station_user_id, -1) = c_4_char
            THEN
               IF LENGTH (l_station_user_id) < 5
               THEN
                  --log_msg (LENGTH (l_station_user_id)=4);
                  l_station_user_id :=
                                 SUBSTR (l_station_user_id, 1, 2)
                                 || '-Lane-A';
               END IF;
            ELSE
               IF LENGTH (l_station_user_id) < 5
               THEN
                  l_station_user_id :=
                                 SUBSTR (l_station_user_id, 1, 2)
                                 || '-Lane-B';
               END IF;
            END IF;

             /*********************************************************
             if classtype is headofstand or lateral or timecriticalout
             create rc_lateral (using the mapping document)
             oid is the same value as rc_topologyelement
             if exists(seq_topologyelementoid.CURRVAL).
             RC_Lateral.lateraltype should be determined from the field :
             station .ind_lateral_stillage in combination with the classtype.
             (If classtype is headofstand : 2 else if value is true : 3
             else if   value is false : 4 else : 1)
            **********************************************************/
            IF c_headofstand_string = l_lower_station_type
            THEN
               l_station_ils := 2;
            ELSIF l_station_ils = 'TRUE'
            THEN
               l_station_ils := 3;
            ELSIF l_station_ils = 'FALSE'
            THEN
               l_station_ils := 4;
            ELSE
               l_station_ils := 1;
            END IF;

            IF c_lateral_string = l_lower_station_type
            THEN
               INSERT INTO rc_lateral
                           (OID, lateralstreetlateraloid,
                            lane, lateraltype
                           )
                    VALUES (seq_topologyelementoid.CURRVAL, '',
                            l_station_user_id, l_station_ils
                           );
            END IF;

            --leave the name filed completely empty
            --If classtypes are headofstand or timecriticalout
            IF    c_headofstand_string = l_lower_station_type
               OR c_timecriticalout_string = l_lower_station_type
               OR c_specialhandling_string = l_lower_station_type
            THEN
               INSERT INTO rc_lateral
                           (OID, lateralstreetlateraloid, lane,
                            lateraltype
                           )
                    VALUES (seq_topologyelementoid.CURRVAL, '', '',
                            l_station_ils
                           );
            END IF;
         --end if for count_topologyelement
         END IF;
         end if;
      END LOOP;

      COMMIT;

      --record how many stations are imported into the database
      SELECT COUNT (*)
        INTO l_nr_nodes
        FROM rc_topologyelement;

      log_msg (   'Total Stations imported in database(rc_topologyelement) : '
               || l_nr_nodes
               || ' .'
              );
      /*****************************************************************
      for each station whose station.type not in allowed classtypes
      Generate an error message
      *****************************************************************/
      l_nodelist :=
         DBMS_XSLPROCESSOR.selectnodes (g_document_node,
                                        c_not_allowed_station_el_xpath
                                       );
      --log_msg ('pass the long parse');
      l_nr_nodes := DBMS_XMLDOM.getlength (l_nodelist);
      log_msg (   'Total of not allowed station nodes in input  .. = '
               || l_nr_nodes
              );

      FOR i IN 0 .. (l_nr_nodes - 1)
      LOOP
         l_node := DBMS_XMLDOM.item (l_nodelist, i);
         --the atrribute id of element satation
         DBMS_XSLPROCESSOR.valueof (l_node,
                                    c_station_type_at_xpath,
                                    l_station_type
                                   );
         log_msg (   'the station type: '
                  || l_station_type
                  || '  is skipped for loading into SM'
                 );
      END LOOP;

      COMMIT;
      /*****************************************************************
       List all stations again to retrive the
       bidirectional_destination_reversed_id
       and then insert the field RC_LATERAL.LATERALSTREETLATERALOID
       Use station.bidirectional_destination_reversed_id to fill RC_LATERAL.
       lateralstreetlateraloid  You will probably have to do that in a second 'pass',
       because of referential integrity you will not be able to insert this value
       when it does not yet exist as a lateral.You will have to take the value of
       station.bidirectional_destination_reversed_id, find the related rc_lateral
      (on osicidentification) and use the OID of that found lateral for the lateralstreetlateraloid.
       If the value does not exist as a lateral , log an error.
       *****************************************************************/
      --retrive the all allowed station nodes
      l_nodelist :=
         DBMS_XSLPROCESSOR.selectnodes (g_document_node,
                                        c_allowed_station_el_xpath
                                       );
      l_nr_nodes := DBMS_XMLDOM.getlength (l_nodelist);

      /********************************************************************
      log_msg (   '(l_station_bdri_temp) station nodes in input  .. = '
               || l_nr_nodes
              );
        *******************************************************************/
      FOR i IN 0 .. (l_nr_nodes - 1)
      LOOP
         l_node := DBMS_XMLDOM.item (l_nodelist, i);
         --the atrribute bidirectional_destination_reversed_id of element satation
         DBMS_XSLPROCESSOR.valueof (l_node,
                                    c_station_bdri_at_xpath,
                                    l_station_bdri_temp
                                   );
         --the atrribute id of element satation
         --the station.id and sation.bidirectional_destination_reversed_id
         --is the same station node(element)
         DBMS_XSLPROCESSOR.valueof (l_node, c_id_at_xpath, l_station_id);

         /**********************************************************
          *Check the NOT NULL vlaue of the l_station_bdri_temp
          **********************************************************

         IF l_station_bdri_temp IS NOT NULL

         THEN
         log_msg (   'The value of the l_station_bdri_temp(NOT NULL) .. =   '
               || l_station_bdri_temp
              );
          END IF;
          **/

         --Check if the atrribute bidirectional_destination_reversed_id  is null
         --or not.
         IF l_station_bdri_temp IS NOT NULL
         THEN
            --Select bidirectional_destination_reversed_id's corresponding OID
            SELECT rc_topologyelement.OID
              INTO l_station_oid
              FROM rc_topologyelement
             WHERE rc_topologyelement.osocidentification = l_station_bdri_temp;

            --Check rc_topologyelement.OID of the l_station_bdri_temp
            --using the same node's station.id
            SELECT rc_topologyelement.OID
              INTO l_station_position
              FROM rc_topologyelement
             WHERE rc_topologyelement.osocidentification = l_station_id;

            --Check if the RC_TOPOLOGYELEMENT.OID is a lateral type
            SELECT rc_lateral.OID
              INTO l_station_bdri
              FROM rc_lateral
             WHERE rc_lateral.OID = l_station_oid;

            --If l_station_bdri is not null, then l_station_bdri  is
            --a lateral and update the rc_lateral.LATERALSTREETLATERALOID value
            --if not, log the an error into the database.
            IF l_station_bdri IS NOT NULL
            THEN
               UPDATE rc_lateral
                  SET lateralstreetlateraloid = l_station_oid
                WHERE rc_lateral.OID = l_station_position;
            --This will leads to the couple numbers of rc_lateral.
            --WHERE rc_lateral.OID = l_station_id;
            ELSE
               log_msg (l_station_bdri_temp || 'is Not a lateral');
            END IF;
         END IF;
      END LOOP;

      COMMIT;
      log_msg ('End the creating tables procedure');
   END create_tables;

   /*****************************************************************
   This function extracts the sortermapping from the related tables
   and creates the records in the sortermapping table.
   *****************************************************************/
   PROCEDURE create_sortermapping_table
   IS
      -- rows numbers in the RC_PRODUCTDESTINATION table
      l_nr_rows           NUMBER (20);
      --OID value where NAME = 'Inner Sorter' in the RC_TOPOLOGYELEMENT table
      l_inner_oid         VARCHAR2 (20);
      --OID value where NAME = 'Outer Sorter'in the RC_TOPOLOGYELEMENT table
      l_outer_oid         VARCHAR2 (20);
      --OID value in the RC_PRODUCTDESTINATION table
      l_pro_dest_oid      rc_productdestination.OID%TYPE;

      -- declare the cursor of table rc_productdestination.OID
      CURSOR pro_dest_oid_cursor
      IS
         SELECT OID
           FROM rc_productdestination;

      --the Name Value in the RC_TOPOLOGYELEMENT table
      l_name              VARCHAR2 (100);
      --the type Value in the RC_TOPOLOGYELEMENT table
      l_type              VARCHAR2 (100);
      --Constant character 1,2,3,4,,5,6,7,8
      c_1_char   CONSTANT CHAR (1)                         := '1';
      c_2_char   CONSTANT CHAR (1)                         := '2';
      c_3_char   CONSTANT CHAR (1)                         := '3';
      c_4_char   CONSTANT CHAR (1)                         := '4';
      c_5_char   CONSTANT CHAR (1)                         := '5';
      c_6_char   CONSTANT CHAR (1)                         := '6';
      c_7_char   CONSTANT CHAR (1)                         := '7';
      c_8_char   CONSTANT CHAR (1)                         := '8';
   BEGIN
      log_msg ('Enter the create sortermapping table procedure');

      --select OID value where NAME = 'Inner Sorter'
      SELECT OID
        INTO l_inner_oid
        FROM rc_topologyelement
       WHERE rc_topologyelement.NAME = 'Inner Sorter';

      --select OID value where NAME = 'Outer Sorter'
      SELECT OID
        INTO l_outer_oid
        FROM rc_topologyelement
       WHERE rc_topologyelement.NAME = 'Outer Sorter';

      -- open the cursor
      OPEN pro_dest_oid_cursor;

      LOOP
         -- fetch the rows from the cursor
         FETCH pro_dest_oid_cursor
          INTO l_pro_dest_oid;

         -- exit the loop when there are no more rows,
         EXIT WHEN pro_dest_oid_cursor%NOTFOUND;

          /******************************************************************
          For table RC_PRODUCTDESTINATION, for each OID, RC_PRODUCTDESTINATION.OID
         joins with RC_TOPOLOGYELEMENT.OID,
         IF found return the NAME field of the  RC_TOPOLOGYELEMENT.
         Based on the value of the NAME field, If it ends on 1,8,4,5
         create a record in rc_sortermapping table
         where topologelement = the-oid-of the "Inner Sorter",
         and  Productdestinationoid =  RC_PRODUCTDESTINATION.OID.
         **********************************************************************/
         SELECT rc_topologyelement.NAME, rc_topologyelement.classtype
           INTO l_name, l_type
           FROM rc_topologyelement
          WHERE rc_topologyelement.OID = l_pro_dest_oid;

         IF    SUBSTR (l_name, -1) = c_1_char
            OR SUBSTR (l_name, -1) = c_8_char
            OR SUBSTR (l_name, -1) = c_4_char
            OR SUBSTR (l_name, -1) = c_5_char
         THEN
            INSERT INTO rc_sortermapping
                        (topologyelementoid, productdestinationoid
                        )
                 VALUES (l_inner_oid, l_pro_dest_oid
                        );
         --If it ends on 2,3,6,7  create a record in rc_sortermapping table
           -- where topologelement = the-oid-of the "Outer Sorter",
           -- and  Productdestinationoid =  RC_PRODUCTDESTINATION.OID.
         ELSIF    SUBSTR (l_name, -1) = c_2_char
               OR SUBSTR (l_name, -1) = c_3_char
               OR SUBSTR (l_name, -1) = c_6_char
               OR SUBSTR (l_name, -1) = c_7_char
         THEN
            INSERT INTO rc_sortermapping
                        (topologyelementoid, productdestinationoid
                        )
                 VALUES (l_outer_oid, l_pro_dest_oid
                        );
         ELSE
            --If it ends on 0,9, do nothing and
            --insert a warning message into the Log table.
            --should only be logged for records in RC_LATERAL
            --not for topologyelements that are no lateral.
            IF LOWER (l_type) = c_lateral_string
            THEN
               log_msg
                  (   'The oid: '
                   || l_pro_dest_oid
                   || ' corresponding NAME value in the table rc_topologyelement :'
                   || l_name
                   || ' does not ends 1 to 8'
                  );
            END IF;
         END IF;
      END LOOP;

      -- close the cursor
      CLOSE pro_dest_oid_cursor;

      log_msg ('End the creating sortermapping table procedure');

      --record how many rerords are imported into the rc_sortermapping table
      SELECT COUNT (*)
        INTO l_nr_rows
        FROM rc_sortermapping;

      log_msg (   'Total rerords imported in rc_sortermapping table : '
               || l_nr_rows
               || ' .'
              );
   END create_sortermapping_table;

   /*****************************************************************
   This function starts up the handling of the reference data. The
   data is extracted and inserted into the datamodel of the CSCI_SM.
   *****************************************************************/
   PROCEDURE process_source(areaOID in number)
   IS
   BEGIN
      prepare_message ();
      log_msg ('1. Make sure file is read file...');
      COMMIT;
      log_msg ('2. Start create tables...');
      create_tables(areaOID);
      COMMIT;
      --DBMS_LOB.freetemporary (l_lm_clob_message);
      DBMS_XMLDOM.freedocument (g_dom_doc);
      DBMS_XMLDOM.freedocument (g_dom_topo_en_doc);
      log_msg ('End of load script for referencedata.');
   EXCEPTION
      WHEN OTHERS
      THEN
         log_msg (' ERROR while executing script.' || CHR (10) || SQLERRM);
   END process_source;

   /*****************************************************************
   This function is to initial LU types
   *****************************************************************/
   PROCEDURE initial_static_data_lutypes
   IS
      l_node                 DBMS_XMLDOM.domnode;
      l_nodelist             DBMS_XMLDOM.domnodelist;
      l_lu_type              VARCHAR2 (3);
      l_min_bags             INT;
      l_nodelist_len         INT;
      l_lu_type_definition   VARCHAR2 (10);
   BEGIN
      log_msg ('enter initial static data luTypes procedure');
      --Retrieve LUTypes
      log_msg (c_lutype_xpath);
      l_nodelist :=
              DBMS_XSLPROCESSOR.selectnodes (g_document_node, c_lutype_xpath);
      l_nodelist_len := DBMS_XMLDOM.getlength (l_nodelist);

      DELETE FROM ps_lutype;

      FOR lutypeindex IN 0 .. (l_nodelist_len - 1)
      LOOP
         l_node := DBMS_XMLDOM.item (l_nodelist, lutypeindex);
         l_lu_type := DBMS_XSLPROCESSOR.valueof (l_node, c_lu_type_xpath);
         l_min_bags := DBMS_XSLPROCESSOR.valueof (l_node, c_min_bags_xpath);

         INSERT INTO ps_lutype
                     (lutype
                     )
              VALUES (l_lu_type
                     );
      END LOOP;

      log_msg ('End the initial static data luTypes procedure');
      COMMIT;
   END initial_static_data_lutypes;
   
   /*****************************************************************
   This function is to initial handlers
   *****************************************************************/
   PROCEDURE initial_static_data_handlers
   IS
      l_node           DBMS_XMLDOM.domnode;
      l_nodelist       DBMS_XMLDOM.domnodelist;
      l_handler_id     VARCHAR2 (20);
      l_nodelist_len   INT;
   BEGIN
      log_msg ('enter initial static data handlers procedure');
      --Retrieve LUTypes
      log_msg (c_handler_xpath);
      l_nodelist :=
             DBMS_XSLPROCESSOR.selectnodes (g_document_node, c_handler_xpath);
      l_nodelist_len := DBMS_XMLDOM.getlength (l_nodelist);

      DELETE FROM ps_handler;

      FOR handlerindex IN 0 .. (l_nodelist_len - 1)
      LOOP
         l_node := DBMS_XMLDOM.item (l_nodelist, handlerindex);
         l_handler_id :=
                       DBMS_XSLPROCESSOR.valueof (l_node, c_handler_id_xpath);

         if l_handler_id = 'KL' then
            l_handler_id := 'KLM';
         end if;

         INSERT INTO ps_handler
                     (OID, NAME)
              VALUES (seq_pshandler.NEXTVAL, l_handler_id);
      END LOOP;
      --set default, used in coding
      update ps_handler set oid = 100 where name = 'QQN';

      log_msg ('End the initial static data handlers procedure');
      COMMIT;
   END initial_static_data_handlers;

   /*****************************************************************
   This function is to insert LU type
   *****************************************************************/
   PROCEDURE process_lu_type
   IS
   BEGIN
      prepare_message ();
      log_msg ('1. Make sure system config file is read file...');
      COMMIT;
      log_msg ('2. Start to insert lutype...');
      initial_static_data_lutypes ();
      COMMIT;
      --DBMS_LOB.freetemporary (l_lm_clob_message);
      DBMS_XMLDOM.freedocument (g_dom_doc);
      DBMS_XMLDOM.freedocument (g_dom_topo_en_doc);
      log_msg ('End of load script for system config.');
   EXCEPTION
      WHEN OTHERS
      THEN
         log_msg (' ERROR while executing script.' || CHR (10) || SQLERRM);
   END process_lu_type;
   
   /*****************************************************************
   This function is to insert Handlers
   *****************************************************************/
   PROCEDURE process_handlers
   IS
   BEGIN
      prepare_message ();
      log_msg ('1. Make sure system config file is read file...');
      COMMIT;
      log_msg ('2. Start to insert handler...');
      initial_static_data_handlers ();
      COMMIT;
      --DBMS_LOB.freetemporary (l_lm_clob_message);
      DBMS_XMLDOM.freedocument (g_dom_doc);
      DBMS_XMLDOM.freedocument (g_dom_topo_en_doc);
      log_msg ('End of load script for system config.');
   EXCEPTION
      WHEN OTHERS
      THEN
         log_msg (' ERROR while executing script.' || CHR (10) || SQLERRM);
   END process_handlers;
END sm_referencedata;
/
