#!/usr/bin/env bash
# ==============================================================================
# JFRsec - macOS Sonoma 14 Security Sandbox Launch Script
# Bare-Metal KVM/QEMU Hypervisor Deployment on Ubuntu LTS
# ==============================================================================

set -euo pipefail

# Hypervisor allocation
RAM=7168
SMP="4,cores=4"
CPU="Penryn,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,kvm=on"
MACHINE="q35"

# Storage & Firmware Paths
OVMF_CODE="/usr/share/OVMF/OVMF_CODE.fd"
OVMF_VARS="/usr/share/OVMF/OVMF_VARS-1024x768.fd"
OPENCORE_IMG="OpenCore.qcow2"
MAC_HDD="mac_hdd_ng.img"

# OSK key for Apple SMC cryptographic validation
OSK="ourhardworkbythesewordsguardedpleasedontsteal"

echo "[*] Initializing macOS Sonoma 14 sandbox under KVM..."

exec qemu-system-x86_64 \
    -enable-kvm -m "$RAM" -smp "$SMP" \
    -cpu $CPU \
    -machine "$MACHINE" -smbios type=2 \
    -device isa-applesmc,osk="$OSK" \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -device ich9-intel-hda -device hda-duplex \
    -device ich9-ahci,id=sata \
    -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$OPENCORE_IMG" \
    -device ide-hd,bus=sata.2,drive=OpenCoreBoot \
    -drive id=MacHDD,if=none,file="$MAC_HDD",format=qcow2 \
    -device ide-hd,bus=sata.4,drive=MacHDD \
    -netdev user,id=net0 -device vmxnet3,netdev=net0,id=net0

# Storage: mac_hdd_ng.img - 64GB APFS, thin-provisioned qcow2 backing file
# SMC: osk key injected via isa-applesmc for Apple firmware validation
