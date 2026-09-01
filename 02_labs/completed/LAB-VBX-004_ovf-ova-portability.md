# LAB-VBX-004 - OVF/OVA Export, Import and Portability

## Status

**PASS**

## Objective

Validate Oracle VirtualBox appliance portability using OVF and OVA,
including export structure, checksums, import behavior, identity
handling and cleanup.

## Source

LAB-VBOX-LINUX-002

The source guest used:

- Debian GNU/Linux 13.6
- EFI
- 4096 MB RAM
- 2 vCPU
- NAT
- Guest Additions 7.2.14

## OVF export

The VM was exported using OVF 2.0.

The resulting appliance contained:

- OVF XML descriptor;
- EFI NVRAM;
- stream-optimized VMDK.

SHA256 hashes were recorded for all exported components.

## OVF inspection

The descriptor was inspected manually.

Confirmed:

- Debian13_64 guest type;
- 2 vCPU;
- 4096 MB RAM;
- NAT;
- disk reference;
- NVRAM reference;
- streamOptimized VMDK.

## Dry-run import

VBoxManage import --dry-run was used before the real import.

The dry-run confirmed the proposed:

- guest OS;
- VM name;
- RAM;
- CPU count;
- NAT network;
- controllers;
- disk image.

## Import

The appliance was imported as:

LAB-VBOX-IMPORT-001

The imported VM received:

- a new VirtualBox UUID;
- a new MAC address.

The imported VM retained:

- EFI;
- 4096 MB RAM;
- 2 vCPU;
- NAT;
- guest OS contents.

## Snapshot behavior

The imported appliance had no VirtualBox snapshots.

This confirms that appliance export/import did not preserve the
VirtualBox snapshot tree.

## Disk format

The original active VM used VDI.

The imported appliance used an independent VMDK base disk.

## Guest identity

The imported guest preserved:

- hostname;
- machine-id;
- SSH host keys.

Therefore appliance portability and guest identity regeneration are
separate operational concerns.

## OVA export

The same source VM was exported as a single OVA archive.

The archive contained:

- OVF descriptor;
- EFI NVRAM;
- VMDK disk image.

SHA256 was recorded for the OVA file.

## Cleanup

The temporary imported VM was unregistered and deleted.

The source VM remained registered.

The OVF and OVA exports remain on E: as reusable appliance artifacts.

## Result

**PASS**
