restore controlfile from '<controlfile_backup>';
alter database mount;
select open_mode from v$database;

