#!/bin/bash

export SERVICE_ENDPOINT=`utils/openstack-config-get /etc/openstack/openstack.conf identity endpoint --default http://127.0.0.1:35357/v2.0/`
export SERVICE_TOKEN=`utils/openstack-config-get /etc/openstack/openstack.conf secrets identity_service_token`

SERVICE_TENANT_NAME=`utils/openstack-config-get /etc/openstack/openstack.conf secrets service_tenant_name --default services`

keystone tenant-create --name ${SERVICE_TENANT_NAME}

# Default roles
keystone role-create --name=admin
keystone role-create --name=KeystoneAdmin
keystone role-create --name=KeystoneServiceAdmin

#keystone tenant-create --name admin
#keystone user-create --name=admin --pass=supersecret
#keystone user-role-add --user admin --role admin --tenant_id admin --byname true

# Configure service users/roles
NOVA_SERVICE_USERNAME=`utils/openstack-config-get /etc/openstack/openstack.conf secrets compute_service_username --default nova`
NOVA_SERVICE_PASSWORD=`utils/openstack-config-get /etc/openstack/openstack.conf secrets compute_service_password`
keystone user-create --name=$NOVA_SERVICE_USERNAME --pass="$NOVA_SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT_NAME --byname true
keystone user-role-add --tenant_id $SERVICE_TENANT_NAME --user $NOVA_SERVICE_USERNAME --role admin --byname true

GLANCE_SERVICE_USERNAME=`utils/openstack-config-get /etc/openstack/openstack.conf secrets compute_service_username --default glance`
GLANCE_SERVICE_PASSWORD=`utils/openstack-config-get /etc/openstack/openstack.conf secrets compute_service_password`
keystone user-create --name=$GLANCE_SERVICE_USERNAME --pass="$GLANCE_SERVICE_PASSWORD" --tenant_id $SERVICE_TENANT_NAME --byname true
keystone user-role-add --tenant_id $SERVICE_TENANT_NAME --user $GLANCE_SERVICE_USERNAME --role admin --byname true

