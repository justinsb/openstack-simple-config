#!/bin/bash

. load-secrets

export PYTHONPATH="/opt/openstack/python-novaclient/:/opt/openstack/glance/"

pushd /opt/openstack/nova
bin/nova-manage --conf /var/openstack/compute/compute.conf db sync 
popd

pushd /opt/openstack/keystone
bin/keystone-manage --conf /var/openstack/identity/identity.conf db_sync
popd
