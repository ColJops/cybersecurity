# LAB-VBX-002 - First Debian VirtualBox VM and Guest Additions

## Status

**REVIEW**

## Purpose

Create the first Oracle VirtualBox guest, install Debian 13.6,
validate the VirtualBox storage model, create a controlled snapshot
chain and test Guest Additions integration features.

## VM

- Name: LAB-VBOX-LINUX-001
- Guest: Debian GNU/Linux 13.6 (trixie)
- Firmware: EFI
- RAM: 4096 MB
- vCPU: 2
- Disk: dynamic VDI, 32 GiB
- Network: NAT
- Active VM storage: D:\VirtualBox\Virtual Machines

## ISO verification

The Debian installer ISO was verified with SHA-512 before use.

File:

debian-13.6.0-amd64-netinst.iso

Result:

**SHA512 MATCH**

## Clean installation

The system was installed manually without VirtualBox unattended
installation.

Validation included:

- Debian 13.6 identification;
- kernel verification;
- NAT/DHCP operation;
- default route;
- EFI boot;
- filesystem usage;
- zero failed systemd units;
- SSH enabled and active.

## Snapshot model

The following controlled snapshot chain was created:

S00-CleanInstall
  -> S01-Patched
    -> S02-GuestAdditions
      -> S03-IntegrationValidated

The lab demonstrated the relationship between:

- base VDI;
- differencing VDI;
- parent UUID;
- snapshot state;
- EFI NVRAM state.

A duplicate S02 snapshot created during validation was safely removed
using its UUID, and VirtualBox completed the merge successfully.

## Guest Additions

Oracle VirtualBox Guest Additions 7.2.14r174565 were installed and
validated.

Verified:

- VBoxControl;
- vboxguest kernel module;
- vboxadd-service;
- automatic display resizing.

## Integration tests

The following features were tested successfully:

- Clipboard Host -> Guest;
- Clipboard Guest -> Host;
- Drag and Drop Host -> Guest;
- Drag and Drop Guest -> Host;
- Shared Folder Read Only;
- enforced write protection in Read Only mode;
- Shared Folder Read/Write;
- Guest -> Host file creation.

After the tests, integration channels were returned to the secure
baseline:

- Clipboard: disabled;
- Drag and Drop: disabled;
- Shared folders: none.

## Storage update

During this laboratory the host gained a new internal 1 TB HDD on E:.

The active VM remains on SSD D:.

E: was used for the controlled Shared Folder exchange path and will be
used as capacity-oriented storage for ISO, OVA/OVF, exports, archives
and selected less performance-sensitive virtual machines.

A separate migration experiment will be used before moving this VM.

## Result

**REVIEW**

LAB-VBX-002 successfully established the first Linux VirtualBox guest
and validated VirtualBox snapshots, Guest Additions and host-guest
integration controls.

## Additional storage migration experiment

LAB-VBOX-LINUX-001 was migrated from SSD D: to the new internal
7200 RPM HDD E: using VBoxManage movevm.

The following items were preserved:

- VM UUID;
- full snapshot hierarchy;
- base VDI;
- differencing VDI chain;
- EFI/NVRAM state;
- VirtualBox Guest Additions;
- NAT networking.

The guest successfully booted and operated from E:.

The VM was then migrated back to SSD D:.

### Performance comparison

| Test | E: HDD | D: SSD |
| --- | ---: | ---: |
| Average boot | 18.019 s | 9.512 s |
| Sequential read | 183 MiB/s | 271 MiB/s |
| Sequential write | 105 MiB/s | 170 MiB/s |
| Random 4K read QD1 | 127 IOPS | 1870 IOPS |
| Random 4K write QD1 | 288 IOPS | 2388 IOPS |

The benchmark confirmed that SSD D: should remain the preferred
location for active VMs.

HDD E: is assigned primarily to capacity-oriented virtualization
storage such as ISO, OVA/OVF, exports, archives and less demanding
guests.

After testing, S03-IntegrationValidated was restored and the guest
returned to its clean validated baseline.
