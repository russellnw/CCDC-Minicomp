

function Get-UserFile {
    $UserFile = Get-Content -Raw -Path "./user-files/users-enc.json"
    $UserFile = $UserFile | ConvertFrom-Json
    
    return $UserFile
}

function Remove-BadDomainUsers ([Object]$UserFile) {
    $ADUsers = Get-ADUser
    $ADUsers
}

function Reset-UserType ([Object]$UserFile) {
    
}

function Set-DomainPasswords ([Object]$UserFile,[System.Security.SecureString]$Key) {
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $KeyHash = $SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
    foreach ($User in $UserFile.DomainUsers.Administrators) {
        $SecureStringPassword = ConvertTo-SecureString -String $User.Password -Key $KeyHash
        Set-ADAccountPassword -Identity $($User.Username) -NewPassword $SecureStringPassword
    }
    foreach ($User in $UserFile.DomainUsers.Standard) {
        $SecureStringPassword = ConvertTo-SecureString -String $User.Password -Key $KeyHash
        Set-ADAccountPassword -Identity $($User.Username) -NewPassword $SecureStringPassword
    }
}

function Set-LocalPasswords ([Object]$UserFile,[System.Security.SecureString]$Key) {
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $KeyHash = $SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
    foreach ($User in $UserFile.LocalUsers.Administrators) {
        $SecureStringPassword = ConvertTo-SecureString -String $User.Password -Key $KeyHash
        Set-LocalUser -Name $($User.Username) -Password $SecureStringPassword
    }
    foreach ($User in $UserFile.LocalUsers.Standard) {
        $SecureStringPassword = ConvertTo-SecureString -String $User.Password -Key $KeyHash
        Set-LocalUser -Name $($User.Username) -Password $SecureStringPassword
    }
}

function Main {
    $HelpString = (@(
        "Remove-BadDomainUsers : Removes domain users not in UserFile (prompts for confirmation)"
        "Remove-BadLocalUsers : Removes local users not in UserFile (prompts for confirmation)"
        ""
        "Reset-DomainUserType : Resets domain user type to the type in UserFile"
        "Reset-LocalUserType : Resets domain user type to the type in UserFile"
        ""
        "Set-DomainPasswords : Set passwords for domain users in UserFile (requires encryption password)"
        "Set-LocalPasswords : Set passwords for local users in UserFile (requires encryption password)"
        ""
        "Get-Help : Print this list"
        "Exit : Exits the script"
    ) -join "`n")
    Write-Host (@(
        ""
        "CCDC Minicomp User Control Script"
        ""
        $HelpString
        ""
    ) -join "`n")

    $UserFile = Get-UserFile

    while ($true) {
        [System.Console]::Write(">>> ")
        $command = ((Read-Host) -split " ")

        switch ($command[0].ToLower()) {
            "remove-baddomainusers" {Remove-BadDomainUsers $UserFile}
            "remove-badlocalusers" {Remove-BadLocalUsers $UserFile}
            "reset-domainusertype" {Reset-DomainUserType $UserFile}
            "reset-localusertype" {Reset-LocalUserType $UserFile}
            "set-domainpasswords" {Set-DomainPasswords $UserFile $(Read-Host -AsSecureString "Input Encryption Key")}
            "set-localpasswords" {Set-LocalPasswords $UserFile $(Read-Host -AsSecureString "Input Encryption Key")}
            "get-help" {Write-Host "`n$HelpString`n"}
            "exit" {Write-Host;exit}
            Default {Write-Host "Invalid Command`n"}
        }
    }
}

if ($MyInvocation.MyCommand.Name -eq 'UserControl.ps1') {
    Main
}