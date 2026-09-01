# LAB-VBX-005 - VirtualBox Automation with VBoxManage

## Status

**PASS**

## Objective

Build and validate repeatable VirtualBox automation using VBoxManage
and PowerShell.

## Manual CLI baseline

A complete VM was created without using the VirtualBox GUI.

The workflow covered:

1. VM registration
2. hardware configuration
3. EFI configuration
4. dynamic VDI creation
5. SATA controller
6. IDE controller
7. ISO attachment
8. boot order
9. NAT networking
10. secure clipboard and drag-and-drop defaults

The VM booted successfully to the Debian 13.6 UEFI installer.

## Snapshot and clone

A CLI snapshot was created.

A full clone was created from the snapshot.

The clone received a new UUID and MAC address and an independent base
VDI.

The temporary clone was removed after validation.

## New-VBoxLabVM.ps1

A reusable VM provisioning tool was developed.

The tool provides:

- parameterized VM name;
- memory selection;
- CPU selection;
- disk capacity selection;
- ISO selection;
- base folder selection;
- NAT or no-network profile;
- input validation;
- protection against existing VM modification;
- ISO existence validation;
- free-space validation;
- secure integration defaults;
- post-creation validation;
- automatic cleanup attempt after partial failure.

## Defensive tests

The following negative scenarios were tested:

- existing VM name;
- missing ISO;
- intentional partial failure.

All were handled as expected.

The intentional failure confirmed successful rollback.

## Invoke-VBoxDiagnostics.ps1

A separate read-only diagnostic tool was developed.

It can inspect the VirtualBox host or a selected VM.

It validates:

- VBoxManage availability;
- VirtualBox version;
- default VM path;
- media health;
- registered and running VMs;
- network infrastructure;
- VM UUID;
- VM state;
- VM NIC configuration;
- VM storage configuration.

## Cleanup

All temporary AUTO test machines were deleted after validation.

Permanent Debian laboratory VMs remained unchanged.

## Result

**PASS**
