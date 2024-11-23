

function Get-UserFile {
    $UserFile = Get-Content -Raw -Path "./user-files/users-enc.json"
    $UserFile = $UserFile | ConvertFrom-Json
    
    return $UserFile
}

function Remove-DomainUsers ([Object]$UserFile) {
    Write-Host
    $ADUsers = $(Get-ADUser -Filter *).samaccountname
    foreach ($ADUser in $ADUsers) {
        $exclude = $false
        foreach ($User in $UserFile.DomainUsers.Administrators) {
            if ($ADUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.DomainUsers.Standard) {
            if ($ADUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.LocalUsers.Administrators) {
            if ($ADUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.LocalUsers.Standard) {
            if ($ADUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        Write-Host $ADUser
    }
    Write-Host "`nType an account name to remove it, or type \stop to exit`n"
    while ($true) {
        [System.Console]::Write("(Remove-DomainUsers) >>> ")
        $UserToRemove = Read-Host
        if ($UserToRemove -eq "\stop") {
            break
        }
        Remove-ADUser -Identity $UserToRemove -Confirm:$true
    }
}

function Remove-LocalUsers ([Object]$UserFile) {
    Write-Host
    $LocalUsers = $(Get-LocalUser).name
    foreach ($LocalUser in $LocalUsers) {
        $exclude = $false
        foreach ($User in $UserFile.DomainUsers.Administrators) {
            if ($LocalUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.DomainUsers.Standard) {
            if ($LocalUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.LocalUsers.Administrators) {
            if ($LocalUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        foreach ($User in $UserFile.LocalUsers.Standard) {
            if ($LocalUser -eq $User.Username) {
                $exclude = $true
                break
            }
        }
        if ($exclude -eq $true) {
            continue
        }
        Write-Host $LocalUser
    }
    Write-Host "`nType an account name to remove it, or type \stop to exit`n"
    while ($true) {
        [System.Console]::Write("(Remove-LocalUsers) >>> ")
        $UserToRemove = Read-Host
        if ($UserToRemove -eq "\stop") {
            break
        }
        Remove-LocalUser -Name $UserToRemove -Confirm
    }
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
        "Remove-DomainUsers : Removes domain users based on user input (prompts for confirmation)"
        "Remove-LocalUsers : Removes local users based on user input (prompts for confirmation)"
        ""
        "(UNIMPLEMENTED) Reset-DomainUserType : Resets domain user type to the type in UserFile"
        "(UNIMPLEMENTED) Reset-LocalUserType : Resets domain user type to the type in UserFile"
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
            "remove-domainusers" {Remove-DomainUsers $UserFile}
            "remove-localusers" {Remove-LocalUsers $UserFile}
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