Installing the head node
=========================

We'll install everything on one node - the head node - first...

Carve up the network
--------------------

*) Assume the full network range is 192.168.0.0/16
*) Allocate 192.168.192.0/18 to virtual machines
*) Allocate 192.168.191.0/24 to host machines

Configure everything
--------------------

```bash

bin/code-get

export HEAD_IP=192.168.191.1
export NETWORK_RANGE=192.168.0.0/16
export CLOUD_RANGE=192.168.192.0/18
export NETWORK_INTERFACE=eth0
export NETWORK_GATEWAY=192.168.1.1

bin/cloud-create 

bin/ring-create ${HEAD_IP}

Configure the network on the first node
---------------------------------------
```bash
CLOUD_IP=${HEAD_IP}
CURRENT_IP=${HEAD_IP} # Change if e.g. the machine doesn't yet have the correct IP

bin/network-preview ${CLOUD_IP}
bin/network-apply ${CLOUD_IP} ${CURRENT_IP}
```

Apply the configuration to the node
-----------------------------------
```bash
bin/node-update ${HEAD_IP}
```

Create system users etc
-----------------------
```bash
bin/cloud-initialize
```

Create a user
=============

```bash

USER=`whoami`
TENANT="privatecloud"
PASS="secret"
bin/user-create ${USER} ${TENANT} ${PASS}

```

Installing additional nodes
===========================

```bash

CLOUD_IP=192.168.191.2

bin/node-create ${CLOUD_IP}

bin/network-preview ${CLOUD_IP}

CURRENT_IP=${CLOUD_IP} # Change if the node doesn't yet have the desired IP
bin/network-apply ${CLOUD_IP} ${CURRENT_IP}


bin/node-role-add ${CLOUD_IP} compute
bin/node-update ${CLOUD_IP}

bin/node-role-add ${CLOUD_IP} objectstore
bin/node-update ${CLOUD_IP}

```