#!/bin/bash

N_VM=$1
RECREATE=$2

for i in $(seq $N_VM $V_VM) ; do
  VMID=$((100 + i))
  NAME="cluster-$i"
  IP="192.168.1.$VMID"

  if [[ $RECREATE == 1 ]] && qm status $VMID &>/dev/null; then
    qm stop $VMID
    qm destroy $VMID
  fi

  if ! qm status $VMID &>/dev/null; then
    qm clone 100 $VMID --name $NAME --full 0
    qm set $VMID --ipconfig0 ip=$IP/24,gw=192.168.1.254
    qm start $VMID
  fi
done