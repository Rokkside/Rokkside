<#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to audit
    System - Security System Extension successes on Windows 11, as required
    by STIG WN11-AU-000150 (V2R7).

    Security System Extension records events related to extension code being
    loaded by the security subsystem. Auditing these events is critical for
    detecting unauthorized security extension loading, identifying configuration
    errors, and analyzing compromises or attacks that may have occurred against
    the security subsystem.

    NOTE: This STIG ID maps to different controls depending on the STIG version.
    In V2R7 (the version used by the DISA_STIG_Microsoft_Windows_11_v2r7.audit
    Tenable file), WN11-AU-000150 maps to Security System Extension, NOT
    Special Logon. Applying the wrong control will not resolve the finding.

    This script handles both the auditpol configuration and the audit.csv
    Group Policy store. For persistence, the GUI steps below must also
    be completed.

    GUI Steps (secpol.msc - Required for Persistence):
        1. Open Local Security Policy (secpol.msc)
        2. Navigate to:
              Security Settings >>
              Advanced Audit Policy Configuration >>
              System Audit Policies >>
              System
        3. Double-click "Audit Security System Extension"
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
    Date Created    : 2026-05-06
    Last Modified   : 2026-05-06
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

# Step 1: Enable Security System Extension auditing (Success) via auditpol
auditpol /set /subcategory:"Security System Extension" /success:enable

# Verify auditpol was applied
Write-Host "Verifying auditpol..." -ForegroundColor Cyan
auditpol /get /subcategory:"Security System Extension"

# Step 2: Write to audit.csv so Group Policy and Tenable can verify the setting
$AuditDir = "C:\Windows\System32\GroupPolicy\Machine\Microsoft\Windows NT\Audit"
New-Item -Path $AuditDir -ItemType Directory -Force | Out-Null

$AuditCSV = "$AuditDir\audit.csv"
$NewEntry = ",System,Security System Extension,{0CCE9211-69AE-11D9-BED3-505054503030},Success,,1"
$Header   = "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value"

If (Test-Path $AuditCSV) {
    $Existing = Get-Content $AuditCSV
    If ($Existing -notmatch "Security System Extension") {
        Add-Content -Path $AuditCSV -Value $NewEntry
        Write-Host "Appended Security System Extension entry to audit.csv" -ForegroundColor Green
    } Else {
        Write-Host "Entry already exists in audit.csv - no change needed" -ForegroundColor Yellow
    }
} Else {
    Set-Content -Path $AuditCSV -Value "$Header`n$NewEntry" -Encoding UTF8
    Write-Host "audit.csv created with Security System Extension entry" -ForegroundColor Green
}

# Step 3: Apply immediately without waiting for next GPO refresh cycle
Write-Host "`nApplying Group Policy refresh..." -ForegroundColor Cyan
gpupdate /force

# Step 4: Final verification
Write-Host "`n=== FINAL VERIFICATION ===" -ForegroundColor Cyan
Write-Host "`nauditpol:" -ForegroundColor White
auditpol /get /subcategory:"Security System Extension"
Write-Host "`naudit.csv contents:" -ForegroundColor White
Get-Content $AuditCSV

# Step 5: Remind operator to complete GUI steps for persistence
Write-Host "`n[ACTION REQUIRED] Complete the GUI steps in the script synopsis" -ForegroundColor Yellow
Write-Host "to ensure this setting persists across reboots and GPO refreshes." -ForegroundColor Yellow
Write-Host "`nExpected auditpol output: Security System Extension    Success" -ForegroundColor Green
