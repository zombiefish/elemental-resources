#!/bin/bash

VIRSH="virsh --connect qemu:///system"

for DOMAIN in `$VIRSH list --title | awk '/elemental/ { print $2 }'`; do
  $VIRSH destroy $DOMAIN
  $VIRSH undefine --remove-all-storage --nvram --domain  ${DOMAIN}
done

for DOMAIN in `$VIRSH list --all --title | awk '/elemental/ { print $2 }'`; do
  $VIRSH undefine --remove-all-storage --nvram --domain  ${DOMAIN}
done
