#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Copy;
use Env;
use Term::ANSIColor;

#================================================================================================================================
#Choose the source and target database												|
#================================================================================================================================

print  color ("green"),"Name of the Source Database: \n", color("reset");
our $SOURCE_DB = <STDIN>;
chomp $SOURCE_DB;

print  color ("green"),"Choose Clone SID: \n", color("reset");
our $DB_SID = <STDIN>;
chomp $DB_SID;
our $UPPER_SID = uc $DB_SID;
print "SId converted :$UPPER_SID \n";

print  color ("green"),"Define your Backup directory: \n", color("reset");
our $BACKUP_DIR = <STDIN>;
chomp  $BACKUP_DIR;

our $CONTROLFILE;
our $DATAFILE_1;
our $DATAFILE_2;
our $FRA;
our $CTL_FILE_SCRIPT = "restore_ctl.sql_$DB_SID";


our $SQL_SCRIPTS = "/oracle/scripts/ACE/sql/";

#Database Controller
our $CMD_SHUTDOWN_ABORT = "sqlplus / as sysdba \@$SQL_SCRIPTS/shutdown_abort.sql";


#================================================================================================================================
#Detect Environment and set the the corresponding directories									|
#================================================================================================================================

our $CMD_DETECT_ENVIRONMENT = "hostname";
our $FIRST7 = `$CMD_DETECT_ENVIRONMENT`;
our $ENVIRONMENT = substr($FIRST7, 0,7);



if ($ENVIRONMENT eq "edu-dev")
{
	print color ("red"), "Setting up Directories for OGA Development Environment \n", color("reset");
	$DATAFILE_1 = "/oracle/oradata/$UPPER_SID";

	our $CMD_MKDIR_DATAFILES_1 = "mkdir -p $DATAFILE_1";
	`$CMD_MKDIR_DATAFILES_1`;
	
	our $CMD_CHECK_DIR = "ls -altr /oracle/oradata/oradata2 | wc -l";
	our $DIR_EXIST = `$CMD_CHECK_DIR`;
	
	if ($DIR_EXIST == 0)
	{
		print "directory not exist creating a new one\n";
		our $CMD_MKDIR_DATAFILES_2 = "mkdir -p /oracle/oradata/oradata2/$UPPER_SID";
		`$CMD_MKDIR_DATAFILES_2`;

	}
	else 
	{
		our $CMD_MKDIR_DATAFILES_2 = "mkdir -p /oracle/oradata/oradata2/$UPPER_SID";
		`$CMD_MKDIR_DATAFILES_2`;
	}

	$DATAFILE_2 = "/oracle/oradata/oradata2/$UPPER_SID";
	
	our $CMD_MKDIR_FRA = "mkdir -p /oracle/fra/$UPPER_SID";
	`$CMD_MKDIR_FRA`;
	$FRA = "/oracle/fra/$UPPER_SID";


	our $CMD_MKDIR_CTL = "mkdir -p /oracle/oradata/$UPPER_SID/controlfile";
        `$CMD_MKDIR_CTL`;
        $CONTROLFILE = "/oracle/oradata/$UPPER_SID/controlfile";
	
  	print  color ("green"), "source: \n", color("reset");
	print "$SOURCE_DB \n";




	print  color ("green"), "target_name: \n", color("reset");
        print "$DB_SID \n";

	print  color ("green"), "Datafiles will be restored in: \n", color("reset"); 
	print "$DATAFILE_1 \n";
	
	print  color ("green"),"Datafiles multiplexed directory:\n" ,color("reset");
	print "$DATAFILE_2 \n";
	
	print  color ("green"), "Archivelogs directory: \n", color("reset");
	print "$FRA \n";

	print  color ("green"), "Controlfiles directory: \n", color("reset");
        print "$CONTROLFILE \n";

	print  color ("green"), "Backup  directory: \n", color("reset");
        print "$BACKUP_DIR \n";
			

}


#================================================================================================================================
#Set up PFILE															|
#================================================================================================================================

our $PFILE_DIR= "/oracle/scripts/ACE/pfile";
our $PFILE_GENERIC = "inittemp.ora";
chomp $PFILE_DIR;
chomp $PFILE_GENERIC;
copy("$PFILE_DIR/$PFILE_GENERIC","$PFILE_DIR/init$DB_SID.ora") or die "Copy failed: $!";

our $CLONE_PFILE = "$PFILE_DIR/init$DB_SID.ora";
chomp $CLONE_PFILE;
print color ("green"), "A backup copy of new pfile is located in \n" ,color("reset");
print "$CLONE_PFILE\n";



#Change parameter on the new pfile
our $CMD_CHANGE_PARAM_0 = "perl -pi.back -e 's{<controlfile>}{$CONTROLFILE/$DB_SID.ctl}g;' $CLONE_PFILE";
our $CMD_CHANGE_PARAM_1 = "perl -pi.back -e 's{<clone_db_unique_name>}{$DB_SID}g;' $CLONE_PFILE";
our $CMD_CHANGE_PARAM_2 = "perl -pi.back -e 's{<source_dbname>}{$SOURCE_DB}g;' $CLONE_PFILE";


`$CMD_CHANGE_PARAM_0`;
`$CMD_CHANGE_PARAM_1`;
`$CMD_CHANGE_PARAM_2`;

copy("$CLONE_PFILE","$ORACLE_HOME/dbs/") or die "Copy failed: $!";

#================================================================================================================================
#Startup the database in NOMOUNT mode                                                                                           |
#================================================================================================================================

$ENV{ORACLE_SID} = "$DB_SID";

print "Starting the clone database in nomount mode using the following env variables\n";
print "ORACLE_SID:$ORACLE_SID \n";
print "ORACLE_HOME:$ORACLE_HOME \n";

our $CMD_START_NOMOUNT_0 = "sqlplus / as sysdba \@$SQL_SCRIPTS/startup_nomount.sql";
system ($CMD_START_NOMOUNT_0);


#================================================================================================================================
#Restore the control file 		                                                                                        |
#================================================================================================================================

our $CMD_CTL_EXIST = "ls -altr $BACKUP_DIR | grep -i control | wc -l ";
our $CTL_EXIST = `$CMD_CTL_EXIST`;
our $CTL_FILE_LOCATOR = "ls  $BACKUP_DIR | grep -i control";
our $CTL_FILE_BACKUP = `$CTL_FILE_LOCATOR`;
chomp $CTL_FILE_BACKUP;


if ($CTL_EXIST >= 1)
{

	print "Backup Exist \n";
	print "Restoring Control File and Mounting Database \n";
	copy("$SQL_SCRIPTS/restore_ctl.sql","$SQL_SCRIPTS/restore_ctl.sql_$DB_SID") or die "Copy failed: $!";
	print color ("green"),"Controlfile backup location is: \n"  ,color("reset");
	print "$BACKUP_DIR/$CTL_FILE_BACKUP\n";
	
	my $CTL_CHANGE = "$SQL_SCRIPTS/$CTL_FILE_SCRIPT";
	our $CMD_CHANGE_CTL_LOC = "perl -pi.back -e 's{<controlfile_backup>}{$BACKUP_DIR/$CTL_FILE_BACKUP}g;' $CTL_CHANGE";
	`$CMD_CHANGE_CTL_LOC`;

	our $RESTORE_CTLFILE = "rman target / cmdfile=$CTL_CHANGE";
	system ($RESTORE_CTLFILE);

	
	
		

}
else 
{
	print  color ("red"), "DudeMan your backup does not exist. Shutting down database instance! \n", color("reset");
	system ($CMD_SHUTDOWN_ABORT);
	exit ();
		

}

#================================================================================================================================
#Generate Restore Script                                                                                                        |
#================================================================================================================================

our $CMD_GEN_RESTORE_SCRIPTS = "sqlplus / as sysdba \@$SQL_SCRIPTS/rman_gen_cmd.sql";
system ($CMD_GEN_RESTORE_SCRIPTS);

our $RESTORE_SCRIPT_DIR = "/oracle/scripts/ACE/restore_scripts";
chomp $RESTORE_SCRIPT_DIR;

our $CMD_RENAME_RESTORE_SCRIPT = "mv $RESTORE_SCRIPT_DIR/restore.rcv $RESTORE_SCRIPT_DIR/$UPPER_SID\_restore.rcv";
`$CMD_RENAME_RESTORE_SCRIPT`;

our $CMD_CHANGE_RESTORE_DIR_0 = "perl -pi.back -e 's{/oracle/disk1/$UPPER_SID}{$DATAFILE_1}g;' $RESTORE_SCRIPT_DIR/$UPPER_SID\_restore.rcv";
`$CMD_CHANGE_RESTORE_DIR_0`;

our $CMD_CHANGE_RESTORE_DIR_1 = "perl -pi.back -e 's{/oracle/disk2/$UPPER_SID}{$DATAFILE_2}g;' $RESTORE_SCRIPT_DIR/$UPPER_SID\_restore.rcv";
`$CMD_CHANGE_RESTORE_DIR_1`;

#================================================================================================================================
#Temporarily disable OMF                                                                                                        |
#================================================================================================================================

our $CMD_DIS_OMF = "sqlplus / as sysdba \@$SQL_SCRIPTS/disable_omf.sql";
system ($CMD_DIS_OMF);



#================================================================================================================================
#Repoint the original redo logfiles to a new directory                                                                          |
#================================================================================================================================

our $CMD_CREATE_NEW_LOGFILES = "sqlplus / as sysdba \@$SQL_SCRIPTS/touch.sql";
`$CMD_CREATE_NEW_LOGFILES`;

copy("$SQL_SCRIPTS/touch.sh","$SQL_SCRIPTS/touch.sh_$DB_SID") or die "Copy failed: $!";
our $CHMOD_TOUCH = "chmod +x $SQL_SCRIPTS/touch.sh_$DB_SID";
`$CHMOD_TOUCH`;

our $CMD_CREATE_REDOS = "$SQL_SCRIPTS/touch.sh_$DB_SID";
`$CMD_CREATE_REDOS`;

our $CMD_RENAME_REDO = "sqlplus / as sysdba \@$SQL_SCRIPTS/rename_redo.sql";
`$CMD_RENAME_REDO`;


#================================================================================================================================
#Restore and Recover database                                                                                                   |
#================================================================================================================================
print "Restoring Database using command file\n";
print "$RESTORE_SCRIPT_DIR/$UPPER_SID\_restore.rcv\n";
our $RESTORE_DB = "rman target / cmdfile=$RESTORE_SCRIPT_DIR/$UPPER_SID\_restore.rcv";
system ($RESTORE_DB);


#=================================================================================================================================
#Create a password file                                                                                                          |
#================================================================================================================================
print color ("green"), "Password file for instance $DB_SID is stored in:\n", color("reset") ;
print "$ORACLE_HOME/dbs/orapw$DB_SID\n";

our $CMD_PWFILE = "orapwd file=$ORACLE_HOME/dbs/orapw$DB_SID password=cat8dog force=y";
`$CMD_PWFILE`;


#================================================================================================================================
#Re-enable OMF                                                                                                                  |
#================================================================================================================================

our $CMD_ENABLE_OMF = "sqlplus / as sysdba \@$SQL_SCRIPTS/enable_omf.sql";
system ($CMD_ENABLE_OMF);

#================================================================================================================================
#Create new TEMP                                                                                                                |
#================================================================================================================================

copy("$SQL_SCRIPTS/new_temp.sql","$SQL_SCRIPTS/new_temp.sql_$DB_SID") or die "Copy failed: $!";

our $minimum = 10;
our $maximum = 20;
our $tmpno = $minimum + int(rand($maximum - $minimum));

print "Designated TEMP number $tmpno\n";

our $CMD_NEW_TEMP_SYNTAX = "perl -pi.back -e 's{<DATAFILE>}{$DATAFILE_1}g;' $SQL_SCRIPTS/new_temp.sql_$DB_SID";
`$CMD_NEW_TEMP_SYNTAX`;

our $CMD_NEW_TEMP_SYNTAX1 = "perl -pi.back -e 's{<tmpno>}{$tmpno}g;' $SQL_SCRIPTS/new_temp.sql_$DB_SID";
`$CMD_NEW_TEMP_SYNTAX1`;

our $CMD_CREATE_DEFAULT_TEMPFILE = "sqlplus / as sysdba \@$SQL_SCRIPTS/new_temp.sql_$DB_SID";
system ($CMD_CREATE_DEFAULT_TEMPFILE);



#================================================================================================================================
#Disable OMF & Drop the old TEMPFILE                                                                                            |
#================================================================================================================================
system ($CMD_DIS_OMF);

our $CMD_CLEAN_RESTART = "sqlplus / as sysdba \@$SQL_SCRIPTS/clean_restart.sql";
`$CMD_CLEAN_RESTART`; 

our $DROP_TMP = "sqlplus / as sysdba \@$SQL_SCRIPTS/drop_temp.sql";
system ($DROP_TMP);

#=================================================================================================================================
#Change DBNAME                                                                                                                   |
#================================================================================================================================

our $CMD_CLEAN_MOUNT = "sqlplus / as sysdba \@$SQL_SCRIPTS/clean_mount.sql";
system ($CMD_CLEAN_MOUNT);

our $CMD_CHNG_DBNAME = "echo \"Y\" | nid target=/ dbname=$DB_SID ";
system ($CMD_CHNG_DBNAME);

copy("$SQL_SCRIPTS/spfile_name.sql","$SQL_SCRIPTS/spfile_name.sql_$DB_SID") or die "Copy failed: $!";


our $CMD_NEW_DBNAME_SYNTAX = "perl -pi.back -e 's{<new_SID>}{$DB_SID}g;' $SQL_SCRIPTS/spfile_name.sql_$DB_SID";
system ($CMD_NEW_DBNAME_SYNTAX);

our $CMD_SP_DBNAME = "sqlplus / as sysdba \@$SQL_SCRIPTS/spfile_name.sql_$DB_SID";
system ($CMD_SP_DBNAME);

#=================================================================================================================================
#Re-enable OMF and file clean up                                                                                                 |
#=================================================================================================================================
system ($CMD_ENABLE_OMF);

our $CLEANUP = "rm /oracle/scripts/ACE/sql/*.back";
our $CLEANUP1 = "rm /oracle/scripts/ACE/sql/touch.sh_*";
our $CLEANUP2 = "rm /oracle/scripts/ACE/sql/new_temp.sql_*";
our $CLEANUP3 = "rm /oracle/scripts/ACE/sql/restore_ctl.sql_*";
our $CLEANUP4 = "rm /oracle/scripts/ACE/sql/spfile_name.sql_*";

`$CLEANUP`;
`$CLEANUP1`;
`$CLEANUP2`;
`$CLEANUP3`;
`$CLEANUP4`;










































=pod
#================================================================================================================
#Check or create directory based  dir provided by the user Generic User                                         |
#================================================================================================================

print "Choose SID: \n";
our $DB_SID = <STDIN>;
chomp $DB_SID;
print "Choose datafiles directory: \n";
our $DATAFILES = <STDIN>;
chomp $DATAFILES;

 


print "your chosen SID is $DB_SID\n";
our $CMD_CHECK_DIR = "ls -altr $DATAFILES/$DB_SID | wc -l ";
print "$DATAFILES/$DB_SID \n";
our $DIR_EXIST = `$CMD_CHECK_DIR`;


if ($DIR_EXIST == 0)
{
	print "directory not exist creating a new one\n";
	our $CMD_MKDIR_DATAFILES = "mkdir -p $DATAFILES/$DB_SID";
	`$CMD_MKDIR_DATAFILES`;
	our $CMD_MKDIR_CONTROL = "mkdir -p $DATAFILES/$DB_SID/controlfile";
	`$CMD_MKDIR_CONTROL`;
	print "Datafiles will be restored in: $DATAFILES/$DB_SID \n";
	print "$ORACLE_BASE \n"; 

}
else 
{
	print "Datafiles will be restored in: $DATAFILES/$DB_SID \n";
	our $CMD_MKDIR_CONTROL = "mkdir -p $DATAFILES/$DB_SID/controlfile";
	`$CMD_MKDIR_CONTROL`;

}
=cut



