--
-- $Id$
--
set pagesize 0
set heading off
set trimspool on
set trimout on
set linesize 200
set feedback off
set verify off
def full_or_rollforward='FULL'
def open_noopen='OPEN'
def file_path='/oracle/disk'
spool '/oracle/scripts/ACE/restore_scripts/restore.rcv'
SELECT
  --
  -- Find the lastest redo log
  -- that is cataloged in the controlfile
  --
  'run{'                   || CHR(10) ||
  'set until sequence '    ||
  TO_CHAR(max(sequence#)+1)||
  ';'
FROM
  v$backup_archivelog_details
/
SELECT
     --
     -- Create new file names and path
     -- this will macke sure the files are created where you want them
     --
     'set newname for datafile '     ||
     f.file#                         ||
     ' to "&file_path'               ||
     --
     -- Alternate disks
     --
     TO_CHAR(mod(f.file#,2)+1)                     || '/' ||
     (SELECT UPPER(instance_name) FROM v$instance) || '/' ||
     t.name                                        || '_' ||
     ltrim( to_char( rank() over (partition by t.name order by f.file#), '00') ) ||
     '.dbf";' ts_file
FROM
     v$datafile   f
JOIN v$tablespace t ON t.ts# = f.ts#
WHERE
     --
     -- Only move datafile on full rebuild
     --
     'FULL'='&full_or_rollforward'
ORDER BY
     t.name
/
SELECT
  --
  -- Need the database to be mounted
  --
  CASE WHEN open_mode IN ('READ WRITE','READ ONLY') THEN
    --
    -- Shut it down and start how we want
    --
    'shutdown immediate;'||CHR(10)||'startup mount;'
  END open_mount_cmds
FROM
  v$database
/
SELECT
  --
  -- Full database restore?
  --
  CASE WHEN '&full_or_rollforward'='FULL' THEN
    'restore database;'              || CHR(10) ||
    'switch datafile all;'
  END                                || CHR(10) ||
  --
  -- Always a recover
  --
  'recover database;'                || CHR(10) ||
  --
  -- Open database or leave in recovery mode (mounted)
  --
  CASE
    WHEN '&open_noopen'='OPEN' THEN
      'alter database open resetlogs;'
    WHEN '&open_noopen'='OPEN_READ_ONLY' THEN
      'sql ''alter database open read only'';'
  END                                || CHR(10) ||
  '}'
FROM
  dual
/
spool off

exit
