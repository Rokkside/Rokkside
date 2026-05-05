<#
.SYNOPSIS
    This PowerShell script ensures that PowerShell script block logging is
    enabled by setting the registry value "EnableScriptBlockLogging" to 1
    under the PowerShell ScriptBlockLogging policy key for Windows 11,
    as required by STIG WN11-CC-000326 (V2R7).

    Enabling PowerShell script block logging records detailed information from
    the processing of PowerShell commands and scripts. This is essential for
    analyzing the security of information assets, detecting signs of suspicious
    behavior, and providing an audit trail of PowerShell activity on the system.
    Logged events appear in the PowerShell Operational event log as Event ID 4104.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              Windows Components >>
              Windows PowerShell
        3. Double-click "Turn on PowerShell Script Block Logging"
        4. Set to: Enabled
        5. Optionally check: "Log script block invocation start / stop events"
           to capture when scripts start and stop in addition to content
        6. Click OK and close the editor
        7. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    key from being overwritten during Group Policy refresh.

    Note: To verify logged events after enabling, open Event Viewer and navigate
    to Applications and Services Logs >> Microsoft >> Windows >> PowerShell >>
    Operational and filter for Event ID 4104.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-CC-000326
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000326/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000326.
    Example syntax:
    PS C:\> .\WN11-CC-000326.ps1
#>

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set value - 1 = Enable PowerShell script block logging (required by STIG)
Set-ItemProperty -Path $RegPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord

# Set value - 1 = Log script block invocation start/stop events (recommended)
Set-ItemProperty -Path $RegPath -Name "EnableScriptBlockInvocationLogging" -Value 1 -Type DWord

# Verify both settings were applied
$Result = Get-ItemProperty -Path $RegPath
Write-Host "EnableScriptBlockLogging          : $($Result.EnableScriptBlockLogging)" -ForegroundColor Green
Write-Host "EnableScriptBlockInvocationLogging: $($Result.EnableScriptBlockInvocationLogging)" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force

# Remind operator how to verify logging is active
Write-Host "`n[INFO] To verify logging is active, open Event Viewer and navigate to:" -ForegroundColor Cyan
Write-Host "Applications and Services Logs >> Microsoft >> Windows >> PowerShell >> Operational" -ForegroundColor White
Write-Host "Filter for Event ID 4104 to confirm script block logging is recording." -ForegroundColor White
