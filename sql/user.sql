DROP ROLE IF EXISTS test;

CREATE ROLE test WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:lMzGgYmxsYW+yNbej7DJEw==$gUtmiFqQec+SVnT/Tywv3CI1bpAXy486woiW+Boxa7o=:Aj4SwglPmIav13M5wfrwj4YLd93k0ipDnQl6CASAkeQ=';