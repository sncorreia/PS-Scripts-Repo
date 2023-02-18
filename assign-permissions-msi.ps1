# PS script developed to assign permissions to an MSI
# To make it work, change the fields marked with the [TO CHANGE] tag

# [TO CHANGE] Name of system-assigned or user-assigned managed service identity. (System-assigned use same name as resource).
$MsiName = "<Your_MSI_Name>"

# [TO CHANGE] YOur tenantId
$tenantId = "<domain>.onmicrosoft.com"

# [TO CHANGE] Array of permissions to grant
$permissions = @(
    "User.Read.All"
    "GroupMember.Read.All" 
    "Application.Read.ALL"
)

$GraphAppId = "00000003-0000-0000-c000-000000000000" 


# Authenticate your Admin user - Change your tenantId 
Connect-MgGraph -Scopes "User.Read.All","AppRoleAssignment.ReadWrite.All","Directory.Read.All"  -TenantId $tenantId -ContextScope Process 

$msiSP = Get-MgServicePrincipal -Filter "displayName eq '$MsiName'"
$graphSP = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"

$appRoles = $graphSP.AppRoles | Where-Object {($_.Value -in $permissions)}


# Apply each permission to the MSI

foreach($appRole in $appRoles){
    $appRoleAssignment = @{
        "PrincipalId" = $msiSP.Id
        "ResourceId" = $graphSP.Id
        "AppRoleId" = $appRole.Id
    }

    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $appRoleAssignment.PrincipalId -BodyParameter $appRoleAssignment 
}
