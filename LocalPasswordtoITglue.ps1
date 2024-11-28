################################################################################################
#Create APIKey in Itglue. When creating API key in ITglue make sure you select the password access 
#OrgID will have to be grabed based on the organization where the asset is located on IT glue
#NewAdminUsername will need to be set to desired username 

###############################################################################################

#To help automate use a site/Org variable in the RMM with the ITglue OrgID
#If device is not found on ITglue it will add password entry under the password configuration item.


$APIKEy = "ITG.apiKey_goeshere"
$APIEndpoint = "https://api.itglue.com"
$orgID = "FromITGLUE"
$ChangeAdminUsername = $true
$NewAdminUsername = "NewAdminVP"

# Grabbing ITGlue Module and installing.
If (Get-Module -ListAvailable -Name "ITGlueAPI") {
    Import-Module ITGlueAPI
} else {
    Install-PackageProvider -Name NuGet -Force
    Install-Module ITGlueAPI -Force
    Import-Module ITGlueAPI
}

# Settings IT-Glue logon information
Add-ITGlueBaseURI -base_uri $APIEndpoint
Add-ITGlueAPIKey $APIKEy
Add-Type -AssemblyName System.Web

# This is the process we'll be performing to set the admin account.
$LocalAdminPassword = [System.Web.Security.Membership]::GeneratePassword(24, 5)

try {
    if ($ChangeAdminUsername -eq $false) {
        Set-LocalUser -name "Administrator" -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force) -PasswordNeverExpires:$true
    } else {
        $ExistingNewAdmin = Get-LocalUser | Where-Object { $_.Name -eq $NewAdminUsername }
        if (!$ExistingNewAdmin) {
            Write-Host "Creating new user" -ForegroundColor Yellow
            New-LocalUser -Name $NewAdminUsername -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force) -PasswordNeverExpires:$true
            Add-LocalGroupMember -Group Administrators -Member $NewAdminUsername
            Disable-LocalUser -Name "Administrator"
        } else {
            Write-Host "Updating admin password" -ForegroundColor Yellow
            Set-LocalUser -name $NewAdminUsername -Password ($LocalAdminPassword | ConvertTo-SecureString -AsPlainText -Force)
        }
    }
    if ($ChangeAdminUsername -eq $false) { $username = "Administrator" } else { $Username = $NewAdminUsername }

    # The script uses the following line to find the correct asset by serial number, match it, and connect it if found. Don't want it to tag at all? Comment it out by adding #
    $TaggedResource = (Get-ITGlueConfigurations -organization_id $orgID -filter_serial_number (Get-CimInstance Win32_BIOS).SerialNumber).data | Select-Object -Last 1
    $PasswordObjectName = "$($Env:COMPUTERNAME) - Local Administrator Account"
    $PasswordObject = @{
        type = 'passwords'
        attributes = @{
            name = $PasswordObjectName
            username = "$Env:COMPUTERNAME\$username"
            password = $LocalAdminPassword
            notes = "Local Admin Password for $($Env:COMPUTERNAME)"
        }
    }
    if ($TaggedResource) {
        $PasswordObject.attributes.Add("resource_id", $TaggedResource.Id)
        $PasswordObject.attributes.Add("resource_type", "Configuration")
    }

    # Now we'll check if it already exists, if not, we'll create a new one.
    $ExistingPasswordAsset = (Get-ITGluePasswords -filter_organization_id $orgID -filter_name $PasswordObjectName).data

    if (!$ExistingPasswordAsset) {
        Write-Host "Creating new Local Administrator Password" -ForegroundColor Yellow
        $ITGNewPassword = New-ITGluePasswords -organization_id $orgID -data $PasswordObject
    } else {
        Write-Host "Updating Local Administrator Password" -ForegroundColor Yellow
        $ITGNewPassword = Set-ITGluePasswords -id $ExistingPasswordAsset.id -data $PasswordObject
    }

    Write-Host "Password updated successfully" -ForegroundColor Green
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
