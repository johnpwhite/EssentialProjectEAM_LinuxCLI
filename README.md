# EssentialProjectEAM_LinuxCLI
Scripts to support installing all components on a clean server install of Ubuntu.

Assumes: You have created an Unbuntu Server 20.04 instance, with a host name of ubuntutemplate, and a user called john

To install:

1) wget https://raw.githubusercontent.com/johnpwhite/EssentialProjectEAM_LinuxCLI/master/install_EAM.sh

2) chmod 777 install_EAM.sh

3) ./install_EAM.sh


4a) Install the client on your desktop following this https://enterprise-architecture.org/docs/essential_os_installation/multiuser_install/#client

or
4b) Run the client on the server and access via X11 (faster!)

1) Install VcXsrv
2) run /opt/Protege_3.5/run_protege.sh with user john

5) Connect via other using:

host: ubuntutemplate:5100
user: Admin
pass: Admin
