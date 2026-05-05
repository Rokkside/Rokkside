<#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to audit
    Logon/Logoff - Special Logon successes on Windows 11, as required by
    STIG WN11-AU-000150 (V2R7).

    Special Logon records logons that use administrative privileges and can
    be used to elevate processes. Auditing these events is critical for
    detecting unauthorized privilege use, tracking administrative access,
    and identifying potential indicators of compromise involving elevated
    account activity.

    This script handles both the registry enforcement and auditpol configuration.
    For persistence, the GUI steps below must also be completed.

    GUI Steps (secpol.msc - Required for Persistence):
        1. Open Local Security Policy (secpol.msc)
        2. Navigate to:
              Security Settings >>
              Advanced Audit Policy Configuration >>
              System Audit Policies >>
              Logon/Logoff
        3. Double-click "Audit Special Logon"
        4. Check: "Configure the following audit events"
        5. Check: "Success"
        6. Click Apply then OK and close the editor
        7. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the
    audit policy from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-AU-000150
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000150/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-AU-000150.
    Example syntax:
    PS C:\> .\WN11-AU-000150.ps1
#>

$RegPath  = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$RegName  = "SCENoApplyLegacyAuditPolicy"
$RegValue = 1

# Step 1: Enforce advanced audit policy over legacy audit policy
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify registry setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Step 2: Enable Special Logon auditing (Success) via auditpol
auditpol /set /subcategory:"Special Logon" /success:enable

# Verify audit policy was applied
Write-Host "`nVerifying audit policy..." -ForegroundColor Cyan
auditpol /get /subcategory:"Special Logon"

# Step 3: Apply immediately without waiting for next GPO refresh cycle
Write-Host "`nApplying Group Policy refresh..." -ForegroundColor Cyan
gpupdate /force

# Step 4: Remind operator to complete GUI steps for persistence
Write-Host "`n[ACTION REQUIRED] Complete the GUI steps in the script synopsis" -ForegroundColor Yellow
Write-Host "to ensure this setting persists across reboots and GPO refreshes." -ForegroundColor Yellow
Write-Host "`nFinal verification command:" -ForegroundColor Cyan
Write-Host 'auditpol /get /subcategory:"Special Logon"' -ForegroundColor White
Write-Host "`nExpected output: Special Logon    Success" -ForegroundColor Green
