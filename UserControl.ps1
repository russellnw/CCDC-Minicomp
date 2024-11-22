#Requires -RunAsAdministrator

function Get-UserFile ([string]$Path) {
    $UserFile = Get-Content -Raw -Path $Path
    $UserFile = $UserFile | ConvertFrom-Json -Depth 4
    
    return $UserFile
}

function Remove-BadUsers ([Object]$UserFile) {
    
}

function Reset-UserType ([Object]$UserFile) {
    
}

function Set-Passwords ([Object]$UserFile,[System.Security.SecureString]$Key) {
    
}

function Main {
    $HelpString = (@(
        "Get-UserFile <Path> : Reads user information from given json file"
        ""
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

    $UserFile

    while ($true) {
        [System.Console]::Write(">>> ")
        $command = ((Read-Host) -split " ")

        switch ($command[0].ToLower()) {
            "get-userfile" {
                $UserFile = Get-UserFile $command[1]
            }
            "remove-badusers" {
                Remove-BadUsers $UserFile
            }
            "reset-userType" {
                Reset-UserType $UserFile
            }
            "set-passwords" {
                
                Set-Passwords $UserFile $(Read-Host -AsSecureString "Input Encryption Key")
            }
            "get-help" {
                Write-Host "`n$HelpString`n"
            }
            "exit" {
                Write-Host
                exit
            }
            Default {
                Write-Host "Invalid Command`n"
            }
        }
    }
}

if ($MyInvocation.MyCommand.Name -eq 'UserControl.ps1') {
    Main
}