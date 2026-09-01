# TR-2026-008 - VirtualBox OVF/OVA Portability

## 1. Metadata

- Report ID: TR-2026-008
- Laboratory: LAB-VBX-004
- Result: **PASS**
- VirtualBox host: 7.2.16r174877
- Guest Additions: 7.2.14r174565
- Guest OS: Debian GNU/Linux 13.6

## 2. Objective

Evaluate VirtualBox appliance portability using OVF and OVA.

## 3. Export storage

Appliance artifacts were stored on the capacity-oriented HDD:

E:\Virtualization\VirtualBox\Exports\LAB-VBX-004

This follows the storage policy established by the SSD/HDD benchmark.

## 4. OVF export

The exported OVF appliance consisted of:

- XML descriptor;
- NVRAM;
- streamOptimized VMDK.

SHA256:

OVF:
0C144B2266D416C40C990DAC8FD89888D97558B406A360D30D107CFE5F688C42

NVRAM:
92453CA3FC81A14842C52F9AA43A15D9FF098D8DCD60B9DCA41E49D78491773F

VMDK:
019FEE97CE550BA2F5C10272A224EA76B7FC6CB67E5FE8B550A479B94277AF2E

## 5. OVA export

OVA size:

2862342656 bytes

SHA256:

820DF2640873E465B848C6AE448AD01701F96D1BBC562586E9E778D6CDEEBA22

The OVA archive contained the same appliance components in one
portable archive.

## 6. Import behavior

The OVF appliance was imported as:

LAB-VBOX-IMPORT-001

The import created a new VirtualBox VM identity.

Source UUID:

bba7a2a5-4c7f-4768-97b6-10116bc70db7

Imported UUID:

3f62e30c-b613-4288-8a54-2019a3e50c13

Source MAC:

0800275BF507

Imported MAC:

080027C0AD50

## 7. Storage behavior

The imported machine used:

VMDK

The source active machine used:

VDI

The import produced an independent base disk.

## 8. Snapshot behavior

The imported machine had no VirtualBox snapshot tree.

Appliance export/import therefore represents a portable machine state,
not a full preservation of VirtualBox snapshot history.

## 9. Guest operating-system identity

The imported guest retained:

- hostname;
- machine-id;
- SSH host keys.

This means that hypervisor identity and guest OS identity must be
managed separately.

When source and imported appliances are intended to operate
simultaneously, guest identity regeneration should be considered.

## 10. EFI portability

The appliance included EFI NVRAM.

The imported guest booted successfully using EFI.

## 11. Guest validation

Validated after import:

- successful boot;
- Guest Additions operational;
- zero failed systemd units;
- NAT addressing operational;
- default route operational.

## 12. Cleanup

The temporary imported VM was deleted after validation.

The source VM remained unchanged.

Export artifacts were retained on E:.

## 13. Security and operational conclusions

OVF is useful when human-readable descriptor inspection is valuable.

OVA is more convenient for transfer and archival because the appliance
is represented as a single file.

SHA256 should be recorded whenever appliances are transferred,
archived or exchanged.

An imported appliance should not automatically be treated as a unique
guest identity merely because VirtualBox generates new UUID and MAC
values.

## 14. Result

**PASS**

LAB-VBX-004 successfully validated OVF/OVA export, integrity,
import behavior, EFI portability and guest identity implications.
