<#
.SYNOPSIS
    This PowerShell script ensures that printing over HTTP is prevented by
    setting the registry value "DisableHTTPPrinting" to 1 under the Internet
    Communication Management policy key for Windows 11.

    Printing over HTTP allows print jobs to be sent across the network using
    the unencrypted HTTP protocol. This can expose print data to interception
    and is not permitted under STIG requirements. Disabling it forces the
    system to use only secure, authorized print paths.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              System >>
              Internet Communication Management >>
              Internet Communication settings
        3. Double-click "Turn off printing over HTTP"
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
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-CC-000110
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000110/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000110.
    Example syntax:
    PS C:\> .\WN11-CC-000110.ps1
#>

$RegPath  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
$RegName  = "DisableHTTPPrinting"
$RegValue = 1

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set value - 1 = Turn off printing over HTTP
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify the setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force
