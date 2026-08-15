#Requires -Version 5.1
<#
.SYNOPSIS
  Read-only security audit for Windows 11 Pro used in Chapter 6 / LAB-WIN-002.

.DESCRIPTION
  Collects a privacy-conscious security baseline without changing security settings.
  The script intentionally avoids exporting recovery passwords, BitLocker protector IDs,
  device serial numbers, user SIDs, Wi-Fi SSIDs and user-profile application paths.

  For the most complete result, run Windows PowerShell 5.1 as Administrator.

.PARAMETER OutputPath
  Optional destination for the Markdown report. If omitted, the script prefers:
    <repo>\private_local\LAB-WIN-002\Windows11-Security-Audit_<timestamp>.md
  when executed from the Cyberbezpieczenstwo repository. Otherwise it writes to the
  current directory.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [string]$LabId = 'LAB-WIN-002'
)

$ErrorActionPreference = 'Continue'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$generated = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

function Test-IsAdministrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch { return $false }
}

function Get-SafeCount {
    param([object[]]$InputObject)
    return @($InputObject | Where-Object { $null -ne $_ -and -not [string]::IsNullOrWhiteSpace([string]$_) }).Count
}

function Add-Line {
    param([System.Collections.Generic.List[string]]$Lines,[string]$Text='')
    [void]$Lines.Add($Text)
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $repoRoot = $null
    try {
        $gitRoot = (& git rev-parse --show-toplevel 2>$null)
        if ($LASTEXITCODE -eq 0 -and $gitRoot) { $repoRoot = $gitRoot.Trim() }
    } catch {}

    if ($repoRoot) {
        $outDir = Join-Path $repoRoot ("private_local\{0}" -f $LabId)
    }
    else {
        $outDir = (Get-Location).Path
    }
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $OutputPath = Join-Path $outDir ("Windows11-Security-Audit_{0}.md" -f $timestamp)
}
else {
    $parent = Split-Path -Parent $OutputPath
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
}

$lines = New-Object 'System.Collections.Generic.List[string]'
$elevated = Test-IsAdministrator

Add-Line $lines '# Windows 11 Security Audit'
Add-Line $lines ''
Add-Line $lines ("- Generated: {0}" -f $generated)
Add-Line $lines ("- Elevated shell: {0}" -f $elevated)
Add-Line $lines '- Mode: read-only security configuration audit (the report file itself is created on disk)'
Add-Line $lines '- Privacy: usernames, SIDs, serial numbers, SSIDs, recovery passwords and BitLocker protector IDs are intentionally omitted.'

# OS
Add-Line $lines ''
Add-Line $lines '## Operating system'
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    Add-Line $lines ("- Caption: {0}" -f $os.Caption)
    Add-Line $lines ("- Version: {0}" -f $os.Version)
    Add-Line $lines ("- DisplayVersion: {0}" -f $cv.DisplayVersion)
    Add-Line $lines ("- EditionID: {0}" -f $cv.EditionID)
    Add-Line $lines ("- Full build: {0}.{1}" -f $cv.CurrentBuildNumber,$cv.UBR)
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Windows Update
Add-Line $lines ''
Add-Line $lines '## Windows Update baseline'
try {
    $wu = Get-Service wuauserv,bits,cryptsvc,usosvc -ErrorAction SilentlyContinue
    foreach ($s in $wu) { Add-Line $lines ("- {0}: {1} / {2}" -f $s.Name,$s.Status,$s.StartType) }
    $cbsPending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    $wuPending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    $pfr = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue).PendingFileRenameOperations
    Add-Line $lines ("- CBS reboot pending: {0}" -f $cbsPending)
    Add-Line $lines ("- Windows Update reboot required: {0}" -f $wuPending)
    Add-Line $lines ("- PendingFileRenameOperations present: {0}" -f ($null -ne $pfr))
    $hf = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
    Add-Line $lines '- Latest hotfixes:'
    foreach ($h in $hf) { Add-Line $lines ("  - {0} | {1} | {2}" -f $h.HotFixID,$h.Description,$h.InstalledOn) }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# AV / Defender
Add-Line $lines ''
Add-Line $lines '## Antimalware architecture'
try {
    $mp = Get-MpComputerStatus
    $pref = Get-MpPreference
    $av = @(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Select-Object -ExpandProperty displayName)
    Add-Line $lines ("- Registered AV products: {0}" -f ($av -join ', '))
    Add-Line $lines ("- Microsoft Defender AMRunningMode: {0}" -f $mp.AMRunningMode)
    Add-Line $lines ("- Defender AntivirusEnabled: {0}" -f $mp.AntivirusEnabled)
    Add-Line $lines ("- Defender RealTimeProtectionEnabled: {0}" -f $mp.RealTimeProtectionEnabled)
    Add-Line $lines ("- Defender Tamper Protection: {0}" -f $mp.IsTamperProtected)
    Add-Line $lines ("- Defender intelligence version: {0}" -f $mp.AntivirusSignatureVersion)
    Add-Line $lines ("- Defender intelligence last updated: {0}" -f $mp.AntivirusSignatureLastUpdated)
    Add-Line $lines ("- Controlled Folder Access configuration: {0}" -f $pref.EnableControlledFolderAccess)
    Add-Line $lines ("- Defender exclusion path count: {0}" -f (Get-SafeCount $pref.ExclusionPath))
    Add-Line $lines ("- Defender exclusion process count: {0}" -f (Get-SafeCount $pref.ExclusionProcess))
    Add-Line $lines ("- Defender exclusion extension count: {0}" -f (Get-SafeCount $pref.ExclusionExtension))
    $asrIds = @($pref.AttackSurfaceReductionRules_Ids | Where-Object { $_ })
    $asrActions = @($pref.AttackSurfaceReductionRules_Actions | Where-Object { $null -ne $_ })
    $asrEx = @($pref.AttackSurfaceReductionOnlyExclusions | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    Add-Line $lines ("- ASR rule IDs configured: {0}" -f $asrIds.Count)
    Add-Line $lines ("- ASR actions configured: {0}" -f $asrActions.Count)
    Add-Line $lines ("- ASR global exclusions: {0}" -f $asrEx.Count)
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Firewall
Add-Line $lines ''
Add-Line $lines '## Windows Firewall'
try {
    $profiles = Get-NetFirewallProfile -PolicyStore ActiveStore
    Add-Line $lines '| Profile | Enabled | Default inbound | Default outbound | Log allowed | Log blocked | Max log KB |'
    Add-Line $lines '|---|---:|---|---|---:|---:|---:|'
    foreach ($p in $profiles) {
        Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $p.Name,$p.Enabled,$p.DefaultInboundAction,$p.DefaultOutboundAction,$p.LogAllowed,$p.LogBlocked,$p.LogMaxSizeKilobytes)
    }
    $net = @(Get-NetConnectionProfile -ErrorAction SilentlyContinue)
    foreach ($n in $net) { Add-Line $lines ("- Network interface {0}: category={1}, IPv4={2}, IPv6={3}" -f $n.InterfaceAlias,$n.NetworkCategory,$n.IPv4Connectivity,$n.IPv6Connectivity) }
    $enabledRules = @(Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object Enabled -eq 'True')
    Add-Line $lines ("- Enabled firewall rules: {0}" -f $enabledRules.Count)
    Add-Line $lines ("- Enabled inbound allow rules: {0}" -f (@($enabledRules | Where-Object { $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' }).Count))
    $broad = @($enabledRules | Where-Object { $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' -and $_.Profile -eq 'Any' })
    Add-Line $lines ("- Enabled inbound allow rules with Profile=Any: {0}" -f $broad.Count)
    if ($broad.Count -gt 0) {
        Add-Line $lines '- Broad rule display names (paths/addresses omitted):'
        foreach ($r in ($broad | Select-Object -First 40)) { Add-Line $lines ("  - {0}" -f $r.DisplayName) }
    }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# SMB
Add-Line $lines ''
Add-Line $lines '## SMB exposure'
try {
    $smb = Get-SmbServerConfiguration
    $customShares = @(Get-SmbShare | Where-Object { -not $_.Special })
    Add-Line $lines ("- SMB1 enabled: {0}" -f $smb.EnableSMB1Protocol)
    Add-Line $lines ("- SMB2/3 enabled: {0}" -f $smb.EnableSMB2Protocol)
    Add-Line $lines ("- Reject unencrypted access: {0}" -f $smb.RejectUnencryptedAccess)
    Add-Line $lines ("- Require security signature: {0}" -f $smb.RequireSecuritySignature)
    Add-Line $lines ("- Non-special SMB share count: {0}" -f $customShares.Count)
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# SmartScreen / SAC
Add-Line $lines ''
Add-Line $lines '## SmartScreen / Smart App Control'
try {
    $sac = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' -Name VerifiedAndReputablePolicyState -ErrorAction SilentlyContinue).VerifiedAndReputablePolicyState
    $sacText = switch ($sac) { 0 {'Off'} 1 {'Enforcement'} 2 {'Evaluation'} default {'Not detected / unknown'} }
    Add-Line $lines ("- VerifiedAndReputablePolicyState: {0}" -f $sac)
    Add-Line $lines ("- Smart App Control interpretation: {0}" -f $sacText)
    if ($pref) { Add-Line $lines ("- Defender PUAProtection: {0}" -f $pref.PUAProtection) }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# BitLocker - safe export
Add-Line $lines ''
Add-Line $lines '## BitLocker'
try {
    $bl = @(Get-BitLockerVolume)
    Add-Line $lines '| Volume | Type | Status | Protection | Encrypted % | Method | Protector types |'
    Add-Line $lines '|---|---|---|---|---:|---|---|'
    foreach ($v in $bl) {
        $types = @($v.KeyProtector | ForEach-Object { [string]$_.KeyProtectorType }) -join ', '
        Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $v.MountPoint,$v.VolumeType,$v.VolumeStatus,$v.ProtectionStatus,$v.EncryptionPercentage,$v.EncryptionMethod,$types)
    }
    Add-Line $lines '- Recovery passwords and protector IDs are intentionally not exported.'
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# TPM / Secure Boot
Add-Line $lines ''
Add-Line $lines '## TPM and Secure Boot'
try {
    $tpm = Get-Tpm
    $tpmCim = Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftTpm -ClassName Win32_Tpm -ErrorAction SilentlyContinue
    Add-Line $lines ("- TPM present: {0}" -f $tpm.TpmPresent)
    Add-Line $lines ("- TPM ready: {0}" -f $tpm.TpmReady)
    Add-Line $lines ("- TPM enabled: {0}" -f $tpm.TpmEnabled)
    Add-Line $lines ("- TPM activated: {0}" -f $tpm.TpmActivated)
    Add-Line $lines ("- TPM owned: {0}" -f $tpm.TpmOwned)
    Add-Line $lines ("- TPM auto provisioning: {0}" -f $tpm.AutoProvisioning)
    Add-Line $lines ("- TPM restart pending: {0}" -f $tpm.RestartPending)
    if ($tpmCim) {
        Add-Line $lines ("- TPM manufacturer: {0}" -f $tpmCim.ManufacturerIdTxt)
        Add-Line $lines ("- TPM specification: {0}" -f $tpmCim.SpecVersion)
    }
    try { Add-Line $lines ("- Secure Boot enabled: {0}" -f (Confirm-SecureBootUEFI)) } catch { Add-Line $lines ("- Secure Boot check error: {0}" -f $_.Exception.Message) }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# VBS / HVCI
Add-Line $lines ''
Add-Line $lines '## VBS / HVCI / code integrity'
try {
    $dg = Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard
    $hvci = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\State' -ErrorAction SilentlyContinue).HVCIEnabled
    $driverBlock = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config' -ErrorAction SilentlyContinue).VulnerableDriverBlocklistEnable
    Add-Line $lines ("- VirtualizationBasedSecurityStatus: {0}" -f $dg.VirtualizationBasedSecurityStatus)
    Add-Line $lines ("- SecurityServicesConfigured: {0}" -f ($dg.SecurityServicesConfigured -join ','))
    Add-Line $lines ("- SecurityServicesRunning: {0}" -f ($dg.SecurityServicesRunning -join ','))
    Add-Line $lines ("- HVCIEnabled: {0}" -f $hvci)
    Add-Line $lines ("- VulnerableDriverBlocklistEnable: {0}" -f $driverBlock)
    $ciIssues = @(Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -MaxEvents 100 -ErrorAction SilentlyContinue | Where-Object { $_.Level -in @(2,3) })
    Add-Line $lines ("- Code Integrity warnings/errors in last 100 events: {0}" -f $ciIssues.Count)
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# UAC / accounts (sanitized)
Add-Line $lines ''
Add-Line $lines '## UAC and local-account posture'
try {
    $uac = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    Add-Line $lines ("- EnableLUA: {0}" -f $uac.EnableLUA)
    Add-Line $lines ("- ConsentPromptBehaviorAdmin: {0}" -f $uac.ConsentPromptBehaviorAdmin)
    Add-Line $lines ("- PromptOnSecureDesktop: {0}" -f $uac.PromptOnSecureDesktop)
    $admin = Get-LocalUser | Where-Object { $_.SID.Value -match '-500$' }
    $guest = Get-LocalUser | Where-Object { $_.SID.Value -match '-501$' }
    Add-Line $lines ("- Built-in Administrator enabled: {0}" -f $admin.Enabled)
    Add-Line $lines ("- Built-in Guest enabled: {0}" -f $guest.Enabled)
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' }
    $adminCount = @($adminGroup | Get-LocalGroupMember -ErrorAction SilentlyContinue).Count
    Add-Line $lines ("- Local Administrators member count: {0}" -f $adminCount)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    Add-Line $lines ("- Current shell elevated: {0}" -f $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Credential protection
Add-Line $lines ''
Add-Line $lines '## Credential protection'
try {
    $ngcLine = (dsregcmd /status | Select-String -Pattern 'NgcSet\s*:' | Select-Object -First 1).Line
    $ngc = if ($ngcLine -match 'YES') {'YES'} elseif ($ngcLine -match 'NO') {'NO'} else {'UNKNOWN'}
    $lsa = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -ErrorAction SilentlyContinue
    $lsaProtected = [bool](Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-Wininit';Id=12} -MaxEvents 1 -ErrorAction SilentlyContinue)
    $wl = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -ErrorAction SilentlyContinue
    $defaultPasswordPresent = ($null -ne $wl.PSObject.Properties['DefaultPassword'] -and -not [string]::IsNullOrWhiteSpace([string]$wl.DefaultPassword))
    Add-Line $lines ("- Windows Hello NgcSet: {0}" -f $ngc)
    Add-Line $lines ("- LSA RunAsPPL: {0}" -f $lsa.RunAsPPL)
    Add-Line $lines ("- LSA RunAsPPLBoot: {0}" -f $lsa.RunAsPPLBoot)
    Add-Line $lines ("- Protected LSASS event (Wininit 12) present: {0}" -f $lsaProtected)
    Add-Line $lines ("- AutoAdminLogon configured: {0}" -f $wl.AutoAdminLogon)
    Add-Line $lines ("- DefaultPassword present: {0}" -f $defaultPasswordPresent)
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Logging
Add-Line $lines ''
Add-Line $lines '## Event logging / audit policy'
try {
    $evtSvc = Get-Service eventlog
    Add-Line $lines ("- Windows Event Log service: {0} / {1}" -f $evtSvc.Status,$evtSvc.StartType)
    $logs = Get-WinEvent -ListLog Security,System,'Microsoft-Windows-Windows Defender/Operational','Microsoft-Windows-PowerShell/Operational'
    Add-Line $lines '| Log | Enabled | Records | Max bytes | Mode |'
    Add-Line $lines '|---|---:|---:|---:|---|'
    foreach ($l in $logs) { Add-Line $lines ("| {0} | {1} | {2} | {3} | {4} |" -f $l.LogName,$l.IsEnabled,$l.RecordCount,$l.MaximumSizeInBytes,$l.LogMode) }
    Add-Line $lines ''
    Add-Line $lines '### Audit Logon'
    Add-Line $lines '```text'
    foreach ($a in (auditpol /get /subcategory:"{0CCE9215-69AE-11D9-BED3-505054503030}")) { Add-Line $lines $a }
    Add-Line $lines '```'
    Add-Line $lines '### Audit Process Creation'
    Add-Line $lines '```text'
    foreach ($a in (auditpol /get /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}")) { Add-Line $lines $a }
    Add-Line $lines '```'
    $sb = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue
    $ml = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -ErrorAction SilentlyContinue
    $tr = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -ErrorAction SilentlyContinue
    Add-Line $lines ("- Script Block Logging policy: {0}" -f $sb.EnableScriptBlockLogging)
    Add-Line $lines ("- Module Logging policy: {0}" -f $ml.EnableModuleLogging)
    Add-Line $lines ("- Transcription policy: {0}" -f $tr.EnableTranscripting)
    $fwLogs = @(Get-Item "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall_*.log" -ErrorAction SilentlyContinue)
    Add-Line $lines ("- Firewall log files present: {0}" -f $fwLogs.Count)
    foreach ($f in $fwLogs) { Add-Line $lines ("  - {0}: {1} bytes; last write {2}" -f $f.Name,$f.Length,$f.LastWriteTime) }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Restore / recovery
Add-Line $lines ''
Add-Line $lines '## Restore / recovery baseline'
try {
    $rp = @(Get-ComputerRestorePoint | Sort-Object SequenceNumber -Descending | Select-Object -First 10)
    Add-Line $lines ("- Restore point count returned: {0}" -f $rp.Count)
    foreach ($r in $rp) { Add-Line $lines ("  - #{0} | {1} | {2} | type={3}" -f $r.SequenceNumber,$r.CreationTime,$r.Description,$r.RestorePointType) }
    $vss = Get-Service VSS,swprv -ErrorAction SilentlyContinue
    foreach ($s in $vss) { Add-Line $lines ("- {0}: {1} / {2}" -f $s.Name,$s.Status,$s.StartType) }
} catch { Add-Line $lines ("- ERROR: {0}" -f $_.Exception.Message) }

# Interpretation notes
Add-Line $lines ''
Add-Line $lines '## Interpretation notes'
Add-Line $lines '- Defender RealTimeProtectionEnabled=False is not automatically a failure when a third-party antivirus is primary and Defender is in Passive Mode.'
Add-Line $lines '- CFA and ASR should be treated as conditional on Microsoft Defender Antivirus being the active primary AV; do not force them in Passive Mode merely to satisfy a checklist.'
Add-Line $lines '- Credential Guard is edition/licensing dependent. Windows 11 Pro alone does not provide the Credential Guard entitlement; verify the actual edition/license before marking it as a requirement.'
Add-Line $lines '- SecurityServicesRunning value 2 indicates Memory Integrity/HVCI; value 1 indicates Credential Guard.'
Add-Line $lines '- A missing VulnerableDriverBlocklistEnable registry value does not by itself prove that the vulnerable-driver blocklist is inactive; HVCI/Smart App Control can enforce it through policy.'
Add-Line $lines '- BitLocker recovery passwords are secrets. Never commit them to Git or paste them into reports/chat logs.'
Add-Line $lines '- A separate administrator account is recommended but can be documented as an accepted risk on a single-user workstation when compensating controls are understood.'
Add-Line $lines '- A restore point is not a backup. Keep backup/recovery as a separate control.'

[System.IO.File]::WriteAllLines($OutputPath,$lines,(New-Object System.Text.UTF8Encoding($true)))
Write-Host "Audit complete. Report: $OutputPath"
