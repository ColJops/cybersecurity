# TR-2026-004 â€” Hyper-V host baseline and laboratory validation

## Status

PASS WITH OBSERVATION

## Data

2026-08-16

## Zakres

Raport dokumentuje instalacjÄ™, konfiguracjÄ™ i walidacjÄ™ Microsoft Hyper-V na hoĹ›cie laboratoryjnym Windows 11 Pro 25H2.

## Podsumowanie wykonawcze

PeĹ‚na funkcja Microsoft Hyper-V zostaĹ‚a uruchomiona i zweryfikowana.

Wszystkie wymagane komponenty Hyper-V sÄ… aktywne, podstawowe usĹ‚ugi dziaĹ‚ajÄ…, moduĹ‚ PowerShell jest dostÄ™pny, a Hyper-V Manager poprawnie komunikuje siÄ™ z lokalnym hostem.

DomyĹ›lne lokalizacje VM i VHDX zostaĹ‚y przeniesione z dysku systemowego na dedykowany magazyn D:.

Host przeszedĹ‚ praktyczne testy dotyczÄ…ce:

- generacji VM,
- VHD/VHDX,
- pamiÄ™ci dynamicznej,
- vCPU,
- Secure Boot,
- vTPM,
- checkpointĂłw,
- eksportu i importu,
- klonowania,
- automatyzacji,
- diagnostyki.

KoĹ„cowy health check zakoĹ„czyĹ‚ siÄ™ wynikiem PASS.

## Konfiguracja hosta

Host:

ACER

Procesory logiczne:

12

VirtualMachinePath:

D:\Hyper-V\Virtual Machines

VirtualHardDiskPath:

D:\Hyper-V\Virtual Hard Disks

Enhanced Session Mode:

Enabled

NUMA Spanning:

Enabled

DomyĹ›lna wersja konfiguracji VM:

12.0

## Komponenty Hyper-V

Zweryfikowane jako Enabled:

- Microsoft-Hyper-V
- Microsoft-Hyper-V-All
- Microsoft-Hyper-V-Hypervisor
- Microsoft-Hyper-V-Management-Clients
- Microsoft-Hyper-V-Management-PowerShell
- Microsoft-Hyper-V-Services
- Microsoft-Hyper-V-Tools-All

## UsĹ‚ugi

vmms:

Running / Automatic

vmcompute:

Running / Manual

## PowerShell

Hyper-V module:

2.0.0.0

Zweryfikowano dziaĹ‚anie miÄ™dzy innymi:

- Get-VM
- Get-VMHost
- Get-VMSwitch
- Get-VHD
- New-VM
- New-VHD
- Set-VMMemory
- Set-VMProcessor
- Set-VMFirmware
- Enable-VMTPM
- Export-VM
- Import-VM
- Checkpoint-VM

## Storage

Do aktywnych VM wykorzystywany jest wewnÄ™trzny SSD D:.

Dyski USB E: i F: nie sÄ… wykorzystywane jako magazyn aktywnych maszyn wirtualnych.

Preferowany format dla nowych VM:

VHDX Dynamic.

Przetestowano rĂłwnieĹĽ:

- VHD,
- VHDX Fixed,
- VHDX Differencing.

ĹaĹ„cuchy dyskĂłw rĂłĹĽnicowych zostaĹ‚y zweryfikowane jako spĂłjne.

## Generation 1 i Generation 2

Przetestowano obie generacje.

Generation 2 zostaĹ‚a przyjÄ™ta jako domyĹ›lny profil dla wspĂłĹ‚czesnych systemĂłw goĹ›cia.

Zweryfikowano:

- UEFI,
- Secure Boot,
- SCSI,
- MicrosoftWindows Secure Boot Template.

## RAM

Zweryfikowano konfiguracjÄ™ Static Memory oraz Dynamic Memory.

Standardowy profil laboratoryjny:

- Minimum: 1 GiB
- Startup: 2 GiB
- Maximum: 4 GiB
- Buffer: 20
- Priority: 50

## CPU

Standardowy profil laboratoryjny:

- 2 vCPU
- Reserve: 0
- Maximum: 100
- RelativeWeight: 100

Nested virtualization pozostaje domyĹ›lnie wyĹ‚Ä…czona.

## BezpieczeĹ„stwo VM

Przetestowano:

- Secure Boot,
- Local Key Protector,
- vTPM.

LAB-SEC-001 oraz LAB-AUTO-001 poprawnie korzystaĹ‚y z vTPM.

Nie wdraĹĽano Shielded VM ani Host Guardian Service.

## Checkpointy

Zweryfikowano Standard checkpoint.

Docelowy profil automatyzowanej VM:

- AutomaticCheckpointsEnabled: False
- CheckpointType: ProductionOnly

PeĹ‚na walidacja Production Checkpoint zostanie przeprowadzona po uruchomieniu systemu goĹ›cia.

## Eksport, import i klonowanie

Zweryfikowano:

- Export-VM,
- Import-VM,
- Copy,
- GenerateNewId,
- niezaleĹĽne VHDX,
- dyski differencing.

Zaimportowana kopia posiadaĹ‚a nowy VM ID oraz niezaleĹĽny VHDX.

## Automatyzacja

Utworzono:

03_tools/hyper-v/New-CyberLabVM.ps1

Skrypt umoĹĽliwia standaryzowane tworzenie nowych maszyn laboratoryjnych.

Zweryfikowano:

- parser PowerShell,
- -WhatIf,
- rzeczywiste utworzenie LAB-AUTO-001,
- zgodnoĹ›Ä‡ wynikowej konfiguracji z wymaganym profilem.

## Diagnostyka

Utworzono:

03_tools/hyper-v/Invoke-HyperVDiagnostics.ps1

KoĹ„cowy wynik:

PASS â€” Hyper-V basic health check passed.

Nie wykryto brakujÄ…cych VHDX ani uszkodzonych relacji parent-child.

## Obserwacja

W:

Microsoft-Windows-Hyper-V-VmSwitch-Operational

wystÄ™pujÄ… powtarzajÄ…ce siÄ™ ostrzeĹĽenia Event ID 285 dotyczÄ…ce Default Switch.

Nie zaobserwowano wpĹ‚ywu tych wpisĂłw na podstawowÄ… sprawnoĹ›Ä‡ Hyper-V.

Zalecenie:

kontynuowaÄ‡ obserwacjÄ™ podczas przyszĹ‚ych laboratoriĂłw sieciowych bez modyfikowania Default Switch na obecnym etapie.

## Elementy odroczone

1. PeĹ‚ny test Enhanced Session Mode z dziaĹ‚ajÄ…cym systemem Windows.
2. Production Checkpoint z dziaĹ‚ajÄ…cym systemem goĹ›cia.
3. Budowa wĹ‚asnych vSwitchy i topologii laboratoryjnej.
4. Dalsza analiza Event ID 285 podczas testĂłw sieciowych.

## Evidence

02_labs/evidence/LAB-HV-001

## Wniosek

Microsoft Hyper-V jest poprawnie zainstalowany i skonfigurowany.

Host speĹ‚nia wymagania do dalszej budowy Ĺ›rodowiska wirtualnego projektu CyberbezpieczeĹ„stwo.

Wynik koĹ„cowy:

PASS WITH OBSERVATION

## Cleanup po walidacji

Po utworzeniu evidence usuniÄ™to wszystkie tymczasowe zasoby LAB-HV-001:

- 13 testowych VM,
- testowe VHD/VHDX,
- dyski rĂłĹĽnicowe,
- eksport testowej VM.

Nie usuniÄ™to ani nie zmodyfikowano Default Switch.

Po cleanupie host pozostaĹ‚ skonfigurowany z:

- VirtualMachinePath: D:\Hyper-V\Virtual Machines,
- VirtualHardDiskPath: D:\Hyper-V\Virtual Hard Disks,
- Enhanced Session Mode: Enabled.

Stan koĹ„cowy hosta zostaĹ‚ ponownie zweryfikowany.
