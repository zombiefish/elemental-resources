#!/bin/bash

VM_PREFIX="cp-"  VM_NETWORK=default NUMOFVMS=3 VM_CORES=4 VM_MEMORY=8192                ./elemental-create.sh /export/iso/fire-nodes-2025-03-14T13_48_54Z.iso
sleep 5

VM_PREFIX="wrk-" VM_NETWORK=default NUMOFVMS=3 VM_CORES=2 VM_MEMORY=4096 VM_DISKSIZE=50 ./elemental-create.sh /export/iso/fire-nodes-2025-03-14T13_48_54Z.iso
