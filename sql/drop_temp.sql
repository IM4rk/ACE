SET SERVEROUTPUT ON
BEGIN
	FOR r_rec IN 
	( 
		select 'DROP TABLESPACE ' || tablespace_name as DROP_TEMP from 
		(
			select tablespace_name from dba_tablespaces 
			where tablespace_name like '%TEMP%'
			and tablespace_name != (select temporary_tablespace TABLESPACE_NAME from dba_users where username = 'SYS')
		) 
	)
	LOOP
	dbms_output.put_line(r_rec.DROP_TEMP);
	EXECUTE IMMEDIATE r_rec.DROP_TEMP;
END LOOP;
END;
/

exit
