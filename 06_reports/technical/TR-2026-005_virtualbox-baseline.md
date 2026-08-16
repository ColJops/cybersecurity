# TR-2026-005 — Oracle VirtualBox baseline

## 1. Informacje ogólne

- Report ID: TR-2026-005
- Laboratory: LAB-VBX-001
- Domain: virtualization
- Platform: Windows 11 Pro 25H2 / Oracle VirtualBox
- Result: **PASS**
- Evidence: `02_labs/evidence/LAB-VBX-001`
- Laboratory report: `02_labs/completed/LAB-VBX-001_virtualbox-installation-and-audit.md`

## 2. Cel

Celem laboratorium było przygotowanie Oracle VirtualBox jako
pomocniczej platformy wirtualizacyjnej na hoście, na którym
Microsoft Hyper-V pozostaje głównym hypervisorem.

Istotnym wymaganiem było zachowanie istniejącego poziomu
bezpieczeństwa hosta. Instalacja VirtualBox nie mogła wymagać
wyłączenia Hyper-V, Virtualization Based Security ani HVCI.

## 3. Stan początkowy

Przed rozpoczęciem instalacji:

- Microsoft Hyper-V był zainstalowany i aktywny;
- hypervisor Windows był uruchamiany podczas startu systemu;
- Virtualization Based Security było aktywne;
- HVCI pozostawało aktywne;
- Windows Hypervisor Platform było wyłączone;
- Virtual Machine Platform było wyłączone;
- Oracle VirtualBox nie był zainstalowany;
- nie istniały interfejsy sieciowe VirtualBox.

## 4. Przygotowanie hosta

W celu umożliwienia współpracy VirtualBox z aktywnym hypervisorem
Microsoft włączono:

`HypervisorPlatform`

Nie włączano:

`VirtualMachinePlatform`

Nie wyłączano:

- Microsoft Hyper-V;
- VBS;
- HVCI;
- hypervisorlaunchtype Auto.

Po ponownym uruchomieniu systemu potwierdzono:

- `HypervisorPresent: True`;
- Hyper-V: Enabled;
- HypervisorPlatform: Enabled;
- VirtualMachinePlatform: Disabled;
- VirtualizationBasedSecurityStatus: 2.

## 5. Weryfikacja instalatora

Przed instalacją zweryfikowano instalator:

`VirtualBox-7.2.14-174565-Win.exe`

Kontrola obejmowała:

- SHA-256;
- podpis Authenticode;
- certyfikat podpisujący;
- metadane wersji pliku.

Wynik:

- SHA-256: **MATCH**;
- Authenticode: **Valid**;
- producent: Oracle America, Inc.;
- ProductVersion: 7.2.14.174565.

Instalację rozpoczęto dopiero po pozytywnym zakończeniu
obu kontroli integralności i autentyczności.

## 6. Zainstalowane komponenty

Zainstalowano:

- Oracle VirtualBox 7.2.14r174565;
- podstawowy sterownik VirtualBox;
- Host-only Networking;
- Bridged Networking.

Celowo nie instalowano:

- VirtualBox USB Support;
- VirtualBox Python Support.

Decyzja ogranicza liczbę dodatkowych komponentów hosta do tych,
które są wymagane w planowanych laboratoriach.

## 7. Sterowniki VirtualBox

Po instalacji wykryto między innymi:

- `VBoxSup`;
- `VBoxNetAdp`;
- `VBoxNetLwf`.

Sterowniki wymagane przez wybraną konfigurację znajdowały się
w stanie prawidłowym.

## 8. Konfiguracja sieci

VirtualBox utworzył interfejs:

`VirtualBox Host-Only Ethernet Adapter`

Potwierdzono również dostępność mechanizmu Bridged Networking.

VirtualBox rozpoznaje fizyczne interfejsy sieciowe hosta,
jednak tryb Bridged nie będzie używany automatycznie.

Dla przyszłych laboratoriów przyjęto zasadę:

- NAT — standardowy dostęp VM do sieci zewnętrznej;
- Host-only — izolowana komunikacja host ↔ VM;
- Internal Network — izolowane laboratoria VM ↔ VM;
- Bridged — wyłącznie wtedy, gdy obecność VM w fizycznej sieci LAN
  jest rzeczywistym wymaganiem ćwiczenia.

## 9. Magazyn maszyn

Utworzono dedykowaną strukturę:

`D:\VirtualBox`

z katalogami:

- `D:\VirtualBox\Virtual Machines`
- `D:\VirtualBox\ISO`
- `D:\VirtualBox\Appliances`
- `D:\VirtualBox\Exports`

Domyślny katalog nowych maszyn został ustawiony na:

`D:\VirtualBox\Virtual Machines`

Pozwala to zachować separację:

- `D:\Hyper-V` — Microsoft Hyper-V;
- `D:\VirtualBox` — Oracle VirtualBox.

Aktywne maszyny nie będą przechowywane na dyskach E: ani F:.

## 10. Extension Pack

Zainstalowano:

`Oracle VirtualBox Extension Pack 7.2.14r174565`

Przed instalacją przeprowadzono weryfikację SHA-256.

Wynik:

- hash: **MATCH**;
- Extension Packs: 1;
- Version: 7.2.14;
- Revision: 174565;
- Usable: true.

## 11. Stan Hyper-V po instalacji

Po instalacji VirtualBox ponownie zweryfikowano hosta.

Microsoft Hyper-V pozostał:

- zainstalowany;
- aktywny;
- dostępny przez PowerShell.

Usługi:

- `vmms`: Running;
- `vmcompute`: Running.

Domyślne ścieżki Hyper-V nie zostały zmienione:

- VM: `D:\Hyper-V\Virtual Machines`;
- VHD: `D:\Hyper-V\Virtual Hard Disks`.

## 12. Stan zabezpieczeń

Po zakończeniu konfiguracji:

- Hyper-V: Enabled;
- Windows Hypervisor Platform: Enabled;
- VBS: Active;
- HVCI: Active;
- hypervisorlaunchtype: Auto.

Nie obniżono poziomu ochrony Windows w celu poprawy wydajności
VirtualBox.

Jest to świadoma decyzja architektoniczna projektu.

VirtualBox pełni funkcję pomocniczą i powinien dostosować się
do zabezpieczonego hosta, a nie odwrotnie.

## 13. Stan końcowy VirtualBox

W chwili zakończenia LAB-VBX-001:

- VirtualBox: 7.2.14r174565;
- Extension Pack: 7.2.14r174565;
- Extension Pack usable: true;
- Default Machine Folder:
  `D:\VirtualBox\Virtual Machines`;
- Host-only Networking: dostępne;
- Bridged Networking: dostępne;
- Registered VMs: 0;
- Running VMs: 0.

Brak maszyn wirtualnych jest stanem oczekiwanym.

Pierwsza VM zostanie utworzona dopiero w kolejnym laboratorium.

## 14. Prywatność evidence

Rozszerzone raporty robocze zawierające lokalne:

- adresy IP;
- adresy MAC;
- GUID interfejsów;
- szczegółowe dane sieciowe

pozostają w `private_local`.

Evidence przeznaczone do repozytorium ograniczono do danych
potrzebnych do wykazania wyniku laboratorium.

## 15. Ocena

**PASS — VirtualBox ready alongside Hyper-V**

Oracle VirtualBox został poprawnie przygotowany jako pomocnicza
platforma wirtualizacyjna.

Microsoft Hyper-V pozostaje głównym hypervisorem projektu.

Nie stwierdzono regresji konfiguracji Hyper-V ani zabezpieczeń VBS/HVCI.

Host jest przygotowany do kolejnych laboratoriów VirtualBox.

## 16. Następny etap

Kolejne laboratorium:

**LAB-VBX-002 — utworzenie pierwszej maszyny VirtualBox,
konfiguracja zasobów i analiza struktury VM.**
