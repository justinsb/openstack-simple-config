#!/bin/bash

set -e

. utils/common

# TODO: Should this be /var/openstack/objectstore/rings??
mkdir -p /var/openstack/objectstore/config
cd /var/openstack/objectstore/config

# We create with REPLICAS=1 so this works on a single-node
# We can grow from here using this patch: https://review.openstack.org/#change,5484
# Note that it isn't clear that this patch will be accepted - certainly not in Essex
REPLICAS=1

export PYTHONPATH=/opt/openstack/swift
RING_BUILDER=/opt/openstack/swift/bin/swift-ring-builder
${RING_BUILDER} account.builder create 18 ${REPLICAS} 1
${RING_BUILDER} container.builder create 18 ${REPLICAS} 1
${RING_BUILDER} object.builder create 18 ${REPLICAS} 1

# Show rings
${RING_BUILDER} account.builder
${RING_BUILDER} container.builder
${RING_BUILDER} object.builder

# Add first node to the rings
export ZONE=1
export STORAGE_LOCAL_NET_IP=${MY_IP}
export WEIGHT=100
export DEVICE=data1

${RING_BUILDER} account.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6002/$DEVICE $WEIGHT
${RING_BUILDER} container.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6001/$DEVICE $WEIGHT
${RING_BUILDER} object.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6000/$DEVICE $WEIGHT

# Show rings
${RING_BUILDER} account.builder
${RING_BUILDER} container.builder
${RING_BUILDER} object.builder

# "Compile" rings
${RING_BUILDER} account.builder rebalance
${RING_BUILDER} container.builder rebalance
${RING_BUILDER} object.builder rebalance

# Show rings
${RING_BUILDER} account.builder
${RING_BUILDER} container.builder
${RING_BUILDER} object.builder


