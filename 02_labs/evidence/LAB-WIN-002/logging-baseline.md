# LAB-WIN-002 — Logging baseline

- Data zakończenia: 2026-08-15
- Zakres: podstawowa telemetria lokalnego hosta

## Windows Event Log

- `eventlog`: Running / Automatic.

| Log | Enabled | MaximumSizeInBytes | Tryb |
|---|---:|---:|---|
| Security | True | 134217728 | Circular |
| System | True | 67108864 | Circular |
| Microsoft-Windows-Windows Defender/Operational | True | 33554432 | Circular |
| Microsoft-Windows-PowerShell/Operational | True | 67108864 | Circular |

## Audit Policy

- Audit Logon: Success and Failure.
- Audit Process Creation: Success.
- Zdarzenie 4688 po zmianie: potwierdzone.
- Pełny command line dla 4688: niewymuszony, aby nie zwiększać ryzyka zapisu sekretów w jawnym tekście.

## PowerShell detailed logging

- Script Block Logging: NotConfigured.
- Module Logging: NotConfigured.
- Transcription: NotConfigured.
- Decyzja: deferred do rozdziału monitoringu/logowania, razem z ochroną i centralizacją logów.

## Windows Firewall logs

Podczas kontroli pliki Domain, Private i Public istniały; profil Private generował aktywną zawartość. Maksymalny rozmiar ustawiono na 20480 KB dla każdego profilu.

## Wynik

**PASS / HARDENED**
