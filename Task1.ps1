Import-Module ActiveDirectory

#Get the admin info
$Username = Read-Host -Prompt "Please enter the admin name"
if ([string]::IsNullOrWhiteSpace($Username)) {
    Write-Host "Invalid username. Please enter a non-empty username."
    return
}
$securePassword = Read-Host -Prompt "Please enter your password" -AsSecureString
if ([string]::IsNullOrWhiteSpace($securePassword)) {
    Write-Host "Invalid password. Please enter a non-empty password."
    return
}

# Load the required assembly
Add-Type -AssemblyName System.DirectoryServices.Protocols

$RootDSE = [ADSI]"LDAP://RootDSE"
$LDAPDirectory = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($RootDSE.dnsHostName)
$Credentials = New-Object System.Net.NetworkCredential($Username, $securePassword)
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($LDAPDirectory, $Credentials)
$LDAPConnection.SessionOptions.ProtocolVersion = 3 # Set the LDAP protocol to version 3


#--------------------------------Functions---------------------------------
function AddUserToAD
{
    # User details
    $NewUserName = Read-Host -Prompt "Enter the sAMAccount name"
    $UserPassword = Read-Host -Prompt "Enter user's password" -AsSecureString
    $UserPrincipalName = Read-Host -Prompt "Enter user's mail address"
    $GivenName = Read-Host -Prompt "Enter user's Given Name"
    $Surname = Read-Host -Prompt "Enter user's surname"
    $DisplayName = "$GivenName $Surname"
    $Path = "CN=Users,DC=RTS,DC=LOCAL"

    # Create the new user
    New-ADUser -Name $NewUserName `
                -GivenName $GivenName `
                -Surname $Surname `
                -SamAccountName $NewUserName `
                -UserPrincipalName $UserPrincipalName `
                -DisplayName $DisplayName `
                -AccountPassword $UserPassword `
                -Path $Path `
                -Enabled $true

    Write-Host "The user with sAMAccount: $NewUserName is created"
}

function RemoveUserFromAD
{
    $UserSamAccountName = Read-Host -Prompt "Enter sAMAccountName"

    # Search for the user
    $User = Get-ADUser -Filter "SamAccountName -eq '$UserSamAccountName'"

    if ($User) {
        # User exists, now remove them
        Remove-ADUser -Identity $User.DistinguishedName -Confirm:$false
        Write-Host "User with $UserSamAccountName  samAccountName has been removed from Active Directory."
    } else {
        Write-Host "User $UserSamAccountName with samAccountName couldn't found in Active Directory."
    }
}

function ChangeUserMail
{

    #Get the user's sAMAccountName whose mail is going to be changed
    $UserToModify = Read-Host -Prompt "Enter user's sAMAccountName" # User's sAMAccountName
    $NewMail = Read-Host -Prompt "Enter the new mail address for the user"
       
    # Search for the user
    $searchFilter = "(&(objectClass=user)(sAMAccountName=$UserToModify))"
    $searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest($RootDSE.defaultNamingContext, $searchFilter, "Subtree")
    $searchResponse = $LDAPConnection.SendRequest($searchRequest)

    # Check if user is found
    if ($searchResponse.Entries.Count -ne 1) {
        Write-Host "User not found or multiple entries returned."
        return
    }

    # Get the user's distinguished name
    $userDn = $searchResponse.Entries[0].DistinguishedName

    # Prepare the modification request
    $modification = New-Object System.DirectoryServices.Protocols.DirectoryAttributeModification
    $modification.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
    $modification.Name = "mail"
    $modification.Add($NewMail)

    $modifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest($userDn, $modification)

    # Try to apply the modification
    try {
        $LDAPConnection.SendRequest($modifyRequest)
        Write-Host "Email updated successfully for user: $UserToModify"
    } catch {
        Write-Host "Failed to update email for user: $UserToModify"
        Write-Host "Error: $_"
    }

    <#do{
        $ContinueAnswer = Read-Host -Prompt "Would you like to continue to change or add another user's mail [yes/no]\n"

        if ($ContinueAnswer -eq "yes") 
        {      
            Write-Host "You chose to continue.\n"
        }
        elseif ($ContinueAnswer -eq "no") 
        {        
            Write-Host "You chose not to continue.\n"
        }
        else 
        {        
            Write-Host "Invalid input. Please enter 'yes' or 'no'.\n"       
        }

    }while($ContinueAnswer -ne "yes" -and $ContinueAnswer -ne "no")#>
    
}

#----------------MainLoop------------------------
do
{
    Write-Host "Choose one of the operations [1/2/3/4]"
    Write-Host "[1]Add user"
    Write-Host "[2]Remove user"
    Write-Host "[3]Update mail account of a user"
    Write-Host "[4]Exit"

    $selectedOperation = Read-Host -Prompt "Choose an operation: "

    switch($selectedOperation)
    {
        1{AddUserToAD}
        2{RemoveUserFromAD}
        3{ChangeUserMail}
        4{}
        default{Write-Host "Invalid input is given!"}
    }

}while($selectedOperation -ne 4)


