-- Role: "PNST_OWNER"
DROP ROLE "PNST_OWNER";

CREATE ROLE "PNST_OWNER" WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  CREATEDB
  NOCREATEROLE
  NOREPLICATION
  PASSWORD 'PNST_OWNER';