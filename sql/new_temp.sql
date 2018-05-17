alter system set db_create_file_dest = '<DATAFILE>' scope=both;
CREATE TEMPORARY TABLESPACE TEMP<tmpno>;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP<tmpno>;

exit
