<#
.SYNOPSIS
    This PowerShell script ensures that Hardened UNC Paths are configured to
    require mutual authentication and integrity for NETLOGON and SYSVOL shares
    on Windows 11, as required by STIG WN11-CC-000050 (V2R7).

    Without hardened UNC paths, domain-joined systems are vulnerable to
    man-in-the-middle attacks that could intercept or tamper with Group Policy
    and logon scripts delivered via NETLOGON and SYSVOL shares.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              Network >>
              Network Provider
        3. Double-click "Hardened UNC Paths"
        4. Set to: Enabled
        5. Click "Show..." under Options
        6. Add the following two entries exactly as shown:

              Value Name                  Value
              ----------                  -----
              \\*\NETLOGON                RequireMutualAuthentication=1, RequireIntegrity=1
              \\*\SYSVOL                  RequireMutualAuthentication=1, RequireIntegrity=1

        7. Click OK on the Show Contents window
        8. Click OK and close the editor
        9. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    keys from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-CC-000050
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000050/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000050.
    Example syntax:
    PS C:\> .\WN11-CC-000050.ps1
#>

$RegPath      = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
$RequiredValue = "RequireMutualAuthentication=1, RequireIntegrity=1"

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set NETLOGON hardened path - REG_SZ (string) type required by STIG
Set-ItemProperty -Path $RegPath `
    -Name "\\*\NETLOGON" `
    -Value $RequiredValue `
    -Type String

# Set SYSVOL hardened path - REG_SZ (string) type required by STIG
Set-ItemProperty -Path $RegPath `
    -Name "\\*\SYSVOL" `
    -Value $RequiredValue `
    -Type String

# Verify both values were applied
$Result = Get-ItemProperty -Path $RegPath
Write-Host "NETLOGON : $($Result.'\\*\NETLOGON')" -ForegroundColor Green
Write-Host "SYSVOL   : $($Result.'\\*\SYSVOL')" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force
