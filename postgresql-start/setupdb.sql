CREATE USER PNST_OWNER WITH SUPERUSER CREATEROLE CREATEDB INHERIT PASSWORD 'PNST_OWNER';
CREATE DATABASE PNST OWNER=PNST_OWNER;