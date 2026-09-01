# LAB-VBX-004 - OVF/OVA Portability Final Audit

- Generated: 2026-09-01T19:06:37+02:00
- Assessment: **PASS**
- VirtualBox host: 7.2.16r174877
- Source VM: LAB-VBOX-LINUX-002

## Source VM

- UUID: bba7a2a5-4c7f-4768-97b6-10116bc70db7
- MAC: 0800275BF507
- State: powered off (since 2026-09-01T16:35:34.000000000)
- Final NIC 1: MAC: 0800275BF507, Attachment: NAT, Cable connected: on, Trace: off (file: none), Type: 82540EM, Reported speed: 0 Mbps, Boot priority: 0, Promisc Policy: deny, Bandwidth group: none

## OVF export

Files:

- LAB-VBOX-LINUX-002.ovf
  - size: 9409 bytes
  - SHA256: 0C144B2266D416C40C990DAC8FD89888D97558B406A360D30D107CFE5F688C42

- LAB-VBOX-LINUX-002.nvram
  - size: 540672 bytes
  - SHA256: 92453CA3FC81A14842C52F9AA43A15D9FF098D8DCD60B9DCA41E49D78491773F

- LAB-VBOX-LINUX-002-disk001.vmdk
  - size: 2861458944 bytes
  - SHA256: 019FEE97CE550BA2F5C10272A224EA76B7FC6CB67E5FE8B550A479B94277AF2E

Validated OVF properties:

- OVF 2.0: True
- Debian13_64: True
- 2 vCPU: True
- 4096 MB RAM: True
- NAT network: True
- EFI NVRAM referenced: True
- VMDK referenced: True
- VMDK streamOptimized: True

## OVA export

File:

- LAB-VBOX-LINUX-002.ova
  - size: 2862342656 bytes
  - SHA256: 820DF2640873E465B848C6AE448AD01701F96D1BBC562586E9E778D6CDEEBA22

OVA archive members:

- LAB-VBOX-LINUX-002.ovf
- LAB-VBOX-LINUX-002.nvram
- LAB-VBOX-LINUX-002-disk001.vmdk

## Import validation

Imported test VM:

LAB-VBOX-IMPORT-001

Observed VirtualBox identity:

- imported UUID: 3f62e30c-b613-4288-8a54-2019a3e50c13
- imported MAC: 080027C0AD50
- source UUID different: True
- source MAC different: True

Imported storage:

- disk format: VMDK
- snapshots transferred: no
- snapshot count after import: 0

Imported guest validation:

- hostname: lab-vbox-linux-002
- machine-id: 1599dc63e73b4d5ebabf6736063adb04
- Guest Additions: 7.2.14r174565
- failed systemd units: 0
- NAT IPv4 observed: 10.0.2.15/24
- default gateway observed: 10.0.2.2

SSH host key fingerprint:

SHA256:/EfLcwLzAqGfjH47GgeqLOrQavKkZ6uw2NOsym3qlBk

The fingerprint was identical on the source and imported guest.

## Identity conclusion

The appliance import created a new VirtualBox identity:

- new VM UUID;
- new MAC address.

The operating-system identity remained preserved:

- hostname preserved;
- machine-id preserved;
- SSH host keys preserved.

Therefore an imported appliance should not automatically be assumed
safe for simultaneous operation beside its source without guest
identity regeneration.

## Snapshot conclusion

VirtualBox snapshots were not exported as a snapshot tree.

The imported appliance represented a flattened portable machine state
with an independent base VMDK.

## Cleanup

- LAB-VBOX-IMPORT-001 unregistered: True
- imported VM files deleted: True
- OVF/OVA export artifacts retained on E:
- source VM retained unchanged

## Validation checks

- VirtualBoxVersionAtLeastBaseline: True
- SourceVMRegistered: True
- SourceVMPoweredOff: True
- SourceBaselineNAT: True
- OVFPresent: True
- VMDKPresent: True
- NVRAMPresent: True
- OVAPresent: True
- OVFVersion20: True
- OVFDebian13: True
- OVFCPU2: True
- OVFMemory4096: True
- OVFNetworkNAT: True
- OVFReferencesVMDK: True
- OVFReferencesNVRAM: True
- VMDKStreamOptimized: True
- OVAContainsOVF: True
- OVAContainsVMDK: True
- OVAContainsNVRAM: True
- ImportedUUIDDifferent: True
- ImportedMACDifferent: True
- ImportedNoSnapshots: True
- ImportedDiskVMDK: True
- GuestHostnamePreserved: True
- GuestMachineIdPreserved: True
- SSHHostKeyPreserved: True
- GuestAdditionsOperational: True
- ImportedVMRemoved: True
- ImportedVMFolderRemoved: True

## Assessment

**PASS**
