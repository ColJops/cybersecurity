# LAB-HV-001 â€” Instalacja, konfiguracja i walidacja Microsoft Hyper-V

## 1. Informacje podstawowe

- ID laboratorium: LAB-HV-001
- Data wykonania: 2026-08-16
- Platforma: Windows 11 Pro 25H2
- Host: ACER
- Hyper-V PowerShell Module: 2.0.0.0
- DomyĹ›lna wersja konfiguracji VM: 12.0
- Autoryzacja: wĹ‚asny host laboratoryjny
- Charakter dziaĹ‚aĹ„: instalacja, konfiguracja, testy funkcjonalne i diagnostyka Hyper-V

## 2. Cel laboratorium

Celem laboratorium byĹ‚o uruchomienie kompletnej platformy Microsoft Hyper-V na hoĹ›cie Windows 11 Pro, skonfigurowanie podstawowych parametrĂłw hosta i maszyn wirtualnych oraz praktyczna walidacja mechanizmĂłw wykorzystywanych w dalszych laboratoriach cyberbezpieczeĹ„stwa.

Zakres obejmowaĹ‚:

- instalacjÄ™ funkcji Hyper-V,
- walidacjÄ™ usĹ‚ug i moduĹ‚u PowerShell,
- konfiguracjÄ™ magazynu VM,
- porĂłwnanie Generation 1 i Generation 2,
- testy formatĂłw VHD i VHDX,
- Dynamic Memory i Static Memory,
- konfiguracjÄ™ vCPU,
- Secure Boot i vTPM,
- Enhanced Session Mode,
- checkpointy,
- eksport i import maszyn,
- klonowanie peĹ‚ne i rĂłĹĽnicowe,
- automatyzacjÄ™ tworzenia VM,
- koĹ„cowÄ… diagnostykÄ™ hosta.

## 3. Stan poczÄ…tkowy

Przed instalacjÄ… peĹ‚nej funkcji Hyper-V system posiadaĹ‚ aktywny hypervisor Windows wykorzystywany przez mechanizmy VBS/HVCI, jednak wszystkie skĹ‚adniki Microsoft-Hyper-V byĹ‚y wyĹ‚Ä…czone.

Nie byĹ‚y dostÄ™pne miÄ™dzy innymi:

- Get-VM,
- Get-VMHost,
- Get-VMSwitch,
- Hyper-V Manager,
- usĹ‚ugi vmms i vmcompute jako peĹ‚ne komponenty Hyper-V.

## 4. Instalacja Hyper-V

WĹ‚Ä…czono kompletnÄ… funkcjÄ™ Microsoft Hyper-V wraz z:

- hypervisorem,
- usĹ‚ugami Hyper-V,
- Hyper-V Manager,
- moduĹ‚em Hyper-V PowerShell,
- narzÄ™dziami administracyjnymi.

Po restarcie wszystkie komponenty Microsoft-Hyper-V zostaĹ‚y zweryfikowane jako Enabled.

UsĹ‚ugi:

- vmms â€” Running / Automatic,
- vmcompute â€” Running / Manual.

ModuĹ‚ PowerShell Hyper-V zostaĹ‚ poprawnie zaĹ‚adowany.

## 5. Konfiguracja hosta

KoĹ„cowa konfiguracja hosta:

- nazwa hosta: ACER,
- procesory logiczne: 12,
- Enhanced Session Mode: Enabled,
- NUMA Spanning: Enabled,
- domyĹ›lna wersja konfiguracji VM: 12.0.

DomyĹ›lne lokalizacje zostaĹ‚y zmienione na:

- VirtualMachinePath:
  D:\Hyper-V\Virtual Machines

- VirtualHardDiskPath:
  D:\Hyper-V\Virtual Hard Disks

Dysk D: zostaĹ‚ wybrany jako gĹ‚Ăłwny magazyn aktywnych maszyn wirtualnych.

## 6. SieÄ‡ Hyper-V

Na etapie laboratorium pozostawiono systemowy:

- Default Switch â€” Internal.

Nie tworzono jeszcze wĹ‚asnych przeĹ‚Ä…cznikĂłw laboratoryjnych.

Projektowanie docelowej topologii sieci Hyper-V zostaĹ‚o odroczone do rozdziaĹ‚u poĹ›wiÄ™conego sieciom laboratoryjnym.

## 7. VHD i VHDX

W ramach LAB-VHD-001 przetestowano:

- VHD Dynamic,
- VHDX Dynamic,
- VHDX Fixed,
- VHDX Differencing.

Zaobserwowano rĂłĹĽnicÄ™ pomiÄ™dzy logicznÄ… pojemnoĹ›ciÄ… dysku a fizycznym rozmiarem pliku na hoĹ›cie.

PrzykĹ‚adowo dynamiczny VHDX o pojemnoĹ›ci logicznej 2 GiB zajmowaĹ‚ poczÄ…tkowo okoĹ‚o 4 MiB.

Przetestowano rĂłwnieĹĽ relacjÄ™ parent-child:

Base-Parent.vhdx
    |
    +-- Child-Differencing.vhdx

Relacja zostaĹ‚a zweryfikowana przy uĹĽyciu Get-VHD.

## 8. Generation 1 i Generation 2

Utworzono:

- LAB-GEN1-001,
- LAB-GEN2-001.

Generation 1 wykazaĹ‚a:

- BIOS,
- kontrolery IDE,
- kontroler SCSI,
- starszy model urzÄ…dzeĹ„ startowych.

Generation 2 wykazaĹ‚a:

- UEFI,
- SCSI,
- Secure Boot,
- szablon MicrosoftWindows.

Do dalszych wspĂłĹ‚czesnych laboratoriĂłw przyjÄ™to Generation 2 jako konfiguracjÄ™ domyĹ›lnÄ….

## 9. PamiÄ™Ä‡ RAM

Przetestowano Dynamic Memory oraz Static Memory.

LAB-MEM-001:

- Dynamic Memory: Enabled,
- Minimum: 1 GiB,
- Startup: 2 GiB,
- Maximum: 4 GiB,
- Buffer: 20,
- Priority: 50.

LAB-MEM-STATIC-001:

- Dynamic Memory: Disabled,
- Startup: 2 GiB.

Zaobserwowano rĂłwnieĹĽ, ĹĽe maszyny utworzone na badanym hoĹ›cie przez New-VM domyĹ›lnie posiadaĹ‚y Dynamic Memory wĹ‚Ä…czone.

Wniosek:

Skrypty automatyzujÄ…ce powinny jawnie definiowaÄ‡ tryb pamiÄ™ci zamiast polegaÄ‡ na konfiguracji domyĹ›lnej hosta.

## 10. Procesory wirtualne

Przetestowano:

- Count,
- Reserve,
- Maximum,
- RelativeWeight,
- ExposeVirtualizationExtensions.

LAB-CPU-001:

- 2 vCPU,
- Reserve 0,
- Maximum 100,
- RelativeWeight 100.

LAB-CPU-002:

- 2 vCPU,
- Reserve 0,
- Maximum 100,
- RelativeWeight 200.

Nested virtualization pozostawiono wyĹ‚Ä…czonÄ….

## 11. Secure Boot i vTPM

Utworzono LAB-SEC-001.

KoĹ„cowa konfiguracja:

- Generation 2,
- Secure Boot: On,
- SecureBootTemplate: MicrosoftWindows,
- Local Key Protector: configured,
- vTPM: Enabled,
- Shielded: False.

Nie wdraĹĽano Guarded Fabric ani Host Guardian Service.

## 12. Enhanced Session Mode

Na hoĹ›cie potwierdzono:

EnableEnhancedSessionMode = True.

Polityka Enhanced Session Mode zostaĹ‚a rĂłwnieĹĽ zweryfikowana w Hyper-V Manager.

PeĹ‚ny test funkcjonalny VMConnect zostaĹ‚ odroczony do momentu instalacji systemu Windows wewnÄ…trz maszyny wirtualnej.

## 13. Checkpointy

Utworzono LAB-CHK-001.

Przetestowano Standard checkpoint, jego enumeracjÄ™ oraz usuniÄ™cie.

KoĹ„cowo ustawiono:

- AutomaticCheckpointsEnabled: False,
- CheckpointType: ProductionOnly.

PeĹ‚ny Production Checkpoint zostanie zweryfikowany na maszynie posiadajÄ…cej dziaĹ‚ajÄ…cy system goĹ›cia.

## 14. Eksport i import VM

Utworzono LAB-EXP-001 z dynamicznym VHDX.

MaszynÄ™:

1. wyeksportowano,
2. zaimportowano jako kopiÄ™,
3. wygenerowano nowy VM ID,
4. zapisano VHDX kopii w niezaleĹĽnej lokalizacji.

PowstaĹ‚a:

LAB-EXP-001-COPY

OryginaĹ‚ i kopia posiadaĹ‚y rĂłĹĽne identyfikatory oraz niezaleĹĽne pliki VHDX.

## 15. Klonowanie rĂłĹĽnicowe

Utworzono:

LAB-CLONE-BASE.vhdx

oraz dwa dyski potomne:

- LAB-CLONE-A.vhdx,
- LAB-CLONE-B.vhdx.

Oba dyski typu Differencing wskazywaĹ‚y na ten sam plik nadrzÄ™dny.

Utworzono rĂłwnieĹĽ niezaleĹĽne maszyny:

- LAB-CLONE-A,
- LAB-CLONE-B.

Zweryfikowano poprawnoĹ›Ä‡ Ĺ‚aĹ„cuchĂłw parent-child.

## 16. Automatyzacja

Utworzono narzÄ™dzie:

03_tools/hyper-v/New-CyberLabVM.ps1

Skrypt:

- waliduje parametry,
- odczytuje konfiguracjÄ™ hosta,
- tworzy Generation 2 VM,
- tworzy dynamiczny VHDX,
- konfiguruje RAM,
- konfiguruje vCPU,
- ustawia ProductionOnly,
- wyĹ‚Ä…cza Automatic Checkpoints,
- ustawia Secure Boot,
- opcjonalnie wĹ‚Ä…cza vTPM,
- opcjonalnie podĹ‚Ä…cza VM do wskazanego vSwitcha,
- obsĹ‚uguje -WhatIf.

Parser PowerShell zwrĂłciĹ‚:

PASS â€” no syntax errors.

Test -WhatIf nie utworzyĹ‚ VM ani pliku VHDX.

NastÄ™pnie LAB-AUTO-001 zostaĹ‚a utworzona poprawnie.

KoĹ„cowy profil:

- Generation: 2,
- vCPU: 2,
- Dynamic Memory: 1 / 2 / 4 GiB,
- Secure Boot: On,
- vTPM: Enabled,
- CheckpointType: ProductionOnly,
- Automatic Checkpoints: Disabled,
- VHDX: D:\Hyper-V\Virtual Hard Disks\LAB-AUTO-001\LAB-AUTO-001.vhdx.

## 17. Diagnostyka

Utworzono narzÄ™dzie:

03_tools/hyper-v/Invoke-HyperVDiagnostics.ps1

KoĹ„cowy audyt zweryfikowaĹ‚:

- funkcje Hyper-V,
- usĹ‚ugi,
- moduĹ‚ PowerShell,
- konfiguracjÄ™ hosta,
- wersje konfiguracji VM,
- przeĹ‚Ä…czniki,
- maszyny,
- Secure Boot i vTPM,
- adaptery sieciowe,
- dyski wirtualne,
- relacje differencing,
- dzienniki zdarzeĹ„ Hyper-V.

KoĹ„cowy wynik:

PASS â€” Hyper-V basic health check passed.

Nie wykryto:

- brakujÄ…cych podĹ‚Ä…czonych VHD/VHDX,
- zerwanych relacji parent-child,
- zatrzymanych podstawowych usĹ‚ug Hyper-V,
- wyĹ‚Ä…czonych wymaganych skĹ‚adnikĂłw Hyper-V.

## 18. Obserwacja diagnostyczna

W dzienniku:

Microsoft-Windows-Hyper-V-VmSwitch-Operational

zaobserwowano powtarzajÄ…ce siÄ™ ostrzeĹĽenia:

Event ID 285

dotyczÄ…ce Default Switch.

OstrzeĹĽenia nie wpĹ‚ynÄ™Ĺ‚y na wynik podstawowego health checku.

Stan zostaĹ‚ zapisany jako obserwacja do dalszej weryfikacji podczas laboratoriĂłw dotyczÄ…cych sieci Hyper-V.

Na tym etapie nie dokonywano zmian w Default Switch.

## 19. Dowody

Evidence:

02_labs/evidence/LAB-HV-001/

Pliki:

- event-285-summary.csv
- hyper-v-features.csv
- hyper-v-final-diagnostics.txt
- hyper-v-host.csv
- hyper-v-services.csv
- supported-vm-versions.csv
- vhd-inventory.csv
- virtual-machines.csv
- virtual-switches.csv
- vm-security.csv

## 20. Wynik

PASS WITH OBSERVATION

Hyper-V zostaĹ‚ poprawnie zainstalowany, skonfigurowany i zweryfikowany.

Host jest gotowy do budowy wĹ‚aĹ›ciwego Ĺ›rodowiska maszyn wirtualnych wykorzystywanego w dalszych laboratoriach projektu.

Otwarte elementy:

- peĹ‚ny test Enhanced Session Mode po instalacji systemu goĹ›cia,
- peĹ‚ny Production Checkpoint na dziaĹ‚ajÄ…cym systemie goĹ›cia,
- projekt wĹ‚asnych sieci Hyper-V,
- obserwacja Event ID 285 podczas dalszych testĂłw sieciowych.

## 21. Cleanup po laboratorium

Po zabezpieczeniu materiaĹ‚u dowodowego wykonano kontrolowany cleanup Ĺ›rodowiska LAB-HV-001.

UsuniÄ™to 13 tymczasowych maszyn wirtualnych oraz powiÄ…zane testowe VHD/VHDX i katalog eksportu.

Po cleanupie zweryfikowano:

- liczba zarejestrowanych VM: 0,
- Default Switch: zachowany,
- VirtualMachinePath: D:\Hyper-V\Virtual Machines,
- VirtualHardDiskPath: D:\Hyper-V\Virtual Hard Disks,
- Enhanced Session Mode: nadal wĹ‚Ä…czony,
- podstawowa konfiguracja hosta Hyper-V: zachowana.

Cleanup zakoĹ„czyĹ‚ siÄ™ wynikiem PASS.
