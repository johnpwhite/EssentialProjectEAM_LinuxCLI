#!/bin/bash
#Script to build Essential EA

#################################################
## Some installers are hard coded:             ##
## tomcat 9, but will get the latest variant   ##
## MySQL JDBC Driver, specific version: 8.0.20 ##
#################################################


################################
### Set your variables first ###
################################
#QUIETMODE=Y #disable most of the console output so you can see the wood for the trees, not recommended
FQHN=$HOSTNAME #we need to set the hostname in a number of protege files
DBUSER="essential"
DBPASS="essential"
RDP=N #Install OpenBox Window manager, and xrdp to support launching Protege from a windows RDP client (no client install required!)

# Let's get the party started
clear

#Re-useable colour script
declare -A colors
#curl www.bunlongheng.com/code/colors.png

# Reset
colors[Color_Off]='\033[0m'       # Text Reset

# Regular Colors
colors[Black]='\033[0;30m'        # Black
colors[Red]='\033[0;31m'          # Red
colors[Green]='\033[0;32m'        # Green
colors[Yellow]='\033[0;33m'       # Yellow
colors[Blue]='\033[0;34m'         # Blue
colors[Purple]='\033[0;35m'       # Purple
colors[Cyan]='\033[0;36m'         # Cyan
colors[White]='\033[0;37m'        # White

# Bold
colors[BBlack]='\033[1;30m'       # Black
colors[BRed]='\033[1;31m'         # Red
colors[BGreen]='\033[1;32m'       # Green
colors[BYellow]='\033[1;33m'      # Yellow
colors[BBlue]='\033[1;34m'        # Blue
colors[BPurple]='\033[1;35m'      # Purple
colors[BCyan]='\033[1;36m'        # Cyan
colors[BWhite]='\033[1;37m'       # White

# Underline
colors[UBlack]='\033[4;30m'       # Black
colors[URed]='\033[4;31m'         # Red
colors[UGreen]='\033[4;32m'       # Green
colors[UYellow]='\033[4;33m'      # Yellow
colors[UBlue]='\033[4;34m'        # Blue
colors[UPurple]='\033[4;35m'      # Purple
colors[UCyan]='\033[4;36m'        # Cyan
colors[UWhite]='\033[4;37m'       # White

# Background
colors[On_Black]='\033[40m'       # Black
colors[On_Red]='\033[41m'         # Red
colors[On_Green]='\033[42m'       # Green
colors[On_Yellow]='\033[43m'      # Yellow
colors[On_Blue]='\033[44m'        # Blue
colors[On_Purple]='\033[45m'      # Purple
colors[On_Cyan]='\033[46m'        # Cyan
colors[On_White]='\033[47m'       # White

# High Intensity
colors[IBlack]='\033[0;90m'       # Black
colors[IRed]='\033[0;91m'         # Red
colors[IGreen]='\033[0;92m'       # Green
colors[IYellow]='\033[0;93m'      # Yellow
colors[IBlue]='\033[0;94m'        # Blue
colors[IPurple]='\033[0;95m'      # Purple
colors[ICyan]='\033[0;96m'        # Cyan
colors[IWhite]='\033[0;97m'       # White

# Bold High Intensity
colors[BIBlack]='\033[1;90m'      # Black
colors[BIRed]='\033[1;91m'        # Red
colors[BIGreen]='\033[1;92m'      # Green
colors[BIYellow]='\033[1;93m'     # Yellow
colors[BIBlue]='\033[1;94m'       # Blue
colors[BIPurple]='\033[1;95m'     # Purple
colors[BICyan]='\033[1;96m'       # Cyan
colors[BIWhite]='\033[1;97m'      # White

# High Intensity backgrounds
colors[On_IBlack]='\033[0;100m'   # Black
colors[On_IRed]='\033[0;101m'     # Red
colors[On_IGreen]='\033[0;102m'   # Green
colors[On_IYellow]='\033[0;103m'  # Yellow
colors[On_IBlue]='\033[0;104m'    # Blue
colors[On_IPurple]='\033[0;105m'  # Purple
colors[On_ICyan]='\033[0;106m'    # Cyan
colors[On_IWhite]='\033[0;107m'   # White

cecho() {
  echo -e "${colors[$1]}$2${colors[Color_Off]}"
}

#Make sure Ubunutu is up to date and we have the tools we need
cecho BIYellow "Prep tasks:"
echo "Updating OS with apt update"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq update > /dev/null
else
  apt-get update
fi

echo "Installing unzip"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq install unzip > /dev/null
else
  apt-get install unzip
fi

echo
# Clean up
rm *.ENV 2> /dev/null

# Get the latest version file names
cecho BIYellow "Identified the following latest versions:"
wget -q https://tomcat.apache.org/download-90.cgi -O - | grep -o -E 'https://downloads.apache.org/tomcat/tomcat-9/v9.*.tar.gz' | head -1 > ./TOMCAT_VERSION.ENV
echo $(cat ./TOMCAT_VERSION.ENV)

wget -q https://www.enterprise-architecture.org/os_download.php -O - > ./EA_PAGE.ENV
cat ./EA_PAGE.ENV | grep -o -E 'essentialinstallupgrade.*.jar' > ./WIDGETS_VERSION.ENV
echo $(cat ./WIDGETS_VERSION.ENV)

#We don't need this as we deploy a copy of the DB with the v6.10 model in
cat ./EA_PAGE.ENV | grep -o -E 'essential_baseline_v.*.zip' > ./MODEL_VERSION.ENV
#echo $(cat ./MODEL_VERSION.ENV)

cat ./EA_PAGE.ENV | grep -o -E 'essential_viewer_.*.war' > ./VIEWER_VERSION.ENV
echo $(cat ./VIEWER_VERSION.ENV)

cat ./EA_PAGE.ENV | grep -o -E 'essential_import_utility_.*.war' > ./IMPORT_VERSION.ENV
echo $(cat ./IMPORT_VERSION.ENV)

echo
#Check what the current version of the model is on the EA website, if not 6.10, warn the user to upgrade after install
var=$(cat ./MODEL_VERSION.ENV)
var=${var#*essential_baseline_v}
var=${var%.zip}
if [[ $var == "6.10" ]]; then
    cecho BIGreen "This installs the latest Essential Project Model (v6.10)"
else
    cecho BIRed "There is a newer version of the Essential Project Model, please install the upgrade pack(s)"
fi

echo
cecho BIYellow "Start downloads:"
# Get support files
cecho White "Downloading support files:"
rm -R EssentialProjectEAM_LinuxCLI-master 2> /dev/null
rm master.zip 2> /dev/null

if [[ $QUIETMODE == "Y" ]]; then
  wget -q https://github.com/johnpwhite/EssentialProjectEAM_LinuxCLI/archive/master.zip 2> /dev/null
else
  wget --tries=3 --progress=bar:force:noscroll https://github.com/johnpwhite/EssentialProjectEAM_LinuxCLI/archive/master.zip
fi

# Download tomcat
echo
cecho BIYellow "Downloading Essential EA files:"
cat ./TOMCAT_VERSION.ENV | grep -o -E 'apache-tomcat-9.*.tar.gz' > ./TOMCAT_FILENAME.ENV
if [ -f "$(cat ./TOMCAT_FILENAME.ENV)" ]; then
    cecho BIGreen "Tomcat download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 $(cat ./TOMCAT_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll $(cat ./TOMCAT_VERSION.ENV)
  fi
fi

# Download essential project files
if [ -f "$(cat ./WIDGETS_VERSION.ENV)" ]; then
    cecho BIGreen "Essential Installer/Widgets download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/essential-widgets/$(cat ./WIDGETS_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/essential-widgets/$(cat ./WIDGETS_VERSION.ENV)
  fi
fi

#No longer needed as we deploy the model via DB restore
#if [ -f "$(cat ./MODEL_VERSION.ENV)" ]; then
#    cecho BIGreen "Essential Model download exists"
#else
#    wget  --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/meta-model/$(cat ./MODEL_VERSION.ENV) 2> /dev/null
#fi

if [ -f "$(cat ./VIEWER_VERSION.ENV)" ]; then
    cecho BIGreen "Essential Viewer download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/viewer/$(cat ./VIEWER_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/viewer/$(cat ./VIEWER_VERSION.ENV)
  fi
fi

if [ -f "$(cat ./IMPORT_VERSION.ENV)" ]; then
    cecho BIGreen "Essential Import Utility download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/import-utility/$(cat ./IMPORT_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/import-utility/$(cat ./IMPORT_VERSION.ENV)
  fi
fi

# Download Protege 3.5
#wget --tries=3 --progress=bar:force:noscroll https://protege.stanford.edu/download/protege/3.5/installanywhere/Web_Installers/InstData/Linux/NoVM/install_protege_3.5.bin
if [ -f "install_protege_3.5-Linux64-noJVM.bin" ]; then
    cecho BIGreen "Protege Installer download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/protege/install_protege_3.5-Linux64-noJVM.bin 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/protege/install_protege_3.5-Linux64-noJVM.bin
  fi
fi

# Download JDBC driver for MySQL
if [ -f "mysql-connector-java-8.0.20.tar.gz" ]; then
    cecho BIGreen "MySQL JDBC Installer download exists"
else
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.20.tar.gz 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.20.tar.gz
  fi
fi

#### PREPARE DOWNLOADS ####
echo
cecho BIYellow "Unpacking downloads:"
# Support files
# These are the various settings and installer driver configs
cecho White "Support files"
rm -R EssentialProjectEAM_LinuxCLI-master 2> /dev/null
if [[ $QUIETMODE == "Y" ]]; then
  unzip -qq master.zip
else
  unzip master.zip
fi

#Protege
chmod u+x install_protege_3.5-Linux64-noJVM.bin

echo
#### START INSTALL ####
#Install Java
apt-get -qq remove openjdk-11-jre-headless
cecho BIYellow "Installing Java:"
echo "Running apt install openjdk-8-jre-headless"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq install openjdk-8-jre-headless 2> /dev/null
else
  apt-get install openjdk-8-jre-headless
fi
echo "Comment out java accessibility wrapper in case you run protege locally"
cat /etc/java-8-openjdk/accessibility.properties | sed -e "s/assistive_technologies=org.GNOME.Accessibility.AtkWrapper/#assistive_technologies=org.GNOME.Accessibility.AtkWrapper/g" > accessibility_new.properties
cp accessibility_new.properties /etc/java-8-openjdk/accessibility.properties

echo
#Install tomcat
#Create tomcat user
cecho BIYellow "Installing Tomcat:"
echo "Setting up users"
groupadd tomcat 2> /dev/null
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat #2> /dev/null

# tomcat
echo "Deploying Tomcat"
systemctl disable tomcat.service 2> /dev/null
systemctl stop tomcat.service 2> /dev/null
rm -R /opt/tomcat 2> /dev/null
mkdir /opt/tomcat
tar xzf $(cat ./TOMCAT_FILENAME.ENV) -C /opt/tomcat --strip-components=1
echo "Setting user permissions"
chown -R tomcat: /opt/tomcat
chmod +x /opt/tomcat/bin/*.sh
echo "Copying webapp user conf file"
cp EssentialProjectEAM_LinuxCLI-master/tomcat-users.xml /opt/tomcat/conf/
echo "Copying tomcat service file and auto starting"
cp EssentialProjectEAM_LinuxCLI-master/tomcat.service /etc/systemd/system/
systemctl daemon-reload 2> /dev/null
systemctl enable tomcat.service 2> /dev/null
echo "Comment out RemoteAddrValve for manager to allow remote access"
cp EssentialProjectEAM_LinuxCLI-master/context.xml /opt/tomcat/webapps/manager/META-INF/

#install mysql
echo
cecho BIYellow "Installing MySQL:"
apt-get -qq remove mysql-server
echo "Installing engine"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq install mysql-server 2> /dev/null
else
  apt-get install mysql-server
fi
echo "Setup DB and User"
MAINDB="EssentialAM"
mysql -e "CREATE DATABASE IF NOT EXISTS ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER IF NOT EXISTS ${DBUSER}@'%' IDENTIFIED BY '${DBPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'%';"
mysql -e "CREATE USER IF NOT EXISTS ${DBUSER}@'localhost' IDENTIFIED BY '${DBPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo "Starting DB restore"
mysql --one-database ${MAINDB}  <  EssentialProjectEAM_LinuxCLI-master/EARepo_backup.sql
echo "Change settings to bind on all IP addresses - 0.0.0.0"
cat /etc/mysql/mysql.conf.d/mysqld.cnf | sed -e "s/bind-address.*/bind-address=0.0.0.0/g" > mysqld_new.cnf
cp mysqld_new.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

echo
#Install Protege
#https://docs.flexera.com/installanywhere2012/Content/helplibrary/ia_ref_command_line_install_uninstall.htm
cecho BIYellow "Installing Protege:"
if [ -d "/opt/Protege_3.5/" ]; then
    cecho white "First uninstalling existing version"
    systemctl disable protege.service 2> /dev/null
    systemctl stop protege.service 2> /dev/null
    /opt/Protege_3.5/Uninstall_Protege\ 3.5/Uninstall\ Protege\ 3.5 -i silent 2>/dev/null
fi
echo "Starting install"
if [[ $QUIETMODE == "Y" ]]; then
  ./install_protege_3.5-Linux64-noJVM.bin -i silent -DUSER_INSTALL_DIR="/opt/Protege_3.5" -f EssentialProjectEAM_LinuxCLI-master/protege-response.txt #2>/dev/null
else
  ./install_protege_3.5-Linux64-noJVM.bin -i console -DUSER_INSTALL_DIR="/opt/Protege_3.5" -f EssentialProjectEAM_LinuxCLI-master/protege-response.txt
fi
echo "Set Sort class tree to false in protege.properties"
#sed -i '$ a ui.sort.class.tree=false' /opt/Protege_3.5/protege.properties
#echo "ui.sort.class.tree=false" >> /opt/Protege_3.5/protege.properties
cp EssentialProjectEAM_LinuxCLI-master/protege.properties /opt/Protege_3.5/

echo "Increase Protege.lax memory setting to 2gb"
cat /opt/Protege_3.5/Protege.lax | sed -e "s/lax.nl.java.option.java.heap.size.max=.*/lax.nl.java.option.java.heap.size.max=2048000000/g" > Protege_new.lax
cp Protege_new.lax /opt/Protege_3.5/Protege.lax

echo "Copy new start/stop script"
cp EssentialProjectEAM_LinuxCLI-master/run_protege_server_fix.sh /opt/Protege_3.5/
cp EssentialProjectEAM_LinuxCLI-master/shutdown_protege_server.sh /opt/Protege_3.5/
cp EssentialProjectEAM_LinuxCLI-master/run_protege.sh /opt/Protege_3.5/
chmod 777 -R /opt/Protege_3.5

echo "Copying Protege service file"
cp EssentialProjectEAM_LinuxCLI-master/protege.service /etc/systemd/system/

echo "Updating host name in 3 Protege files"
echo "protege.service"
cat /etc/systemd/system/protege.service | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > protege_new.service
cp protege_new.service /etc/systemd/system/protege.service
echo "protege.properties"
cat /opt/Protege_3.5/protege.properties | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > protege_new.properties
cp protege_new.properties /opt/Protege_3.5/protege.properties
echo "run_protege_server_fix.sh"
cat /opt/Protege_3.5/run_protege_server_fix.sh | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > run_protege_server_fix_new.sh
cp run_protege_server_fix_new.sh /opt/Protege_3.5/run_protege_server_fix.sh

#Enable the protege service
systemctl daemon-reload 2> /dev/null
systemctl enable protege.service 2> /dev/null

#Install JDBC driver
echo "Installing MySQL JDBC driver"
#apt-get -qq install ./mysql-connector-java_8.0.20-1ubuntu20.04_all.deb #> /dev/null
tar -xzf mysql-connector-java-8.0.20.tar.gz --wildcards --no-anchored '*.jar'
cp ./mysql-connector-java-8.0.20/mysql-connector-java-8.0.20.jar /opt/Protege_3.5/driver.jar

echo
#Install Essential EA
cecho BIYellow "Installing Essential EA:"
if [[ $QUIETMODE == "Y" ]]; then
  java -jar $(cat ./WIDGETS_VERSION.ENV) -mode=silent EssentialProjectEAM_LinuxCLI-master/auto-install.xml 2> /dev/null
else
  java -jar $(cat ./WIDGETS_VERSION.ENV) -mode=silent EssentialProjectEAM_LinuxCLI-master/auto-install.xml
fi
#Install the latest model
cecho BIYellow "Installing Essential Model Project Files"
echo "Copying preconfigured v6.10 model DB based project files"
rm -R /opt/essentialAM/ 2> /dev/null
mkdir /opt/essentialAM 2> /dev/null
mkdir /opt/essentialAM/repo 2> /dev/null
unzip -qq EssentialProjectEAM_LinuxCLI-master/essential_projects.zip -d /opt/essentialAM/repo
chmod 777 -R /opt/essentialAM
echo "Copying server meta project files"
cp -r EssentialProjectEAM_LinuxCLI-master/server /opt/essentialAM/server

# Install the tomcat war files and tidy up
echo "Installing Essential Viewer"
cp $(cat ./VIEWER_VERSION.ENV) /opt/tomcat/webapps/essential_viewer.war
echo "Installing Essential Import Utility"
cp $(cat ./IMPORT_VERSION.ENV) /opt/tomcat/webapps/essential_import_utility.war

cecho BIYellow "Re-starting mysql for changes to take effect"
systemctl restart mysql 2> /dev/null

cecho BIYellow "Starting protege"
systemctl start protege.service 2> /dev/null

cecho BIYellow "Starting tomcat"
systemctl start tomcat.service 2> /dev/null

if [[ $RDP == "Y" ]]; then
  apt-get install openbox
  apt-get install xrdp
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/xrdp.ini /etc/xrdp
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/startwm.sh /etc/xrdp
  chmod 777 /etc/xrdp/startwm.sh
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/rc.xml /etc/xdg/openbox/
fi

# Clean up
rm *.ENV 2> /dev/null
#rm ./install_protege_3.5.bin
#rm ./$(cat ./WIDGETS_VERSION.ENV)
#rm ./$(cat ./MODEL_VERSION.ENV)
#rm ./$(cat ./VIEWER_VERSION.ENV)
#rm ./$(cat ./IMPORT_VERSION.ENV)

cecho BIGreen "ALL DONE!"
