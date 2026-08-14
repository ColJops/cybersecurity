# Host readiness assessment

- Script version: **1.2**
- Audit time: 2026-08-14T17:00:32.5093881+02:00
- Computer: ACER
- Result: **READY**
- Project resource profile: **standard**
- OS: Microsoft Windows 11 Pro, build 26200
- Installed RAM: 32 GiB
- Windows-visible RAM: 31.91 GiB
- Preferred VM-storage free space: 1067.8 GiB
- Hypervisor present: True
- Hyper-V optional feature state: Disabled
- Audit session elevated: True

## Mandatory checks

| Check | Result |
|---|---|
| Windows11ProOrEnterprise | True |
| VMMonitorModeExtensionsEffective | True |
| SLATEffective | True |
| VirtualizationEnabledOrHypervisorPresent | True |

## Virtualization evidence

- Hypervisor present: True
- VirtualizationFirmwareEnabled reported by Win32_Processor: False
- VMMonitorModeExtensions reported by Win32_Processor: False
- SLAT reported by Win32_Processor: False
- Interpretation: HypervisorPresent=True. Raw Win32_Processor virtualization flags may be False while the Windows hypervisor is active; effective checks therefore use the active hypervisor as evidence.

## Storage inventory

| Drive | Type | Bus | Size GiB | Free GiB | Free | Preferred for active VMs |
|---|---|---|---:|---:|---:|---|
| C: | Fixed | RAID | 930.56 | 769.61 | 82.7% | True |
| D: | Fixed | RAID | 447.12 | 298.16 | 66.7% | True |
| E: | Fixed | USB | 465.76 | 9.21 | 2% | False |
| F: | Removable | USB | 230.95 | 230.93 | 100% | False |

## Performance sample

- Samples collected: 15
- Average CPU: 7.27%
- Maximum CPU: 23%
- Average available memory: 21557.93 MB
- Minimum available memory: 21511 MB
- Average disk transfers/sec: 219.2
- Average disk queue length: 0.07
- Maximum disk queue length: 1

## Advisories

- Low free space: E: (2% free).
- External/removable buses excluded from preferred VM storage: E: [USB], F: [USB].
- Raw systeminfo.exe output was not saved for privacy.

## Interpretation

- READY: mandatory platform checks pass and resources match the standard or extended project profile.
- CONDITIONALLY_READY: mandatory platform checks pass, but simultaneous VM scenarios should be limited.
- NOT_READY: at least one mandatory platform requirement is missing or cannot be confirmed.
- When HypervisorPresent=True, raw Win32_Processor virtualization flags can be misleading; the effective checks account for this.
- Storage temperature values of 0-1 C are treated as unavailable because some controllers return placeholder values.
- Wear values are controller-dependent; a value of 0 does not by itself prove either zero wear or unsupported telemetry.

## Safety and privacy

This script is read-only. Serial numbers and module identifiers are hidden by default. Raw systeminfo.exe output is also omitted by default because it may expose registered-owner information, Product ID, local/VPN IP addresses and other environment details. Review generated files before publishing them.
