<#
.SYNOPSIS
    Configures the system to audit Detailed Tracking - Process Creation (Success).

.DESCRIPTION
    Uses PowerShell to enable auditing and registry configuration.
    Includes clear distinction between command-line actions and required GUI steps for persistence.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-04-20
    Last Modified   : 2026-05-02
    Version         : 1.3
    STIG-ID         : WN11-AU-000050

.TESTED ON
    Windows 11 | PowerShell 5.1

.USAGE
    Run as Administrator:
    PS C:\> .\WN11-AU-000050.ps1
#>

# ================================
# 💻 COMMAND LINE (POWERSHELL)
# ================================

# --- Step 1: Enforce Advanced Audit Policy ---
# Ensures Windows uses advanced audit policy instead of legacy
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "SCENoApplyLegacyAuditPolicy" -Value 1 -Type DWord

# --- Step 2: Enable Process Creation auditing (Success) ---
# Enables logging of process creation events (STIG requirement)
auditpol /set /subcategory:"Process Creation" /success:enable

# --- Step 3: Verify via CLI ---
Write-Host "`n[+] Verifying audit policy (CLI)..." -ForegroundColor Cyan
auditpol /get /subcategory:"Process Creation"

# --- Step 4: Verify registry ---
Write-Host "`n[+] Verifying registry setting..." -ForegroundColor Cyan
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "SCENoApplyLegacyAuditPolicy"

# --- Step 5: Apply policy refresh ---
Write-Host "`n[+] Applying group policy refresh..." -ForegroundColor Cyan
gpupdate /force


# ================================
# 🖥️ GUI (MANUAL - REQUIRED FOR PERSISTENCE)
# ================================

Write-Host "`n[!] MANUAL STEP REQUIRED (GUI)" -ForegroundColor Yellow
Write-Host "PowerShell enables the setting, but GUI/GPO makes it persistent." -ForegroundColor Yellow

Write-Host "`nOpen: secpol.msc" -ForegroundColor Yellow

Write-Host "Navigate to:" -ForegroundColor Yellow
Write-Host "Security Settings" -ForegroundColor Yellow
Write-Host "→ Advanced Audit Policy Configuration" -ForegroundColor Yellow
Write-Host "→ System Audit Policies" -ForegroundColor Yellow
Write-Host "→ Detailed Tracking" -ForegroundColor Yellow
Write-Host "→ Audit Process Creation" -ForegroundColor Yellow

Write-Host "`nThen configure:" -ForegroundColor Yellow
Write-Host "[✔] Configure the following audit events" -ForegroundColor Yellow
Write-Host "[✔] Success" -ForegroundColor Yellow
Write-Host "Click Apply → OK" -ForegroundColor Yellow


# ================================
# 🔁 FINAL VERIFICATION
# ================================

Write-Host "`n[+] FINAL CHECK (after GUI step):" -ForegroundColor Cyan
Write-Host "Run: auditpol /get /subcategory:`"Process Creation`"" -ForegroundColor Cyan

Write-Host "`nExpected Output:" -ForegroundColor Green
Write-Host "Process Creation    Success" -ForegroundColor Green
