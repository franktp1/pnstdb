#!/bin/bash
set -e
echo env
printenv
echo end of env
pwd
echo workdir
id
echo that is me
echo $0
mydir='dir $0'
echo $mydir
initphasedir=postgresql-start


# database creation as in default way 
# NOW DONE AS END OF progresql-init
#sudo /usr/share/container-scripts/postgresql/start/set_passwords.sh

#psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/setupdb.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/rc.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/ps.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/quartz.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/SM_Reference_data_tables.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/SM_RC_TOPOLOGYELEMENT.sequence


psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_ref_data_log.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_ref_data.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_area.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_topologyment.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_productdestination.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_outputpoint.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_rc_lateral.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_ps_lutype.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/fill_ps_handler.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/DistanceGenerator.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/PSFILL.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./${initphasedir}/DEFAULTHANDLERPLANSETTING.sql
