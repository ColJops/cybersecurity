# Raport laboratorium

- ID laboratorium: LAB-WIN-001
- Tytuł: Ocena gotowości hosta do laboratoriów cyberbezpieczeństwa
- Data: 2026-08-14
- Autor: Daniel Kupracz
- Status: executed
- Cel: Zweryfikowanie, czy komputer gospodarza spełnia wymagania sprzętowe, systemowe, wirtualizacyjne i magazynowe niezbędne do realizacji laboratoriów projektu „Cyberbezpieczeństwo”.
- Autoryzacja i zasady bezpieczeństwa: Audyt wykonano wyłącznie na własnym komputerze gospodarza. Skrypt działa w trybie tylko do odczytu. Dane mogące identyfikować sprzęt, takie jak numery seryjne i identyfikatory modułów pamięci, są ukrywane. Surowy wynik `systeminfo.exe` nie jest zapisywany domyślnie.
- Wymagania wstępne: Windows 11 Pro, Windows PowerShell uruchomiony jako administrator, możliwość wykonywania lokalnych skryptów PowerShell.
- Topologia: Pojedynczy fizyczny host Windows 11 Pro; bez uruchamiania maszyn wirtualnych podczas audytu.
- Wersje systemów i narzędzi: Microsoft Windows 11 Pro build 26200; `Invoke-HostReadinessAudit.ps1` v1.2; Windows PowerShell.
- Migawka początkowa: Nie dotyczy — audyt wykonywany na fizycznym hoście w trybie tylko do odczytu.

## Hipoteza i kryteria sukcesu

### Hipoteza

Komputer gospodarza posiada wystarczające zasoby sprzętowe i funkcje wirtualizacji, aby pełnić rolę podstawowej platformy laboratoryjnej projektu „Cyberbezpieczeństwo”.

### Kryteria sukcesu

1. System operacyjny spełnia wymagania Hyper-V.
2. Dostępne są wymagane mechanizmy wirtualizacji sprzętowej.
3. Host posiada co najmniej 32 GiB zainstalowanej pamięci RAM dla profilu standard.
4. Dostępna jest wystarczająca ilość miejsca na wewnętrznych nośnikach przeznaczonych dla aktywnych maszyn wirtualnych.
5. Nośniki zewnętrzne i wymienne nie są klasyfikowane jako preferowany magazyn aktywnych VM.
6. Host nie wykazuje podczas próbki pomiarowej oznak istotnego przeciążenia CPU, pamięci lub podsystemu dyskowego.
7. Wyniki audytu nie zawierają niepotrzebnie ujawnionych danych wrażliwych.

## Procedura

1. Uruchomiono Windows PowerShell jako administrator.
2. Przejście do katalogu narzędzi projektu:

   ```powershell
   Set-Location F:\Cyberbezpieczenstwo\03_tools
   ```

3. Dla bieżącego procesu ustawiono politykę wykonywania skryptów:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
   ```

4. Uruchomiono:

   ```powershell
   .\Invoke-HostReadinessAudit.ps1
   ```

5. Skrypt zebrał informacje dotyczące:
   - systemu operacyjnego,
   - procesora,
   - pamięci RAM,
   - wirtualizacji,
   - dysków fizycznych,
   - woluminów,
   - dostępnego miejsca,
   - stanu nośników,
   - krótkiej próbki wydajności.

6. Zweryfikowano raport końcowy oraz pliki CSV.
7. Oddzielono bezpieczny pakiet dowodowy od pełnych danych roboczych.
8. Pełny zestaw danych audytu przeniesiono do `private_local`, który jest ignorowany przez Git.

## Wyniki i dowody

Końcowy wynik audytu:

- Status: **READY**
- Profil zasobów: **standard**
- System: Microsoft Windows 11 Pro, build 26200
- Zainstalowana pamięć RAM: **32 GiB**
- Pamięć RAM widoczna przez Windows: **31,91 GiB**
- Preferowana wolna przestrzeń dla aktywnych VM: **1067,8 GiB**
- Hypervisor obecny: **True**
- Sesja audytu uruchomiona z podniesionymi uprawnieniami: **True**

Obowiązkowe testy platformy:

- `Windows11ProOrEnterprise`: True
- `VMMonitorModeExtensionsEffective`: True
- `SLATEffective`: True
- `VirtualizationEnabledOrHypervisorPresent`: True

### Magazyny danych

- **C:** — wewnętrzny NVMe, 769,61 GiB wolnego, dopuszczony jako magazyn aktywnych VM.
- **D:** — wewnętrzny SSD, 298,16 GiB wolnego, dopuszczony jako magazyn aktywnych VM.
- **E:** — zewnętrzny HDD 5200 RPM podłączony przez USB, 9,21 GiB wolnego, wykluczony z magazynu aktywnych VM.
- **F:** — pendrive USB, wykluczony z magazynu aktywnych VM.

### Próbka wydajności

- Liczba próbek: 15
- Średnie użycie CPU: 7,27%
- Maksymalne użycie CPU: 23%
- Średnia dostępna pamięć: 21557,93 MB
- Minimalna dostępna pamięć: 21511 MB
- Średnia liczba transferów dyskowych na sekundę: 219,2
- Średnia długość kolejki dysku: 0,07
- Maksymalna długość kolejki dysku: 1

### Dowody

Pakiet dowodowy:

`02_labs/evidence/LAB-WIN-001/`

Zawiera:

- `host-assessment.md`
- `memory-modules.csv`
- `performance-summary.csv`
- `physical-disks.csv`
- `processors.csv`
- `systeminfo-privacy-note.txt`
- `volumes.csv`

Pełny zestaw roboczy został zachowany lokalnie w:

`private_local/host-audits/LAB-WIN-001_20260814_165955/`

i nie podlega wersjonowaniu przez Git.

## Błędy i diagnostyka

Podczas pierwszej próby audytu wystąpił błąd dostępu do `Get-StorageReliabilityCounter`, ponieważ PowerShell nie został uruchomiony jako administrator.

W pierwszej wersji skryptu wykryto również błąd obsługi właściwości `Count` przy pracy z pojedynczym obiektem PowerShell.

Kolejna wersja ujawniła problem interpretacyjny: przy aktywnym hypervisorze właściwości `Win32_Processor` dotyczące SLAT i rozszerzeń VM Monitor mogą zwracać wartości `False`, mimo że mechanizmy wirtualizacji faktycznie działają.

W wersji 1.2:

- wprowadzono efektywną ocenę wymagań wirtualizacyjnych,
- poprawiono klasyfikację pamięci RAM,
- dodano mapowanie woluminów na dyski fizyczne,
- wykluczono magistrale USB z preferowanego magazynu VM,
- poprawiono interpretację niewiarygodnych temperatur 0–1°C,
- poprawiono zbieranie próbek wydajności na polskim Windows,
- domyślnie wyłączono zapis surowego `systeminfo.exe`.

## Wnioski

Host spełnia wymagania projektu i może być wykorzystywany jako podstawowa platforma laboratoryjna.

Komputer został zakwalifikowany jako:

**READY — profil STANDARD**

Do przechowywania aktywnych maszyn wirtualnych należy wykorzystywać przede wszystkim wewnętrzne nośniki C: i D:.

Zewnętrzny dysk E: może służyć jako magazyn plików, obrazów ISO, archiwów i danych pomocniczych, ale ze względu na połączenie USB, niską prędkość obrotową 5200 RPM oraz bardzo małą ilość wolnego miejsca nie powinien być wykorzystywany do aktywnych VM.

Pendrive F: powinien pozostać nośnikiem transportowym i magazynem projektu, a nie magazynem aktywnych maszyn wirtualnych.

Pełna funkcja `Microsoft-Hyper-V-All` jest obecnie wyłączona, mimo że Windows hypervisor jest aktywny. Konfiguracja pełnego środowiska Hyper-V zostanie wykonana w odpowiednim laboratorium dotyczącym wirtualizacji.

## Procedura odtworzenia

1. Uruchomić Windows PowerShell jako administrator.
2. Przejść do katalogu zawierającego `Invoke-HostReadinessAudit.ps1`.
3. Ustawić dla bieżącego procesu politykę:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
   ```

4. Uruchomić:

   ```powershell
   .\Invoke-HostReadinessAudit.ps1
   ```

5. Sprawdzić końcowy status audytu.
6. Zweryfikować `host-assessment.md`.
7. Zweryfikować woluminy i nośniki przeznaczone dla VM.
8. Zweryfikować próbkę wydajności.
9. Przed umieszczeniem dowodów w repozytorium przeprowadzić kontrolę prywatności.

## Ocena powtarzalności

- [x] odtworzone bez instrukcji
- [x] wykonane drugi raz po poprawieniu procedury i narzędzia
- [x] wersje i dowody kompletne

Ocena końcowa: **wysoka powtarzalność**.
