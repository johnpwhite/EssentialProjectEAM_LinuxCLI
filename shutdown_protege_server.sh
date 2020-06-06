#!/bin/sh
JAVA_PATH=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/bin/
CLASSPATH=protege.jar:looks.jar:unicode_panel.jar:driver.jar
MAINCLASS=edu.stanford.smi.protege.server.Shutdown

# ------------------- JVM Options ------------------- 
MAX_MEMORY=-Xmx100M
# ------------------- JVM Options ------------------- 

$JAVA_PATH/java -cp $CLASSPATH $MAINCLASS $1
