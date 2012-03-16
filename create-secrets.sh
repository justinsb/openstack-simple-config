#!/bin/bash

FILE=/etc/openstack/secrets

touch ${FILE}

for k in SERVICE_PASSWORD DB_PASSWORD RABBIT_PASSWORD
do
	grep ${k} ${CONF} || PW=`pwgen 12 1`; echo "${k}=${PW}" >> ${CONF}
done
 
