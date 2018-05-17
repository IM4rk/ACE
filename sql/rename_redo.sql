SET SERVEROUTPUT ON
BEGIN
FOR r_rec IN (
select SYNTAX  || DIR  || '/' || FILE_NAME  || r ||'.log' || ''''  AS RENAME_REDO from
(
    select 'ALTER DATABASE RENAME FILE' || '''' || member  || '''' ||' ' ||'to' || ' ' ||'''' ||'/oracle/fra/' AS SYNTAX
    , (select upper(instance_name) from v$instance) AS DIR
    , (select lower(instance_name) from v$instance) AS FILE_NAME
    , rownum as R
    from v$logfile order by group#
)
) LOOP
dbms_output.put_line( r_rec.RENAME_REDO);
EXECUTE IMMEDIATE r_rec.RENAME_REDO;
END LOOP;
END;

/

exit
