#!/bin/sh
JAVA_PATH=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/bin/
CLASSPATH=protege.jar:looks.jar:driver.jar
MAINCLASS=edu.stanford.smi.protege.server.Server


# ------------------- JVM Options ------------------- 
MAX_MEMORY=-Xmx2048M
HEADLESS=-Djava.awt.headless=true
CODEBASE_URL=file:/opt/Protege_3.5/protege.jar
CODEBASE=-Djava.rmi.server.codebase=$CODEBASE_URL
HOSTNAME_PARAM=-Djava.rmi.server.hostname=ubuntutemplate.localdomain
TX="-Dtransaction.level=READ_COMMITTED"
LOG4J_OPT="-Dlog4j.configuration=file:/opt/Protege_3.5/log4j.xml"

OPTIONS="$MAX_MEMORY $HEADLESS $CODEBASE $HOSTNAME_PARAM ${TX} ${LOG4J_OPT}"

#
# Instrumentation debug, delay simulation,  etc
#
PORTOPTS="-Dprotege.rmi.server.port=5200 -Dprotege.rmi.registry.port=5100"
#DEBUG_OPT="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

OPTIONS="${OPTIONS} ${PORTOPTS} ${DEBUG_OPT}"
# ------------------- JVM Options ------------------- 

# ------------------- Cmd Options -------------------
# If you want automatic saving of the project, 
# setup the number of seconds in SAVE_INTERVAL_VALUE
# SAVE_INTERVAL=-saveIntervalSec=120
# ------------------- Cmd Options -------------------

METAPROJECT=/opt/essentialAM/server/metaproject.pprj

$JAVA_PATH/rmiregistry -J-Djava.class.path=$CLASSPATH 5100& 
$JAVA_PATH/java -cp $CLASSPATH $TX $OPTIONS $MAINCLASS $SAVE_INTERVAL $METAPROJECT
