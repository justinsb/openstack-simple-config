#!/bin/bash

. load-secrets

export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0/
export SERVICE_TOKEN=ADMIN

SERVICE_TENANT_NAME=services

keystone tenant-create --name admin
keystone tenant-create --name ${SERVICE_TENANT_NAME}

keystone user-create --name=admin --pass=supersecret

keystone role-create --name=admin
keystone role-create --name=KeystoneAdmin
keystone role-create --name=KeystoneServiceAdmin


keystone user-role-add --user admin --role admin --tenant_id admin --byname true


# Configure service users/roles
keystone user-create --name=nova \
                     --pass="$SERVICE_PASSWORD" \
                                        --tenant_id $SERVICE_TENANT_NAME --byname true

keystone user-role-add --tenant_id $SERVICE_TENANT_NAME --user nova --role admin --byname true

keystone user-create --name=glance \
                                          --pass="$SERVICE_PASSWORD" \
                                          --tenant_id $SERVICE_TENANT_NAME --byname true

keystone user-role-add --tenant_id $SERVICE_TENANT_NAME --user glance --role admin --byname true

