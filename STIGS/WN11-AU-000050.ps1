<#
.SYNOPSIS
    Configures the system to audit Detailed Tracking - Process Creation successes using both PowerShell and GUI.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-04-20
    Last Modified   : 2026-04-20
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-AU-000050

.TESTED ON
    Date(s) Tested  : 2026-04-20
    Tested By       : Orok Ironbar
    Systems Tested  : Windows 11
    PowerShell Ver. : 5.1.26100.8115

.USAGE
    Run as Administrator:
    PS C:\> .\WN11-AU-000050.ps1
#>

# Enforce Advanced Audit Policy (Registry)
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f

# Reboot the machine for the policy to take effect
shutdown /r /t 0

# After reboot, apply WN11-AU-000050 via PowerShell
auditpol /set /subcategory:"Process Creation" /success:enable

# Verify that the audit policy is applied
auditpol /get /subcategory:"Process Creation"

# GUI Method to Manually Enable Process Creation Audit (if needed)
Write-Host "Alternatively, you can enable the 'Audit Process Creation' policy manually via the GUI:"
Write-Host "1. Open Local Security Policy (secpol.msc)."
Write-Host "2. Navigate to Advanced Audit Policy Configuration > Detailed Tracking > Audit Process Creation."
Write-Host "3. Set it to 'Success' and click Apply."
Write-Host "4. Ensure that the policy is applied after this change."

# Confirm settings via GUI (in case needed)
Write-Host "Once the GUI setting is applied, verify the status with 'auditpol /get /subcategory:\"Process Creation\"'."
