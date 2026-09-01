# TR-2026-009 - VirtualBox Automation Baseline

## 1. Metadata

- Report ID: TR-2026-009
- Laboratory: LAB-VBX-005
- Result: **PASS**
- VirtualBox host: 7.2.16r174877
- Automation: Windows PowerShell 5.1 / VBoxManage

## 2. Objective

Evaluate VirtualBox automation using command-line tooling and convert
the validated workflow into reusable PowerShell utilities.

## 3. Manual VBoxManage workflow

The following operations were validated manually:

- createvm
- modifyvm
- createmedium
- storagectl
- storageattach
- snapshot
- clonevm
- startvm
- controlvm
- unregistervm

This established a known-good CLI sequence before scripting.

## 4. Provisioning baseline

The automated VM baseline uses:

- Debian 13 64-bit guest type
- EFI
- 2 GiB default RAM
- 2 vCPU
- VMSVGA
- dynamic VDI
- SATA IntelAhci
- IDE PIIX4
- NAT
- disabled clipboard
- disabled drag and drop
- disabled audio
- DVD-first boot order

## 5. Provisioning tool

Tool:

03_tools/virtualbox/New-VBoxLabVM.ps1

The script provides controlled VM provisioning.

Safety mechanisms include:

- existing VM detection;
- target directory protection;
- ISO validation;
- conservative free-space validation;
- post-creation audit;
- rollback after partial failure.

## 6. Existing VM protection

Attempting to create LAB-VBOX-AUTO-002 a second time was rejected.

No modification of the existing VM occurred.

Result:

PASS

## 7. ISO validation

A deliberately invalid ISO path was supplied.

The script rejected the request before creating a VM.

Result:

PASS

## 8. Rollback validation

A controlled exception was injected after VM creation and hardware
configuration.

The script detected the error and executed unregistervm --delete.

The temporary VM and directory were removed.

Result:

PASS

## 9. Diagnostics tool

Tool:

03_tools/virtualbox/Invoke-VBoxDiagnostics.ps1

The diagnostics workflow is read-only.

It inspects:

- host VirtualBox version;
- default machine path;
- Extension Pack;
- Host-only interfaces;
- NAT Networks;
- virtual media;
- inaccessible media;
- registered and running VMs;
- optional detailed VM configuration.

## 10. Diagnostics results

Host audit:

PASS

Per-VM audit:

PASS

No inaccessible virtual media were detected.

## 11. Operational conclusion

Manual VBoxManage commands are useful for understanding individual
VirtualBox operations.

Reusable PowerShell wrappers provide better repeatability and safety
for larger cyberlab environments.

Automated workflows should validate inputs before mutation and provide
cleanup logic for partial failures.

## 12. Cleanup

All temporary automation objects were removed.

Remaining VirtualBox laboratory VMs:

- LAB-VBOX-LINUX-001
- LAB-VBOX-LINUX-002

## 13. Result

**PASS**

LAB-VBX-005 successfully validated VirtualBox CLI automation,
defensive provisioning, rollback and read-only diagnostics.
