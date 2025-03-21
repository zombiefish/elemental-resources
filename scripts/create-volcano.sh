#!/bin/bash

: ${CP:=1}
: ${WRK:=1}
: ${ISO:="fire-nodes-2025-03-20T12_08_23Z.iso"}
IMG=/export/iso/$ISO

VM_PREFIX="cp-"  \
  VM_NETWORK=default \
  NUMOFVMS=$CP \
  VM_CORES=4 \
  VM_MEMORY=8192 \
  ./elemental-create.sh $IMG

VM_PREFIX="wrk-" \
  VM_NETWORK=default \
  NUMOFVMS=$WRK \
  VM_CORES=2 \
  VM_MEMORY=4096 \
  VM_DISKSIZE=50 \
  ./elemental-create.sh $IMG
