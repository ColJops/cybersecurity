#requires -RunAsAdministrator
#requires -Modules Hyper-V

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$Name,

    [ValidateRange(1, 64)]
    [int]$ProcessorCount = 2,

    [ValidateRange(1, 1024)]
    [int]$StartupMemoryGiB = 2,

    [ValidateRange(1, 1024)]
    [int]$MinimumMemoryGiB = 1,

    [ValidateRange(1, 1024)]
    [int]$MaximumMemoryGiB = 4,

    [ValidateRange(1, 4096)]
    [int]$VhdSizeGiB = 40,

    [switch]$StaticMemory,

    [switch]$EnableTPM,

    [string]$SwitchName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'


function Write-Step {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}


Write-Step 'Checking Hyper-V host'

$vmHost = Get-VMHost

if ($null -eq $vmHost) {
    throw 'Hyper-V host configuration is unavailable.'
}


Write-Step 'Validating parameters'

if ($MinimumMemoryGiB -gt $StartupMemoryGiB) {
    throw 'MinimumMemoryGiB cannot exceed StartupMemoryGiB.'
}

if ($StartupMemoryGiB -gt $MaximumMemoryGiB) {
    throw 'StartupMemoryGiB cannot exceed MaximumMemoryGiB.'
}

if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
    throw "VM '$Name' already exists."
}

if ($SwitchName) {
    $existingSwitch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue

    if ($null -eq $existingSwitch) {
        throw "Virtual switch '$SwitchName' does not exist."
    }
}


$vmRoot = $vmHost.VirtualMachinePath
$vhdRoot = $vmHost.VirtualHardDiskPath

$vhdDirectory = Join-Path -Path $vhdRoot -ChildPath $Name
$vhdPath = Join-Path -Path $vhdDirectory -ChildPath "$Name.vhdx"

if (Test-Path -LiteralPath $vhdPath) {
    throw "VHDX already exists: $vhdPath"
}


$startupBytes = [int64]$StartupMemoryGiB * 1GB
$minimumBytes = [int64]$MinimumMemoryGiB * 1GB
$maximumBytes = [int64]$MaximumMemoryGiB * 1GB
$vhdSizeBytes = [int64]$VhdSizeGiB * 1GB


$action = 'Create standardized Hyper-V laboratory VM'

if (-not $PSCmdlet.ShouldProcess($Name, $action)) {
    return
}


Write-Step 'Creating VHDX directory'

$directoryParams = @{
    Path        = $vhdDirectory
    ItemType    = 'Directory'
    Force       = $true
    ErrorAction = 'Stop'
}

New-Item @directoryParams | Out-Null


Write-Step 'Creating Generation 2 VM'

$newVMParams = @{
    Name               = $Name
    Generation         = 2
    MemoryStartupBytes = $startupBytes
    NoVHD              = $true
    Path               = $vmRoot
    ErrorAction        = 'Stop'
}

if ($SwitchName) {
    $newVMParams['SwitchName'] = $SwitchName
}

New-VM @newVMParams | Out-Null


Write-Step 'Creating dynamic VHDX'

$newVhdParams = @{
    Path        = $vhdPath
    SizeBytes   = $vhdSizeBytes
    Dynamic     = $true
    ErrorAction = 'Stop'
}

New-VHD @newVhdParams | Out-Null


Write-Step 'Attaching VHDX'

$diskParams = @{
    VMName             = $Name
    ControllerType     = 'SCSI'
    ControllerNumber   = 0
    ControllerLocation = 0
    Path               = $vhdPath
    ErrorAction        = 'Stop'
}

Add-VMHardDiskDrive @diskParams


Write-Step 'Configuring vCPU'

$cpuParams = @{
    VMName         = $Name
    Count          = $ProcessorCount
    Reserve        = 0
    Maximum        = 100
    RelativeWeight = 100
    ErrorAction    = 'Stop'
}

Set-VMProcessor @cpuParams


Write-Step 'Configuring memory'

if ($StaticMemory) {
    $memoryParams = @{
        VMName               = $Name
        DynamicMemoryEnabled = $false
        StartupBytes         = $startupBytes
        ErrorAction          = 'Stop'
    }
}
else {
    $memoryParams = @{
        VMName               = $Name
        DynamicMemoryEnabled = $true
        MinimumBytes         = $minimumBytes
        StartupBytes         = $startupBytes
        MaximumBytes         = $maximumBytes
        Buffer               = 20
        Priority             = 50
        ErrorAction          = 'Stop'
    }
}

Set-VMMemory @memoryParams


Write-Step 'Configuring checkpoints'

$vmSettings = @{
    Name                        = $Name
    AutomaticCheckpointsEnabled = $false
    CheckpointType              = 'ProductionOnly'
    ErrorAction                 = 'Stop'
}

Set-VM @vmSettings


Write-Step 'Configuring Secure Boot'

$firmwareParams = @{
    VMName             = $Name
    EnableSecureBoot   = 'On'
    SecureBootTemplate = 'MicrosoftWindows'
    ErrorAction        = 'Stop'
}

Set-VMFirmware @firmwareParams


if ($EnableTPM) {
    Write-Step 'Creating local Key Protector'

    $keyProtectorParams = @{
        VMName               = $Name
        NewLocalKeyProtector = $true
        ErrorAction          = 'Stop'
    }

    Set-VMKeyProtector @keyProtectorParams

    Write-Step 'Enabling vTPM'

    $tpmParams = @{
        VMName      = $Name
        ErrorAction = 'Stop'
    }

    Enable-VMTPM @tpmParams
}


Write-Step 'Configuration completed'


$vm = Get-VM -Name $Name
$memory = Get-VMMemory -VMName $Name
$cpu = Get-VMProcessor -VMName $Name
$firmware = Get-VMFirmware -VMName $Name
$security = Get-VMSecurity -VMName $Name
$disk = Get-VMHardDiskDrive -VMName $Name | Select-Object -First 1
$network = Get-VMNetworkAdapter -VMName $Name | Select-Object -First 1

$switchValue = $null

if ($null -ne $network) {
    $switchValue = $network.SwitchName
}


Write-Host ""
Write-Host '=== VM SUMMARY ===' -ForegroundColor Green

[PSCustomObject]@{
    Name                        = $vm.Name
    Generation                  = $vm.Generation
    State                       = $vm.State
    ProcessorCount              = $cpu.Count
    DynamicMemory               = $memory.DynamicMemoryEnabled
    MemoryMinimumGiB            = [math]::Round($memory.Minimum / 1GB, 2)
    MemoryStartupGiB            = [math]::Round($memory.Startup / 1GB, 2)
    MemoryMaximumGiB            = [math]::Round($memory.Maximum / 1GB, 2)
    SecureBoot                  = $firmware.SecureBoot
    SecureBootTemplate          = $firmware.SecureBootTemplate
    TPM                         = $security.TpmEnabled
    AutomaticCheckpointsEnabled = $vm.AutomaticCheckpointsEnabled
    CheckpointType              = $vm.CheckpointType
    VHDPath                     = $disk.Path
    SwitchName                  = $switchValue
} | Format-List
