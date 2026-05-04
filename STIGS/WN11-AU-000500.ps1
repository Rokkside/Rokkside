<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application
    event log is configured to at least 32768 KB (32 MB) by setting the registry
    value "MaxSize" under the EventLog Application policy key for Windows 11.

    Undersized event logs can result in older security events being overwritten
    before they can be reviewed, reducing visibility into potential incidents.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              Windows Components >>
              Event Log Service >>
              Application
        3. Double-click "Specify the maximum log file size (KB)"
        4. Set to: Enabled
        5. Set the Maximum Log Size (KB) to: 32768 or greater
        6. Click OK and close the editor
        7. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    key from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-03-03
    Last Modified   : 2026-05-03
    Version         : 1.2
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-AU-000500
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000500/
.TESTED ON
    Date(s) Tested  : 2026-04-20
    Tested By       : Orok Ironbar
    Systems Tested  : Windows 11
    PowerShell Ver. : 5.1.26100.8115
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-AU-000500.
    Example syntax:
    PS C:\> .\WN11-AU-000500.ps1
#>

$RegPath  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$RegName  = "MaxSize"
$RegValue = 32768

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set MaxSize (DWord) to 32768 KB (32 MB) - minimum required by STIG
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify the setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName) KB" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force
