@echo off

for /f "tokens=1,2 eol=# delims==" %%a in (%~1) do (
rem	"%EXECUTABLE% //US/%SERVICE_NAME% ++JvmOptions -D%%a=%%b
	echo -D%%a=%%b
)