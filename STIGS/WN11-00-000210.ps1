<#
.SYNOPSIS
    This PowerShell script ensures that Bluetooth radios are disabled on
    Windows 11 systems where Bluetooth is not organizationally approved,
    as required by STIG WN11-00-000210 (V2R7).

    If not configured properly, Bluetooth may allow rogue devices to communicate
    with a system. If a rogue device is paired with a system, there is potential
    for sensitive information to be compromised. Disabling unapproved Bluetooth
    radios removes this attack surface entirely.

    NOTE: This STIG is N/A if the system does not have a Bluetooth adapter.
    Virtual machines running on VMware, Hyper-V, or VirtualBox typically do
    not have Bluetooth hardware and should be marked Not Applicable in the scan.
    Verify hardware presence before running this script.

    This control has no registry key or GPO setting. Remediation is performed
    by disabling the Bluetooth adapter via PowerShell and Device Manager.
    Organizational policy for Bluetooth use must also be documented with the ISSO.

    GUI Steps (Device Manager - Required for Persistence):
        1. Open Device Manager (devmgmt.msc)
        2. Expand "Bluetooth"
        3. Right-click each Bluetooth adapter listed
        4. Select "Disable device"
        5. Click "Yes" to confirm
        6. Repeat for all Bluetooth adapters listed

    Note: If Bluetooth must remain enabled for an organizationally approved
    use case, that approval must be documented with the ISSO. The finding
    can then be marked as an accepted exception rather than remediated.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-00-000210
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-00-000210/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-00-000210.
    Only run if the system has a Bluetooth adapter that is not organizationally approved.
    Example syntax:
    PS C:\> .\WN11-00-000210.ps1
#>

# Check if any Bluetooth adapters are present on this system
$BluetoothDevices = Get-PnpDevice | Where-Object { $_.Class -eq "Bluetooth" }

If ($BluetoothDevices) {
    Write-Host "`nBluetooth adapter(s) found:" -ForegroundColor Cyan
    $BluetoothDevices | Format-Table Name, Status, InstanceId -AutoSize

    # Disable all Bluetooth adapters
    $BluetoothDevices | Disable-PnpDevice -Confirm:$false

    # Verify all adapters were disabled
    $Verified = Get-PnpDevice | Where-Object { $_.Class -eq "Bluetooth" }
    Write-Host "`nVerification - Bluetooth adapter status after remediation:" -ForegroundColor Cyan
    $Verified | Format-Table Name, Status -AutoSize

    Write-Host "All Bluetooth adapters have been disabled." -ForegroundColor Green

} Else {
    Write-Host "`nNo Bluetooth adapters detected on this system." -ForegroundColor Yellow
    Write-Host "This finding is N/A. Mark as Not Applicable in the scan." -ForegroundColor Yellow
}

# Remind operator of ISSO documentation requirement
Write-Host "`n[ACTION REQUIRED] If Bluetooth is required for an approved use case," -ForegroundColor Yellow
Write-Host "document the exception with the ISSO before re-enabling any adapters." -ForegroundColor Yellow
