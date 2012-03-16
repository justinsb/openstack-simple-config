#!/bin/bash 

. load-conf

mkdir -p /var/openstack/imagestore/conf

cp /opt/openstack/glance/etc/* /var/openstack/imagestore/conf/
# policy.json has to be in /etc/glance
# TODO: Fix this suckage
mkdir -p /etc/glance
cp /opt/openstack/glance/etc/policy.json /etc/glance/policy.json

sed -i 's/\/var\/log\/glance/\/var\/log\/openstack\/imagestore/g' /var/openstack/imagestore/conf/glance-api.conf
sed -i 's/\/var\/log\/glance/\/var\/log\/openstack\/imagestore/g' /var/openstack/imagestore/conf/glance-registry.conf

# Modified from devstack
    function glance_config {
        sed -e "
            s,%SERVICE_TENANT_NAME%,$SERVICE_TENANT_NAME,g;
            s,%SERVICE_USER%,glance,g;
            s,%SERVICE_PASSWORD%,$SERVICE_PASSWORD,g;
        " -i $1
    }

glance_config /var/openstack/imagestore/conf/glance-api.conf
glance_config /var/openstack/imagestore/conf/glance-api-paste.ini
glance_config /var/openstack/imagestore/conf/glance-registry.conf
glance_config /var/openstack/imagestore/conf/glance-registry-paste.ini

cat > /var/openstack/imagestore/conf/glance-api.conf << EOF
[paste_deploy]
flavor = keystone
EOF

cat > /var/openstack/imagestore/conf/glance-registry.conf << EOF
[paste_deploy]
flavor = keystone
EOF


mkdir -p /var/openstack/identity

DB_IDENTITY="postgresql://keystone:${DB_PASSWORD}@localhost/keystone"

cp /opt/openstack/keystone/etc/keystone.conf /var/openstack/identity/
cp /opt/openstack/keystone/etc/default_catalog.templates /var/openstack/identity/
cp /opt/openstack/keystone/etc/policy.json /var/openstack/identity

sed -i 's/connection = sqlite/#connection = sqlite/g' /var/openstack/identity/keystone.conf 
sed -i "/^\[sql\]/a connection = ${DB_IDENTITY}"  /var/openstack/identity/keystone.conf

sed -i 's/\.\/etc\/default_catalog\.templates/\/var\/openstack\/identity\/default_catalog\.templates/g' /var/openstack/identity/keystone.conf

sed -i "s/localhost/${HEAD_IP}/g" /var/openstack/identity/default_catalog.templates

mkdir -p /var/openstack/compute

cp /opt/openstack/nova/etc/nova/api-paste.ini /var/openstack/compute/

#admin_tenant_name = %SERVICE_TENANT_NAME%
#admin_user = %SERVICE_USER%
#admin_password = %SERVICE_PASSWORD%


sed -e "
        /admin_tenant_name/s/^.*$/admin_tenant_name = $SERVICE_TENANT_NAME/;
	/admin_user/s/^.*$/admin_user = nova/;
        /admin_password/s/^.*$/admin_password = $SERVICE_PASSWORD/;
        " -i /var/openstack/compute/api-paste.ini

echo "MY_IP=${MY_IP}"

cat > /var/openstack/compute/compute.conf << EOF
[DEFAULT]
verbose=True
instances_path=/var/openstack/compute/instances
auth_strategy=keystone
allow_resize_to_same_host=True
root_helper=sudo /opt/openstack/nova/bin/nova-rootwrap
compute_scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler
dhcpbridge_flagfile=/etc/nova/nova.conf
fixed_range=${NETWORK}/${NETWORK_SIZE}
s3_host=${HEAD_IP}
network_manager=nova.network.manager.FlatManager
volume_group=nova-volumes
volume_name_template=volume-%08x
iscsi_helper=tgtadm
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
my_ip=${MY_IP}
public_interface=br100
vlan_interface=${NETWORK_INTERFACE}
flat_network_bridge=br100
flat_interface=${NETWORK_INTERFACE}
sql_connection=postgresql://nova:${DB_PASSWORD}@localhost/nova
libvirt_type=kvm
instance_name_template=instance-%08x
novncproxy_base_url=http://${HEAD_IP}:6080/vnc_auto.html
xvpvncproxy_base_url=http://${HEAD_IP}:6081/console
vncserver_listen=127.0.0.1
vncserver_proxyclient_address=127.0.0.1
api_paste_config=/var/openstack/compute/api-paste.ini
image_service=nova.image.glance.GlanceImageService
ec2_dmz_host=${HEAD_IP}
rabbit_host=localhost
rabbit_password=${RABBIT_PASSWORD}
glance_api_servers=${HEAD_IP}:9292
force_dhcp_release=True
flat_injected=True
connection_type=libvirt
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
EOF

