#!/bin/bash

. load-secrets

pushd /opt/openstack/nova
PYTHONPATH=/opt/openstack/python-novaclient/:/opt/openstack/glance/ bin/nova-manage --conf /var/openstack/compute/compute.conf db  sync 
popd

pushd /opt/openstack/keystone
bin/keystone-manage --conf /var/openstack/identity/keystone.conf db_sync
popd
