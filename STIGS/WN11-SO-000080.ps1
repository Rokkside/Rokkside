<#
.SYNOPSIS
    This PowerShell script ensures that the Windows logon legal notice title
    is configured by setting the registry value "LegalNoticeCaption" under
    the System policy key for Windows 11, as required by STIG WN11-SO-000080 (V2R7).

    Failure to display a logon banner prior to a logon attempt can negate
    legal proceedings resulting from unauthorized access to system resources.
    This setting configures the title bar of the logon warning dialog and works
    in conjunction with WN11-SO-000075 which sets the banner body text.

    Acceptable values for the title are:
        - "DoD Notice and Consent Banner"
        - "US Department of Defense Warning Statement"
        - A site-defined equivalent that does not contradict WN11-SO-000075

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Local Security Policy editor (secpol.msc)
        2. Navigate to:
              Security Settings >>
              Local Policies >>
              Security Options
        3. Double-click "Interactive logon: Message title for users attempting to log on"
        4. Enter: DoD Notice and Consent Banner
        5. Click OK and close the editor
        6. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    key from being overwritten during Group Policy refresh.

    Note: This setting must be configured alongside WN11-SO-000075 which sets
    the required body text of the logon banner. Both must be present for
    full compliance.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-SO-000080
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-SO-000080/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-SO-000080.
    Example syntax:
    PS C:\> .\WN11-SO-000080.ps1
#>

$RegPath  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegName  = "LegalNoticeCaption"
$RegValue = "DoD Notice and Consent Banner"

# Create the registry key if it does not already exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set value - REG_SZ = Legal notice title displayed at logon
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type String

# Verify the setting was applied
$Result = Get-ItemProperty -Path $RegPath -Name $RegName
Write-Host "Registry value '$RegName' set to: $($Result.$RegName)" -ForegroundColor Green

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force

# Remind operator to also remediate the companion STIG
Write-Host "`n[REMINDER] Also verify WN11-SO-000075 is remediated." -ForegroundColor Yellow
Write-Host "That STIG sets the required body text of the logon banner." -ForegroundColor Yellow
Write-Host "Both must be present for full compliance." -ForegroundColor Yellow
