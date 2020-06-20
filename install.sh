#!/bin/bash
clear
if [ $USER != root ] ; then
  echo "Must be root, now exiting"
  exit
fi

if [ "$(lsb_release -sr)" != "18.04" ] ; then
  echo "Must be Ubuntu 18.04 else an unsupported of MYSQL will be used and will break the import tool, now exiting"
  exit
fi

#Script to build Essential EA

#################################################
## Some installers are hard coded:             ##
## tomcat 9, but will get the latest variant   ##
## MySQL JDBC Driver, specific version: 8.0.20 ##
#################################################

#Creating Protégé Users after install
#useradd john
#passwd john
#(manually enter password)
#usermod -a -G protegeusers john
#mkdir /home/john
#chown john:john /home/john/

################################
### Set your variables first ###
################################
#QUIETMODE=Y #disable most of the console output so you can see the wood for the trees, not recommended
FQHN=$HOSTNAME #we need to set the hostname in a number of protege files
DBUSER="essential"
DBPASS="essential"
RDP=N ##IGNORE NOW - See WebSwing## #Install OpenBox Window manager, and xrdp to support launching Protege from a windows RDP client (no client install required!)
WEBSWING="Y" #install WebSwing to host the protege java app in a web page, super cool.... say no to RDP with this.
DBRESTORE="Y" #If you want to not restore the pre configured v6.10, and install the latest non DB project files. You'll need to re setup the DB and Annotations project

# Let's get the party started
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
cecho BIGreen "Updating OS with apt update"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq update > /dev/null
else
  apt-get update
fi

cecho BIGreen "Installing unzip"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq install unzip > /dev/null
else
  apt-get install unzip -y
fi

echo
# Clean up
rm *.ENV 2> /dev/null

# Get the latest version file names
cecho BIYellow "Identified the following latest versions:"
wget -q https://tomcat.apache.org/download-90.cgi -O - | grep -o -E 'https://downloads.apache.org/tomcat/tomcat-9/v9.*.tar.gz' | head -1 > ./TOMCAT_VERSION.ENV
cecho BIGreen $(cat ./TOMCAT_VERSION.ENV)

wget -q https://www.enterprise-architecture.org/os_download.php -O - > ./EA_PAGE.ENV
cat ./EA_PAGE.ENV | grep -o -E 'essentialinstallupgrade.*.jar' > ./WIDGETS_VERSION.ENV
cecho BIGreen $(cat ./WIDGETS_VERSION.ENV)

cat ./EA_PAGE.ENV | grep -o -E 'essential_baseline_v.*.zip' > ./MODEL_VERSION.ENV
cecho BIGreen $(cat ./MODEL_VERSION.ENV)
  
if [[ $DBRESTORE == "Y" ]]; then
  #We don't need this as we deploy a copy of the DB with the v6.10 model in
  #Check what the current version of the model is on the EA website, if not 6.10, warn the user to upgrade after install
  var=$(cat ./MODEL_VERSION.ENV)
  var=${var#*essential_baseline_v}
  var=${var%.zip}
  if [[ $var != "6.10" ]]; then
    cecho BIRed "There is a newer version of the Essential Project Model, please install the upgrade pack(s) after this completes"
  fi
fi

cat ./EA_PAGE.ENV | grep -o -E 'essential_viewer_.*.war' > ./VIEWER_VERSION.ENV
cecho BIGreen $(cat ./VIEWER_VERSION.ENV)

cat ./EA_PAGE.ENV | grep -o -E 'essential_import_utility_.*.war' > ./IMPORT_VERSION.ENV
cecho BIGreen $(cat ./IMPORT_VERSION.ENV)

echo
cecho BIYellow "Start downloads:"
# Get support files
cecho BIGreen "Downloading support files"
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
  cecho BIGreen "Downloading tomcat"
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
  cecho BIGreen "Downloading Essential Installer/Widgets"
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/essential-widgets/$(cat ./WIDGETS_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/essential-widgets/$(cat ./WIDGETS_VERSION.ENV)
  fi
fi

if [[ $DBRESTORE != "N" ]]; then
  #We don't need this as we deploy a copy of the DB with the v6.10 model in
  echo "Skipping model download as deploying via DB& project restore"
else
  if [ -f "$(cat ./MODEL_VERSION.ENV)" ]; then
     cecho BIGreen "Essential Model download exists"
  else
     cecho BIGreen "Downloading Essential Model"
     if [[ $QUIETMODE == "Y" ]]; then
       wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/meta-model/$(cat ./MODEL_VERSION.ENV) 2> /dev/null     
     else
       wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/meta-model/$(cat ./MODEL_VERSION.ENV)
     fi 
  fi
fi

if [ -f "$(cat ./VIEWER_VERSION.ENV)" ]; then
    cecho BIGreen "Essential Viewer download exists"
else
  cecho BIGreen "Downloading Essential Viewer"
  if [[ $QUIETMODE == "Y" ]]; then
    wget -q --tries=3 https://essential-cdn.s3.eu-west-2.amazonaws.com/viewer/$(cat ./VIEWER_VERSION.ENV) 2> /dev/null
  else
    wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/viewer/$(cat ./VIEWER_VERSION.ENV)
  fi
fi

if [ -f "$(cat ./IMPORT_VERSION.ENV)" ]; then
    cecho BIGreen "Essential Import Utility download exists"
else
  cecho BIGreen "Downloading Essential Import Utility"
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
  cecho BIGreen "Downloading Protege"
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
  cecho BIGreen "Downloading MySQL JDBC Installer"
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
cecho BIGreen "Support files"
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
  apt-get -qq install openjdk-8-jre-headless -y 1> /dev/null 2> /dev/null
else
  apt-get install openjdk-8-jre-headless -y
fi
cecho BIGreen "Comment out java accessibility wrapper in case you run protege locally"
cat /etc/java-8-openjdk/accessibility.properties | sed -e "s/assistive_technologies=org.GNOME.Accessibility.AtkWrapper/#assistive_technologies=org.GNOME.Accessibility.AtkWrapper/g" > accessibility_new.properties
cp accessibility_new.properties /etc/java-8-openjdk/accessibility.properties

echo
#Install tomcat
#Create tomcat user
cecho BIYellow "Installing Tomcat:"
cecho BIGreen "Setting up users"
groupadd tomcat 2> /dev/null
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat #2> /dev/null

# tomcat
cecho BIGreen "Deploying Tomcat"
systemctl disable tomcat.service 2> /dev/null
systemctl stop tomcat.service 2> /dev/null
rm -R /opt/tomcat 2> /dev/null
mkdir /opt/tomcat
tar xzf $(cat ./TOMCAT_FILENAME.ENV) -C /opt/tomcat --strip-components=1
cecho BIGreen "Setting user permissions"
chown -R tomcat: /opt/tomcat
chmod +x /opt/tomcat/bin/*.sh
cecho BIGreen "Copying webapp user conf file"
cp EssentialProjectEAM_LinuxCLI-master/tomcat-users.xml /opt/tomcat/conf/
cecho BIGreen "Copying tomcat service file and auto starting"
cp EssentialProjectEAM_LinuxCLI-master/tomcat.service /etc/systemd/system/
systemctl daemon-reload 2> /dev/null
systemctl enable tomcat.service 2> /dev/null
cecho BIGreen "Comment out RemoteAddrValve for manager to allow remote access"
cp EssentialProjectEAM_LinuxCLI-master/context.xml /opt/tomcat/webapps/manager/META-INF/

cecho BIPurple "Starting tomcat"
systemctl start tomcat.service 2> /dev/null

#install mysql
echo
cecho BIYellow "Installing MySQL:"
apt-get -qq remove mysql-server
cecho BIGreen "Installing engine"
if [[ $QUIETMODE == "Y" ]]; then
  apt-get -qq install mysql-server -y 1> /dev/null 2> /dev/null
else
  apt-get install mysql-server -y
fi
cecho BIGreen "Setup DB and User"
MAINDB="EssentialAM"
mysql -e "CREATE DATABASE IF NOT EXISTS ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER IF NOT EXISTS ${DBUSER}@'%' IDENTIFIED BY '${DBPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'%';"
mysql -e "CREATE USER IF NOT EXISTS ${DBUSER}@'localhost' IDENTIFIED BY '${DBPASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${DBUSER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

cecho BIGreen "Change settings to bind on all IP addresses - 0.0.0.0"
cat /etc/mysql/mysql.conf.d/mysqld.cnf | sed -e "s/bind-address.*/bind-address=0.0.0.0/g" > mysqld_new.cnf
cp mysqld_new.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

if [[ $DBRESTORE == "N" ]]; then
  #No restore taken
  cecho BIGreen "Skipping restore to deploy vendor project file based model in a later step"
else
  cecho BIGreen "Starting DB restore"
  mysql --one-database ${MAINDB}  <  EssentialProjectEAM_LinuxCLI-master/EARepo_backup.sql
fi

echo
#Install Protege
#https://docs.flexera.com/installanywhere2012/Content/helplibrary/ia_ref_command_line_install_uninstall.htm
cecho BIYellow "Installing Protege:"
if [ -d "/opt/Protege_3.5/" ]; then
    cecho BIGreen "First uninstalling existing version"
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
cecho BIGreen "Set Sort class tree to false in protege.properties"
#sed -i '$ a ui.sort.class.tree=false' /opt/Protege_3.5/protege.properties
#cecho BIGreen "ui.sort.class.tree=false" >> /opt/Protege_3.5/protege.properties
cp EssentialProjectEAM_LinuxCLI-master/protege.properties /opt/Protege_3.5/

cecho BIGreen "Increase Protege.lax memory setting to 2gb"
cat /opt/Protege_3.5/Protege.lax | sed -e "s/lax.nl.java.option.java.heap.size.max=.*/lax.nl.java.option.java.heap.size.max=2048000000/g" > Protege_new.lax
cp Protege_new.lax /opt/Protege_3.5/Protege.lax

cecho BIGreen "Copy new start/stop script"
cp EssentialProjectEAM_LinuxCLI-master/run_protege_server.sh /opt/Protege_3.5/
cp EssentialProjectEAM_LinuxCLI-master/shutdown_protege_server.sh /opt/Protege_3.5/
cp EssentialProjectEAM_LinuxCLI-master/run_protege.sh /opt/Protege_3.5/
chmod 775 -R /opt/Protege_3.5

cecho BIGreen "Copying Protege service file"
cp EssentialProjectEAM_LinuxCLI-master/protege.service /etc/systemd/system/

cecho BIGreen "Updating host name in 3 Protege files"
cecho BIGreen "protege.service"
cat /etc/systemd/system/protege.service | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > protege_new.service
cp protege_new.service /etc/systemd/system/protege.service
cecho BIGreen "protege.properties"
cat /opt/Protege_3.5/protege.properties | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > protege_new.properties
cp protege_new.properties /opt/Protege_3.5/protege.properties
cecho BIGreen "run_protege_server.sh"
cat /opt/Protege_3.5/run_protege_server.sh | sed -e "s/ubuntutemplate.localdomain/$FQHN/" > run_protege_server_new.sh
cp run_protege_server_new.sh /opt/Protege_3.5/run_protege_server.sh

#Enable the protege service
systemctl daemon-reload 2> /dev/null
systemctl enable protege.service 2> /dev/null

#create group for future users
groupadd protegeusers
chgrp -R protegeusers /opt/Protege_3.5/

#Install JDBC driver
cecho BIGreen "Installing MySQL JDBC driver"
#apt-get -qq install ./mysql-connector-java_8.0.20-1ubuntu20.04_all.deb #> /dev/null
tar -xzf mysql-connector-java-8.0.20.tar.gz --wildcards --no-anchored '*.jar'
cp ./mysql-connector-java-8.0.20/mysql-connector-java-8.0.20.jar /opt/Protege_3.5/driver.jar

echo
#Install Essential EA
cecho BIYellow "Installing Essential EA:"
if [[ $QUIETMODE == "Y" ]]; then
  java -jar $(cat ./WIDGETS_VERSION.ENV) -mode=silent EssentialProjectEAM_LinuxCLI-master/auto-install.xml 1> /dev/null 2> /dev/null
else
  java -jar $(cat ./WIDGETS_VERSION.ENV) -mode=silent EssentialProjectEAM_LinuxCLI-master/auto-install.xml
fi
#Install the latest model
cecho BIYellow "Installing Essential Model Project Files"
rm -R /opt/essentialAM/ 2> /dev/null
mkdir /opt/essentialAM 2> /dev/null
mkdir /opt/essentialAM/repo 2> /dev/null

cecho BIGreen "Copying server meta project files"
cp -r EssentialProjectEAM_LinuxCLI-master/server /opt/essentialAM/server

if [[ $DBRESTORE == "N" ]]; then
  cecho BIGreen "Unzipping latest meta model project files"
  unzip -qq $(cat ./MODEL_VERSION.ENV) -d /opt/essentialAM/repo
else
  #Restore the version configured to use the DB
  cecho BIGreen "Restoring DB configured meta model project files"
  unzip -qq EssentialProjectEAM_LinuxCLI-master/essential_projects.zip -d /opt/essentialAM/repo
  chmod 777 -R /opt/essentialAM
fi

# Install the tomcat war files and tidy up
cecho BIGreen "Installing Essential Viewer"
cp $(cat ./VIEWER_VERSION.ENV) /opt/tomcat/webapps/essential_viewer.war
cecho BIGreen "Installing DEV Essential Viewer"
cp $(cat ./VIEWER_VERSION.ENV) /opt/tomcat/webapps/essential_viewer_dev.war
cecho BIGreen "Installing TEST Essential Viewer"
cp $(cat ./VIEWER_VERSION.ENV) /opt/tomcat/webapps/essential_viewer_test.war

cecho BIGreen "Installing Essential Import Utility"
cp $(cat ./IMPORT_VERSION.ENV) /opt/tomcat/webapps/essential_import_utility.war

cecho BIGreen "Re-starting mysql for changes to take effect"
systemctl restart mysql 2> /dev/null

cecho BIPurple "Starting protege"
systemctl start protege.service 2> /dev/null

#Not recommended now we have WebSwing
if [[ $RDP == "Y" ]]; then
  apt-get install openbox -y
  apt-get install xrdp -y
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/xrdp.ini /etc/xrdp
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/startwm.sh /etc/xrdp
  chmod 777 /etc/xrdp/startwm.sh
  cp EssentialProjectEAM_LinuxCLI-master/xrdp/rc.xml /etc/xdg/openbox/
fi

if [[ $WEBSWING == "Y" ]]; then
  cecho BIYellow "Deploying WebSwing to host Protege Java App"
  # Get the latest version file name
  cecho BIGreen "Identified the following latest version of webswing:"
  wget -q https://bitbucket.org/meszarv/webswing/downloads/ -O - | grep -o -m 1 'webswing-.*\.zip"' | sed 's/"//g' > ./WEBSWING_VERSION.ENV
  cecho BIGreen $(cat ./WEBSWING_VERSION.ENV)
  
  if [ -f "$(cat ./WEBSWING_VERSION.ENV)" ]; then
    cecho BIGreen "WebSwing download exists"
  else
    if [[ $QUIETMODE == "Y" ]]; then
      wget -q --tries=3 https://bitbucket.org/meszarv/webswing/downloads/$(cat ./WEBSWING_VERSION.ENV) 2> /dev/null
    else
      wget --tries=3 --progress=bar:force:noscroll https://bitbucket.org/meszarv/webswing/downloads/$(cat ./WEBSWING_VERSION.ENV)
    fi
  fi

  #Unzip to target dir
  rm -R /opt/webswing 2> /dev/null
  mkdir /opt/webswing
  if [[ $QUIETMODE == "Y" ]]; then
    unzip -qq $(cat ./WEBSWING_VERSION.ENV) -d /opt/webswing/
  else
    unzip $(cat ./WEBSWING_VERSION.ENV) -d /opt/webswing/
  fi
  mv /opt/webswing/webswing-examples*/* /opt/webswing/
  rmdir /opt/webswing/webswing-examples*

  #Install dependencies
  cecho BIGreen "Installing WebSwing dependencies"
  apt-get -qq install xvfb -y
  apt-get -qq install libxext6 -y
  apt-get -qq install libxi6 -y
  apt-get -qq install libxtst6 -y
  apt-get -qq install libxrender1 -y

  #Configure WebSwing
  cecho BIGreen "Configure WebSwing"
  #jetty.properties - Change ports to 80 & 443 and disable HTTP
  cp EssentialProjectEAM_LinuxCLI-master/jetty.properties /opt/webswing/
  
  #UPDATE webswing.config to add Protege
  cp EssentialProjectEAM_LinuxCLI-master/webswing.config /opt/webswing/
  
  cecho BIGreen "Copying protege logo to webswing directory"
  cp EssentialProjectEAM_LinuxCLI-master/protege_logo.png /opt/webswing/
  
  cecho BIGreen "Copying webswing service file and auto starting"
  systemctl disable webswing.service 2> /dev/null
  systemctl stop webswing.service 2> /dev/null
  cp EssentialProjectEAM_LinuxCLI-master/webswing.service /etc/systemd/system/
  systemctl daemon-reload 2> /dev/null
  systemctl enable webswing.service 2> /dev/null
  
  cecho BIPurple "Starting Webswing"
  systemctl start webswing.service 2> /dev/null
fi

cecho BIGreen "Give group 'protegeusers' access to the user folder in the viewer (to allow uploads for branding etc.)"
sleep 5 #to give tomcat enough time to unpack the war files above
chgrp -R protegeusers /opt/tomcat/webapps/essential_viewer/user
chgrp -R protegeusers /opt/tomcat/webapps/essential_viewer_dev/user
chgrp -R protegeusers /opt/tomcat/webapps/essential_viewer_test/user
#Make sure the group can search and write to the full path
chmod -R 775 /opt

# Clean up
rm *.ENV 2> /dev/null
#rm ./install_protege_3.5.bin
#rm ./$(cat ./WIDGETS_VERSION.ENV)
#rm ./$(cat ./MODEL_VERSION.ENV)
#rm ./$(cat ./VIEWER_VERSION.ENV)
#rm ./$(cat ./IMPORT_VERSION.ENV)
apt-get -qq autoremove -y

cecho BIGreen "ALL DONE!"
