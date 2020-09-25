#!/bin/bash
set -e


psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./rc.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./ps.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./quartz.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./SM_Reference_data_tables.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./SM_RC_TOPOLOGYELEMENT.sequence


psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_ref_data_log.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_ref_data.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_area.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_topologyment.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_productdestination.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_outputpoint.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_rc_lateral.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_ps_lutype.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./fill_ps_handler.sql

psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./DistanceGenerator.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./PSFILL.sql
psql -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE}| -f ./DEFAULTHANDLERPLANSETTING.sql
