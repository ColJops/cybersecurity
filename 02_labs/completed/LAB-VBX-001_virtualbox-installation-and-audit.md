# LAB-VBX-001 â€” VirtualBox installation and host audit

## Status

**PASS**

## Purpose

Instalacja i weryfikacja Oracle VirtualBox jako pomocniczej
platformy wirtualizacyjnej obok Microsoft Hyper-V.

## Initial state

Przed instalacjÄ…:

- Microsoft Hyper-V byĹ‚ aktywny;
- Windows Hypervisor Platform byĹ‚ wyĹ‚Ä…czony;
- VBS pozostawaĹ‚o aktywne;
- VirtualBox nie byĹ‚ zainstalowany.

## Changes performed

1. WĹ‚Ä…czono Windows Hypervisor Platform.
2. Hyper-V pozostawiono aktywny.
3. VBS pozostawiono aktywne.
4. Zweryfikowano instalator VirtualBox przez SHA-256 i Authenticode.
5. Zainstalowano Oracle VirtualBox 7.2.14.
6. Zainstalowano skĹ‚adniki sieciowe Host-only i Bridged.
7. Nie instalowano skĹ‚adnika USB.
8. Nie instalowano integracji Python.
9. Utworzono magazyn:

   D:\VirtualBox\

10. DomyĹ›lny katalog VM ustawiono na:

    D:\VirtualBox\Virtual Machines

11. Zweryfikowano i zainstalowano Oracle VirtualBox Extension Pack 7.2.14.
12. Potwierdzono prawidĹ‚owÄ… konfiguracjÄ™ w VirtualBox Manager.

## Final state

- VirtualBox: 7.2.14r174565
- Extension Pack: 7.2.14 r174565
- Extension Pack usable: true
- Hyper-V: Enabled
- Windows Hypervisor Platform: Enabled
- VBS status: 2
- Default VirtualBox VM path: D:\VirtualBox\Virtual Machines
- Registered VirtualBox VMs: 0

## Security assessment

Nie wyĹ‚Ä…czono Hyper-V ani VBS w celu poprawy kompatybilnoĹ›ci
VirtualBox. VirtualBox bÄ™dzie pracowaĹ‚ jako platforma pomocnicza
na hoĹ›cie z aktywnym hypervisorem Microsoft.

DostÄ™p Bridged bÄ™dzie wykorzystywany wyĹ‚Ä…cznie w laboratoriach,
ktĂłre rzeczywiĹ›cie wymagajÄ… obecnoĹ›ci VM w fizycznej sieci LAN.

## Evidence

- inal-audit.md
- preflight oraz post-install audit pozostajÄ… rĂłwnieĹĽ w private_local
  jako rozszerzone dane robocze.

## Result

**PASS**

Laboratorium przygotowaĹ‚o host do dalszych Ä‡wiczeĹ„ VirtualBox bez
naruszenia istniejÄ…cej infrastruktury Hyper-V i zabezpieczeĹ„ VBS.
