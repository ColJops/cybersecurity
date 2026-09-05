# TR-2026-010 - Hyper-V vs VirtualBox Practical Comparison

## 1. Metadata

- Report ID: TR-2026-010
- Laboratory: LAB-VIRT-001
- Result: **PASS**
- Host: Windows 11 Pro
- Guest: Debian GNU/Linux 13.6

## 2. Objective

Compare Microsoft Hyper-V and Oracle VirtualBox using similar guest
configurations and the same physical host.

The experiment focused on practical cyberlab use rather than synthetic
hypervisor theory.

## 3. Normalized VM profile

Both platforms used:

- 2 vCPU;
- 4 GiB RAM;
- approximately 32 GiB virtual disk;
- Debian 13.6;
- EFI/UEFI;
- graphical desktop;
- SSD D: as host storage.

Hyper-V used a Generation 2 VM with fixed memory and Default Switch.

VirtualBox used EFI, VDI and NAT.

## 4. Boot time

VirtualBox:

9.512 s stable average.

Hyper-V:

16.984 s stable average.

VirtualBox was approximately 1.79x faster in the measured boot
scenario.

Hyper-V userspace startup was strongly affected by
plymouth-quit-wait.service, so the complete difference cannot be
attributed directly to the hypervisor.

## 5. Storage performance

| Workload | Hyper-V | VirtualBox |
|---|---:|---:|
| Sequential write | 407 MiB/s | 170 MiB/s |
| Sequential read | 308 MiB/s | 271 MiB/s |
| Random 4K read QD1 | 5417 IOPS | 1870 IOPS |
| Random 4K write QD1 | 7835 IOPS | 2388 IOPS |

Hyper-V was approximately:

- 2.39x faster in sequential write;
- 1.14x faster in sequential read;
- 2.9x faster in random 4K read;
- 3.28x faster in random 4K write.

## 6. Network

Virtual gateway average RTT:

- Hyper-V: 0.439 ms;
- VirtualBox: 1.29 ms.

Hyper-V local virtual-network RTT was approximately 2.94x
lower.

Internet target 1.1.1.1:

- Hyper-V: 21.49 ms;
- VirtualBox: 22.808 ms.

Both platforms:

- zero packet loss;
- DNS PASS;
- HTTPS PASS.

## 7. Host-resource observations

Baseline host:

- RAM used: 9.87 GiB;
- CPU average: 1.33 percent.

Hyper-V idle:

- RAM used: 14.05 GiB;
- delta: +4.18 GiB;
- CPU average: 6.33 percent;
- delta: +5 percentage points.

VirtualBox idle:

- RAM used: 11.22 GiB;
- delta: +1.35 GiB;
- CPU average: 2 percent;
- delta: +3.94 percentage points.

These measurements must be interpreted as whole-system observations.

They include guest memory commitment, management processes, host cache
and background host activity.

They must not be treated as pure hypervisor overhead.

## 8. Operational comparison

### Hyper-V strengths

- strong storage performance;
- strong random I/O performance;
- low local virtual-network latency;
- native Windows integration;
- PowerShell automation;
- Generation 2 VM model;
- suitable for persistent cyberlab infrastructure.

### VirtualBox strengths

- shorter boot time in this tested guest;
- lower observed idle resource increase;
- simple NAT, Host-only and Internal Network modes;
- OVF/OVA portability;
- broad cross-platform availability;
- convenient appliance and training workflows.

## 9. Security-lab implications

Hyper-V is a strong primary hypervisor for the Windows 11 Pro lab host.

VirtualBox remains valuable as a secondary platform where portability,
appliances or explicit network-mode experimentation are more important.

Using both platforms provides broader operational knowledge and avoids
designing the cyberlab around a single virtualization technology.

## 10. Methodological limitations

The benchmark was performed on one physical host.

The results describe the tested configuration and must not be treated
as universal performance rankings for Hyper-V or VirtualBox.

Boot time was affected by guest userspace services.

Network Internet latency depended partly on external network
conditions.

Host RAM and CPU measurements included the complete running platform,
guest and management stack.

## 11. Conclusion

The experiment did not identify one universal winner.

Hyper-V clearly led in storage I/O and local virtual-network latency.

VirtualBox clearly led in boot time for the tested Debian configuration
and produced lower observed host-resource deltas during the idle test.

Platform selection should therefore depend on workload and laboratory
purpose rather than product preference.

## 12. Result

**PASS**
