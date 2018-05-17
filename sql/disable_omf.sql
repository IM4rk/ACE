create spfile from pfile;
startup force mount;
alter system set "_omf" = disabled scope=spfile;
startup force mount;

-- shows that OMF has been successfully disabled
col name format a25
col value format a10
select x.ksppinm name, y.kspftctxvl value, y.kspftctxdf isdefault, decode(bitand(y.kspftctxvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismod,
decode(bitand(y.kspftctxvf,2),2,'TRUE','FALSE') isadj from sys.x$ksppi x, sys.x$ksppcv2 y where x.inst_id = userenv('Instance')
and y.inst_id = userenv('Instance') and x.indx+1 = y.kspftctxpn
and x.ksppinm like '%omf%' ;

exit



