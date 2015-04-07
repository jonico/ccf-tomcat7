#!/bin/sh

FILENAME=$CATALINA_HOME/ccf.conf

# ensure that the for loop works in the presence of spaces in a line
OLDIFS="${IFS}"
IFS="
"

test ".$JAVA_OPTS" != . && JAVA_OPTS="${JAVA_OPTS} "
JAVA_OPTS="${JAVA_OPTS}-Xms512m -Xmx1024m "
JAVA_OPTS="${JAVA_OPTS}-XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256m "

for line in $(<$FILENAME tr -d '\r' | egrep -v '^#' | egrep -v '^\s*$');do
	opt=$(echo $line | awk -F= '{printf("-D%s=%s",$1,$2)}')
#	echo $opt
	test ".$JAVA_OPTS" != . && JAVA_OPTS="${JAVA_OPTS} "
	JAVA_OPTS="${JAVA_OPTS}$opt"
done
IFS="${OLDIFS}"
echo JAVA_OPTS=$JAVA_OPTS
