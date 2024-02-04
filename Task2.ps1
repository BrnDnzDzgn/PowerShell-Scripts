#--------------Functions---------------
function GetHash 
{
    param([parameter()] [String]$data)
     
    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($data)
    $hashBytes = $hasher.ComputeHash($inputBytes)
    $hashString = [BitConverter]::ToString($hashBytes) -replace '-', ''
    return $hashString
}

function AddNewUser
{
    # User details, trimmed to remove potential whitespace
    $NewUserName = (Read-Host -Prompt "Enter the sAMAccount name").Trim()
    $NewUserNameHash = GetHash -data $NewUserName

    $filePath = "C:\Users\Public\user.txt"
    $DoesUserExist = Select-String -Path $filePath -Pattern "sAMAccountName: $NewUserNameHash" -Quiet

    if($DoesUserExist -eq $false)
    {
        $UserPassword = (Read-Host -Prompt "Enter user's password").Trim()
        $UserPrincipalName = (Read-Host -Prompt "Enter user's principal name").Trim()
        $GivenName = (Read-Host -Prompt "Enter user's Given Name").Trim()
        $Surname = (Read-Host -Prompt "Enter user's surname").Trim()
        $DisplayName = "$GivenName $Surname".Trim()
        $Email = (Read-Host -Prompt "Enter user's email address").Trim()
        $Path = "CN=Users,DC=RTS,DC=LOCAL"

        # Hashing user details
        $UserPasswordHash = GetHash -data $UserPassword
        $UserPrincipalNameHash = GetHash -data $UserPrincipalName
        $GivenNameHash = GetHash -data $GivenName
        $SurnameHash = GetHash -data $Surname
        $DisplayNameHash = GetHash -data $DisplayName
        $EmailHash = GetHash -data $Email

        # Combine user info into a string
        $userInfo = "sAMAccountName: $NewUserNameHash, UserPrincipalName: $UserPrincipalNameHash, GivenName: $GivenNameHash, Surname: $SurnameHash, DisplayName: $DisplayNameHash, Email: $EmailHash, PasswordHash: $UserPasswordHash"

        # Add user info to the file
        Add-Content -Path $filePath -Value $userInfo

        Write-Host "`r`nThe user with sAMAccount: $NewUserName is created and information is saved to $filePath`r`n"
    }
    else
    {
        Write-Host "`r`nThe user with sAMAccount: $NewUserName already exists`r`n"
    }
}

function SearchUser
{
    $filePath = "C:\Users\Public\user.txt"

    $username = Read-Host -Prompt "Enter the sAMAccount name"
    $password = Read-Host -Prompt "Enter your password"

    $usernameHash = GetHash -data $username
    $passwordHash = GetHash -data $password

    $onTheSameLine = Get-Content $filePath | Where-Object {$_ -match "sAMAccountName: $usernameHash" -and $_ -match "PasswordHash: $passwordHash"}

    if ($onTheSameLine)
    {
        Write-Host "`r`nCorrect credentials`r`n"
    }
    else
    {
        Write-Host "`r`nYour username or password are wrong`r`n"
    }
}


#--------------MainLoop---------------
do
{
    Write-Host "Choose one of the operations [1/2/3]"
    Write-Host "[1]Add new user"
    Write-Host "[2]Are you the user?"
    Write-Host "[3]Exit`r`n"

    $selectedOperation = Read-Host -Prompt "Choose an operation:"

    switch($selectedOperation)
    {
        1{AddNewUser}
        2{SearchUser}
        3{}
        default{cls Write-Host "`r`nInvalid input is given!`r`n"}
    }

}while($selectedOperation -ne 3)
