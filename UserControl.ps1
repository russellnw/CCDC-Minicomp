

function Get-UserFile {
    $UserFile = Get-Content -Raw -Path "./user-files/users-enc.json"
    $UserFile = $UserFile | ConvertFrom-Json -Depth 4
    
    return $UserFile
}

function Remove-BadUsers ([Object]$UserFile) {
    $LocalUsers = Get-LocalUser
    foreach ($User in $LocalUsers) {
        if (($UserFile.LocalUsers.Administrators -notcontains $User) -and ($UserFile.LocalUsers.Standard -notcontains $User)) {
            Write-Host $User
        }
    }
}

function Reset-UserType ([Object]$UserFile) {
    
}

function Set-Passwords ([Object]$UserFile,[System.Security.SecureString]$Key) {
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
        "Remove-BadUsers : Removes users not in UserFile (prompts for confirmation)"
        "Reset-UserType : Resets the user type to the type in UserFile"
        "Set-Passwords : Set passwords for users in UserFile (requires encryption password)"
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
            "remove-badusers" {Remove-BadUsers $UserFile}
            "reset-userType" {Reset-UserType $UserFile}
            "set-passwords" {Set-Passwords $UserFile $(Read-Host -AsSecureString "Input Encryption Key")}
            "get-help" {Write-Host "`n$HelpString`n"}
            "exit" {Write-Host;exit}
            Default {Write-Host "Invalid Command`n"}
        }
    }
}

if ($MyInvocation.MyCommand.Name -eq 'UserControl.ps1') {
    Main
}