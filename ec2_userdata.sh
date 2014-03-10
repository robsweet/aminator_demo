#!/bin/bash

export FACTER_special_guest='Charlie Chaplin'

export FACTER_launchconfig=true 

/usr/bin/puppet apply --logdest /var/log/puppet_launchconfig --debug --verbose -e 'include web_server'\n",