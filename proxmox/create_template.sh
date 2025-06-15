#!/usr/bin/env bash

IMAGE="Rocky-9-GenericCloud.latest.x86_64.qcow2"
URL="https://dl.rockylinux.org/pub/rocky/9/images/x86_64/${IMAGE}"

TEMPLATE_ID=100
TEMPLATE_IP=192.168.1.100
TEMPLATE_CIDR=24
TEMPLATE_GW=192.168.1.254

if [ -f ${IMAGE}.CHECKSUM ]; then
  rm ${IMAGE}.CHECKSUM
fi
wget ${URL}.CHECKSUM

# if image does not exist or fails checksum, download it
if [ ! -f $IMAGE ] || ! $(sha256sum -c ${IMAGE}.CHECKSUM --status) ; then
  if [ -f $IMAGE ] ; then 
    rm $IMAGE
  fi
  wget $URL
fi

# checksum again and exit if it fails
if ! $(sha256sum -c ${IMAGE}.CHECKSUM --status) ; then
  echo "Image failed checksum"
  exit 1
fi

qm destroy $TEMPLATE_ID

qm create $TEMPLATE_ID \
 --name rocky-linux-9p6-cloud-init \
 --description "Rocky Linux 9.6 Cloud Init template" \
 --ostype l26 \
 --cpu cputype=host \
 --cores 1 \
 --sockets 1 \
 --memory 2048 \
 --scsihw virtio-scsi-pci \
 --net0 virtio,bridge=vmbr0

qm importdisk $TEMPLATE_ID $IMAGE local-lvm
qm set $TEMPLATE_ID --scsi0 local-lvm:vm-${TEMPLATE_ID}-disk-0
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --ide2 local-lvm:cloudinit

qm set $TEMPLATE_ID --sshkey ~/.ssh/authorized_keys
qm set $TEMPLATE_ID --ipconfig0 ip=${TEMPLATE_IP}/${TEMPLATE_CIDR},gw=${TEMPLATE_GW}
qm set $TEMPLATE_ID --ciupgrade 0 

qm start $TEMPLATE_ID

COMMAND='sudo dnf update -y ; sudo dnf install @Server @"Scientific Support" @"Development Tools" -y '
SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectionAttempts=10 -o ConnectTimeout=10"
echo $COMMAND | ssh $SSH_OPTIONS rocky@${TEMPLATE_IP}

qm shutdown $TEMPLATE_ID
qm template $TEMPLATE_ID
