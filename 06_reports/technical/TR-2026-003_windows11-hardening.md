# TR-2026-003 — Hardening Windows 11 Pro

- ID raportu: TR-2026-003
- Powiązane laboratorium: LAB-WIN-002
- Data: 2026-08-15
- Autor: Daniel Kupracz
- Status: final
- Klasyfikacja: techniczny / wewnętrzny
- Platforma: Windows 11 Pro 25H2, build 26200.9168

## 1. Cel raportu

Celem raportu jest przedstawienie stanu zabezpieczeń hosta Windows 11 Pro po laboratorium `LAB-WIN-002` oraz udokumentowanie zmian, decyzji architektonicznych, ryzyk rezydualnych i zaleceń.

## 2. Podsumowanie wykonawcze

Końcowa ocena hosta:

**PASS / HARDENED**

Najważniejsze rezultaty:

- aktualny sierpniowy poziom aktualizacji bezpieczeństwa,
- jednoznaczna architektura AV: Avast aktywny, Defender Passive Mode,
- utwardzona zapora z pełniejszym logowaniem,
- Smart App Control w Enforcement,
- Secure Boot aktywny,
- TPM 2.0 gotowy i owned,
- BitLocker aktywny wyłącznie na C:,
- UAC/Secure Desktop i LSA Protection aktywne,
- Windows Hello skonfigurowane,
- VBS/HVCI i Vulnerable Driver Blocklist aktywne,
- ochrona ransomware aktywna,
- audyt logowania i tworzenia procesów aktywny,
- utworzony punkt przywracania po hardeningu.

## 3. System i aktualizacje

- Windows 11 Pro 25H2.
- Build: 26200.9168.
- KB5121003: zainstalowana.
- Mechanizm Windows Update działa.
- Security intelligence Defender: 1.457.164.0.
- Pozostałe oferty Windows Update podczas audytu dotyczyły sterowników i zostały odroczone do osobnej oceny.

## 4. Ochrona antymalware i reputacyjna

Avast Antivirus jest podstawowym AV. Microsoft Defender pozostaje w `Passive Mode`, co wyjaśnia `RealTimeProtectionEnabled=False` bez traktowania tego jako luki.

- Tamper Protection: True.
- CFA: N/A w bieżącej architekturze.
- ASR: N/A w bieżącej architekturze.
- Smart App Control: Enforcement.
- SmartScreen Edge/Store i PUA blocking: aktywne.
- Ransomware Shield Avast: aktywny, tryb inteligentny.

Jedno wąskie wykluczenie Defendera dla `JetBrains\Rider\r2r` pozostawiono jako INFO/REVIEW.

## 5. Zapora i sieć

Wszystkie profile Windows Firewall są aktywne. Efektywna polityka:

- inbound: Block,
- outbound: Allow.

Hardening:

- `LogAllowed=True`,
- `LogBlocked=True`,
- osobne pliki Domain/Private/Public,
- 20480 KB per log,
- reguły μTorrent ograniczone do profilu Private i lokalnego portu 46927 TCP/UDP.

SMB1 pozostaje wyłączony; brak własnych udziałów SMB.

## 6. Secure Boot, TPM i BitLocker

Secure Boot był wyłączony i został aktywowany w UEFI. Po zmianie:

- `Confirm-SecureBootUEFI=True`,
- `UEFISecureBootEnabled=1`.

TPM:

- TPM 2.0,
- Present/Ready/Enabled/Activated/Owned = True,
- AutoProvisioning = Enabled.

BitLocker C::

- Fully Encrypted,
- 100%,
- XTS-AES 128,
- Protection On,
- protectors: TPM + Recovery Password.

Recovery password nie jest przechowywany w repozytorium. D:, E: i F: pozostają nieszyfrowane zgodnie z decyzją użytkownika.

Kontrolny restart przeszedł bez recovery prompt.

## 7. Tożsamość i poświadczenia

- UAC: włączony.
- Secure Desktop: włączony.
- wbudowany Administrator i Gość: wyłączone.
- Windows Hello: skonfigurowane.
- LSA Protection: aktywne i potwierdzone Wininit ID 12.
- AutoAdminLogon: brak.
- DefaultPassword w Winlogon: brak.

Oddzielne konto administratora nie zostało wdrożone. Decyzja: **ACCEPTED RISK** dla jednoosobowej stacji roboczej, kompensowane przez UAC, Secure Desktop, Smart App Control, Secure Boot, TPM, BitLocker, AV i firewall.

## 8. VBS / HVCI / integralność kodu

- VBS status: 2 — running.
- SecurityServicesConfigured: {2}.
- SecurityServicesRunning: {2} — HVCI/Memory Integrity.
- HVCIEnabled: 1.
- VulnerableDriverBlocklistEnable: 1.
- Brak warning/error w kontrolowanej próbce Code Integrity.

Po włączeniu Secure Boot log Kernel-Boot wskazał `Pcr7SealingUsed=1` i `UefiContentIsSealed=1`.

## 9. Rejestrowanie i obserwowalność

Końcowe limity:

- Security: 128 MB,
- System: 64 MB,
- Defender Operational: 32 MB,
- PowerShell Operational: 64 MB.

Audit Policy:

- Logon: Success and Failure,
- Process Creation: Success,
- zdarzenie 4688: potwierdzone.

Pełny command line w 4688 nie został wymuszony. Script Block Logging, Module Logging i Transcription odroczono do rozdziału zaawansowanego monitoringu.

## 10. Odtwarzanie i backup

- System Protection C:: włączone.
- VSS: działa.
- Post-hardening restore point: `LAB-WIN-002 post-hardening baseline`.
- Full-image backup: deferred do czasu zapewnienia dedykowanego magazynu.

Punkt przywracania nie jest traktowany jako zamiennik kopii zapasowej.

## 11. Findings i decyzje

- `F-WIN-002-001` — Defender RTP False: **INFORMATIONAL / EXPECTED** (Passive Mode + Avast).
- `F-WIN-002-002` — Rider r2r exclusion: **INFORMATIONAL / REVIEW**.
- `F-WIN-002-003` — Firewall logging disabled: **REMEDIATED**.
- `F-WIN-002-004` — Broad μTorrent inbound rules: **REMEDIATED**.
- `F-WIN-002-005` — dodatkowe ostrzeżenia Enhanced Phishing Protection: **RECOMMENDATION / FINAL STATE NOT VERIFIED**.
- `F-WIN-002-006` — BitLocker disabled on C:: **REMEDIATED**.
- `F-WIN-002-007` — Secure Boot disabled: **REMEDIATED**.

Ryzyka/odroczenia:

1. oddzielne konto administratora — accepted risk,
2. full-image backup — deferred,
3. ASR/CFA — N/A przy Defender Passive Mode,
4. zaawansowane PowerShell logging / WEF / Sysmon — deferred,
5. `TPM RestartPending=True` — informational; funkcje TPM/BitLocker działają prawidłowo.

## 12. Ocena końcowa

Host osiągnął **PASS / HARDENED** dla zakresu Rozdziału 6.

Najistotniejsze wzmocnienia to Secure Boot, BitLocker C:, Windows Hello, VBS/HVCI, utwardzona zapora oraz zwiększona obserwowalność lokalna.

## 13. Powiązane artefakty

- Baseline wejściowy: `06_reports/technical/TR-2026-002_host-readiness.md`
- Laboratorium: `02_labs/completed/LAB-WIN-002_windows11-hardening.md`
- Dowody: `02_labs/evidence/LAB-WIN-002/`
- Raport: `06_reports/technical/TR-2026-003_windows11-hardening.md`
