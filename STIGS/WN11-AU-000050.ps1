 <#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to audit Detailed Tracking - Process Creation successes.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-04-20
    Last Modified   : 2026-04-20
    Version         : 1.0
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

# Force advanced audit policy
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f

# Reboot is required
shutdown /r /t 0

# After reboot:

# Apply WN11-AU-000050
auditpol /set /subcategory:"Process Creation" /success:enable

# Verify.
auditpol /get /subcategory:"Process Creation" 
