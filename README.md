# packer-qemu-debian-bookworm

This repository contains scripts to build a fairly minimal Debian disk image under QEMU for deployment in cluster/cloud environments.

You can either extend the scripts here to tweak the image as you need, or use the output from here to build your own customised versions with separate Packer scripts (TODO: example).

This uses the [Packer QEMU Builder](https://developer.hashicorp.com/packer/plugins/builders/qemu) and is based on [packer-qemu-debian](https://github.com/multani/packer-qemu-debian) by Jonathan Ballet.
