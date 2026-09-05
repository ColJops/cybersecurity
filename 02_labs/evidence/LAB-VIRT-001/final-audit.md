# LAB-VIRT-001 - Hyper-V vs VirtualBox Final Audit

- Generated: 2026-09-05T19:59:16+02:00
- Assessment: **PASS**
- Host OS: Windows 11 Pro
- Hyper-V VM: LAB-HV-LINUX-001
- VirtualBox VM: LAB-VBOX-LINUX-001
- Guest OS: Debian GNU/Linux 13.6

## Objective

Compare Microsoft Hyper-V and Oracle VirtualBox on the same Windows
host using similar Debian 13.6 virtual-machine profiles.

The comparison covered:

- VM configuration;
- boot time;
- sequential storage performance;
- random 4K storage performance;
- virtual-network latency;
- Internet connectivity;
- DNS and HTTPS;
- host RAM usage;
- host CPU usage.

## Test profile

Both test systems used:

- Debian GNU/Linux 13.6;
- 2 vCPU;
- 4 GiB RAM;
- approximately 32 GiB virtual disk;
- EFI/UEFI firmware;
- SSD D: as host storage;
- graphical desktop;
- SSH capability.

Hyper-V used:

- Generation 2;
- fixed 4 GiB startup RAM;
- dynamic VHDX;
- Default Switch;
- Secure Boot disabled.

VirtualBox used:

- EFI;
- 4 GiB RAM;
- VDI;
- NAT.

## Boot benchmark

VirtualBox:

- run 1: 9.063 s
- run 2: 9.96 s
- stable average: 9.512 s

Hyper-V:

- stable run 1: 16.93 s
- stable run 2: 17.038 s
- stable average: 16.984 s

VirtualBox was approximately 1.79x faster in this boot test.

An earlier Hyper-V post-install boot result of 26.075 s was treated as
a warm-up/post-install observation and excluded from the stable
average.

Hyper-V boot analysis showed that approximately 13.7 seconds could be
attributed to plymouth-quit-wait.service.

Therefore the complete boot-time difference must not be attributed
solely to the hypervisor.

## Storage benchmark

| Test | Hyper-V | VirtualBox | Comparison |
|---|---:|---:|---:|
| Sequential write | 407 MiB/s | 170 MiB/s | Hyper-V 2.39x |
| Sequential read | 308 MiB/s | 271 MiB/s | Hyper-V 1.14x |
| Random 4K read QD1 | 5417 IOPS | 1870 IOPS | Hyper-V 2.9x |
| Random 4K write QD1 | 7835 IOPS | 2388 IOPS | Hyper-V 3.28x |

Hyper-V showed a strong advantage in random storage I/O and sequential
write performance.

## Network benchmark

Hyper-V virtual gateway:

- average RTT: 0.439 ms
- packet loss: 0 percent

VirtualBox NAT gateway:

- average RTT: 1.29 ms
- packet loss: 0 percent

Hyper-V gateway RTT was approximately 2.94x lower.

Internet target 1.1.1.1:

- Hyper-V average RTT: 21.49 ms
- VirtualBox average RTT: 22.808 ms
- Hyper-V packet loss: 0 percent
- VirtualBox packet loss: 0 percent

Hyper-V Internet RTT was approximately 5.8 percent
lower in this sample.

Both platforms successfully validated:

- DNS resolution for debian.org;
- HTTPS connection to www.debian.org;
- HTTP 200 response.

## Host resource observation

Baseline host:

- used RAM: 9.87 GiB
- average CPU: 1.33 percent

Hyper-V idle:

- used RAM: 14.05 GiB
- RAM delta: +4.18 GiB
- average CPU: 6.33 percent
- CPU delta: +5 percentage points

VirtualBox idle:

- used RAM: 11.22 GiB
- RAM delta: +1.35 GiB
- average CPU: 2 percent
- CPU delta: +3.94 percentage points

These values are operational observations, not pure hypervisor
overhead measurements.

Host physical-memory accounting, guest memory commitment, graphical
management processes, filesystem cache and background services can
affect the result.

## Current storage locations

Hyper-V:

D:\Hyper-V\LAB-VIRT-001\LAB-HV-LINUX-001\Virtual Hard Disks\LAB-HV-LINUX-001.vhdx

VirtualBox:

D:\VirtualBox\Virtual Machines\LAB-VBOX-LINUX-001\Snapshots/{f3b55fb9-d798-4067-8e02-28f5c2bf25db}.vdi

## Validation checks

- HyperVVMRegistered: True
- HyperVPoweredOff: True
- HyperVGeneration2: True
- HyperVCPU2: True
- HyperVRAM4096MB: True
- HyperVDynamicMemoryDisabled: True
- HyperVSecureBootDisabled: True
- HyperVDefaultSwitch: True
- HyperVDiskOnDDrive: True
- VBoxVMRegistered: True
- VBoxPoweredOff: True
- VBoxCPU2: True
- VBoxRAM4096MB: True
- VBoxEFI: True
- VBoxNATBaseline: True
- VBoxDiskOnDDrive: True
- SameCPUProfile: True
- SameRAMProfile: True
- SameHostStorageClass: True
- BootBenchmarkCompleted: True
- SequentialIOBenchmarkCompleted: True
- RandomIOBenchmarkCompleted: True
- NetworkBenchmarkCompleted: True
- HostResourceBenchmarkCompleted: True
- DNSValidationPassed: True
- HTTPSValidationPassed: True
- PacketLossZeroBothPlatforms: True

## Failed checks

- None

## Assessment

**PASS**
