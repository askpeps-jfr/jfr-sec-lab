# JFRsec Virtualization Range & Security Sandbox

A self-hosted, quarantined bare-metal laboratory engineered for defensive security baselining, threat modeling, active directory hardening, and offensive security verification.

---

## 1. Physical Hardware & Hypervisor Architecture

The lab operates on dedicated physical hardware decoupled from domestic and production networks.

* **Bare-Metal Host:** Dell Latitude E7270 (Intel Core i7, 16 GB DDR4 RAM, 512 GB NVMe SSD)
* **Host Operating System:** Ubuntu Linux LTS (Minimal Server / Kernel-level KVM)
* **Hypervisor Stack:** Linux KVM (Kernel-based Virtual Machine) + QEMU + `virt-manager` / `virsh` CLI
* **Network Isolation:** ASUS GS-BE18000 Managed Switch — Tagged 802.1Q VLAN 53 (`192.168.50.0/24`)
* **Internet Boundary:** Disabled / Quarantined. Lab VMs communicate exclusively via an isolated virtual bridge (`virbr53`) with no forwarding to the physical LAN interface.

---

## 2. Virtual Environment Inventory

+-------------------------------------------------------------------------------+
|                       ISOLATED VLAN 53 (192.168.50.0/24)                      |
|                                                                               |
|  +--------------------+     +--------------------+     +-------------------+  |
|  | Windows Server 22  |     |  macOS Sonoma 14   |     |    Kali Linux     |  |
|  | Domain Controller  |     |  Endpoint Sandbox  |     |  Offensive Node   |  |
|  |  192.168.50.10     |     |  192.168.50.20     |     |  192.168.50.30    |  |
|  +--------------------+     +--------------------+     +-------------------+  |
+-------------------------------------------------------------------------------+

### Node 01: Enterprise Domain Controller (`W2K22`)
* **Role:** Active Directory Domain Services (AD DS), DNS, Kerberos Key Distribution Center (KDC)
* **Domain:** `an.local`
* **Hardening Objectives:**
  * Enforce GPO baselines: SMBv1 decommissioned, mandatory SMB signing enabled.
  * Mitigation of NetNTLM relay: LLMNR disabled, NetBIOS over TCP/IP stripped.
  * Account policies: 14-character minimum length, 24-password history retention, Kerberos AES-256 enforcement.

### Node 02: macOS Sonoma 14 Security Sandbox
* **Role:** Non-Windows endpoint attack surface evaluation and malware triage.
* **Emulation Architecture:** QEMU `q35` machine type, Intel Penryn CPU flags with `invtsc` passthrough.
* **Firmware & Storage:** OVMF UEFI firmware, OpenCore bootloader, Apple OSK string injection via `isa-applesmc`, APFS thin-provisioned `qcow2` storage.

### Node 03: Kali Linux Offensive Platform
* **Role:** Automated vulnerability discovery, protocol auditing, and compliance verification.
* **Tooling:** Nmap (custom NSE automation), Impacket, NetExec, Wireshark, BloodHound CE.

---

## 3. Repository Structure

.
├── README.md
├── scripts/
│   ├── gpo-hardening-baseline.ps1    # PowerShell script enforcing AD DC GPO baselines
│   └── launch-sonoma.sh              # QEMU/KVM startup script for macOS Sonoma 14
└── logs/
└── smb-protocols-audit.log       # Nmap NSE protocol verification & remediation report

---

## 4. Verification & Audit Results

All configurations applied across the virtual environments are tested from the offensive node (`Kali`) to verify that hardening policies successfully eliminate legacy protocol exposure.

See `logs/smb-protocols-audit.log` for the validation output demonstrating complete mitigation of SMBv1 and mandatory message signing enforcement.
