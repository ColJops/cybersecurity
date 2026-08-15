# LAB-WIN-002 — Evidence manifest

- Laboratorium: LAB-WIN-002
- Data: 2026-08-15
- Lokalizacja: `02_labs/evidence/LAB-WIN-002/`
- Klasyfikacja: sanitizowane dowody techniczne / Git-safe

| Plik | Przeznaczenie | SHA-256 |
|---|---|---|
| `security-baseline.md` | sanitizowany eksport stanu | `0DDEC9540D8D34CCE724D4D8F694D44541C9E5AE741B34436EB3E8504C8EC911` |
| `firewall-baseline.md` | sanitizowany eksport stanu | `749739650D4BC04CE3F63A0D9A28EA0A0E1607D00927496D5590EF08952287C9` |
| `platform-security.md` | sanitizowany eksport stanu | `CC4F6406D52E6F574FDBF07016F859C3529A497A58995D9EA5ECA0D383AAA404` |
| `logging-baseline.md` | sanitizowany eksport stanu | `CAF0A1BCA36B5E1AB53C425DE702F89A42FED9FFFEF0C350C6439B98E7237B8B` |

## Celowo wyłączone z Git

- BitLocker recovery password i protector IDs,
- numery seryjne sprzętu,
- kompletne SID-y i szczegółowe identyfikatory kont,
- SSID/nazwa sieci,
- pełne ścieżki profilu użytkownika,
- surowe komunikaty Security log ujawniające lokalne tożsamości,
- screenshoty zawierające niepotrzebne dane środowiska.

Pełny kontekst roboczy może być przechowywany w `private_local/LAB-WIN-002/`, które jest ignorowane przez Git.
