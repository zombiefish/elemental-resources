#!/bin/bash

ISO=$(kubectl -n fleet-default get seedimages.elemental.cattle.io fire  -o json | jq -r '(. |  .status.downloadURL)')

curl --remote-name --remote-header-name --location $ISO
