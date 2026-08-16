#requires -RunAsAdministrator
#requires -Modules Hyper-V

[CmdletBinding()]
param ()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " HYPER-V FINAL DIAGNOSTICS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan


Write-Host "`n=== 1. HYPER-V FEATURES ===" -ForegroundColor Cyan

Get-WindowsOptionalFeature -Online |
    Where-Object {
        $_.FeatureName -match '^Microsoft-Hyper-V'
    } |
    Sort-Object FeatureName |
    Format-Table FeatureName, State -AutoSize


Write-Host "`n=== 2. CORE SERVICES ===" -ForegroundColor Cyan

Get-Service vmms, vmcompute -ErrorAction SilentlyContinue |
    Format-Table Name, DisplayName, Status, StartType -AutoSize


Write-Host "`n=== 3. POWERSHELL MODULE ===" -ForegroundColor Cyan

Get-Module -ListAvailable Hyper-V |
    Select-Object Name, Version, Path |
    Format-List


Write-Host "`n=== 4. HOST CONFIGURATION ===" -ForegroundColor Cyan

Get-VMHost |
    Select-Object `
        Name,
        LogicalProcessorCount,
        VirtualMachinePath,
        VirtualHardDiskPath,
        EnableEnhancedSessionMode,
        NumaSpanningEnabled |
    Format-List


Write-Host "`n=== 5. VM CONFIGURATION VERSIONS ===" -ForegroundColor Cyan

Write-Host "`nDefault:" -ForegroundColor Yellow

Get-VMHostSupportedVersion -Default |
    Format-Table -AutoSize

Write-Host "`nAll supported:" -ForegroundColor Yellow

Get-VMHostSupportedVersion |
    Format-Table -AutoSize


Write-Host "`n=== 6. VIRTUAL SWITCHES ===" -ForegroundColor Cyan

Get-VMSwitch |
    Select-Object `
        Name,
        SwitchType,
        NetAdapterInterfaceDescription |
    Format-Table -AutoSize


Write-Host "`n=== 7. VIRTUAL MACHINES ===" -ForegroundColor Cyan

Get-VM |
    Sort-Object Name |
    Select-Object `
        Name,
        State,
        Generation,
        Version,
        ProcessorCount,
        DynamicMemoryEnabled,
        CheckpointType,
        AutomaticCheckpointsEnabled |
    Format-Table -AutoSize


Write-Host "`n=== 8. VM SECURITY ===" -ForegroundColor Cyan

$securityResults = @()

foreach ($vm in (Get-VM | Where-Object { $_.Generation -eq 2 })) {

    $firmware = Get-VMFirmware -VMName $vm.Name
    $security = Get-VMSecurity -VMName $vm.Name

    $securityResults += [PSCustomObject]@{
        VMName             = $vm.Name
        SecureBoot         = $firmware.SecureBoot
        SecureBootTemplate = $firmware.SecureBootTemplate
        TPM                = $security.TpmEnabled
        Shielded           = $security.Shielded
    }
}

$securityResults |
    Sort-Object VMName |
    Format-Table -AutoSize


Write-Host "`n=== 9. VM NETWORK ADAPTERS ===" -ForegroundColor Cyan

$networkResults = @()

foreach ($vm in Get-VM) {

    foreach ($adapter in (Get-VMNetworkAdapter -VMName $vm.Name)) {

        $networkResults += [PSCustomObject]@{
            VMName     = $vm.Name
            Adapter    = $adapter.Name
            SwitchName = $adapter.SwitchName
            Status     = $adapter.Status
        }
    }
}

$networkResults |
    Sort-Object VMName |
    Format-Table -AutoSize


Write-Host "`n=== 10. ATTACHED VIRTUAL DISKS ===" -ForegroundColor Cyan

$diskResults = @()

foreach ($vm in Get-VM) {

    $drives = Get-VMHardDiskDrive `
        -VMName $vm.Name `
        -ErrorAction SilentlyContinue

    foreach ($drive in $drives) {

        $exists = Test-Path -LiteralPath $drive.Path

        $vhdType = $null
        $parent = $null

        if ($exists) {

            try {
                $vhd = Get-VHD -Path $drive.Path -ErrorAction Stop
                $vhdType = $vhd.VhdType
                $parent = $vhd.ParentPath
            }
            catch {
                $vhdType = 'READ_ERROR'
            }
        }

        $diskResults += [PSCustomObject]@{
            VMName     = $vm.Name
            Path       = $drive.Path
            Exists     = $exists
            VhdType    = $vhdType
            ParentPath = $parent
        }
    }
}

$diskResults |
    Sort-Object VMName |
    Format-Table -AutoSize


Write-Host "`n=== 11. ALL VHD/VHDX CHAINS ===" -ForegroundColor Cyan

$vhdRoot = (Get-VMHost).VirtualHardDiskPath

$vhdFiles = Get-ChildItem `
    -Path $vhdRoot `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Extension -in '.vhd', '.vhdx', '.avhd', '.avhdx'
    }

$chainResults = @()

foreach ($file in $vhdFiles) {

    try {

        $vhd = Get-VHD -Path $file.FullName -ErrorAction Stop

        $parentExists = $null

        if ($vhd.ParentPath) {
            $parentExists = Test-Path -LiteralPath $vhd.ParentPath
        }

        $chainResults += [PSCustomObject]@{
            File         = $file.Name
            Type         = $vhd.VhdType
            SizeGiB      = [math]::Round($vhd.Size / 1GB, 2)
            FileMiB      = [math]::Round($vhd.FileSize / 1MB, 2)
            ParentPath   = $vhd.ParentPath
            ParentExists = $parentExists
        }
    }
    catch {

        $chainResults += [PSCustomObject]@{
            File         = $file.Name
            Type         = 'READ_ERROR'
            SizeGiB      = $null
            FileMiB      = $null
            ParentPath   = $null
            ParentExists = $null
        }
    }
}

$chainResults |
    Sort-Object File |
    Format-Table -AutoSize


Write-Host "`n=== 12. HYPER-V EVENT LOGS ===" -ForegroundColor Cyan

$startTime = (Get-Date).AddDays(-1)

$hyperVLogs = Get-WinEvent `
    -ListLog '*Hyper-V*' `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IsEnabled -eq $true
    }

$eventResults = @()

foreach ($log in $hyperVLogs) {

    try {

        $events = Get-WinEvent `
            -FilterHashtable @{
                LogName   = $log.LogName
                StartTime = $startTime
                Level     = @(1,2,3)
            } `
            -ErrorAction Stop

        foreach ($event in $events) {

            $eventResults += [PSCustomObject]@{
                TimeCreated = $event.TimeCreated
                LogName     = $event.LogName
                Id          = $event.Id
                Level       = $event.LevelDisplayName
                Message     = (
                    $event.Message -replace "`r|`n", ' '
                )
            }
        }
    }
    catch {
        # Brak zdarzen albo log niedostepny.
    }
}

if ($eventResults.Count -eq 0) {

    Write-Host `
        "No Critical/Error/Warning Hyper-V events found in the last 24 hours." `
        -ForegroundColor Green
}
else {

    $eventResults |
        Sort-Object TimeCreated -Descending |
        Select-Object -First 30 |
        Format-Table `
            TimeCreated,
            LogName,
            Id,
            Level,
            Message `
            -Wrap
}


Write-Host "`n=== 13. QUICK HEALTH CHECK ===" -ForegroundColor Cyan

$problems = @()

$featureProblems = Get-WindowsOptionalFeature -Online |
    Where-Object {
        $_.FeatureName -match '^Microsoft-Hyper-V' -and
        $_.State -ne 'Enabled'
    }

if ($featureProblems) {
    $problems += 'One or more Hyper-V features are not enabled.'
}


$serviceProblems = Get-Service vmms, vmcompute |
    Where-Object {
        $_.Status -ne 'Running'
    }

if ($serviceProblems) {
    $problems += 'One or more core Hyper-V services are not running.'
}


$missingDisks = $diskResults |
    Where-Object {
        $_.Exists -eq $false
    }

if ($missingDisks) {
    $problems += 'One or more attached VHD/VHDX files are missing.'
}


$brokenParents = $chainResults |
    Where-Object {
        $_.ParentPath -and
        $_.ParentExists -eq $false
    }

if ($brokenParents) {
    $problems += 'One or more differencing disks have a missing parent.'
}


if ($problems.Count -eq 0) {

    Write-Host "`n[PASS] Hyper-V basic health check passed." `
        -ForegroundColor Green
}
else {

    Write-Host "`n[WARN] Problems detected:" `
        -ForegroundColor Yellow

    foreach ($problem in $problems) {
        Write-Host " - $problem" -ForegroundColor Yellow
    }
}


Write-Host "`n=== END OF DIAGNOSTICS ===" -ForegroundColor Cyan