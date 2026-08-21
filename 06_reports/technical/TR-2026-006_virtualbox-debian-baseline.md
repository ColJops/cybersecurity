# TR-2026-006 - VirtualBox Debian guest baseline

## 1. Report metadata

- Report ID: TR-2026-006
- Laboratory: LAB-VBX-002
- Result: **REVIEW**
- Platform: Windows 11 Pro 25H2 / Oracle VirtualBox / Debian 13.6
- Evidence: 02_labs/evidence/LAB-VBX-002
- Completed lab:
  02_labs/completed/LAB-VBX-002_debian-first-vm-and-guest-additions.md

## 2. Objective

Establish and validate the first Linux guest running under Oracle
VirtualBox alongside the existing Microsoft Hyper-V environment.

## 3. Installation media

- Debian GNU/Linux 13.6 (trixie)
- amd64 netinst
- SHA-512 verification: PASS
- ISO storage:
  D:\VirtualBox\ISO\debian-13.6.0-amd64-netinst.iso

## 4. VM baseline

- Name: LAB-VBOX-LINUX-001
- Guest profile: Debian 13 Trixie (64-bit)
- RAM: 4096 MB
- CPUs: 2
- EFI: enabled
- VDI: 32 GiB dynamic
- Network: NAT
- Clipboard: disabled at final state
- Drag and Drop: disabled at final state
- Shared folders: none at final state

## 5. Operating system validation

The guest was verified as Debian GNU/Linux 13.6.

The lab confirmed:

- successful EFI boot;
- working NAT and DHCP;
- working default route;
- SSH service;
- zero failed systemd units;
- correct filesystem deployment.

## 6. Virtual disk behavior

The initial dynamic VDI occupied approximately 2 MiB before guest
installation.

After Debian installation the base VDI grew to approximately 6.39 GB.

The first snapshot caused VirtualBox to create a differencing VDI.

Further snapshots created an explicit parent-child differencing chain.

This behavior was inspected with VBoxManage.

## 7. Snapshot baseline

Final snapshot hierarchy:

- S00-CleanInstall
- S01-Patched
- S02-GuestAdditions
- S03-IntegrationValidated

The snapshot design provides controlled rollback points for:

- clean operating system;
- patched operating system;
- Guest Additions;
- validated host-guest integration.

## 8. Guest Additions

Guest Additions version:

7.2.14r174565

Validated components:

- VBoxControl;
- vboxguest;
- vboxadd-service.

## 9. Integration validation

Automatic display resizing: PASS

Clipboard:

- Host -> Guest: PASS
- Guest -> Host: PASS

Drag and Drop:

- Host -> Guest: PASS
- Guest -> Host: PASS

Shared Folder:

- read access: PASS
- read-only enforcement: PASS
- read-write mode: PASS
- Guest -> Host write: PASS

## 10. Security baseline

Integration features were enabled only for individual tests.

Final configuration:

- Shared Clipboard: disabled
- Drag and Drop: disabled
- Shared Folders: none

This preserves host-guest isolation while retaining Guest Additions
for graphics and controlled future integration.

## 11. Storage architecture update

The host now contains:

- D: SSD - active performance-sensitive virtual machines;
- E: internal 1 TB HDD - capacity-oriented virtualization storage;
- G: portable media - Cyberbezpieczenstwo Git repository.

LAB-VBOX-LINUX-001 remains on D: until a dedicated migration test is
performed.

E:\Virtualization\Exchange\LAB-VBX-002 was used for the Shared Folder
validation.

## 12. Assessment

**REVIEW**

The Debian guest is stable, patched, snapshot-protected and integrated
with Oracle VirtualBox Guest Additions.

The final configuration returns optional host-guest data exchange
channels to the disabled state.

LAB-VBX-002 is ready for closure.

## 13. Storage migration and SSD/HDD benchmark

A controlled live-storage experiment was performed after the primary
LAB-VBX-002 validation.

The same VM and snapshot chain were moved:

D: SSD -> E: HDD -> D: SSD

using VBoxManage movevm.

The VM UUID, snapshot UUIDs and VDI parent-child chain were preserved.

### Measured results

| Metric | E: HDD | D: SSD | Difference |
| --- | ---: | ---: | ---: |
| Average boot | 18.019 s | 9.512 s | 1.89x faster on SSD |
| Sequential read | 183 MiB/s | 271 MiB/s | 1.48x |
| Sequential write | 105 MiB/s | 170 MiB/s | 1.62x |
| Random 4K read QD1 | 127 IOPS | 1870 IOPS | 14.72x |
| Random 4K write QD1 | 288 IOPS | 2388 IOPS | 8.29x |

The largest advantage of SSD is visible in random 4K I/O rather than
sequential transfer.

This measurement supports a tiered storage architecture:

- D: SSD for active and I/O-sensitive VMs;
- E: HDD for capacity-oriented virtualization data and less demanding
  guests.

The VM was finally returned to D: SSD and snapshot
S03-IntegrationValidated was restored.

## 14. Final storage state

LAB-VBOX-LINUX-001:

D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001

Result:

**PASS**
