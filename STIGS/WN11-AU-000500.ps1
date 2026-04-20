  <#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-03-03
    Last Modified   : 2026-04-16
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-AU-000500

.TESTED ON
    Date(s) Tested  : 2026-04-20
    Tested By       : Orok Ironbar
    Systems Tested  : Windows 11
    PowerShell Ver. :  5.1.26100.8115 


.USAGE
    Run as Administrator:
    PS C:\> .\STIG-ID-WN11-AU-000500.ps1 
#>

# Define the registry path
$Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"

# Ensure the registry key exists
New-Item -Path $Path -Force | Out-Null

# Set MaxSize (DWORD) to 32768 (0x8000)
New-ItemProperty -Path $Path -Name "MaxSize" -Value 32768 -PropertyType DWord -Force | Out-Null

# Verify the setting.
Get-ItemProperty -Path $Path -Name MaxSize 
