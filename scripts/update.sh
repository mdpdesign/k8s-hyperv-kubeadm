#!/usr/bin/env bash

set -euxo pipefail

: "=== Install packages updates and newer kernel ==="
apt-get update && apt-get -y upgrade
apt-get install -y python3-pip && pip3 install ansible
apt-get install -y linux-image-generic-hwe-22.04 linux-cloud-tools-generic-hwe-22.04

: "=== Reboot system ==="
# Reboot will be done by vagrant
# [[ -f /var/run/reboot-required || -f /var/run/reboot-required.pkgs ]] && systemctl reboot
