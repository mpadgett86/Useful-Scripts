<#

+SYNOPSIS
    Use this script to invite users as B2B connections for cross domain-trust establishment in Azure/O365.
    Users will be granted access to the SharePoint site specified in the $url variable and whatever other groups
    that are specified in the $groups array.

+REQUIRED
    This script requires the AzureAD PowerShell module and must be run from an administrative PowerShell terminal.

+PROCESS
    1. Enter the Azure tenant ID from the Azure Portal into the $tenantID variable.
    2. Specify a SharePoint site as a landing page in the $url variable (optional)
    3. Specify user emails in the $user_upns array.
    4. Enter the full display name of users in the same order as entered in the previous step.
    5. Enter any O365 groups that you want the users to have access to.
    6. Run the script. It will check if the AzureAD PS Module is installed. If not, it will install it. Accept the prompt with 'Y'
    7. Users will be sent an invite and added to the groups specified below.

#>

$logfile = "aad.b2b.integrate.log"
$module = "AzureAD"
$objectID = "" 
$tenantID = "PUT YOUR AZURE TENANT ID HERE"
$url = "https://SOME_SHARE_POINT_SITE_URL.sharepoint.com/SitePages/Home.aspx"


$user_upns = @(
    <#
    <Enter multiple users in this format>

        "user1@domain.com",
        "user2@domain.com",
        "user3@domain.com"

    <or, a single user in this format>
    
        "user_name@domain.com"
    #>

)

$user_displaynames = @(
    <#
        "User Name",
        "User Name",
        "User Name"
    
    <or>
        "User Name"
    #>

)

# replace with general o365 group
$groups = @(
    <#
        "O365 Group1",
        "O365 Group2",
        "O365 Group3"
    #>

)

Start-Transcript -Path $logfile


function checkModule {
    if (!(Get-Module | Where-Object {$_.Name -eq $module} )) 
    {
        Install-Module $module
        Import-Module $module
    }
}

function connectAAD { Connect-AzureAD -TenantId $tenantID}

function addUser {
    
    for ($i = 0; $i -lt $user_upns.length; $i++) {
            New-AzureADMSInvitation -InvitedUserDisplayName $user_displaynames[$i] -InvitedUserEmailAddress $user_upns[$i] -InviteRedirectURL $url -SendInvitationMessage $True

            $objectID = (Get-AzureADUser -SearchString $user_upns[$i] | Select-Object -ExpandProperty ObjectId)

            foreach ($group in $groups) {
                Add-AzureADGroupMember -ObjectId  (Get-AzureADGroup -SearchString $group).ObjectId -RefObjectId $objectID
            }
    }
    
}

## TODO
<#
    pull ref object ID
    assign company properties
    firstName, lastName, manager, etc.
#>


###################

checkModule
connectAAD
addUser



Stop-Transcript