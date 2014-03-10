sudo su -

yum install -y puppet git

git clone https://github.com/robsweet/aminator_demo.git

/usr/bin/puppet apply --modulepath=${HOME}/aminator_demo/modules -e 'include aminator'