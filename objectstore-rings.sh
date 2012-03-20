# TODO: Should this be /var/openstack/objectstore/rings??
cd /var/openstack/objectstore/config

# We create with REPLICAS=1 so this works on a single-node
# We can grow from here using this patch: https://review.openstack.org/#change,5484
# Note that it isn't clear that this patch will be accepted - certainly not in Essex
REPLICAS=1

swift-ring-builder account.builder create 18 ${REPLICAS} 1
swift-ring-builder container.builder create 18 ${REPLICAS} 1
swift-ring-builder object.builder create 18 ${REPLICAS} 1

# Show rings
swift-ring-builder account.builder
swift-ring-builder container.builder
swift-ring-builder object.builder

export ZONE=1                    # set the zone number for that storage device
export STORAGE_LOCAL_NET_IP=192.168.90.1    # and the IP address
export WEIGHT=100               # relative weight (higher for bigger/faster disks)
export DEVICE=sdb1
swift-ring-builder account.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6002/$DEVICE $WEIGHT
swift-ring-builder container.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6001/$DEVICE $WEIGHT
swift-ring-builder object.builder add z$ZONE-$STORAGE_LOCAL_NET_IP:6000/$DEVICE $WEIGHT

# Show rings
swift-ring-builder account.builder
swift-ring-builder container.builder
swift-ring-builder object.builder


swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance

# Show rings
swift-ring-builder account.builder
swift-ring-builder container.builder
swift-ring-builder object.builder


