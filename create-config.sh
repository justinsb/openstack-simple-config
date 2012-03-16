#!/bin/bash 

NETWORK=192.168.0.0
NETWORK_SIZE=16
NETWORK_NETMASK=255.255.0.0
HEAD_IP=192.168.100.1
NETWORK_INTERFACE=eth0
NETWORK_GATEWAY=192.168.1.1
BRIDGE_INTERFACE=br100

if [[ "$MY_IP" == "" ]]; then
	MY_IP=`/sbin/ifconfig ${NETWORK_INTERFACE} | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
fi

echo "MY_IP=${MY_IP}"

HEAD_IP=${HEAD_IP}

utils/openstack-config-set /etc/openstack/openstack.conf network head_node ${HEAD_IP}

utils/generate-secrets

DB_PASSWORD_COMPUTE=`utils/openstack-config-get /etc/openstack/openstack.conf secrets compute_db_password`
RABBIT_PASSWORD=`utils/openstack-config-get /etc/openstack/openstack.conf secrets rabbitmq_password`

# Build (template) compute specific config file
cat > /etc/openstack/compute.conf << EOF
[DEFAULT]
verbose=True
instances_path=/var/openstack/compute/instances
auth_strategy=keystone
allow_resize_to_same_host=True
root_helper=sudo /opt/openstack/nova/bin/nova-rootwrap
compute_scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler
dhcpbridge_flagfile=/etc/openstack/compute.conf
fixed_range=${NETWORK}/${NETWORK_SIZE}
s3_host=${HEAD_IP}
network_manager=nova.network.manager.FlatManager
volume_group=nova-volumes
volume_name_template=volume-%08x
iscsi_helper=tgtadm
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
my_ip=${MY_IP}
public_interface=${BRIDGE_INTERFACE}
vlan_interface=${NETWORK_INTERFACE}
flat_network_bridge=${BRIDGE_INTERFACE}
flat_interface=${NETWORK_INTERFACE}
sql_connection=postgresql://openstack_compute:${DB_PASSWORD_COMPUTE}@${HEAD_IP}/openstack_compute
libvirt_type=kvm
instance_name_template=instance-%08x
novncproxy_base_url=http://${HEAD_IP}:6080/vnc_auto.html
xvpvncproxy_base_url=http://${HEAD_IP}:6081/console
vncserver_listen=127.0.0.1
vncserver_proxyclient_address=127.0.0.1
api_paste_config=/var/openstack/compute/api-paste.ini
image_service=nova.image.glance.GlanceImageService
ec2_dmz_host=${HEAD_IP}
rabbit_host=${HEAD_IP}
rabbit_password=${RABBIT_PASSWORD}
glance_api_servers=${HEAD_IP}:9292
force_dhcp_release=True
flat_injected=True
connection_type=libvirt
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
EOF

# Build (template) compute specific config file
cat > /etc/openstack/network-interfaces.example << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${BRIDGE_INTERFACE}
iface ${BRIDGE_INTERFACE} inet static
        bridge_ports ${NETWORK_INTERFACE}
        bridge_stp off
        bridge_maxwait 0
        bridge_fd 0
        address ${MY_IP}
        netmask ${NETWORK_NETMASK}
        gateway ${NETWORK_GATEWAY}
EOF


