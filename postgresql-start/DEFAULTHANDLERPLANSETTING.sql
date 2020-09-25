CREATE OR REPLACE PROCEDURE defaultHandlerPlanSetting()
LANGUAGE plpgsql
AS $$
declare
handlerPlanOid PS_BAGGAGEHANDLERPLAN.OID%type;
handlerOid PS_HANDLER.OID%type;
topologyOid RC_TOPOLOGYELEMENT.OID%type;
productDestinationOid PS_BHPPRODUCTDESTINATIONMAP.OID%type;

startTime PS_BHPPRODUCTDESTINATIONMAP.STARTTIME%type;

endTime PS_BHPPRODUCTDESTINATIONMAP.ENDTIME%type;

cur_handlerPlan cursor  for select OID from PS_HANDLER where HANDLER_KIND = 1;

cur_topologyElement cursor  for select OID from RC_PRODUCTDESTINATION;

begin

delete from PS_BHPPRODUCTDESTINATIONMAP;

startTime := TO_Date( '12/31/1969 23:00:00', 'MM/DD/YYYY HH24:MI:SS');
endTime := TO_Date( '12/31/1969 23:00:00', 'MM/DD/YYYY HH24:MI:SS');
select nextval('SEQ_PSBAGGAGEHANDLERPLAN') into handlerPlanOid;

insert into PS_BAGGAGEHANDLERPLAN (OID, STARTDATE) values (handlerPlanOid, TO_Date( '01/01/1970', 'MM/DD/YYYY'));

open cur_handlerPlan;

loop
	fetch cur_handlerPlan into handlerOid;
        exit when NOT FOUND;
	open cur_topologyElement;

	loop
		fetch cur_topologyElement into topologyOid;
                exit when NOT FOUND;
		select nextval('SEQ_PSBHPPRODUCTDESTINATIONMAP')into productDestinationOid;

		insert into PS_BHPPRODUCTDESTINATIONMAP
	   		  (OID, BHPOID, PRODUCTDESTINATIONOID, HANDLEROID, STARTWEEKDAY, STARTTIME, ENDWEEKDAY, ENDTIME)
			   values
               (productDestinationOid, handlerPlanOid, topologyOid, handlerOid, 2, startTime, 2, endTime);
	end loop;

	close cur_topologyElement;
end loop;

close cur_handlerPlan;

--commit;

exception
     when others then
	 raise notice   'Error while calling procedure.';
	 RAISE EXCEPTION '(%)', SQLERRM;
     
                            

end $$;
