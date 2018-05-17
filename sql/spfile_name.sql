startup nomount;
ALTER SYSTEM SET DB_NAME=<new_SID> SCOPE=SPFILE;
shutdown immediate;
startup mount;
alter database open resetlogs;
select instance_name from v$instance;
select open_mode, NAME, DB_UNIQUE_NAME from v$database;
exit


