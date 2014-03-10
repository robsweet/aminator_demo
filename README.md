Aminating for Fun and Profit
============================

This demo is designed for use with *Amazon Linux* (AFAIK, a derivative of CentOS).  It would probably work with other distros with minimal work like changing package names and binary paths.

We've basically got three steps to do:

0. Build an Aminator box
1. Make a new AMI with Aminator
2. Launch a new EC2 instance with our new AMI

#  Building a Box to Aminate With #
**Note:**  I've provided a script [here](https://github.com/robsweet/aminator_demo/blob/master/aminator_bootstrap.sh) to speed up the bootstrapping process.  I'm using a simple Puppet manifest to do the install.  Repeatable process FTW!

0. Start up a new Amazon Linux EC2 Instance to run Aminator on
 
    * Make sure the instance's Security Group allows SSH

    * Make sure the instance has an IAM role with a policy at least as permissive as [this example](https://github.com/Netflix/aminator/wiki/Configuration#sample-policy) from NetFlix
    
    * Make sure the instance will be able to get to the public Internet
    
    * Make sure you specify an SSH keypair for the box
    
0. SSH to the box

0. sudo su -

0. yum install -y puppet git

0. git clone https://github.com/robsweet/aminator_demo.git

0. /usr/bin/puppet apply --modulepath=${HOME}/aminator_demo/modules -e 'include aminator'

**At this point, you should have a running box that can build AMIs with Aminator.**


#  Let's Aminate! #

We'll be using the Puppet provisioner plugin for Aminator to build our AMI and we're going to run Puppet in 'Masterless' mode (just using the manifests in this repo).  The Aminating process would work similarly with Chef, which also works with Aminator right out of the box.

The web_server Puppet module that we'll be telling Puppet to use can be found in this repo.  [Here's a link](https://github.com/robsweet/aminator_demo/blob/master/modules/web_server/manifests/init.pp) directly to the main class.

I've create [a simple wrapper](https://github.com/robsweet/aminator_demo/blob/master/aminate.sh) to run Aminator with the appropriate options.  As you can see, I'm also passing an arbitrary Facter fact to Puppet in the arguments and telling Puppet what class to use.  

The script also makes a tarball of our Puppet modules and passes that to the Aminator.  The tarball gets expanded into /etc/puppet/modules on the new disk image by the Puppet plugin.  These manifests will be available when the new AMI boots too, allowing us to do a 'launchconfig' Puppet run when an instance comes up using the new AMI box- or environment-specific config before services start.

**After running the aminate.sh script, you should end up with a brand new AMI that has Apache2, PHP 5.5, and a simple index.php file.**


# Using our New AMI #

Now we can launch an EC2 instance with our new AMI.  In the EC2 console, go to My AMIs, find the AMI that we just created, and start the Launch wizard.

- On **Step 3: Configure Instance Details**, open the **Advanced Details** section at the bottom and paste in the script [here](https://github.com/robsweet/aminator_demo/blob/master/ec2_userdata.sh).  This will pass a shell script to the new instance via the Userdata mechanism that will do the 'launchconfig' Puppet run to do post-Aminator config that we don't want as part of our generic AMI.  To illustrate the point, change the value of the **FACTER_special_guest** variable in the script to something else.
 
- Make sure the instance is in a Security Group and Subnet that will allow connections from your workstation to port 80 on the instance.
 
- Launch the instance!
 
**When the instance boots, you should be able to go to the IP of the new instance in your browser and see the demo page.  Note that the page shows the Special Guest that you specified in the FACTER_special_guest variable that was passed to Puppet.**
