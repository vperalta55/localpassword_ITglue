# ITGlue API Local Admin Password Manager Script

This PowerShell script automates the process of creating and updating local administrator passwords and syncing them with ITGlue. It handles the creation of a new local admin account, updates the password if the account exists, and stores the password securely in ITGlue.

## Features

- **Create or Update Local Admin Account**: The script checks if a specified local admin account exists and either updates the password or creates a new one.
- **Password Generation**: A new strong password is automatically generated for the local admin account.
- **Sync with ITGlue**: The script syncs the local admin password with ITGlue, associating the password with the relevant device in your ITGlue account.
- **Error Handling**: If there is an issue at any step, the script will report the error and continue.

## Prerequisites

- PowerShell 5.1 or higher.
- Access to ITGlue API with valid API key.
- The **ITGlueAPI** PowerShell module.
- Administrator privileges to create or modify local users.
- ITGlue organization ID and access to the appropriate configuration items.

## Configuration

Before running the script, you need to configure the following parameters:

- **$APIKEy**: Your ITGlue API key.
- **$APIEndpoint**: The ITGlue API endpoint (usually `https://api.itglue.com`).
- **$orgID**: Your ITGlue organization ID (This can be grabbed based on the organization where the asset is located).
- **$ChangeAdminUsername**: Set to `$true` if you want to change the default "Administrator" account username, or `$false` to keep it.
- **$NewAdminUsername**: The new admin username to set (if `$ChangeAdminUsername` is `$true`).

### Example:
```powershell
$APIKEy = "ITG.apiKey_goeshere"
$APIEndpoint = "https://api.itglue.com"
$orgID = "ITglueorgID"
$ChangeAdminUsername = $true
$NewAdminUsername = "NewAdminVP"
