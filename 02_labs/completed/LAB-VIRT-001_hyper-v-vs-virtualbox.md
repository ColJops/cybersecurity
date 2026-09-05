# LAB-VIRT-001 - Hyper-V vs VirtualBox

## Status

**PASS**

## Objective

Perform a practical comparison of Microsoft Hyper-V and Oracle
VirtualBox on the same Windows 11 Pro host.

## Test systems

### Hyper-V

- VM: LAB-HV-LINUX-001
- Generation 2
- 2 vCPU
- 4 GiB fixed RAM
- approximately 32 GiB dynamic VHDX
- Debian 13.6
- Default Switch
- UEFI
- Secure Boot disabled

### VirtualBox

- VM: LAB-VBOX-LINUX-001
- 2 vCPU
- 4 GiB RAM
- approximately 32 GiB VDI
- Debian 13.6
- NAT
- EFI

Both VM storage locations were placed on SSD D:.

## Results

### Boot

VirtualBox stable average:

9.512 s

Hyper-V stable average:

16.984 s

VirtualBox booted approximately 1.79x faster in this specific
configuration.

The Hyper-V guest showed approximately 13.7 seconds in
plymouth-quit-wait.service, so the full difference cannot be attributed
only to the hypervisor.

### Storage

Hyper-V achieved:

- 407 MiB/s sequential write;
- 308 MiB/s sequential read;
- 5417 IOPS random 4K read QD1;
- 7835 IOPS random 4K write QD1.

VirtualBox achieved:

- 170 MiB/s sequential write;
- 271 MiB/s sequential read;
- 1870 IOPS random 4K read QD1;
- 2388 IOPS random 4K write QD1.

Hyper-V had the strongest advantage in random 4K I/O and sequential
write.

### Network

Hyper-V gateway RTT:

0.439 ms average.

VirtualBox gateway RTT:

1.29 ms average.

Both platforms had zero packet loss.

Internet RTT:

- Hyper-V: 21.49 ms;
- VirtualBox: 22.808 ms.

DNS and HTTPS tests passed on both platforms.

### Host resources

Observed host-memory increase:

- Hyper-V: +4.18 GiB;
- VirtualBox: +1.35 GiB.

Observed average CPU increase:

- Hyper-V: +5 percentage points;
- VirtualBox: +3.94 percentage points.

These measurements describe the complete running test configuration,
not isolated hypervisor overhead.

## Practical conclusion

Neither platform was universally superior.

Hyper-V provided clearly stronger virtual storage performance and
lower local virtual-network latency.

VirtualBox provided shorter guest boot time in this configuration and
lower observed host RAM/CPU increase during the idle measurement.

For this cyberlab:

- Hyper-V is well suited to long-running Windows/Linux laboratories,
  high-I/O workloads and environments tightly integrated with Windows
  PowerShell management.

- VirtualBox is well suited to portable laboratories, OVF/OVA
  appliances, training environments and workflows where cross-platform
  compatibility and explicit network-mode switching are valuable.

The two platforms are complementary rather than interchangeable in
every scenario.

## Result

**PASS**
