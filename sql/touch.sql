set feedback off
set lines 200
set pages 200
col SYNTAX for a150
set heading off
set echo off
spool /oracle/scripts/ACE/sql/touch.sh

select '#!/bin/sh' from dual
/
select 'touch /oracle/fra/' || DIR  || '/' || FILE_NAME  || r ||'.log' AS CREATE_FILE from 
(
	select 'ALTER DATABASE RENAME FILE' || '''' || member  || '''' ||' ' ||'to' || ' ' ||'''' ||'/oracle/fra/' AS SYNTAX 
	, (select upper(instance_name) from v$instance) AS DIR
	, (select lower(instance_name) from v$instance) AS FILE_NAME
	, rownum as R 
	from v$logfile order by group#
);
spool off;
exit;
