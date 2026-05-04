<#
.SYNOPSIS
    This PowerShell script ensures that the lock screen slide show is disabled
    by setting the registry value "NoLockScreenSlideshow" to 1 under the
    Personalization policy key for Windows 11.

    Enabling a lock screen slide show can expose content on an unattended
    workstation without requiring authentication. Disabling it ensures the
    system cannot display information to unauthenticated users.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              Control Panel >>
              Personalization
        3. Double-click "Prevent enabling lock screen slide show"
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
    Date Created    : 2026-05-03
    Last Modified   : 2026-05-03
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-CC-000050
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000050/
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : Windows 11
    PowerShell Ver. : 
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000050.
    Example syntax:
    PS C:\> .\WN11-CC-000050.ps1
#>

$RegPath  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$RegName  = "NoLockScreenSlideshow"
$RegValue = 1

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set value - 1 = Prevent enabling lock screen slide show
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify the setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force
