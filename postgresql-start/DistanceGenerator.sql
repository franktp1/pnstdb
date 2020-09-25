create or replace procedure DistanceGenerator()
LANGUAGE 'plpgsql'
AS $$
/******************************************************************************
   NAME:       DistanceGenerator
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        6/19/2009          1. Created this procedure.
   2.0        12/21/2009         2. Topology name is changed.

   NOTES:
     ROW1: ZSB80,ZL116,ZL114,ZL112,ZL110,ZL108,ZL106,ZSB81
     ROW2: ZL120,ZL119,ZL118,ZL117,ZL115,ZL113,ZL111,ZL109,ZL107,ZL105,ZL014,ZL103,ZL102,ZL101
     ROW3: ZM201,ZM203,ZM203,ZM204,ZM205,ZM206
     New Row1: ZSB50,ZL205,ZL207,ZL209,ZL211,ZL213,ZL215,ZSB51
     New Row2: ZL201,ZL202,ZL203,ZL204,ZL206,ZL208,ZL210,ZL212,ZL214,ZL216,ZL217,ZL218,ZL219,ZL220
     New Row3: ZRB01,ZRB02,ZRB03,ZRB04,ZRB05,ZRB06
     Update by Topology A87
         ZL203 -> ZL209
         ZL202 -> ZL208
         ZL201 -> ZL207
         ZL204 -> ZL210
         ZL206 -> ZL211
         ZL205 -> ZL201
         ZL208 -> ZL212
         ZL207 -> ZL202
         ZL210 -> ZL213
         ZL209 -> ZL203
         ZL212 -> ZL214
         ZL211 -> ZL204
         ZL214 -> ZL215
         ZL213 -> ZL205
         ZL215 -> ZL206
      New Row1: ZSB50,ZL201,ZL202,ZL203,ZL204,ZL205,ZL206,ZSB51
      New Row2: ZL207,ZL208,ZL209,ZL210,ZL211,ZL212,ZL213,ZL214,ZL215,ZL216,ZL217,ZL218,ZL219,ZL220
      New Row3: ZRB01,ZRB02,ZRB03,ZRB04,ZRB05,ZRB06
      Update by Topology A89
         ZL220 -> ZSB52
      New Row1: ZSB50,ZL201,ZL202,ZL203,ZL204,ZL205,ZL206,ZSB51
      New Row2: ZL207,ZL208,ZL209,ZL210,ZL211,ZL212,ZL213,ZL214,ZL215,ZL216,ZL217,ZL218,ZL219,ZSB52
      New Row3: ZRB01,ZRB02,ZRB03,ZRB04,ZRB05,ZRB06

     Distance calculation
     1. Distance between rows = 20, so R1-R2=20, R2-R3=20 and R1-R3=40
     2. Distance between items within row is 2, or 1 if they are direct neighbours.

   Automatically available Auto Replace Keywords:
      Object Name:     DistanceGenerator
      Sysdate:         6/19/2009
      Date and Time:   6/19/2009, 4:55:30, and 6/19/2009 4:55:30
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   DECLARE
   fromDestOid  rc_topologyelement.oid%TYPE;
      toDestOid    rc_topologyelement.oid%TYPE;
      distance     rc_topologydistance.distance%TYPE;
      fromFlag     rc_topologyelement.oid%TYPE;
      toFlag       rc_topologyelement.oid%TYPE;
	  cur_from record;
	  cur_to record;

begin

    delete from rc_topologydistance;

    For cur_from in
     (SELECT * FROM rc_topologyelement
       where osocidentification in ('ZSB50','ZL201','ZL202','ZL203','ZL204','ZL205','ZL206','ZSB51',
       'ZL207','ZL208','ZL209','ZL210','ZL211','ZL212','ZL213','ZL214','ZL215','ZL216','ZL217','ZL218','ZL219','ZSB52',
       'ZRB01','ZRB02','ZRB03','ZRB04','ZRB05','ZRB06')) LOOP

       fromDestOid := cur_from.oid;

       if cur_from.osocidentification = 'ZSB50' then
         fromFlag := 1001;
       elsif cur_from.osocidentification = 'ZL201' then
         fromFlag := 1002;
       elsif cur_from.osocidentification = 'ZL202' then
         fromFlag := 1003;
       elsif cur_from.osocidentification = 'ZL203' then
         fromFlag := 1004;
       elsif cur_from.osocidentification = 'ZL204' then
         fromFlag := 1005;
       elsif cur_from.osocidentification = 'ZL205' then
         fromFlag := 1006;
       elsif cur_from.osocidentification = 'ZL206' then
         fromFlag := 1007;
       elsif cur_from.osocidentification = 'ZSB51' then
         fromFlag := 1008;
       elsif cur_from.osocidentification = 'ZL207' then
         fromFlag := 2001;
       elsif cur_from.osocidentification = 'ZL208' then
         fromFlag := 2002;
       elsif cur_from.osocidentification = 'ZL209' then
         fromFlag := 2003;
       elsif cur_from.osocidentification = 'ZL210' then
         fromFlag := 2004;
       elsif cur_from.osocidentification = 'ZL211' then
         fromFlag := 2005;
       elsif cur_from.osocidentification = 'ZL212' then
         fromFlag := 2006;
       elsif cur_from.osocidentification = 'ZL213' then
         fromFlag := 2007;
       elsif cur_from.osocidentification = 'ZL214' then
         fromFlag := 2008;
       elsif cur_from.osocidentification = 'ZL215' then
         fromFlag := 2009;
       elsif cur_from.osocidentification = 'ZL216' then
         fromFlag := 2010;
       elsif cur_from.osocidentification = 'ZL217' then
         fromFlag := 2011;
       elsif cur_from.osocidentification = 'ZL218' then
         fromFlag := 2012;
       elsif cur_from.osocidentification = 'ZL219' then
         fromFlag := 2013;
       elsif cur_from.osocidentification = 'ZSB52' then
         fromFlag := 2014;
       elsif cur_from.osocidentification = 'ZRB01' then
         fromFlag := 3001;
       elsif cur_from.osocidentification = 'ZRB02' then
         fromFlag := 3002;
       elsif cur_from.osocidentification = 'ZRB03' then
         fromFlag := 3003;
       elsif cur_from.osocidentification = 'ZRB04' then
         fromFlag := 3004;
       elsif cur_from.osocidentification = 'ZRB05' then
         fromFlag := 3005;
       elsif cur_from.osocidentification = 'ZRB06' then
         fromFlag := 3006;
       end if;

      for cur_to in (SELECT * FROM rc_topologyelement
       where osocidentification in ('ZSB50','ZL201','ZL202','ZL203','ZL204','ZL205','ZL206','ZSB51',
       'ZL207','ZL208','ZL209','ZL210','ZL211','ZL212','ZL213','ZL214','ZL215','ZL216','ZL217','ZL218','ZL219','ZSB52',
       'ZRB01','ZRB02','ZRB03','ZRB04','ZRB05','ZRB06') and oid <> cur_from.oid) LOOP

         toDestOid := cur_to.oid;

         if cur_to.osocidentification = 'ZSB50' then
           toFlag := 1001;
         elsif cur_to.osocidentification = 'ZL201' then
           toFlag := 1002;
         elsif cur_to.osocidentification = 'ZL202' then
           toFlag := 1003;
         elsif cur_to.osocidentification = 'ZL203' then
           toFlag := 1004;
         elsif cur_to.osocidentification = 'ZL204' then
           toFlag := 1005;
         elsif cur_to.osocidentification = 'ZL205' then
           toFlag := 1006;
         elsif cur_to.osocidentification = 'ZL206' then
           toFlag := 1007;
         elsif cur_to.osocidentification = 'ZDB81' then
           toFlag := 1008;
         elsif cur_to.osocidentification = 'ZL207' then
           toFlag := 2001;
         elsif cur_to.osocidentification = 'ZL208' then
           toFlag := 2002;
         elsif cur_to.osocidentification = 'ZL209' then
           toFlag := 2003;
         elsif cur_to.osocidentification = 'ZL210' then
           toFlag := 2004;
         elsif cur_to.osocidentification = 'ZL211' then
           toFlag := 2005;
         elsif cur_to.osocidentification = 'ZL212' then
           toFlag := 2006;
         elsif cur_to.osocidentification = 'ZL213' then
           toFlag := 2007;
         elsif cur_to.osocidentification = 'ZL214' then
           toFlag := 2008;
         elsif cur_to.osocidentification = 'ZL215' then
           toFlag := 2009;
         elsif cur_to.osocidentification = 'ZL216' then
           toFlag := 2010;
         elsif cur_to.osocidentification = 'ZL217' then
           toFlag := 2011;
         elsif cur_to.osocidentification = 'ZL218' then
           toFlag := 2012;
         elsif cur_to.osocidentification = 'ZL219' then
           toFlag := 2013;
         elsif cur_to.osocidentification = 'ZSB52' then
           toFlag := 2014;
         elsif cur_to.osocidentification = 'ZRB01' then
           toFlag := 3001;
         elsif cur_to.osocidentification = 'ZRB02' then
           toFlag := 3002;
         elsif cur_to.osocidentification = 'ZRB03' then
           toFlag := 3003;
         elsif cur_to.osocidentification = 'ZRB04' then
           toFlag := 3004;
         elsif cur_to.osocidentification = 'ZRB05' then
           toFlag := 3005;
         elsif cur_to.osocidentification = 'ZRB06' then
           toFlag := 3006;
         end if;

        if floor(fromFlag/1000) - floor(toFlag/1000) = 0 then
          if abs(fromFlag - toFlag) = 1  then
             distance := 1;
          else
             distance := 2;
          end if;
        else
          distance := abs(floor(fromFlag/1000) - floor(toFlag/1000)) * 20;
        end if;

       insert into rc_topologydistance values (fromDestOid, toDestOid, distance);

       END LOOP;
    END LOOP;

   -- commit;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;

end $$;

