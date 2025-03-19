#!/bin/bash

VIRSH="virsh --connect qemu:///system"

for DOMAIN in `$VIRSH list --title | awk '/elemental/ { print $2 }'x `; do
  $VIRSH destroy $DOMAIN
  $VIRSH undefine --remove-all-storage --nvram --domain  ${DOMAIN}
done
