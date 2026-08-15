# LAB-WIN-002 — Firewall baseline

- Data zakończenia: 2026-08-15
- Zakres: sanitizowany stan zapory i ekspozycji sieciowej

## Profile Windows Firewall

| Profil | Enabled | Default inbound | Default outbound | LogAllowed | LogBlocked | LogMaxSizeKilobytes |
|---|---:|---|---|---:|---:|---:|
| Domain | True | Block | Allow | True | True | 20480 |
| Private | True | Block | Allow | True | True | 20480 |
| Public | True | Block | Allow | True | True | 20480 |

Pliki logów są rozdzielone per profil:

- `pfirewall_Domain.log`
- `pfirewall_Private.log`
- `pfirewall_Public.log`

## Usługi

- Base Filtering Engine (`BFE`): Running / Automatic.
- Windows Defender Firewall (`MpsSvc`): Running / Automatic.
- Avast Firewall Service: Running / Automatic.

## Profil sieci

- Aktywny interfejs Wi-Fi: `Private`.
- Nazwa/SSID sieci celowo pominięta.

## Reguły μTorrent po hardeningu

| Reguła | Profil | Protokół | LocalPort | RemotePort | Kierunek | Akcja |
|---|---|---|---:|---|---|---|
| μTorrent (TCP-In) | Private | TCP | 46927 | Any | Inbound | Allow |
| μTorrent (UDP-In) | Private | UDP | 46927 | Any | Inbound | Allow |

Stan początkowy: `Profile=Any`, `LocalPort=Any`. Zmianę zweryfikowano po restarcie klienta — port nasłuchu pozostał 46927.

## SMB

- SMB1: wyłączony.
- SMB2/3: włączony.
- `RejectUnencryptedAccess=True`.
- `RequireSecuritySignature=True`.
- Brak własnych udziałów SMB (`Special=False`).
- W kontrolowanym odczycie ActiveStore nie wykryto aktywnej reguły Allow dla inbound TCP/445 lub 139.

## Wynik

**PASS / HARDENED**

Zmiany: włączenie pełnego logowania zapory, osobne logi per profil oraz zawężenie reguł μTorrent.
