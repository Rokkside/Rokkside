<#
.SYNOPSIS
    Remediates WN11-00-000210 - Bluetooth must be turned off unless approved by the organization.

.DESCRIPTION
    This script remediates the DISA STIG finding WN11-00-000210 by:
    1. Setting the AllowBluetooth registry policy value to 0
    2. Stopping and disabling the Bluetooth Support Service (bthserv)
    3. Disabling all Bluetooth adapters via PnP Device Manager

    Intended for standalone (non-Intune) Windows 11 systems.
    For Intune-managed systems, apply the DOD Windows 11 STIG Settings Catalog policy via cyber.mil.

.NOTES
    STIG ID   : WN11-00-000210
    Severity  : CAT II
    Version   : Windows 11 STIG V2R7
    Author    : 
    Date      : 
    
    Run as Administrator. If Bluetooth is required for an approved use case,
    document the exception with the ISSO before re-enabling any adapters.
#>

# Disable via registry (what Tenable likely checks)
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WirelessCommunication"
If (-Not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}
Set-ItemProperty -Path $RegPath -Name "AllowBluetooth" -Value 0 -Type DWord

# Disable the Bluetooth Support Service
Stop-Service -Name bthserv -Force -ErrorAction SilentlyContinue
Set-Service -Name bthserv -StartupType Disabled -ErrorAction SilentlyContinue

# Disable all Bluetooth adapters
$BluetoothDevices = Get-PnpDevice | Where-Object { $_.Class -eq "Bluetooth" }
$BluetoothDevices | Disable-PnpDevice -Confirm:$false

# Verify
Write-Host "`nVerification - Bluetooth adapter status after remediation:" -ForegroundColor Cyan
Get-PnpDevice | Where-Object { $_.Class -eq "Bluetooth" } | Format-Table Name, Status -AutoSize
Write-Host "Remediation complete." -ForegroundColor Green

# ISSO notice
Write-Host "`n[ACTION REQUIRED] If Bluetooth is required for an approved use case," -ForegroundColor Yellow
Write-Host "document the exception with the ISSO before re-enabling any adapters." -ForegroundColor Yellow
