#!/bin/sh
JAVA_PATH=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/bin/
#JARS=/opt/Protege_3.5/protege.jar:/opt/Protege_3.5/driver.jar:/opt/Protege_3.5/looks.jar:/opt/Protege_3.5/unicode_panel.jar
JARS=/opt/Protege_3.5/protege.jar:/opt/Protege_3.5/looks.jar:/opt/Protege_3.5/unicode_panel.jar
MAIN_CLASS=edu.stanford.smi.protege.Application

# ------------------- JVM Options ------------------- 
MAXIMUM_MEMORY=-Xmx2048M
OPTIONS=$MAXIMUM_MEMORY

#DELAY="-Dserver.delay=80 -Dserver.upload.kilobytes.second=128 -Dserver.download.kilobytes.second=500"
LOG4J_OPT="-Dlog4j.configuration=file:log4j.xml"

#Possible instrumentation options - debug, etc.
#DEBUG_OPT="-agentlib:jdwp=transport=dt_socket,address=8100,server=y,suspend=n"
# For yjp remember to set the LDLIBRARY path
# e.g export 
#      LD_LIBRARY_PATH=/home/tredmond/dev/packages/yjp-7.5.6/bin/linux-x86-32
#YJP_OPT="-agentlib:yjpagent=port=8142"


OPTIONS="${OPTIONS} ${DEBUG_OPT} ${YJP_OPT} ${DELAY} ${LOG4J_OPT}"
# ------------------- JVM Options ------------------- 

# Run Protege
$JAVA_PATH/java $OPTIONS -Dprotege.dir=/opt/Protege_3.5 -Duser.country=UK -Duser.language=en -cp $JARS $MAIN_CLASS $1
