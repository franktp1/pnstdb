#!/bin/bash
set -e
echo env
printenv
echo end of env
pwd
echo workdir
id
echo that is me

# database creation as in default way 
sudo /usr/share/container-scripts/postgresql/start/set_passwords.sh

#psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/setupdb.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/rc.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/ps.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/quartz.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/SM_Reference_data_tables.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/SM_RC_TOPOLOGYELEMENT.sequence


psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_ref_data_log.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_ref_data.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_area.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_topologyment.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_productdestination.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_outputpoint.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_rc_lateral.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_ps_lutype.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/fill_ps_handler.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/DistanceGenerator.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/PSFILL.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} -f ./postgresql-init/DEFAULTHANDLERPLANSETTING.sql
