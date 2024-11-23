function Read-UserFile ([string]$Path) {
    $UserFile = Get-Content -Raw -Path $Path
    $UserFile = $UserFile | ConvertFrom-Json
    
    return $UserFile
}

function Write-UserFile ([string]$Path,[Object]$UserFile) {
    $UserFile = $UserFile | ConvertTo-Json
    $UserFile | Set-Content -Path $Path
}

function Get-Password {
    try {
        $ApiRequestURL = "https://random-word-api.herokuapp.com/word?number=3"
        $Words = Invoke-RestMethod -Uri $ApiRequestURL -Method Get
        return "$($Words -join "-")-$(Get-Random -Minimum 0 -Maximum 999)"
    }
    catch {
        exit
    }
}

function Set-UserPasswords ([Object]$UserFile) {
    foreach ($User in $UserFile.DomainUsers.Administrators) {
        $User.Password = Get-Password
        Write-Host "Got password for $($User.Username)"
    }
    foreach ($User in $UserFile.DomainUsers.Standard) {
        $User.Password = Get-Password
        Write-Host "Got password for $($User.Username)"
    }
    foreach ($User in $UserFile.LocalUsers.Administrators) {
        $User.Password = Get-Password
        Write-Host "Got password for $($User.Username)"
    }
    foreach ($User in $UserFile.LocalUsers.Standard) {
        $User.Password = Get-Password
        Write-Host "Got password for $($User.Username)"
    }
    return $UserFile
}

function Protect-Password ([string]$Password,[string]$Key) {
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $KeyHash = $SHA256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Key))
    $SecureStringPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $EncryptedPassword = ConvertFrom-SecureString -SecureString $SecureStringPassword -Key $KeyHash
    return $EncryptedPassword
}

function Protect-UserPasswords ([Object]$UserFile,[System.Security.SecureString]$Key) {
    foreach ($User in $UserFile.DomainUsers.Administrators) {
        $User.Password = Protect-Password $User.Password $Key
    }
    foreach ($User in $UserFile.DomainUsers.Standard) {
        $User.Password = Protect-Password $User.Password $Key
    }
    foreach ($User in $UserFile.LocalUsers.Administrators) {
        $User.Password = Protect-Password $User.Password $Key
    }
    foreach ($User in $UserFile.LocalUsers.Standard) {
        $User.Password = Protect-Password $User.Password $Key
    }
    return $UserFile
}

function Main {
    $UserFilePath = "./user-files/users-template.json"
    $UserFile = Read-UserFile  $UserFilePath

    $UserFile = Set-UserPasswords $UserFile
    $UserFilePath = "./user-files/users.json"
    Write-UserFile $UserFilePath $UserFile
    Write-Host "`nWrote UserFile to ./user-files/users.json`n"

    $Key = Read-Host -AsSecureString "Input Encryption Key"
    $UserFile = Protect-UserPasswords $UserFile $Key
    $UserFileEncryptedPath = "./user-files/users-enc.json"
    Write-UserFile $UserFileEncryptedPath $UserFile
    Write-Host "`nWrote UserFile with encrypted passwords to ./user-files/users-enc.json`n"
}

if ($MyInvocation.MyCommand.Name -eq "PasswordGenerator.ps1") {
    Main
}