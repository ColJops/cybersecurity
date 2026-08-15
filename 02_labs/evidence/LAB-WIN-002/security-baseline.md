# LAB-WIN-002 — Security baseline

- Data zakończenia: 2026-08-15
- Zakres: sanitizowany stan bezpieczeństwa hosta po hardeningu
- System: Microsoft Windows 11 Pro 25H2
- Build: 26200.9168
- Aktualizacja bezpieczeństwa: KB5121003 zainstalowana

## Ochrona antymalware

- Avast Antivirus: zarejestrowany jako główny produkt AV i aktywny.
- Microsoft Defender Antivirus: `Passive Mode`.
- `RealTimeProtectionEnabled`: False — oczekiwane przy aktywnym zewnętrznym AV.
- Tamper Protection: True.
- Security intelligence: 1.457.164.0.
- Controlled Folder Access: wyłączone / N/A przy Defender Passive Mode.
- ASR: brak skonfigurowanych reguł i wykluczeń; N/A przy Defender Passive Mode.
- Wykluczenia Defendera: jedna wąska ścieżka `C:\Program Files\JetBrains\Rider\r2r`; brak wykluczeń procesów i rozszerzeń.

## Ochrona reputacyjna

- Smart App Control: `Enforcement` (`VerifiedAndReputablePolicyState=1`).
- `VerifiedAndReputableDesktop`: enforced.
- SmartScreen dla Microsoft Edge: włączony.
- Blokowanie PUA w warstwie reputacyjnej: włączone.
- SmartScreen dla aplikacji Microsoft Store: włączony.
- Enhanced Phishing Protection: włączone; podczas audytu dwa dodatkowe ostrzeżenia (reuse/unsafe storage) były wyłączone — późniejsza zmiana nie została potwierdzona poleceniem, więc pozostaje rekomendacją do weryfikacji.

## UAC i konta

- `EnableLUA=1`.
- `ConsentPromptBehaviorAdmin=5`.
- `PromptOnSecureDesktop=1`.
- Wbudowany Administrator: wyłączony.
- Gość: wyłączony.
- Codzienne konto użytkownika pozostaje członkiem lokalnej grupy Administratorzy; zwykłe procesy działają bez elevation.
- Oddzielne konto administratora: świadomie niewdrożone; decyzja `ACCEPTED RISK` dla jednoosobowej stacji roboczej.

## Ochrona poświadczeń

- LSA Protection: `RunAsPPL=2`, `RunAsPPLBoot=2`.
- Wininit ID 12 potwierdza uruchamianie LSASS jako procesu chronionego.
- AutoAdminLogon: brak konfiguracji.
- `DefaultPassword` w Winlogon: brak.
- Windows Hello: skonfigurowane podczas laboratorium; końcowy odczyt `NgcSet` nie został zapisany w evidence.
- Konto Microsoft: 2-step verification pozostaje mechanizmem ochrony logowania zdalnego.

## OPSEC

Plik celowo nie zawiera nazw kont, SID-ów, numerów seryjnych, identyfikatorów BitLocker, recovery password, SSID ani ścieżek profilu użytkownika.
