# LAB-WIN-002 — Platform security baseline

- Data zakończenia: 2026-08-15
- Zakres: Secure Boot, TPM, BitLocker, VBS/HVCI i odtwarzanie

## Secure Boot

- Stan początkowy: Disabled (`Confirm-SecureBootUEFI=False`).
- Stan końcowy: Enabled (`Confirm-SecureBootUEFI=True`, `UEFISecureBootEnabled=1`).
- System uruchomił się poprawnie po zmianie UEFI.

## TPM

- SpecVersion: `2.0, 0, 1.38`.
- Manufacturer: `INTC`.
- Present: True.
- Ready: True.
- Enabled: True.
- Activated: True.
- Owned: True.
- AutoProvisioning: Enabled.
- `RestartPending=True` pozostało po restarcie; sklasyfikowane jako INFO, ponieważ TPM jest Ready/Owned, a BitLocker przeszedł test odblokowania po restarcie.

## BitLocker — tylko C:

- BitLocker Version: 2.0.
- Conversion Status: Fully Encrypted.
- Percentage Encrypted: 100%.
- Encryption Method: XTS-AES 128.
- Protection Status: Protection On.
- Lock Status: Unlocked.
- Key protectors: TPM + Recovery Password.
- Recovery password i identyfikatory protectorów celowo pominięte.
- D:, E: i F: pozostają bez BitLockera zgodnie z decyzją projektową.
- Kontrolny restart przeszedł bez ekranu recovery.

## VBS / HVCI

- `VirtualizationBasedSecurityStatus=2` — VBS działa.
- `SecurityServicesConfigured={2}`.
- `SecurityServicesRunning={2}` — Memory Integrity/HVCI działa.
- `HVCIEnabled=1`.
- `VulnerableDriverBlocklistEnable=1`.
- W kontrolowanej próbce `Microsoft-Windows-CodeIntegrity/Operational` nie wykryto warning/error.

## PCR7 / VSM

Po aktywacji Secure Boot log Kernel-Boot pokazał `Pcr7SealingUsed=1` i `UefiContentIsSealed=1`, co potwierdza zmianę względem wcześniejszego stanu `0`.

## System Restore

- System Protection dla C:: włączone.
- VSS działa; shadow storage C: około 18,6 GB maximum podczas audytu.
- Utworzony punkt: `LAB-WIN-002 post-hardening baseline`.
- SequenceNumber: 16.
- Pełny image backup: deferred do czasu zapewnienia dedykowanego magazynu.

## Wynik

**PASS / HARDENED**
