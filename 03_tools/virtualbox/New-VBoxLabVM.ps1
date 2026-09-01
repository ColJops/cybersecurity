[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{2,63}$')]
    [string]$Name,

    [ValidateRange(512, 32768)]
    [int]$MemoryMB = 2048,

    [ValidateRange(1, 8)]
    [int]$CPUCount = 2,

    [ValidateRange(4096, 131072)]
    [int]$DiskSizeMB = 16384,

    [string]$IsoPath =
        'D:\VirtualBox\ISO\debian-13.6.0-amd64-netinst.iso',

    [string]$BaseFolder =
        'D:\VirtualBox\Virtual Machines',

    [ValidateSet('NAT', 'None')]
    [string]$NetworkMode = 'NAT'
)

$ErrorActionPreference = 'Stop'

$VBoxManage =
    'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'

$CreatedVM = $false

function Invoke-VBox {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & $VBoxManage @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "VBoxManage failed. Exit code: $LASTEXITCODE"
    }
}

Write-Host ''
Write-Host '=== NEW VIRTUALBOX LAB VM ===' -ForegroundColor Cyan
Write-Host ''

# ------------------------------------------------------------
# Preflight
# ------------------------------------------------------------

if (-not (Test-Path $VBoxManage)) {
    throw "VBoxManage not found: $VBoxManage"
}

if (-not (Test-Path $BaseFolder)) {
    throw "Base folder does not exist: $BaseFolder"
}

if (-not (Test-Path $IsoPath)) {
    throw "ISO does not exist: $IsoPath"
}

if ([IO.Path]::GetExtension($IsoPath) -ne '.iso') {
    throw "Installation media is not an ISO file."
}

$VBoxVersion = (& $VBoxManage --version).Trim()

Write-Host "VirtualBox: $VBoxVersion"
Write-Host "VM name:    $Name"
Write-Host "RAM:        $MemoryMB MB"
Write-Host "CPU:        $CPUCount"
Write-Host "Disk:       $DiskSizeMB MB"
Write-Host "ISO:        $IsoPath"
Write-Host "Storage:    $BaseFolder"
Write-Host "Network:    $NetworkMode"
Write-Host ''

# ------------------------------------------------------------
# Existing VM protection
# ------------------------------------------------------------

$RegisteredVMs = @(
    & $VBoxManage list vms
)

$VMExists = [bool](
    $RegisteredVMs |
    Where-Object {
        $_ -match ('^"' + [regex]::Escape($Name) + '"')
    } |
    Select-Object -First 1
)

if ($VMExists) {
    throw "VM '$Name' already exists. Existing VM will not be modified."
}

$VMDirectory = Join-Path $BaseFolder $Name
$VDIPath = Join-Path $VMDirectory "$Name.vdi"

if (Test-Path $VMDirectory) {
    throw "Target VM directory already exists: $VMDirectory"
}

# ------------------------------------------------------------
# Free space check
# ------------------------------------------------------------

$DriveRoot = [IO.Path]::GetPathRoot($BaseFolder)

$DriveLetter = $DriveRoot.Substring(0,1)

$Drive = Get-PSDrive -Name $DriveLetter

$RequestedBytes = [int64]$DiskSizeMB * 1MB

# Dynamic VDI does not consume its full capacity immediately,
# but require a conservative amount of free space.
$MinimumFreeBytes = [math]::Min(
    $RequestedBytes,
    4GB
)

if ($Drive.Free -lt $MinimumFreeBytes) {
    throw "Insufficient free space on $DriveRoot"
}

# ------------------------------------------------------------
# Creation
# ------------------------------------------------------------

try {
    Write-Host '[1/7] Creating VM...' -ForegroundColor Cyan

    Invoke-VBox @(
        'createvm',
        '--name', $Name,
        '--ostype', 'Debian13_64',
        '--basefolder', $BaseFolder,
        '--register'
    )

    $CreatedVM = $true

    Write-Host '[2/7] Configuring hardware...' -ForegroundColor Cyan

    $Nic1 = if ($NetworkMode -eq 'NAT') {
        'nat'
    }
    else {
        'none'
    }

    Invoke-VBox @(
        'modifyvm', $Name,
        '--memory', $MemoryMB,
        '--cpus', $CPUCount,
        '--firmware', 'efi',
        '--graphicscontroller', 'vmsvga',
        '--vram', '16',
        '--audio-enabled', 'off',
        '--clipboard-mode', 'disabled',
        '--drag-and-drop', 'disabled',
        '--nic1', $Nic1,
        '--nic2', 'none',
        '--boot1', 'dvd',
        '--boot2', 'disk',
        '--boot3', 'none',
        '--boot4', 'none'
    )

    if ($NetworkMode -eq 'NAT') {
        Invoke-VBox @(
            'modifyvm', $Name,
            '--cable-connected1', 'on'
        )
    }

    Write-Host '[3/7] Creating VDI...' -ForegroundColor Cyan

    Invoke-VBox @(
        'createmedium', 'disk',
        '--filename', $VDIPath,
        '--size', $DiskSizeMB,
        '--format', 'VDI',
        '--variant', 'Standard'
    )

    Write-Host '[4/7] Creating SATA controller...' -ForegroundColor Cyan

    Invoke-VBox @(
        'storagectl', $Name,
        '--name', 'SATA',
        '--add', 'sata',
        '--controller', 'IntelAhci',
        '--bootable', 'on'
    )

    Invoke-VBox @(
        'storageattach', $Name,
        '--storagectl', 'SATA',
        '--port', '0',
        '--device', '0',
        '--type', 'hdd',
        '--medium', $VDIPath
    )

    Write-Host '[5/7] Creating IDE controller...' -ForegroundColor Cyan

    Invoke-VBox @(
        'storagectl', $Name,
        '--name', 'IDE',
        '--add', 'ide',
        '--controller', 'PIIX4',
        '--bootable', 'on'
    )

    Write-Host '[6/7] Attaching installation ISO...' -ForegroundColor Cyan

    Invoke-VBox @(
        'storageattach', $Name,
        '--storagectl', 'IDE',
        '--port', '0',
        '--device', '0',
        '--type', 'dvddrive',
        '--medium', $IsoPath
    )

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    Write-Host '[7/7] Validating configuration...' -ForegroundColor Cyan

    $Info = @(
        & $VBoxManage showvminfo $Name
    )

    $InfoText = $Info -join "`n"

    $Checks = [ordered]@{
        Registered       = $true
        MemoryCorrect    = $InfoText -match "Memory size:\s+$($MemoryMB)MB"
        CPUCorrect       = $InfoText -match "Number of CPUs:\s+$CPUCount"
        FirmwareEFI      = $InfoText -match 'Firmware:\s+EFI'
        GraphicsVMSVGA   = $InfoText -match 'Graphics Controller:\s+VMSVGA'
        ClipboardOff     = $InfoText -match 'Clipboard Mode:\s+disabled'
        DragDropOff      = $InfoText -match 'Drag and drop Mode:\s+disabled'
        DiskAttached     = $InfoText -match [regex]::Escape($VDIPath)
        ISOAttached      = $InfoText -match [regex]::Escape($IsoPath)
        BootDVD          = $InfoText -match 'Boot Device 1:\s+DVD'
        BootDisk         = $InfoText -match 'Boot Device 2:\s+HardDisk'
    }

    if ($NetworkMode -eq 'NAT') {
        $Checks['NetworkCorrect'] =
            $InfoText -match 'NIC 1:.*Attachment:\s+NAT'
    }
    else {
        $Checks['NetworkCorrect'] =
            $InfoText -match 'NIC 1:\s+disabled'
    }

    $FailedChecks = @(
        $Checks.GetEnumerator() |
        Where-Object {
            -not $_.Value
        }
    )

    Write-Host ''
    Write-Host '--- VALIDATION ---' -ForegroundColor Cyan

    foreach ($Check in $Checks.GetEnumerator()) {
        $Color = if ($Check.Value) {
            'Green'
        }
        else {
            'Red'
        }

        Write-Host (
            '{0,-24} {1}' -f $Check.Key, $Check.Value
        ) -ForegroundColor $Color
    }

    Write-Host ''

    if ($FailedChecks.Count -gt 0) {
        throw 'VM was created but validation failed.'
    }

    Write-Host 'ASSESSMENT: PASS' -ForegroundColor Green
    Write-Host ''
    Write-Host "VM created: $Name"
    Write-Host "VDI:        $VDIPath"
    Write-Host "ISO:        $IsoPath"
}
catch {
    Write-Host ''
    Write-Host 'ERROR:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    if ($CreatedVM) {
        Write-Host ''
        Write-Host 'Attempting rollback...' -ForegroundColor Yellow

        try {
            & $VBoxManage unregistervm $Name --delete | Out-Null
            Write-Host 'Rollback completed.' -ForegroundColor Yellow
        }
        catch {
            Write-Host `
                'Automatic rollback failed. Manual review required.' `
                -ForegroundColor Red
        }
    }

    throw
}