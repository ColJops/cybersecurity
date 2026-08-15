# Raport laboratorium

- ID laboratorium: LAB-WIN-002
- Tytuł: Hardening i bazowa konfiguracja bezpieczeństwa Windows 11 Pro
- Data: 2026-08-15
- Autor: Daniel Kupracz
- Status: executed
- Cel: Zweryfikowanie i utwardzenie podstawowych mechanizmów bezpieczeństwa fizycznego hosta Windows 11 Pro przed dalszymi laboratoriami projektu „Cyberbezpieczeństwo”.
- Autoryzacja i zasady bezpieczeństwa: Zmiany wykonano wyłącznie na własnym komputerze gospodarza. Operacje modyfikujące konfigurację poprzedzano odczytem stanu. Sekrety, recovery password i szczegółowe identyfikatory nie są umieszczane w Git.
- Wymagania wstępne: Windows 11 Pro 25H2, dostęp administracyjny/UAC, TPM 2.0, możliwość konfiguracji UEFI.
- Topologia: pojedynczy fizyczny host Windows 11 Pro.
- Wersje systemów i narzędzi: Microsoft Windows 11 Pro 25H2, build 26200.9168; Windows PowerShell 5.1; wbudowane moduły NetSecurity, BitLocker i TrustedPlatformModule.
- Migawka początkowa: `TR-2026-002` / `LAB-WIN-001` jako baseline gotowości hosta.

## Hipoteza i kryteria sukcesu

### Hipoteza

Host Windows 11 Pro może zostać utwardzony bez utraty zgodności z dotychczasowym sposobem pracy, przy zachowaniu funkcji developerskich i laboratoryjnych.

### Kryteria sukcesu

1. System posiada aktualny poziom aktualizacji bezpieczeństwa.
2. Architektura AV jest jednoznaczna i nie wymusza dwóch aktywnych silników ochrony czasu rzeczywistego.
3. Wszystkie profile Windows Firewall są aktywne, a logowanie zapory działa.
4. Secure Boot i TPM 2.0 są aktywne.
5. C: jest chroniony BitLockerem z TPM i Recovery Password.
6. Smart App Control, UAC, LSA Protection, VBS/HVCI i bloklista podatnych sterowników działają.
7. Ochrona ransomware jest aktywna w używanym rozwiązaniu AV.
8. Audit Logon i Audit Process Creation zapewniają bazową telemetrię.
9. Istnieje punkt przywracania po hardeningu.
10. Dowody przeznaczone do Git są zanonimizowane/sanitizowane.

## Procedura

1. Zweryfikowano Windows 11 Pro 25H2, build 26200.9168 i KB5121003.
2. Zaktualizowano security intelligence Microsoft Defender do 1.457.164.0.
3. Potwierdzono Avast Antivirus jako główny AV i Defender `Passive Mode`.
4. Zweryfikowano UAC, konta lokalne i wbudowane konta Administrator/Gość.
5. Zweryfikowano i utwardzono Windows Firewall: logowanie allow/block, osobne logi per profil, 20 MB per profil.
6. Zawężono reguły μTorrent z Any/Any do Private/46927 dla TCP i UDP.
7. Zweryfikowano SMB; SMB1 jest wyłączony, brak własnych udziałów.
8. Potwierdzono Smart App Control w `Enforcement` i aktywne warstwy SmartScreen.
9. Włączono Secure Boot w UEFI i potwierdzono po restarcie.
10. Zweryfikowano TPM 2.0.
11. Włączono BitLocker wyłącznie na C:; osiągnięto 100% szyfrowania XTS-AES 128, `Protection On`.
12. Wykonano test restartowy BitLocker/TPM — system uruchomił się bez recovery prompt.
13. Pozostawiono jedno codzienne konto w grupie Administratorzy jako świadomie zaakceptowane ryzyko przy aktywnym UAC/Secure Desktop.
14. Skonfigurowano Windows Hello.
15. Potwierdzono LSA Protection i Wininit ID 12.
16. Potwierdzono VBS/HVCI i Vulnerable Driver Blocklist.
17. Zweryfikowano Avast Ransomware Shield w trybie inteligentnym.
18. ASR i Microsoft CFA oznaczono jako N/A przy Defender Passive Mode.
19. Zwiększono retencję podstawowych logów i włączono Audit Process Creation.
20. Utworzono `LAB-WIN-002 post-hardening baseline` w System Restore.
21. Wygenerowano sanitizowany pakiet evidence.

## Wyniki i dowody

Końcowy wynik: **PASS / HARDENED**.

Najważniejsze wyniki:

- Secure Boot: włączony.
- TPM 2.0: Present / Ready / Enabled / Activated / Owned.
- BitLocker C:: 100%, XTS-AES 128, Protection On, TPM + Recovery Password.
- D:/E:/F:: bez BitLockera zgodnie z decyzją użytkownika.
- Smart App Control: Enforcement.
- VBS: running.
- HVCI/Memory Integrity: running.
- Vulnerable Driver Blocklist: enabled.
- UAC + Secure Desktop: enabled.
- LSA Protection: enabled.
- Windows Hello: skonfigurowane.
- Windows Firewall: wszystkie profile enabled, inbound Block, outbound Allow, logging hardened.
- Audit Process Creation: Success, event 4688 potwierdzony.
- Ransomware Shield: active / Smart.
- Restore point: `LAB-WIN-002 post-hardening baseline`.

### Dowody

`02_labs/evidence/LAB-WIN-002/`

- `security-baseline.md`
- `firewall-baseline.md`
- `platform-security.md`
- `logging-baseline.md`
- `evidence-manifest.md`

Pełne dane robocze pozostają lokalnie w `private_local/LAB-WIN-002/` i nie podlegają wersjonowaniu.

## Błędy i diagnostyka

1. `Get-ComputerInfo` zwracał legacy `WindowsProductName=Windows 10 Pro`; właściwy stan potwierdzono przez `Win32_OperatingSystem` i rejestr CurrentVersion.
2. Wklejanie bloków wielowierszowych w Windows Terminal powodowało problemy z konstrukcjami `else`/`foreach`; później stosowano polecenia jednoliniowe.
3. Defender RTP=False został wyjaśniony jako oczekiwany stan `Passive Mode` przy aktywnym Avast.
4. Wykryto wyłączone logowanie Windows Firewall — naprawiono.
5. Wykryto szerokie reguły μTorrent — naprawiono przez ograniczenie profilu i portu.
6. Secure Boot był wyłączony — włączono i zweryfikowano.
7. BitLocker był celowo wyłączony po reinstalacji i zmianie układu partycji — włączono tylko na C: po pre-checku TPM/Secure Boot/WinRE/GPT.
8. Audit Process Creation był wyłączony — włączono i zweryfikowano 4688.
9. Oddzielne konto administratora nie zostało utworzone — `ACCEPTED RISK`.

## Wnioski

Host ma obecnie znacząco mocniejszy baseline bezpieczeństwa, przy zachowaniu ergonomii pracy developerskiej i laboratoryjnej.

Ryzyka/odroczenia:

- oddzielne konto administratora — accepted risk,
- pełny image backup — deferred,
- ASR i Microsoft CFA — N/A przy Defender Passive Mode,
- zaawansowane PowerShell logging / WEF / Sysmon — deferred do rozdziału monitoringu,
- `TPM RestartPending=True` — INFO; TPM jest Ready/Owned, a test BitLocker po restarcie przeszedł poprawnie,
- dodatkowe opcje Enhanced Phishing Protection (reuse/unsafe storage) — końcowy stan nie został zweryfikowany w evidence.

## Procedura odtworzenia

1. Zweryfikować build i aktualizacje Windows.
2. Sprawdzić architekturę AV i tryb Defendera.
3. Sprawdzić profile, politykę i logi Windows Firewall.
4. Zweryfikować Smart App Control / SmartScreen.
5. Sprawdzić Secure Boot, TPM i BitLocker C: bez ujawniania recovery password.
6. Zweryfikować UAC, Windows Hello i LSA Protection.
7. Zweryfikować VBS/HVCI i driver blocklist.
8. Sprawdzić ochronę ransomware.
9. Sprawdzić Audit Logon/Process Creation i limity logów.
10. Zweryfikować System Restore i post-hardening checkpoint.
11. Przed commitem przeprowadzić kontrolę prywatności evidence.

## Ocena powtarzalności

- [x] procedura wykonana krok po kroku i zweryfikowana poleceniami kontrolnymi
- [x] zmiany krytyczne potwierdzone po restarcie
- [x] stan końcowy opisany w kontrolowanym evidence
- [ ] laboratorium nie zostało wykonane ponownie od czystej instalacji

Ocena końcowa: **R1 — odtwarzalne przez autora**.
