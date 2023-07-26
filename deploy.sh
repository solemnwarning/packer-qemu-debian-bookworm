#!/bin/bash

BUILDS="/mnt/builds"

set -e

packer build packer-qemu-debian-bookworm.pkr.hcl

version=$(date --utc '+%Y%m%d%H%M%S')

mkdir -p "${BUILDS}/qemu-debian-bookworm/"
cp -a "output" "${BUILDS}/qemu-debian-bookworm/qemu-debian-bookworm-${version}"
ln -sfn "qemu-debian-bookworm-${version}" "${BUILDS}/qemu-debian-bookworm/latest"
