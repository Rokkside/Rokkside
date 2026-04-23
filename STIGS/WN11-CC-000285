 <#
.SYNOPSIS
     Ensures Remote Desktop Session Host requires secure RPC communication.

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
<#
.SYNOPSIS
    Ensures Remote Desktop Session Host requires secure RPC communication.

.NOTES
    Author          : Orok Ironbar
    STIG-ID         : WN11-CC-000285
#>

$Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$Name = "fEncryptRPCTraffic"
$Value = 1

# Ensure key exists
New-Item -Path $Path -Force | Out-Null

# Set value
Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord

# Verify
Get-ItemProperty -Path $Path -Name $Name

gpupdate /force 
