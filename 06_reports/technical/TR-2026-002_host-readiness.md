# TR-2026-002 — Ocena gotowości hosta do laboratoriów cyberbezpieczeństwa

- ID raportu: TR-2026-002
- Powiązane laboratorium: LAB-WIN-001
- Data: 2026-08-14
- Autor: Daniel Kupracz
- Status: final
- Klasyfikacja: techniczny / wewnętrzny
- Narzędzie: `Invoke-HostReadinessAudit.ps1` v1.2

## 1. Cel raportu

Celem raportu jest przedstawienie technicznej oceny komputera gospodarza przeznaczonego do realizacji laboratoriów projektu „Cyberbezpieczeństwo”.

Raport podsumowuje wyniki laboratorium `LAB-WIN-001`, ze szczególnym uwzględnieniem:

- zgodności systemu operacyjnego,
- możliwości wirtualizacji,
- zasobów procesora i pamięci,
- dostępnej przestrzeni dyskowej,
- przydatności poszczególnych nośników do aktywnych maszyn wirtualnych,
- podstawowej kondycji wydajnościowej hosta,
- zasad bezpiecznego przechowywania wyników diagnostycznych.

## 2. Podsumowanie wykonawcze

Host uzyskał wynik:

**READY — profil STANDARD**

Komputer spełnia wymagania przyjęte dla podstawowej platformy laboratoryjnej projektu.

Najważniejsze wyniki:

- Windows 11 Pro, build 26200,
- 32 GiB zainstalowanej pamięci RAM,
- procesor 6-rdzeniowy / 12-wątkowy,
- aktywny hypervisor Windows,
- efektywne wymagania SLAT i VM Monitor Mode Extensions spełnione,
- około 1067,8 GiB wolnej przestrzeni na nośnikach zakwalifikowanych do aktywnych VM,
- brak oznak istotnego przeciążenia podczas krótkiej próbki wydajnościowej,
- nośniki USB prawidłowo wykluczone z preferowanego magazynu aktywnych maszyn wirtualnych.

## 3. Środowisko

### 3.1. System

- System operacyjny: Microsoft Windows 11 Pro
- Build: 26200
- Architektura: 64-bit
- Sesja audytu: uruchomiona z uprawnieniami administratora

### 3.2. Procesor

- Model: Intel Core i5-10400F
- Rdzenie: 6
- Procesory logiczne: 12

### 3.3. Pamięć

- Zainstalowana pamięć RAM: 32 GiB
- Pamięć widoczna dla Windows: 31,91 GiB
- Konfiguracja: 4 × 8 GiB Kingston

## 4. Wirtualizacja

Audyt wykazał obecność aktywnego hypervisora Windows.

Właściwości zwracane bezpośrednio przez `Win32_Processor` dla:

- `VirtualizationFirmwareEnabled`,
- `VMMonitorModeExtensions`,
- `SLAT`

zwracały wartości `False`.

Przy aktywnym hypervisorze wartości te nie zostały uznane za rozstrzygające. Skrypt v1.2 stosuje dlatego ocenę efektywną, uwzględniającą obecność działającego hypervisora.

Wynik końcowy:

- `VMMonitorModeExtensionsEffective`: True
- `SLATEffective`: True
- `VirtualizationEnabledOrHypervisorPresent`: True

Pełna opcjonalna funkcja `Microsoft-Hyper-V-All` pozostaje obecnie wyłączona. Jej instalacja i konfiguracja zostaną wykonane w osobnym laboratorium dotyczącym Hyper-V.

## 5. Magazyny danych

### 5.1. Nośniki przeznaczone do aktywnych VM

**C:**
- wewnętrzny NVMe,
- około 769,61 GiB wolnego,
- dopuszczony do aktywnych VM.

**D:**
- wewnętrzny SSD,
- około 298,16 GiB wolnego,
- dopuszczony do aktywnych VM.

Łączna wolna przestrzeń preferowana dla aktywnych maszyn wirtualnych wynosi około:

**1067,8 GiB**

### 5.2. Nośniki wykluczone

**E:**
- zewnętrzny HDD 2,5",
- 5200 RPM,
- połączenie USB,
- około 9,21 GiB wolnego,
- przeznaczenie: pobieranie plików, archiwum i dane pomocnicze,
- wykluczony z aktywnych VM.

**F:**
- pendrive USB,
- system plików exFAT,
- przeznaczenie: nośnik transportowy i magazyn projektu,
- wykluczony z aktywnych VM.

## 6. Stan nośników

Wszystkie wykryte dyski raportowały stan:

- `HealthStatus: Healthy`
- `OperationalStatus: OK`

Dla zewnętrznego HDD uzyskano wiarygodny odczyt temperatury około 37°C.

Wartości temperatur 0–1°C zwracane przez niektóre kontrolery zostały w wersji 1.2 skryptu uznane za niewiarygodne i zapisane jako brak danych.

Wartość `Wear = 0` nie jest interpretowana jako jednoznaczne potwierdzenie zerowego zużycia, ponieważ dostępność i znaczenie tego licznika zależą od kontrolera.

## 7. Próbka wydajności

Zebrano 15 próbek.

Wyniki:

- średnie użycie CPU: 7,27%,
- maksymalne użycie CPU: 23%,
- średnia dostępna pamięć: 21557,93 MB,
- minimalna dostępna pamięć: 21511 MB,
- średnia liczba transferów dyskowych na sekundę: 219,2,
- średnia długość kolejki dysku: 0,07,
- maksymalna długość kolejki dysku: 1.

W czasie pomiaru nie stwierdzono oznak istotnego przeciążenia hosta.

## 8. Problemy wykryte podczas audytu

Podczas rozwijania i wykonywania audytu wykryto kilka problemów:

1. Pierwsze uruchomienie wykonano bez podniesionych uprawnień, co powodowało odmowę dostępu do części danych CIM.
2. Pierwsza wersja skryptu zawierała błąd obsługi właściwości `Count`.
3. Pierwotna logika błędnie traktowała wartości `False` z `Win32_Processor` jako brak SLAT i VM Monitor Mode Extensions przy aktywnym hypervisorze.
4. Pamięć 31,91 GiB widoczna dla Windows prowadziła do błędnej klasyfikacji profilu mimo fizycznie zainstalowanych 32 GiB.
5. Nośniki USB były początkowo uwzględniane w całkowitej wolnej przestrzeni magazynu VM.
6. Część kontrolerów zwracała niewiarygodne temperatury 0–1°C.
7. Surowy wynik `systeminfo.exe` ujawnił dane, których nie należy domyślnie przechowywać w publicznym repozytorium.

Problemy te zostały uwzględnione w wersji 1.2 narzędzia.

## 9. Prywatność i OPSEC

Pełny wynik audytu zawiera informacje umożliwiające szczegółowe profilowanie stanowiska.

Z tego powodu:

- numery seryjne i identyfikatory modułów są ukrywane,
- surowy `systeminfo.exe` nie jest zapisywany domyślnie,
- pełny zestaw wyników jest przechowywany lokalnie w `private_local`,
- do repozytorium trafia wyłącznie kontrolowany pakiet dowodowy,
- `private_local/` jest wykluczony przez `.gitignore`.

Pakiet dowodowy laboratorium znajduje się w:

`02_labs/evidence/LAB-WIN-001/`

Pełne dane robocze pozostają w:

`private_local/host-audits/LAB-WIN-001_20260814_165955/`

## 10. Zalecenia

1. Wykorzystywać C: i D: jako podstawowe magazyny aktywnych VM.
2. Nie uruchamiać aktywnych VM z dysku E: ani z pendrive F:.
3. Zwolnić miejsce na E:, jeśli dysk ma dalej pełnić funkcję magazynu pomocniczego.
4. Zachować minimum kilku–kilkunastu GiB RAM dla systemu gospodarza przy projektowaniu scenariuszy wielomaszynowych.
5. Włączyć i skonfigurować pełną rolę Hyper-V dopiero w dedykowanym laboratorium.
6. Kontynuować oddzielanie surowych danych diagnostycznych od materiałów przeznaczonych do Git.
7. Przy istotnych zmianach sprzętu, BIOS/UEFI, systemu lub platformy wirtualizacyjnej powtórzyć audyt.

## 11. Ocena końcowa

Komputer gospodarza jest odpowiedni do realizacji planowanych laboratoriów projektu „Cyberbezpieczeństwo”.

**Status końcowy: READY**

**Profil: STANDARD**

Ograniczeniem nie jest obecnie podstawowa wydajność hosta, lecz konieczność rozsądnego planowania liczby jednocześnie uruchomionych maszyn wirtualnych oraz właściwego rozmieszczenia ich dysków.

## 12. Powiązane artefakty

- Laboratorium: `02_labs/completed/LAB-WIN-001_host-readiness.md`
- Dowody: `02_labs/evidence/LAB-WIN-001/`
- Narzędzie: `03_tools/host-readiness/Invoke-HostReadinessAudit.ps1`
- Raport techniczny: `06_reports/technical/TR-2026-002_host-readiness.md`
