Import-Module ActiveDirectory

#Get-Credential | Export-Clixml C:\Users\Administrator\pass.xml  #in your first run uncomment this line, after you enter the credientials you can comment it again.
$adminAccount = Import-Clixml C:\Users\Administrator\pass.xml #in your first run comment this line. after that uncomment it.

# Load the required assembly
Add-Type -AssemblyName System.DirectoryServices.Protocols

$RootDSE = [ADSI]"LDAP://RootDSE"
$LDAPDirectory = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($RootDSE.dnsHostName)
$Credentials = New-Object System.Net.NetworkCredential($adminAccount.Username, $adminAccount.Password)
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($LDAPDirectory, $Credentials)

#--------------------------------Functions---------------------------------
function DisplayUsers
{
    # Retrieve and display email addresses of all users except krbtgt
    Get-ADUser -Filter {SamAccountName -ne 'krbtgt'} -Property mail | Select-Object sAMAccountName,mail,distinguishedName | Format-Table -AutoSize

}

function AddUserToAD
{
    # User details
    $NewUserName = Read-Host -Prompt "Enter the sAMAccount name"
    $UserPassword = Read-Host -Prompt "Enter user's password" -AsSecureString
    $UserPrincipalName = Read-Host -Prompt "Enter user's principal name"
    $GivenName = Read-Host -Prompt "Enter user's Given Name"
    $Surname = Read-Host -Prompt "Enter user's surname"
    $DisplayName = "$GivenName $Surname"
    $Email = Read-Host -Prompt "Enter user's email address"
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
                -Enabled $true `
                -EmailAddress $Email

    Write-Host "`r`nThe user with sAMAccount: $NewUserName is created`r`n"
}

function RemoveUserFromAD
{
    $UserSamAccountName = Read-Host -Prompt "Enter sAMAccountName"

    # Search for the user
    $User = Get-ADUser -Filter "SamAccountName -eq '$UserSamAccountName'"

    if ($User) {
        # User exists, now remove them
        Remove-ADUser -Identity $User.DistinguishedName -Confirm:$false
        Write-Host "`r`nUser with $UserSamAccountName  samAccountName has been removed from Active Directory.`r`n"
    } else {
        Write-Host "`r`nUser with $UserSamAccountName samAccountName couldn't found in Active Directory.`r`n"
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
        Write-Host "`r`nUser not found or multiple entries returned.`r`n"
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
        Write-Host "`r`nEmail updated successfully for user: $UserToModify`r`n"
    } catch {
        Write-Host "`r`nFailed to update email for user: $UserToModify`r`n"
        Write-Host "Error: $_"
    }
}

#------------------------MainLoop-------------------------
do
{
    Write-Host "`r`nChoose one of the operations [0/1/2/3/4]"
    Write-Host "[0]Display all users"
    Write-Host "[1]Add user"
    Write-Host "[2]Remove user"
    Write-Host "[3]Update mail account of a user"
    Write-Host "[4]Exit`r`n"

    $selectedOperation = Read-Host -Prompt "Choose an operation: "

    switch($selectedOperation)
    {
        0{DisplayUsers}
        1{AddUserToAD}
        2{RemoveUserFromAD}
        3{ChangeUserMail}
        4{}
        default{ cls Write-Host "Invalid input is given!"}        
    }

}while($selectedOperation -ne 4)
