#!/bin/bash

FILE=/etc/openstack/openstack.conf

touch ${FILE}

for k in db_password_compute db_password_identity rabbitmq_password identity_service_token
do
	utils/openstack-config-get --create ${FILE} secrets ${k}
done
 
