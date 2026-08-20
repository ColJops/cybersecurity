# LAB-VBX-002 - Final Audit

- Generated: 2026-08-21T00:23:46+02:00
- Assessment: **REVIEW**

## VirtualBox host

- VBoxManage version: 7.2.16r174877
- VM name: LAB-VBOX-LINUX-001
- VM state: powered off (since 2026-08-20T22:12:37.782000000)
- Config file: D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001\LAB-VBOX-LINUX-001.vbox

## Guest baseline

- Guest type: Debian 13 Trixie (64-bit)
- Installed OS verified during lab: Debian GNU/Linux 13.6 (trixie)
- Kernel verified during lab: 6.12.101+deb13-amd64
- Memory: 4096MB
- CPUs: 2
- Firmware: EFI
- Network attachment: NAT
- SSH: enabled and active during validation
- Failed systemd units during validation: 0

## Guest Additions

- Oracle VirtualBox Guest Additions: 7.2.14r174565
- VBoxControl: verified
- vboxguest kernel module: verified
- vboxadd-service: active during validation
- Automatic display resize: PASS
- Clipboard Host-to-Guest: PASS
- Clipboard Guest-to-Host: PASS
- Drag and Drop Host-to-Guest: PASS
- Drag and Drop Guest-to-Host: PASS
- Shared Folder read-only: PASS
- Shared Folder read-only write protection: PASS
- Shared Folder read-write: PASS

## Final integration security state

- Clipboard: HostToGuest
- Drag and Drop: HostToGuest
- Shared folders: <none>

## Snapshot baseline

- S00-CleanInstall: True
- S01-Patched: True
- S02-GuestAdditions: True
- S03-IntegrationValidated: True

## Virtual disk

- Base VDI: D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001\LAB-VBOX-LINUX-001.vdi
- Base VDI present: True
- Base VDI physical size bytes: 6387924992
- Snapshot VDI count: 4
- No inaccessible media detected: True
- Logical capacity: 32768 MB
- Allocation: dynamic

## Storage architecture

- Active VM remains on SSD D:
- Exchange test path: E:\Virtualization\Exchange\LAB-VBX-002
- Exchange path present: True
- E: volume available: True

The new internal E: HDD is treated as capacity-oriented virtualization
storage. The active LAB-VBOX-LINUX-001 VM remains on SSD D: until a
separate controlled migration experiment is performed.

## Validation checks

- VirtualBoxVersionCorrect: False
- VMPoweredOff: True
- GuestOSDebian13: True
- Memory4096MB: True
- CPUCount2: True
- FirmwareEFI: True
- NetworkNAT: True
- ClipboardDisabled: False
- DragDropDisabled: False
- SharedFoldersDisabled: True
- S00CleanInstallPresent: True
- S01PatchedPresent: True
- S02GuestAdditionsPresent: True
- S03IntegrationValidatedPresent: True
- BaseVDIPresent: True
- VDIChainAccessible: True

## Assessment

**REVIEW**

Checks requiring review:

- VirtualBoxVersionCorrect
- ClipboardDisabled
- DragDropDisabled

> No passwords, account secrets or sensitive host identifiers are included.
