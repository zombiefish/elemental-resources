curl -sL https://raw.githubusercontent.com/rancher/kontainer-driver-metadata/release-v2.10/data/data.json | jq -r '.rke2.releases[].version'
