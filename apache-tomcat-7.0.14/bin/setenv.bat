@echo off

set JAVA_OPTS=%JAVA_OPTS% -Xms256m -Xmx512m
rem voodoo parameters to try to avoid OutOfMemoryErrors on webapp redeployment
set JAVA_OPTS=%JAVA_OPTS% -XX:+CMSClassUnloadingEnabled

set CCF_CONF="%CATALINA_HOME%\ccf.conf"
if exist %CCF_CONF% (
	echo setting up CCF system properties
	for /f "usebackq tokens=1,2 eol=# delims==" %%a in (%CCF_CONF%) do (
		echo setting %%a to %%b
		call set JAVA_OPTS=%%JAVA_OPTS%% "-D%%a=%%b"
	)
) else (
	echo WARNING: could not find CCF configuration file: %CCF_CONF%
)
echo JAVA_OPTS: %JAVA_OPTS%

