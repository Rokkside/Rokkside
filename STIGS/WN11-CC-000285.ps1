<#
.SYNOPSIS
    This PowerShell script ensures that the Remote Desktop Session Host is configured
    to require secure RPC communication by setting the registry value "fEncryptRPCTraffic"
    to 1 under the Terminal Services policy key for Windows 11.

    This prevents man-in-the-middle attacks and unauthorized access by enforcing
    encrypted RPC traffic between RDP clients and the session host.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              Windows Components >>
              Remote Desktop Services >>
              Remote Desktop Session Host >>
              Security
        3. Double-click "Require secure RPC communication"
        4. Set to: Enabled
        5. Click OK and close the editor
        6. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    key from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-04-20
    Last Modified   : 2026-05-03
    Version         : 1.2
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-CC-000285
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000285/
.TESTED ON
    Date(s) Tested  : 2026-04-22
    Tested By       : Orok Ironbar
    Systems Tested  : Windows 11
    PowerShell Ver. : 5.1.26100.8115
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000285.
    Example syntax:
    PS C:\> .\WN11-CC-000285.ps1
#>

$RegPath  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$RegName  = "fEncryptRPCTraffic"
$RegValue = 1

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set value - 1 = Require secure RPC communication
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify the setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force
