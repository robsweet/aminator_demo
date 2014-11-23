#!/bin/bash

# Amazon Linux PVM
AWS_FOUNDATION_AMI_ID=ami-246ed34c


PUPPET_ENV_VARS="FACTER_event='AWS Atlanta Aminator Demo'"

PUPPET_CLASS='web_server'


tar -czvf manifests.tgz modules
tar -czvf hieradata.tgz hiera.yaml hieradata/

echo "************************************************************************************************************************************"

sudo /usr/bin/aminate --debug --name $(date +%Y.%m.%d.%H.%M) -B ${AWS_FOUNDATION_AMI_ID} --preserve-on-error \
	-e ec2_puppet_redhat \
	--puppet-env-vars="${PUPPET_ENV_VARS}" \
	--puppet-args="-e 'include ${PUPPET_CLASS}'" \
	--puppet-hieradata hieradata.tgz \
	--puppet-install-cmd "yum install -y rubygems && gem install puppet -v '>=3.1' && ln -s /usr/local/bin/puppet /usr/bin/puppet" \
	manifests.tgz | tee aminator.log

AMI_ID=$(grep ' id: ami-' aminator.log | awk '{ print $5 }')

if [ -z "$AMI_ID" ]; then exit 1; fi

echo "************************************************************************************************************************************"

echo AMI_ID=$AMI_ID > AMI_ID
