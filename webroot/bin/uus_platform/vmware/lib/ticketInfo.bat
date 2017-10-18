@echo off
cd uus_platform
cd vmware
cd lib
SET CLASSPATH=.;
SetLocal EnableDelayedExpansion  
FOR %%i IN ("*.jar") DO SET CLASSPATH=!CLASSPATH!;%%i
%1 -classpath %CLASSPATH% com.ibm.ivp.tool.CimTicket %2 %3 %4 %5
EndLocal
cd ../