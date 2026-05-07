<#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to audit
    Privilege Use - Sensitive Privilege Use successes on Windows 11, as
    required by STIG WN11-AU-000115 (V2R7).

    Sensitive Privilege Use records events related to the use of sensitive
    privileges such as "Act as part of the operating system" or "Debug
    programs". Auditing these events is critical for detecting unauthorized
    privilege escalation, identifying accounts abusing elevated rights, and
    providing forensic evidence of sensitive privilege activity on the system.

    NOTE: Tenable V2R7 verifies this setting by reading the audit.csv file at:
    C:\Windows\System32\GroupPolicy\Machine\Microsoft\Windows NT\Audit\audit.csv
    Setting this via auditpol alone is not sufficient to pass the scan. Both
    auditpol and audit.csv must be configured for full compliance.

    This script handles the registry enforcement, auditpol configuration, and
    audit.csv write. For persistence, the GUI steps below must also be completed.

    GUI Steps (secpol.msc - Required for Persistence):
        1. Open Local Security Policy (secpol.msc)
        2. Navigate to:
              Security Settings >>
              Advanced Audit Policy Configuration >>
              System Audit Policies >>
              Privilege Use
        3. Double-click "Audit Sensitive Privilege Use"
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
    STIG-ID         : WN11-AU-000115
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000115/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-AU-000115.
    Example syntax:
    PS C:\> .\WN11-AU-000115.ps1
#>

$RegPath  = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$RegName  = "SCENoApplyLegacyAuditPolicy"
$RegValue = 1

# Step 1: Enforce advanced audit policy over legacy audit policy
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord

# Verify registry setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Step 2: Enable Sensitive Privilege Use auditing (Success) via auditpol
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable

# Verify auditpol was applied
Write-Host "`nVerifying audit policy..." -ForegroundColor Cyan
auditpol /get /subcategory:"Sensitive Privilege Use"

# Step 3: Write to audit.csv so Tenable V2R7 can verify the setting
$AuditDir = "C:\Windows\System32\GroupPolicy\Machine\Microsoft\Windows NT\Audit"
New-Item -Path $AuditDir -ItemType Directory -Force | Out-Null

$AuditCSV = "$AuditDir\audit.csv"
$NewEntry = ",System,Sensitive Privilege Use,{0CCE9228-69AE-11D9-BED3-505054503030},Success,,1"
$Header   = "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value"

If (Test-Path $AuditCSV) {
    $Existing = Get-Content $AuditCSV
    If ($Existing -notmatch "Sensitive Privilege Use") {
        Add-Content -Path $AuditCSV -Value $NewEntry
        Write-Host "Appended Sensitive Privilege Use entry to audit.csv" -ForegroundColor Green
    } Else {
        Write-Host "Entry already exists in audit.csv - no change needed" -ForegroundColor Yellow
    }
} Else {
    Set-Content -Path $AuditCSV -Value "$Header`n$NewEntry" -Encoding UTF8
    Write-Host "audit.csv created with Sensitive Privilege Use entry" -ForegroundColor Green
}

# Step 4: Apply immediately without waiting for next GPO refresh cycle
Write-Host "`nApplying Group Policy refresh..." -ForegroundColor Cyan
gpupdate /force

# Step 5: Final verification
Write-Host "`n=== FINAL VERIFICATION ===" -ForegroundColor Cyan
Write-Host "`nauditpol:" -ForegroundColor White
auditpol /get /subcategory:"Sensitive Privilege Use"
Write-Host "`naudit.csv contents:" -ForegroundColor White
Get-Content $AuditCSV

# Step 6: Remind operator to complete GUI steps for persistence
Write-Host "`n[ACTION REQUIRED] Complete the GUI steps in the script synopsis" -ForegroundColor Yellow
Write-Host "to ensure this setting persists across reboots and GPO refreshes." -ForegroundColor Yellow
Write-Host "`nExpected auditpol output: Sensitive Privilege Use    Success" -ForegroundColor Green
