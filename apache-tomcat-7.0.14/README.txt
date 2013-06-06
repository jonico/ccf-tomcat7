This file contains the instructions on how to run TeamForge Connector Server 2.2 aka CollabNet Connect/Sync in this tomcat
distribution.


Prerequisites
=============

TeamForge Connector Server 2.2 requires the following software to be installed on the computer
it is running on

- a Java 6 runtime environment. For QC<->CTF integrations, it must be
  a 32-bit runtime.  Make sure that the environment variable JAVA_HOME
  is pointing to the JRE you intend to use.

Preparations
------------

If you're reading this file, I'm assuming you have successfully obtained the 
TeamForge Connector Server 2.2 distribution and extracted it to the directory
where you wish to deploy the framework.

1. Verify whether following properties files - "ccf.conf" and
  "ccfhomeruntimeconfig-template.properties" exists in the extracted folder.

2. Open the "ccf.conf" configuration file(e.g. $CATALINA_HOME/ccf.conf ), 
   modify ccfhome property value to a folder(e.g. c:/ccf/ccfhome) created
   and to be used by TeamForge Connector Server 2.2. 

3. Copy the "ccfhomeruntimeconfig-template.properties" (e.g. $CATALINA_HOME/ccfhomeruntimeconfig-
   template.properties)to the folder path specified in the ccfhome property (e.g. c:/ccf/ccfhome)
   and rename the file to ccfhomeruntimeconfig.properties.   

4. Edit the runtime configuration properties present in ccfhomeruntimeconfig.properties to suit
   your environment.


Running as a Windows Service
============================

Install the windows service.
----------------------------

1. Open an command prompt with administrator rights.  On Windows
   Vista/7, running the prompt as an administrator user is not
   enough. You *must* follow the following steps:

   - click on the start menu.
   - type "cmd" in the search box, but don't hit enter.
   - right-click on cmd.exe and select "Run as administrator".
   - if a UAC warning pops up, click OK.

2. change into the directory where you unzipped the TeamForge Connector Server 2.2 distribution:

   cd c:\path\to\apache-tomcat-7.0.14
    
3. To install the service, run the following command:
   
   bin\service.bat
   
   This will register TeamForge Connector Server 2.2 as a windows service and set it up
   according to the settings you specified in ccfhomeruntimeconfig.properties. If you get
   errors in this step, make sure the command prompt has administrator
   privileges (see step 1.).

   
Installing multiple Services
----------------------------

It is possible to run multiple instances of CCFMaster on one machine.
In order to do so, you need to supply a name for each service instance
when calling service.bat in step 3. above.

For example:
	<edit ccf.conf and ccfhomeruntimeconfig.properties with settings for service 1>
	bin\service.bat CCFMaster1
	copy ccf.conf ccf.conf.master1
	<edit ccf.conf and ccfhomeruntimeconfig.properties with settings for service 2>
	bin\service.bat CCFMaster2 
	copy ccf.conf ccf.conf.master2
	

   
Run the service
---------------

To run the TeamForge Connector Server 2.2 distribution, you can start the service using the
Services console in windows.  Alternatively, you can run tomcat7w.exe
in the bin directory to configure, start and stop the service.


Running as a Linux service (32-bit)
===================================

Setting up and installing the Service
-------------------------------------

1. Running CCFMaster as a service on linux systems relies on the
   service launcher jsvc, which is part of apache
   commons-daemon. Since this is a native executable, we can only
   supply it for certain architectures. If the steps below do not work
   for you, please follow the instructions at
   http://tomcat.apache.org/tomcat-7.0-doc/setup.html#Unix_daemon
   to create a version of jsvc for your machine.  Alternatively, the
   package management system of your distribution may contain a
   package providing commons-daemon.

2. In addition to the settings specified in ccf.conf and ccfhomeruntimeconfig.properties 
   (see section "Preparations" above), you need to edit the following two lines
   near the beginning of bin/CCFMaster.sh that specify where you
   unzipped the TeamForge Connector Server 2.2 distribution
   and the location of your JRE:

        CATALINA_HOME="/opt/ccfmaster/apache-tomcat-7.0.14"
        JAVA_HOME="/opt/java/jdk1.6.0_25"

3. Add a user named ccf to your system. This will be the user that the
   tomcat server runs as:

        adduser -r -s /sbin/nologin

   If you want to run CCFMaster as a different user, edit
   bin/CCFMaster.sh accordingly.

4. The service launcher script, bin/CCFMaster.sh, acts as a regular
   systemV init script and expects one argument to specify the action
   it should take. Possible actions include:

   - start
   - stop
   - restart

   To install the service, simply copy (or symlink) bin/CCFMaster.sh
   to /etc/init.d and create the appropriate links to call the script
   on system start/shutdown. While this is distribution-specific, here
   are a couple of examples:

   Redhat/CentOS/Debian:

        cp bin/CCFMaster.sh /etc/init.d
        for f in /etc/rc{3,5}.d/{S,K}99CCFMaster.sh; do \
            ln -vs /etc/init.d/CCFMaster.sh $f; \
        done
