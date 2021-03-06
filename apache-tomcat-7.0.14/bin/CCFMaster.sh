#!/bin/sh
CATALINA_HOME="/opt/ccfmaster/apache-tomcat-7.0.14"
JAVA_HOME="/opt/java/jdk1.6.0_25"

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# resolve links - $0 may be a softlink
ARG0="$0"
while [ -h "$ARG0" ]; do
  ls=`ls -ld "$ARG0"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    ARG0="$link"
  else
    ARG0="`dirname $ARG0`/$link"
  fi
done
DIRNAME="`dirname $ARG0`"
PROGRAM="`basename $ARG0`"
for o
do
  case "$o" in
    --java-home )
        JAVA_HOME="$2"
        shift; shift;
        continue
    ;;
    --catalina-home )
        CATALINA_HOME="$2"
        shift; shift;
        continue
    ;;
    --catalina-base )
        CATALINA_BASE="$2"
        shift; shift;
        continue
    ;;
    --catalina-pid )
        CATALINA_PID="$2"
        shift; shift;
        continue
    ;;
    --tomcat-user )
        TOMCAT_USER="$2"
        shift; shift;
        continue
    ;;
    * )
        break
    ;;
  esac
done

# Setup parameters for running the jsvc
#
test ".$TOMCAT_USER" = . && TOMCAT_USER=ccf
# Set JAVA_HOME to working JDK or JRE
# JAVA_HOME=/opt/jdk-1.6.0.22
# If not set we'll try to guess the JAVA_HOME
# from java binary if on the PATH
#
if [ -z "$JAVA_HOME" ]; then
    JAVA_BIN="`which java 2>/dev/null || type java 2>&1`"
    test -x "$JAVA_BIN" && JAVA_HOME="`dirname $JAVA_BIN`"
    test ".$JAVA_HOME" != . && JAVA_HOME=`cd "$JAVA_HOME/.." >/dev/null; pwd`
else
    JAVA_BIN="$JAVA_HOME/bin/java"
fi

# Only set CATALINA_HOME if not already set
test ".$CATALINA_HOME" = . && CATALINA_HOME=`cd "$DIRNAME/.." >/dev/null; pwd`
test ".$CATALINA_BASE" = . && CATALINA_BASE="$CATALINA_HOME"
test ".$CATALINA_MAIN" = . && CATALINA_MAIN=org.apache.catalina.startup.Bootstrap
PROCESSOR_ARCHITECTURE="$(uname -p)"
test ".$JSVC" = . && JSVC="$CATALINA_BASE/bin/jsvc"
test -x "${JSVC}.${PROCESSOR_ARCHITECTURE}" && JSVC="${JSVC}.${PROCESSOR_ARCHITECTURE}"


# Ensure that any user defined CLASSPATH variables are not used on startup,
# but allow them to be specified in setenv.sh, in rare case when it is needed.
CLASSPATH=
JAVA_OPTS=
if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
  . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
fi

# Add on extra jar files to CLASSPATH
test ".$CLASSPATH" != . && CLASSPATH="${CLASSPATH}:"
CLASSPATH="$CLASSPATH$CATALINA_HOME/bin/bootstrap.jar:$CATALINA_HOME/bin/commons-daemon.jar"

test ".$CATALINA_OUT" = . && CATALINA_OUT="$CATALINA_BASE/logs/catalina-daemon.out"
test ".$CATALINA_TMP" = . && CATALINA_TMP="$CATALINA_BASE/temp"

# Add tomcat-juli.jar to classpath
# tomcat-juli.jar can be over-ridden per instance
if [ -r "$CATALINA_BASE/bin/tomcat-juli.jar" ] ; then
  CLASSPATH="$CLASSPATH:$CATALINA_BASE/bin/tomcat-juli.jar"
else
  CLASSPATH="$CLASSPATH:$CATALINA_HOME/bin/tomcat-juli.jar"
fi
# Set juli LogManager config file if it is present and an override has not been issued
if [ -z "$LOGGING_CONFIG" ]; then
  if [ -r "$CATALINA_BASE/conf/logging.properties" ]; then
    LOGGING_CONFIG="-Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties"
  else
    # Bugzilla 45585
    LOGGING_CONFIG="-Dnop"
  fi
fi

test ".$LOGGING_MANAGER" = . && LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
JAVA_OPTS="$JAVA_OPTS $LOGGING_MANAGER"

# Set -pidfile
test ".$CATALINA_PID" = . && CATALINA_PID="$CATALINA_BASE/logs/catalina-daemon.pid"

# ----- Execute The Requested Command -----------------------------------------
case "$1" in
    run     )
      shift
      "$JSVC" $* \
      -java-home "$JAVA_HOME" \
      -pidfile "$CATALINA_PID" \
      -wait 10 \
      -nodetach \
      -outfile "&1" \
      -errfile "&2" \
      -classpath "$CLASSPATH" \
      "$LOGGING_CONFIG" $JAVA_OPTS $CATALINA_OPTS \
      -Djava.endorsed.dirs="$JAVA_ENDORSED_DIRS" \
      -Dcatalina.base="$CATALINA_BASE" \
      -Dcatalina.home="$CATALINA_HOME" \
      -Djava.io.tmpdir="$CATALINA_TMP" \
      $CATALINA_MAIN
      exit $?
    ;;
    start   )
      "$JSVC" \
      -java-home "$JAVA_HOME" \
      -user $TOMCAT_USER \
      -pidfile "$CATALINA_PID" \
      -wait 10 \
      -outfile "$CATALINA_OUT" \
      -errfile "&1" \
      -classpath "$CLASSPATH" \
      "$LOGGING_CONFIG" $JAVA_OPTS $CATALINA_OPTS \
      -Djava.endorsed.dirs="$JAVA_ENDORSED_DIRS" \
      -Dcatalina.base="$CATALINA_BASE" \
      -Dcatalina.home="$CATALINA_HOME" \
      -Djava.io.tmpdir="$CATALINA_TMP" \
      $CATALINA_MAIN
      exit $?
    ;;
    stop    )
      "$JSVC" \
      -stop \
      -pidfile "$CATALINA_PID" \
      -classpath "$CLASSPATH" \
      -Djava.endorsed.dirs="$JAVA_ENDORSED_DIRS" \
      -Dcatalina.base="$CATALINA_BASE" \
      -Dcatalina.home="$CATALINA_HOME" \
      -Djava.io.tmpdir="$CATALINA_TMP" \
      $CATALINA_MAIN
      exit $?
    ;;
    version  )
      "$JSVC" \
      -java-home "$JAVA_HOME" \
      -pidfile "$CATALINA_PID" \
      -classpath "$CLASSPATH" \
      -errfile "&2" \
      -version \
      -check \
      $CATALINA_MAIN
      if [ "$?" = 0 ]; then
        "$JAVA_BIN" \
        -classpath "$CATALINA_HOME/lib/catalina.jar" \
        org.apache.catalina.util.ServerInfo
      fi
      exit $?
    ;;
    *       )
      echo "Unkown command: \`$1'"
      echo "Usage: $PROGRAM ( commands ... )"
      echo "commands:"
      echo "  run               Start Catalina without detaching from console"
      echo "  start             Start Catalina"
      echo "  stop              Stop Catalina"
      echo "  version           What version of commons daemon and Tomcat"
      echo "                    are you running?"
      exit 1
    ;;
esac
