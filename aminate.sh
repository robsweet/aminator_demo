#!/bin/bash

AWS_FOUNDATION_AMI_ID=ami-35792c5c

PUPPET_ENV_VARS="FACTER_event='AWS Atlanta Aminator Demo'"

PUPPET_CLASS='web_server'



tar -czvf manifests.tgz modules

echo "************************************************************************************************************************************"

sudo /usr/bin/aminate --debug --name $(date +%Y.%m.%d.%H.%M) -B ${AWS_FOUNDATION_AMI_ID} --preserve-on-error \
	--puppet-env-vars="${PUPPET_ENV_VARS}" \
	--puppet-args="-e 'include ${PUPPET_CLASS}'" \
	manifests.tgz | tee aminator.log

AMI_ID=$(grep ' id: ami-' ${WORKSPACE}/aminator.log | awk '{ print $5 }')

if [ -z "$AMI_ID" ]; then exit 1; fi

echo "************************************************************************************************************************************"

echo AMI_ID=$AMI_ID > AMI_ID