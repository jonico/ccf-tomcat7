#!/bin/sh

# this is just the commands from CREATE_DISTRIBUTION.txt for convenience.

svn export https://ctf.open.collab.net/svn/repos/ccf/trunk/ccf-tomcat7/apache-tomcat-7.0.14
wget \
    http://bit.ly/ccfmaster_last_successful_build \
    -O apache-tomcat-7.0.14/webapps/CCFMaster.war
tar czf ccf-tomcat.tar.gz apache-tomcat-7.0.14
zip -r9q ccf-tomcat.zip apache-tomcat-7.0.14