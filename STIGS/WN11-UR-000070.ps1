<#
.SYNOPSIS
    This PowerShell script ensures that the "Deny access to this computer from
    the network" user right is configured to include the required accounts and
    groups on Windows 11, as required by STIG WN11-UR-000070 (V2R7).

    Without this setting, high-privilege domain accounts and local accounts could
    be used to authenticate to the system over the network, increasing the risk
    of lateral movement and credential theft attacks across the domain.

    The following must be assigned this right:
        - Domain Systems Only:
            Enterprise Admins
            Domain Admins
            Local account (built-in security group)
        - All Systems:
            Guests

    *** CRITICAL WARNING - READ BEFORE RUNNING ***

        This script WILL lock you out of the machine if you are currently
        connected remotely (RDP, PSRemoting, or any network-based session)
        using any of the following account types:

            - Local administrator accounts
            - Domain Admin accounts
            - Enterprise Admin accounts

        This happened because SeDenyNetworkLogonRight blocks ALL network-based
        logons for the listed accounts and groups — including your own active
        session. Once applied, you cannot reconnect remotely using those
        accounts. The only recovery option at that point is physical console
        access to the machine or rebuilding the VM entirely.

    PRE-FLIGHT CHECKLIST - Complete ALL steps before running:

        [ ] 1. Confirm you are physically at the machine console, NOT remote.
               If you are remote, STOP. Do not run this script.

        [ ] 2. Create a dedicated non-admin remote access account before running:
                   net user RemoteOps <password> /add
                   net localgroup "Remote Desktop Users" RemoteOps /add
               This account will not be affected by the deny rule and will
               remain your safe remote access path after the STIG is applied.

        [ ] 3. Test that the new account can RDP in successfully BEFORE
               running this script.

        [ ] 4. If domain-joined, coordinate with your domain administrator
               to stage this via AD GPO rather than running locally.

        [ ] 5. Snapshot or checkpoint the VM before running so you can roll
               back instantly without rebuilding if something goes wrong.

    For persistence across reboots and GPO refreshes (especially on domain-joined
    machines), this setting should also be enforced via Group Policy:

    GUI Steps:
        1. Open the Local Group Policy Editor (gpedit.msc)
        2. Navigate to:
              Computer Configuration >>
              Windows Settings >>
              Security Settings >>
              Local Policies >>
              User Rights Assignment
        3. Double-click "Deny access to this computer from the network"
        4. Click "Add User or Group"
        5. Add the following (as applicable to your environment):
              Guests
              Enterprise Admins   (domain-joined systems only)
              Domain Admins       (domain-joined systems only)
              Local account       (domain-joined systems only)
        6. Click OK and close the editor
        7. Run: gpupdate /force
           to apply immediately without waiting for the next refresh cycle

    Note: On domain-joined machines, this setting should be applied at the
    Active Directory GPO level by a domain administrator to prevent the user
    right from being overwritten during Group Policy refresh.

.NOTES
    Author          : Orok Ironbar
    LinkedIn        : linkedin.com/in/rokkside/
    GitHub          : github.com/rokkside
    Date Created    : 2026-05-04
    Last Modified   : 2026-05-04
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : Windows Compliance Checks
    STIG-ID         : WN11-UR-000070
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-UR-000070/
.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  : Windows 11
    PowerShell Ver. :
.USAGE
    Run this script with administrative privileges to remediate STIG WN11-UR-000070.
    ONLY run from a physical console session. Never run while connected remotely.
    Example syntax:
    PS C:\> .\WN11-UR-000070.ps1
#>

$TempDir = "C:\Windows\Temp"
$InfFile = "$TempDir\WN11-UR-000070.inf"
$DbFile  = "$TempDir\WN11-UR-000070.sdb"

# Safety check - warn operator before proceeding
Write-Host "`n*** PRE-FLIGHT WARNING ***" -ForegroundColor Red
Write-Host "This script will deny network logons to local and privileged accounts." -ForegroundColor Yellow
Write-Host "If you are connected remotely RIGHT NOW you will be locked out." -ForegroundColor Yellow
Write-Host ""
$Confirm = Read-Host "Are you physically at the console and have a non-admin remote account ready? (yes/no)"

If ($Confirm -ne "yes") {
    Write-Host "`nScript aborted. Complete the pre-flight checklist in the synopsis before running." -ForegroundColor Red
    Exit
}

# SIDs used:
# *S-1-5-32-546 = Guests (built-in, works on all systems)
# *S-1-5-113    = Local account (built-in group, covers all local accounts)
# Note: Enterprise Admins and Domain Admins must be added manually via
# gpedit.msc on domain-joined systems as they require domain context.

$InfContent = @"
[Unicode]
Unicode=yes
[System Access]
[Event Audit]
[Registry Values]
[Privilege Rights]
SeDenyNetworkLogonRight = *S-1-5-32-546,*S-1-5-113
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

# Write the security template to disk
Set-Content -Path $InfFile -Value $InfContent -Encoding Unicode

# Import and apply the security template
secedit /configure /db $DbFile /cfg $InfFile /areas USER_RIGHTS /quiet

# Verify the setting was applied
Write-Host "`nVerifying current User Rights Assignment..." -ForegroundColor Cyan
secedit /export /cfg "$TempDir\current_policy.inf" /areas USER_RIGHTS /quiet
$Policy   = Get-Content "$TempDir\current_policy.inf"
$DenyLine = $Policy | Where-Object { $_ -match "SeDenyNetworkLogonRight" }
Write-Host "Current setting: $DenyLine" -ForegroundColor Green

# Clean up temp files
Remove-Item $InfFile, $DbFile, "$TempDir\current_policy.inf" -ErrorAction SilentlyContinue

# Apply immediately without waiting for next GPO refresh cycle
gpupdate /force

# Remind operator to add domain groups manually
Write-Host "`n[ACTION REQUIRED] If this is a domain-joined system, complete the" -ForegroundColor Yellow
Write-Host "GUI steps in the script synopsis to add Enterprise Admins, Domain" -ForegroundColor Yellow
Write-Host "Admins, and the Local account group via gpedit.msc or AD GPO." -ForegroundColor Yellow
