#!/bin/bash

: ${REL:=2.10}

curl -sL https://raw.githubusercontent.com/rancher/kontainer-driver-metadata/release-v$REL/data/data.json | jq -r '.rke2.releases[].version'
