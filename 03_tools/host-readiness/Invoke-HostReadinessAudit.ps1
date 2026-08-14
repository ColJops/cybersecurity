<#
.SYNOPSIS
  Read-only readiness audit for a Windows 11 host used in a Hyper-V cybersecurity lab.

.DESCRIPTION
  Version 1.2.
  Collects operating-system, processor, virtualization, memory, firmware, storage,
  Hyper-V/VBS and lightweight performance information without changing system settings.

  Privacy defaults:
  - hardware serial numbers and memory part numbers are hidden unless -IncludeIdentifiers is used;
  - raw systeminfo.exe output is NOT saved unless -IncludeRawSystemInfo is used.

  Important virtualization note:
  When the Microsoft hypervisor is already running (for example because Hyper-V or VBS/HVCI
  is active), Win32_Processor may report virtualization capability flags such as SLAT,
  VMMonitorModeExtensions and VirtualizationFirmwareEnabled as False. In that situation,
  HypervisorPresent is treated as effective evidence that the virtualization platform is active.
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PWD ("HostAudit_" + (Get-Date -Format "yyyyMMdd_HHmmss"))),
    [switch]$IncludeIdentifiers,
    [switch]$IncludeRawSystemInfo,
    [ValidateRange(1,60)]
    [int]$CounterSeconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptVersion = '1.2'

function Get-SafeValue {
    param(
        [scriptblock]$Action,
        $Fallback = $null
    )
    try {
        & $Action
    }
    catch {
        $Fallback
    }
}

function Convert-BytesToGiB {
    param([Nullable[double]]$Bytes)
    if ($null -eq $Bytes) { return $null }
    [math]::Round(([double]$Bytes / 1GB), 2)
}

function Get-NullableStat {
    param(
        [object[]]$Values,
        [ValidateSet('Average','Maximum','Minimum')]
        [string]$Operation
    )

    $usable = @($Values | Where-Object { $null -ne $_ })
    if ($usable.Count -eq 0) { return $null }

    $measurement = $usable | Measure-Object -Average -Maximum -Minimum
    $value = switch ($Operation) {
        'Average' { $measurement.Average }
        'Maximum' { $measurement.Maximum }
        'Minimum' { $measurement.Minimum }
    }

    if ($null -eq $value) { return $null }
    [math]::Round([double]$value, 2)
}

function Get-DriveStorageMapping {
    param([Parameter(Mandatory)][string]$DeviceId)

    $letter = $DeviceId.TrimEnd(':')
    $partition = Get-SafeValue {
        Get-Partition -DriveLetter $letter -ErrorAction Stop | Select-Object -First 1
    }

    if (-not $partition) {
        return [pscustomobject]@{
            DiskNumber   = $null
            DiskName     = $null
            BusType      = $null
            PartitionStyle = $null
        }
    }

    $disk = Get-SafeValue {
        Get-Disk -Number $partition.DiskNumber -ErrorAction Stop
    }

    [pscustomobject]@{
        DiskNumber     = if ($disk) { $disk.Number } else { $partition.DiskNumber }
        DiskName       = if ($disk) { $disk.FriendlyName } else { $null }
        BusType        = if ($disk) { [string]$disk.BusType } else { $null }
        PartitionStyle = if ($disk) { [string]$disk.PartitionStyle } else { $null }
    }
}

function Get-PerformanceSnapshot {
    $cpu = Get-SafeValue {
        Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction Stop
    }
    $memory = Get-SafeValue {
        Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory -ErrorAction Stop
    }
    $disk = Get-SafeValue {
        Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk -ErrorAction Stop |
            Where-Object { $_.Name -eq '_Total' } |
            Select-Object -First 1
    }

    if (-not $cpu -and -not $memory -and -not $disk) {
        return $null
    }

    [pscustomobject]@{
        Timestamp              = (Get-Date).ToString('o')
        CpuPercent             = if ($cpu) { [double]$cpu.PercentProcessorTime } else { $null }
        AvailableMemoryMB      = if ($memory) { [double]$memory.AvailableMBytes } else { $null }
        DiskTransfersPerSec    = if ($disk) { [double]$disk.DiskTransfersPersec } else { $null }
        DiskReadBytesPerSec    = if ($disk) { [double]$disk.DiskReadBytesPersec } else { $null }
        DiskWriteBytesPerSec   = if ($disk) { [double]$disk.DiskWriteBytesPersec } else { $null }
        DiskQueueLength        = if ($disk) { [double]$disk.CurrentDiskQueueLength } else { $null }
    }
}

New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null

$isElevated = Get-SafeValue {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} $false

$computerSystem = Get-CimInstance Win32_ComputerSystem
$operatingSystem = Get-CimInstance Win32_OperatingSystem
$processors = @(Get-CimInstance Win32_Processor)
$bios = Get-CimInstance Win32_BIOS
$baseBoard = Get-SafeValue { Get-CimInstance Win32_BaseBoard -ErrorAction Stop }
$memoryModules = @(Get-CimInstance Win32_PhysicalMemory)
$logicalDisks = @(
    Get-CimInstance Win32_LogicalDisk |
        Where-Object { $_.DriveType -in @(2,3) -and $_.Size -and $_.DeviceID }
)
$physicalDisks = @(Get-SafeValue { Get-PhysicalDisk -ErrorAction Stop } @())

$hyperVFeature = Get-SafeValue {
    Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction Stop |
        Select-Object FeatureName, State
}

$deviceGuard = Get-SafeValue {
    Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop |
        Select-Object VirtualizationBasedSecurityStatus, SecurityServicesConfigured, SecurityServicesRunning
}

$processorInfo = foreach ($cpu in $processors) {
    [pscustomobject]@{
        Name                                   = $cpu.Name.Trim()
        Manufacturer                           = $cpu.Manufacturer
        Architecture                           = $cpu.AddressWidth
        Cores                                  = $cpu.NumberOfCores
        LogicalProcessors                      = $cpu.NumberOfLogicalProcessors
        MaxClockMHz                            = $cpu.MaxClockSpeed
        VirtualizationFirmwareEnabledReported  = $cpu.VirtualizationFirmwareEnabled
        VMMonitorModeExtensionsReported        = $cpu.VMMonitorModeExtensions
        SLATReported                           = $cpu.SecondLevelAddressTranslationExtensions
    }
}

$memoryInfo = foreach ($module in $memoryModules) {
    [pscustomobject]@{
        Bank               = $module.BankLabel
        CapacityGiB        = Convert-BytesToGiB $module.Capacity
        SpeedMTs           = $module.Speed
        ConfiguredClockMTs = $module.ConfiguredClockSpeed
        Manufacturer       = $module.Manufacturer
        PartNumber         = if ($IncludeIdentifiers) { ([string]$module.PartNumber).Trim() } else { '[hidden]' }
        SerialNumber       = if ($IncludeIdentifiers) { ([string]$module.SerialNumber).Trim() } else { '[hidden]' }
    }
}

$volumeInfo = foreach ($disk in $logicalDisks) {
    $mapping = Get-DriveStorageMapping -DeviceId $disk.DeviceID
    $busType = $mapping.BusType
    $driveTypeName = switch ([int]$disk.DriveType) {
        2 { 'Removable' }
        3 { 'Fixed' }
        default { "Type$($disk.DriveType)" }
    }

    # A USB-attached HDD can be reported by Win32_LogicalDisk as DriveType=Fixed.
    # Exclude USB/SD/MMC media from the preferred active-VM storage pool.
    $externalBus = $busType -in @('USB','SD','MMC')
    $eligibleForVmStorage = ([int]$disk.DriveType -eq 3) -and (-not $externalBus)

    [pscustomobject]@{
        Drive                = $disk.DeviceID
        DriveType            = $driveTypeName
        FileSystem           = $disk.FileSystem
        SizeGiB              = Convert-BytesToGiB $disk.Size
        FreeGiB              = Convert-BytesToGiB $disk.FreeSpace
        FreePercent          = if ($disk.Size) { [math]::Round((([double]$disk.FreeSpace / [double]$disk.Size) * 100), 1) } else { $null }
        PhysicalDisk         = $mapping.DiskName
        BusType              = $busType
        PartitionStyle       = $mapping.PartitionStyle
        EligibleForVmStorage = $eligibleForVmStorage
    }
}

$physicalInfo = foreach ($disk in $physicalDisks) {
    $reliability = try {
        $disk | Get-StorageReliabilityCounter -ErrorAction Stop
    }
    catch {
        $null
    }

    $temperature = $null
    if ($reliability -and $null -ne $reliability.Temperature) {
        $rawTemperature = [double]$reliability.Temperature
        # 0-1 C is not a credible operating temperature for a powered storage device;
        # some controllers return these values when the sensor is unsupported.
        if ($rawTemperature -ge 2 -and $rawTemperature -le 120) {
            $temperature = $rawTemperature
        }
    }

    [pscustomobject]@{
        FriendlyName                  = $disk.FriendlyName
        MediaType                     = [string]$disk.MediaType
        BusType                       = [string]$disk.BusType
        SizeGiB                       = Convert-BytesToGiB $disk.Size
        HealthStatus                  = [string]$disk.HealthStatus
        OperationalStatus             = ($disk.OperationalStatus -join ', ')
        ReliabilityCountersAvailable  = [bool]($null -ne $reliability)
        TemperatureC                  = $temperature
        Wear                          = if ($reliability) { $reliability.Wear } else { $null }
        SerialNumber                  = if ($IncludeIdentifiers) { $disk.SerialNumber } else { '[hidden]' }
    }
}

# Localization-independent performance sample using CIM performance classes rather than
# hard-coded English Get-Counter paths. This works on Polish Windows as well.
$performanceSamples = @()
for ($i = 0; $i -lt $CounterSeconds; $i++) {
    $snapshot = Get-SafeValue { Get-PerformanceSnapshot }
    if ($snapshot) {
        $performanceSamples += $snapshot
    }
    if ($i -lt ($CounterSeconds - 1)) {
        Start-Sleep -Seconds 1
    }
}

$performanceSummary = [ordered]@{
    SamplesCollected          = @($performanceSamples).Count
    CpuPercentAverage         = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.CpuPercent }) -Operation Average
    CpuPercentMaximum         = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.CpuPercent }) -Operation Maximum
    AvailableMemoryMBAverage  = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.AvailableMemoryMB }) -Operation Average
    AvailableMemoryMBMinimum  = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.AvailableMemoryMB }) -Operation Minimum
    DiskTransfersPerSecAverage = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.DiskTransfersPerSec }) -Operation Average
    DiskQueueLengthAverage    = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.DiskQueueLength }) -Operation Average
    DiskQueueLengthMaximum    = Get-NullableStat -Values @($performanceSamples | ForEach-Object { $_.DiskQueueLength }) -Operation Maximum
}

$visibleRamGiB = Convert-BytesToGiB $computerSystem.TotalPhysicalMemory
$installedRamBytes = ($memoryModules | Measure-Object -Property Capacity -Sum).Sum
$installedRamGiB = if ($installedRamBytes) {
    Convert-BytesToGiB $installedRamBytes
}
else {
    $visibleRamGiB
}

$fixedFreeGiB = [math]::Round((($logicalDisks | Where-Object { $_.DriveType -eq 3 } | Measure-Object FreeSpace -Sum).Sum / 1GB), 1)
$vmStorageFreeBytes = ($volumeInfo | Where-Object { $_.EligibleForVmStorage -eq $true } | ForEach-Object {
    $drive = $_.Drive
    ($logicalDisks | Where-Object { $_.DeviceID -eq $drive } | Select-Object -First 1).FreeSpace
} | Measure-Object -Sum).Sum
$vmStorageFreeGiB = if ($vmStorageFreeBytes) { [math]::Round(($vmStorageFreeBytes / 1GB), 1) } else { 0 }

$hypervisorPresent = [bool]$computerSystem.HypervisorPresent
$virtualizationReported = @($processors | Where-Object { $_.VirtualizationFirmwareEnabled -eq $true }).Count -gt 0
$slatReported = @($processors | Where-Object { $_.SecondLevelAddressTranslationExtensions -eq $true }).Count -gt 0
$vmMonitorReported = @($processors | Where-Object { $_.VMMonitorModeExtensions -eq $true }).Count -gt 0

# If the Windows hypervisor is already running, processor capability flags may be hidden or
# reported as False. Treat the active hypervisor as effective evidence for these requirements.
$virtualizationEffective = $virtualizationReported -or $hypervisorPresent
$slatEffective = $slatReported -or $hypervisorPresent
$vmMonitorEffective = $vmMonitorReported -or $hypervisorPresent

$osSuitable = ($operatingSystem.Caption -match 'Windows 11') -and ($operatingSystem.Caption -match '(Pro|Enterprise)')

# Use installed DIMM capacity for resource classification. Windows-visible memory may be slightly
# below the nominal installed capacity because of hardware reservations.
$profileRamGiB = if ($installedRamGiB) { $installedRamGiB } else { $visibleRamGiB }
$projectProfile = if ($profileRamGiB -ge 64 -and $vmStorageFreeGiB -ge 700) {
    'extended'
}
elseif ($profileRamGiB -ge 32 -and $vmStorageFreeGiB -ge 350) {
    'standard'
}
elseif ($profileRamGiB -ge 16 -and $vmStorageFreeGiB -ge 180) {
    'basic'
}
else {
    'limited'
}

$requiredPass = $osSuitable -and $slatEffective -and $vmMonitorEffective -and $virtualizationEffective
$status = if ($requiredPass -and $projectProfile -in @('standard','extended')) {
    'READY'
}
elseif ($requiredPass) {
    'CONDITIONALLY_READY'
}
else {
    'NOT_READY'
}

$hyperVFeatureState = if ($hyperVFeature) { [string]$hyperVFeature.State } else { 'Unavailable' }

$lowSpaceVolumes = @(
    $volumeInfo |
        Where-Object { $null -ne $_.FreePercent -and $_.FreePercent -lt 10 } |
        ForEach-Object { "$($_.Drive) ($($_.FreePercent)% free)" }
)

$externalVolumes = @(
    $volumeInfo |
        Where-Object { $_.BusType -in @('USB','SD','MMC') } |
        ForEach-Object { "$($_.Drive) [$($_.BusType)]" }
)

$capabilityNote = if ($hypervisorPresent -and (-not $slatReported -or -not $vmMonitorReported -or -not $virtualizationReported)) {
    'HypervisorPresent=True. Raw Win32_Processor virtualization flags may be False while the Windows hypervisor is active; effective checks therefore use the active hypervisor as evidence.'
}
else {
    'Processor virtualization capability flags are being used directly.'
}

$summary = [ordered]@{
    ScriptVersion = $ScriptVersion
    AuditTime = (Get-Date).ToString('o')
    ComputerName = $env:COMPUTERNAME
    Status = $status
    ProjectProfile = $projectProfile
    OperatingSystem = [ordered]@{
        Caption = $operatingSystem.Caption
        Version = $operatingSystem.Version
        BuildNumber = $operatingSystem.BuildNumber
        Architecture = $operatingSystem.OSArchitecture
        LastBoot = $operatingSystem.LastBootUpTime
    }
    Hardware = [ordered]@{
        Manufacturer = $computerSystem.Manufacturer
        Model = $computerSystem.Model
        InstalledRamGiB = $installedRamGiB
        WindowsVisibleRamGiB = $visibleRamGiB
        FixedVolumeFreeGiB = $fixedFreeGiB
        PreferredVmStorageFreeGiB = $vmStorageFreeGiB
        HypervisorPresent = $hypervisorPresent
        AuditSessionElevated = [bool]$isElevated
    }
    Requirements = [ordered]@{
        Windows11ProOrEnterprise = $osSuitable
        VMMonitorModeExtensionsEffective = $vmMonitorEffective
        SLATEffective = $slatEffective
        VirtualizationEnabledOrHypervisorPresent = $virtualizationEffective
    }
    VirtualizationEvidence = [ordered]@{
        HypervisorPresent = $hypervisorPresent
        VirtualizationFirmwareEnabledReported = $virtualizationReported
        VMMonitorModeExtensionsReported = $vmMonitorReported
        SLATReported = $slatReported
        CapabilityReportingNote = $capabilityNote
        HyperVFeatureState = $hyperVFeatureState
    }
    Firmware = [ordered]@{
        Vendor = $bios.Manufacturer
        Version = ($bios.SMBIOSBIOSVersion -join ', ')
        ReleaseDate = $bios.ReleaseDate
        BaseBoard = if ($baseBoard) { "$($baseBoard.Manufacturer) $($baseBoard.Product)" } else { $null }
        SerialNumber = if ($IncludeIdentifiers) { $bios.SerialNumber } else { '[hidden]' }
    }
    Processor = $processorInfo
    MemoryModules = $memoryInfo
    Volumes = $volumeInfo
    PhysicalDisks = $physicalInfo
    HyperVFeature = $hyperVFeature
    DeviceGuard = $deviceGuard
    PerformanceSummary = $performanceSummary
    Advisories = [ordered]@{
        LowSpaceVolumes = $lowSpaceVolumes
        ExternalVolumesExcludedFromPreferredVmStorage = $externalVolumes
        RawSystemInfoSaved = [bool]$IncludeRawSystemInfo
    }
}

$summary | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $OutputDirectory 'host-summary.json') -Encoding UTF8
$processorInfo | Export-Csv -Path (Join-Path $OutputDirectory 'processors.csv') -NoTypeInformation -Encoding UTF8
$memoryInfo | Export-Csv -Path (Join-Path $OutputDirectory 'memory-modules.csv') -NoTypeInformation -Encoding UTF8
$volumeInfo | Export-Csv -Path (Join-Path $OutputDirectory 'volumes.csv') -NoTypeInformation -Encoding UTF8
$physicalInfo | Export-Csv -Path (Join-Path $OutputDirectory 'physical-disks.csv') -NoTypeInformation -Encoding UTF8
$performanceSamples | Export-Csv -Path (Join-Path $OutputDirectory 'performance-sample.csv') -NoTypeInformation -Encoding UTF8
[pscustomobject]$performanceSummary | Export-Csv -Path (Join-Path $OutputDirectory 'performance-summary.csv') -NoTypeInformation -Encoding UTF8

if ($IncludeRawSystemInfo) {
    systeminfo.exe | Set-Content -Path (Join-Path $OutputDirectory 'systeminfo.txt') -Encoding UTF8
}
else {
    @"
Raw systeminfo.exe output was intentionally not saved by default.
Reason: it can expose registered owner information, Windows Product ID, local IP addresses,
VPN interface addresses and other environment details.

If you explicitly need it for a private diagnostic run, rerun this script with:
  -IncludeRawSystemInfo
"@ | Set-Content -Path (Join-Path $OutputDirectory 'systeminfo-privacy-note.txt') -Encoding UTF8
}

$reqRows = foreach ($item in $summary.Requirements.GetEnumerator()) {
    "| $($item.Key) | $($item.Value) |"
}

$volumeRows = foreach ($volume in $volumeInfo) {
    $bus = if ($volume.BusType) { $volume.BusType } else { 'Unknown' }
    "| $($volume.Drive) | $($volume.DriveType) | $bus | $($volume.SizeGiB) | $($volume.FreeGiB) | $($volume.FreePercent)% | $($volume.EligibleForVmStorage) |"
}

$advisoryLines = @()
if ($lowSpaceVolumes.Count -gt 0) {
    $advisoryLines += "- Low free space: $($lowSpaceVolumes -join ', ')."
}
if ($externalVolumes.Count -gt 0) {
    $advisoryLines += "- External/removable buses excluded from preferred VM storage: $($externalVolumes -join ', ')."
}
if (-not $IncludeRawSystemInfo) {
    $advisoryLines += '- Raw systeminfo.exe output was not saved for privacy.'
}
if ($advisoryLines.Count -eq 0) {
    $advisoryLines += '- No additional storage/privacy advisories.'
}

$md = @"
# Host readiness assessment

- Script version: **$ScriptVersion**
- Audit time: $($summary.AuditTime)
- Computer: $($summary.ComputerName)
- Result: **$($summary.Status)**
- Project resource profile: **$($summary.ProjectProfile)**
- OS: $($summary.OperatingSystem.Caption), build $($summary.OperatingSystem.BuildNumber)
- Installed RAM: $($summary.Hardware.InstalledRamGiB) GiB
- Windows-visible RAM: $($summary.Hardware.WindowsVisibleRamGiB) GiB
- Preferred VM-storage free space: $($summary.Hardware.PreferredVmStorageFreeGiB) GiB
- Hypervisor present: $($summary.Hardware.HypervisorPresent)
- Hyper-V optional feature state: $($summary.VirtualizationEvidence.HyperVFeatureState)
- Audit session elevated: $($summary.Hardware.AuditSessionElevated)

## Mandatory checks

| Check | Result |
|---|---|
$($reqRows -join "`n")

## Virtualization evidence

- Hypervisor present: $hypervisorPresent
- VirtualizationFirmwareEnabled reported by Win32_Processor: $virtualizationReported
- VMMonitorModeExtensions reported by Win32_Processor: $vmMonitorReported
- SLAT reported by Win32_Processor: $slatReported
- Interpretation: $capabilityNote

## Storage inventory

| Drive | Type | Bus | Size GiB | Free GiB | Free | Preferred for active VMs |
|---|---|---|---:|---:|---:|---|
$($volumeRows -join "`n")

## Performance sample

- Samples collected: $($performanceSummary.SamplesCollected)
- Average CPU: $($performanceSummary.CpuPercentAverage)%
- Maximum CPU: $($performanceSummary.CpuPercentMaximum)%
- Average available memory: $($performanceSummary.AvailableMemoryMBAverage) MB
- Minimum available memory: $($performanceSummary.AvailableMemoryMBMinimum) MB
- Average disk transfers/sec: $($performanceSummary.DiskTransfersPerSecAverage)
- Average disk queue length: $($performanceSummary.DiskQueueLengthAverage)
- Maximum disk queue length: $($performanceSummary.DiskQueueLengthMaximum)

## Advisories

$($advisoryLines -join "`n")

## Interpretation

- READY: mandatory platform checks pass and resources match the standard or extended project profile.
- CONDITIONALLY_READY: mandatory platform checks pass, but simultaneous VM scenarios should be limited.
- NOT_READY: at least one mandatory platform requirement is missing or cannot be confirmed.
- When HypervisorPresent=True, raw Win32_Processor virtualization flags can be misleading; the effective checks account for this.
- Storage temperature values of 0-1 C are treated as unavailable because some controllers return placeholder values.
- Wear values are controller-dependent; a value of 0 does not by itself prove either zero wear or unsupported telemetry.

## Safety and privacy

This script is read-only. Serial numbers and module identifiers are hidden by default. Raw systeminfo.exe output is also omitted by default because it may expose registered-owner information, Product ID, local/VPN IP addresses and other environment details. Review generated files before publishing them.
"@

$md | Set-Content -Path (Join-Path $OutputDirectory 'host-assessment.md') -Encoding UTF8

Write-Host "Audit complete: $OutputDirectory"
Write-Host "Status: $status; profile: $projectProfile"
Write-Host "Installed RAM: $installedRamGiB GiB; preferred VM storage free: $vmStorageFreeGiB GiB"
Write-Host "Hypervisor present: $hypervisorPresent; Hyper-V feature: $hyperVFeatureState"
if ($performanceSummary.SamplesCollected -eq 0) {
    Write-Warning 'Performance sample could not be collected. The rest of the audit is still valid.'
}
