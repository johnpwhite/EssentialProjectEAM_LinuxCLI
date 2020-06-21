# EssentialProjectEAM_LinuxCLI
Scripts to support installing all components on a clean server install of Ubuntu.

NOTE: This creates a multi-user environment, and pre-loads the 6.10 models directly in MySQL, it can download the latest models (project files), but doesn't automate deploying them in the database as you need to do this through the protege UI, so i did this manually, then exported the DB to script re-loading it in a clean instance.

Apply the eup packs from here if there is a newer model file (it will tell you)
https://enterprise-architecture.org/update_packs.php

NOTE: The security posture of this is very low, it assumes you are using this to test the product and that you'll harden it for a production like instance. For instance user/passwords are very basic or passwords not required etc.

Assumes: You have created an Unbuntu Server 18.04 instance
To install:

1) wget https://raw.githubusercontent.com/johnpwhite/EssentialProjectEAM_LinuxCLI/master/install.sh

2) chmod 777 install.sh

3) Check the variables at top of script:

nano install.sh

4) ./install.sh

5) Browse to https://yourserver/protege (You'll get SSL errors, just ignore those)

6) Connect via protege 'open server connection' using:
    host: localhost:5100
    user: Admin
    pass: Admin
