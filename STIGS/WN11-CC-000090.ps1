<#
.SYNOPSIS
    This PowerShell script ensures that Group Policy objects are reprocessed even
    if they have not changed, by setting the registry value "NoGPOListChanges" to 0
    under the Group Policy registry processing key for Windows 11.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Group Policy Management Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Administrative Templates >>
              System >>
              Group Policy
        3. Double-click "Configure registry policy processing"
        4. Set to: Enabled
        5. Check the box: "Process even if the Group Policy objects have not changed"
        6. Click OK and close the editor
        7. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the registry
    key from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-03
    Last Modified   : 2026-05-03
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000090
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000090/
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-CC-000090.
    Example syntax:
    PS C:\> .\WN11-CC-000090.ps1
#>

# Set the registry key to force GPO reprocessing even if unchanged
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"

# Create the key if it doesn't exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set the value - 0 = Process even if GPO has not changed
Set-ItemProperty -Path $RegPath -Name "NoGPOListChanges" -Value 0 -Type DWord

# Verify the setting
Get-ItemProperty -Path $RegPath -Name "NoGPOListChanges"
