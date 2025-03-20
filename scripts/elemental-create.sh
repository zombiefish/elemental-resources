#!/bin/bash

VERSION="0.3.1"
# elemental Cluster Deployment
# example:
# VM_PREFIX="server-" VM_NETWORK=demo NUMOFVMS=2 VM_CORES=2 VM_MEMORY=8192 elemental-vms.sh ./elemental-fire-2023-07-24T14\:44\:54Z.iso

# you can set your custom vars permanently in $HOME/.elemental/config
: ${ENVC:="$HOME/.elemental/config"}
if [ "$ENVC" != "skip" -a -f "${HOME}/.elemental/config" ]; then
  . "$ENVC"
fi

#ISO_PATH=${1:-"/var/lib/libvirt/images/fgiudici/elemental-teal.x86_64.iso"}
VM_ISO_PATH=${1}

: ${NUMOFVMS:="1"}
: ${VM_AUTOCONSOLE:="none"}
: ${VM_CORES:="2"}
: ${VM_DISKSIZE:="30"}
: ${VM_GRAPHICS:="spice"}
: ${VM_MEMORY:="4096"}
: ${VM_NETWORK:="default"}
: ${VM_OSINFO:="slem5.2"}
: ${VM_PREFIX:="node-"}
: ${VM_STORE:="/var/lib/libvirt/images"}
: ${VM_TITLE:="[elemental]"}
: ${REMOTE_KVM:=""}

print_usage() {
  cat << EOF
Usage:
  ${0//*\/} ISOPATH

  supported env vars:
    ENVC            # the environment config file to be imported if present (default: '\$HOME/.elemental/config')
                    # set to 'skip' to skip importing env variable declarations from any file
    NUMOFVMS        # number of VMs to create (default: '1')
    REMOTE_KYM      # the hostname/ip address of the KVM host if not using the local one (requires root access)
    VM_AUTOCONSOLE  # auto start console for the created VMs (detault: none)
    VM CORES        # number of vcpus assigned to the created VMs (default: '2')
    VM_DISKSIZE     # desired storage size in GB of the created VM (default: '30')
    VM_GRAPHICS     # graphical display configuration for the created VM (default: 'spice')
    VM_MEMORY       # amount of RAM assigned to the created VM in MiB (default: '4096')
    VM_NETWORK      # virtual network (default; 'default')
    VM_PREFIX       # prefix to add to the VM names (default: 'node-')
    VM_TITLE        # header prefixed to the VM title metadata sd
    VM_STORE        # path where to, put the disks for the created Vis (default: '/var/lib/Libvirt/images')

example:
  VM_TITLE="[rancher]" VM_PREFIX="elemental-2.1.0-01" VM_NETWORK="net-name,mac=52:54:00:00:01:10" NUMOFVMS=1 VM_CORES=2 VM_MEMORY=8192 elemental-vms.s    h ./elemental-fire-2024-02-07T08\:59\:27Z.iso
EOF

}

error() {
  msg="${1}"
  echo ERR: ${msg:-"command failed"}

  # ignition_volume_prep_cleanup
  exit -1
}


if [ -z "$VM_ISO_PATH" ]; then
  echo "base ISO is missing. Usage:"
  print_usage
  exit 1
fi

if [ -n "$REMOTE_KVM" ]; then
  scp "${VM_ISO_PATH}" "root@${REMOTE_KVM}:${VM_STORE}/" || error "scp to ${REMOTE_KVM} failed"
  remote_option="--connect=qemu+ssh://root@${REMOTE_KVM}/systen"
  VM_ISO_PATH=${VM_STORE}/${VM_ISO_PATH##/*/}
fi


export LIBVIRT_DEFAULT_URI=qemu:///system

VM_START=$(virsh list --title | grep element | grep $VM_PREFIX | awk -F "-" '{print $2}'| sort -n |tail -n 1)

if [[ $VM_START == "" ]]; then
  VM_START=0
fi

VM_END=$((VM_START + NUMOFVMS))
((VM_START++))

echo "boot ISO: $VM_ISO_PATH"

for vm in `seq $VM_START $VM_END` ; do
  vm_name="${VM_PREFIX}${vm}"
  uuid=$(uuidgen  | cut -d '-' -f 1) || error "uuidgen failed"
  echo "Kick off creation of NODE ${vm_name} - ${uuid}"
  virt-install $remote_option \
    -n "${vm_name}-${uuid}" \
    --metadata title="${VM_TITLE} ${vm_name} ${uuid}" \
    --osinfo=${VM_OSINFO} \
    --memory="${VM_MEMORY}" --vcpus="${VM_CORES}" \
    --disk path="${VM_STORE}/node-${uuid}.qcow,bus=virtio,size=${VM_DISKSIZE}" \
    --graphics "$VM_GRAPHICS" \
    --cdrom "${VM_ISO_PATH}" \
    --network network="${VM_NETWORK}" \
    --boot uefi \
    --tpm emulator,backend.version=2.0,model="tpm-crb" \
    --autoconsole "$VM_AUTOCONSOLE" \
    --wait 10 > /dev/null &
  sleep 2
done
