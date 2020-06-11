# EssentialProjectEAM_LinuxCLI
Scripts to support installing all components on a clean server install of Ubuntu.

NOTE: This creates a multi-user environment, and pre-loads the 6.10 models directly in MySQL, it can download the latest models (project files), but doesn't automate deploying them in the database as you need to do this through the protege UI, so i did this manually, then exported the DB to script re-loading it in a clean instance.

I'm thinking as v6.11, v6.12 and so on comes out, you just create your v6.10 instance from this, then apply the eup(?) packs from here:
https://enterprise-architecture.org/update_packs.php

NOTE: The security posture of this is very low, it assumes you are using this to test the product and that you'll harden it for a production like instance. For instance user/passwords are very basic or passwords not required etc.

Assumes: You have created an Unbuntu Server 20.04 instance

To install:

1) wget https://raw.githubusercontent.com/johnpwhite/EssentialProjectEAM_LinuxCLI/master/install.sh

2) chmod 777 install.sh

3) Check the variables at top of script:

nano install.sh

4) ./install.sh

5a) Install the client on your desktop following this https://enterprise-architecture.org/docs/essential_os_installation/multiuser_install/#client

or

5b) Run the client on the server and access via X11 (faster!)
    a) Install VcXsrv
    b) run /opt/Protege_3.5/run_protege.sh with user john (or what ever admin account you created when installing ubuntu)

6) Connect via protege 'open server connection' using:
    host: ubuntutemplate:5100
    user: Admin
    pass: Admin
