# LAB-VBX-002 - Storage Migration and Performance Benchmark

## Purpose

Validate safe relocation of LAB-VBOX-LINUX-001 between the active SSD
storage on D: and the capacity-oriented HDD storage on E:, and compare
real guest performance on both physical storage classes.

## Migration path

1. Initial active storage:

   D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001

2. VM moved to:

   E:\Virtualization\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001

3. Full functional validation performed on E:.

4. VM moved back to:

   D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001

5. S03-IntegrationValidated restored after the benchmark.

## Migration validation

- VM UUID preserved: 6e90c7bc-8231-4435-b1a8-bca9d8077ee5
- Snapshot hierarchy preserved: PASS
- Base VDI preserved: PASS
- Differencing VDI chain preserved: PASS
- EFI/NVRAM preserved: PASS
- Old D: location removed after D -> E migration: PASS
- Guest boot from E: PASS
- Guest Additions after migration: PASS
- NAT after migration: PASS
- Clean shutdown after migration: PASS
- E -> D return migration: PASS
- No inaccessible media: True
- S03-IntegrationValidated present: True

## Final VM state

- State: powered off (since 2026-08-21T17:27:42.725000000)
- Config file: D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001\LAB-VBOX-LINUX-001.vbox
- Snapshot folder: D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001\Snapshots
- Final active storage on SSD D: True

## Boot benchmark

HDD E:

- Boot 1: 18.656 s
- Boot 2: 17.382 s
- Average: 18.019 s

SSD D:

- Boot 1: 9.063 s
- Boot 2: 9.96 s
- Average: 9.512 s

SSD reduces average guest boot time by approximately a factor of:

1.89 x

## fio benchmark

All fio tests used the same guest, same VirtualBox configuration,
same snapshot chain and the same test parameters.

| Test | E: HDD | D: SSD | SSD advantage |
| --- | ---: | ---: | ---: |
| Sequential read | 183 MiB/s | 271 MiB/s | 1.48x |
| Sequential write | 105 MiB/s | 170 MiB/s | 1.62x |
| Random 4K read QD1 | 127 IOPS | 1870 IOPS | 14.72x |
| Random 4K write QD1 | 288 IOPS | 2388 IOPS | 8.29x |

## Interpretation

Sequential throughput on the 7200 RPM Toshiba HDD is adequate for
large files, ISO images, appliances, exports and archive workloads.

The largest difference appears in random 4K I/O.

Random 4K read:

127 IOPS -> 1870 IOPS

Random 4K write:

288 IOPS -> 2388 IOPS

This explains why an operating system VM can feel much more responsive
on SSD even when the HDD provides good sequential throughput.

## Storage policy derived from measurement

D: SSD is preferred for:

- active virtual machines;
- GUI operating systems;
- frequently patched guests;
- snapshot-heavy workloads;
- database workloads;
- workloads performing many small random I/O operations.

E: HDD is preferred for:

- ISO images;
- OVA/OVF appliances;
- exports;
- archives;
- powered-off clones;
- backup copies;
- less frequently used and less I/O-sensitive virtual machines.

## Cleanup

The fio test file was removed.

S03-IntegrationValidated was restored after benchmarking.

The fio package installed after S03 was removed implicitly by snapshot
restore and is absent from the restored guest baseline.

## Result

**PASS**

The migration D: -> E: -> D: completed successfully and the benchmark
provides measured evidence for the project's tiered virtualization
storage policy.
