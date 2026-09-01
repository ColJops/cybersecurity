[CmdletBinding()]
param(
    [string]$VMName
)

$ErrorActionPreference = 'Stop'

$VBoxManage =
    'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'

if (-not (Test-Path $VBoxManage)) {
    throw "VBoxManage not found: $VBoxManage"
}

function Invoke-VBoxReadOnly {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $Output = @(
        & $VBoxManage @Arguments 2>&1
    )

    if ($LASTEXITCODE -ne 0) {
        throw (
            "VBoxManage failed: " +
            ($Arguments -join ' ')
        )
    }

    return $Output
}

Write-Host ''
Write-Host '=== VIRTUALBOX DIAGNOSTICS ===' `
    -ForegroundColor Cyan
Write-Host ''

# ------------------------------------------------------------
# Host
# ------------------------------------------------------------

$VersionOutput = @(
    Invoke-VBoxReadOnly @('--version')
)

$Version = (
    $VersionOutput |
    Select-Object -First 1
).ToString().Trim()

Write-Host "VirtualBox version: $Version"

$SystemProperties = @(
    Invoke-VBoxReadOnly @(
        'list',
        'systemproperties'
    )
)

$DefaultFolderMatch = (
    $SystemProperties |
    Select-String 'Default machine folder:' |
    Select-Object -First 1
)

$DefaultFolder = if ($DefaultFolderMatch) {
    $DefaultFolderMatch.ToString()
}
else {
    ''
}

Write-Host $DefaultFolder

# ------------------------------------------------------------
# Registered / running VMs
# ------------------------------------------------------------

$RegisteredVMs = @(
    Invoke-VBoxReadOnly @(
        'list',
        'vms'
    )
)

$RunningVMs = @(
    Invoke-VBoxReadOnly @(
        'list',
        'runningvms'
    )
)

Write-Host ''
Write-Host 'Registered VMs:' `
    -ForegroundColor Cyan

if ($RegisteredVMs.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $RegisteredVMs |
        ForEach-Object {
            Write-Host $_
        }
}

Write-Host ''
Write-Host 'Running VMs:' `
    -ForegroundColor Cyan

if ($RunningVMs.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $RunningVMs |
        ForEach-Object {
            Write-Host $_
        }
}

# ------------------------------------------------------------
# Extension packs
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Extension Packs:' `
    -ForegroundColor Cyan

$ExtPacks = @(
    Invoke-VBoxReadOnly @(
        'list',
        'extpacks'
    )
)

$ExtPacks |
    ForEach-Object {
        Write-Host $_
    }

# ------------------------------------------------------------
# Host-only interfaces
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Host-only interfaces:' `
    -ForegroundColor Cyan

$HostOnly = @(
    Invoke-VBoxReadOnly @(
        'list',
        'hostonlyifs'
    )
)

if ($HostOnly.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $HostOnly |
        ForEach-Object {
            Write-Host $_
        }
}

# ------------------------------------------------------------
# NAT Networks
# ------------------------------------------------------------

Write-Host ''
Write-Host 'NAT Networks:' `
    -ForegroundColor Cyan

$NatNetworks = @(
    Invoke-VBoxReadOnly @(
        'natnetwork',
        'list'
    )
)

if ($NatNetworks.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $NatNetworks |
        ForEach-Object {
            Write-Host $_
        }
}

# ------------------------------------------------------------
# Media
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Virtual disks:' `
    -ForegroundColor Cyan

$Hdds = @(
    Invoke-VBoxReadOnly @(
        'list',
        'hdds'
    )
)

$Hdds |
    ForEach-Object {
        Write-Host $_
    }

$HasInaccessibleMedia = [bool](
    $Hdds |
    Select-String '(?i)inaccessible'
)

# ------------------------------------------------------------
# Optional VM audit
# ------------------------------------------------------------

$VMExists = $false
$VMInfoText = ''

if ($VMName) {

    Write-Host ''
    Write-Host "VM audit: $VMName" `
        -ForegroundColor Cyan

    $VMExists = [bool](
        $RegisteredVMs |
        Where-Object {
            $_ -match (
                '^"' +
                [regex]::Escape($VMName) +
                '"'
            )
        } |
        Select-Object -First 1
    )

    if (-not $VMExists) {
        throw "VM '$VMName' is not registered."
    }

    $VMInfo = @(
        Invoke-VBoxReadOnly @(
            'showvminfo',
            $VMName
        )
    )

    $VMInfoText = $VMInfo -join "`n"

    $VMInfo |
        ForEach-Object {
            Write-Host $_
        }
}

# ------------------------------------------------------------
# Assessment
# ------------------------------------------------------------

$Checks = [ordered]@{
    VBoxManageAvailable =
        (Test-Path $VBoxManage)

    VersionDetected =
        ($Version -match '^\d+\.\d+\.\d+')

    DefaultMachineFolderDetected =
        ($DefaultFolder -match
            'Default machine folder:')

    NoInaccessibleMedia =
        (-not $HasInaccessibleMedia)
}

if ($VMName) {

    $Checks['RequestedVMRegistered'] =
        $VMExists

    $Checks['VMUUIDDetected'] =
    ($VMInfoText -match
        '(?m)^UUID:\s+\S+')

$Checks['VMStateDetected'] =
    ($VMInfoText -match
        '(?m)^State:\s+.+')

$Checks['VMNIC1Detected'] =
    ($VMInfoText -match
        '(?m)^NIC 1:\s+.+')

$Checks['VMStorageDetected'] =
    ($VMInfoText -match
        '(?m)^Storage Controllers:')
}

$Failed = @(
    $Checks.GetEnumerator() |
    Where-Object {
        -not $_.Value
    }
)

Write-Host ''
Write-Host '--- VALIDATION ---' `
    -ForegroundColor Cyan

foreach ($Check in $Checks.GetEnumerator()) {

    $Color = if ($Check.Value) {
        'Green'
    }
    else {
        'Red'
    }

    Write-Host (
        '{0,-32} {1}' -f
        $Check.Key,
        $Check.Value
    ) -ForegroundColor $Color
}

Write-Host ''

if ($Failed.Count -eq 0) {
    Write-Host 'ASSESSMENT: PASS' `
        -ForegroundColor Green
}
else {
    Write-Host 'ASSESSMENT: REVIEW' `
        -ForegroundColor Yellow
}