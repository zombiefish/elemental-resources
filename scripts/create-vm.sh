#!/bin/bash

sudo virt-install \
  -n elemental-1 \
  --description "Test VM with Elemental" \
  --os-variant=slem5.0 \
  --ram=8192 \
  --vcpus=2 \
  --disk path=/var/lib/libvirt/images/elemenatal-1.img,bus=virtio,size=40 \
  --cdrom /export/iso/test-2025-03-12T14_09_04Z.iso \
  --network default


exit
  --graphics none \
