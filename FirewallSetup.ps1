$ServicesInbound = @{
    "AD/DNS" = @(
        @(0,"ICMPv4","ICMPv6")
        @(53,"TCP","UDP"),
        @(123,"UDP"),
        @(138,"UDP"),
        @(389,"TCP","UDP"),
        @(445,"TCP","UDP"),
        @(636,"TCP"),
        @(3268,"TCP"),
        @(3269,"TCP"),
        @("RPC","TCP"),
        @("RPCEPMap","TCP")
    )
    "IIS" = @(80,443)
    "SMB" = @(445)
    "WinRM" = @(5985,5986)
}

function Main {
    $Service = Read-Host "Service Names"
    if ($ServicesInbound -notcontains $Service) {
        Write-Host "Invalid Service"
        exit
    }
    # Get-NetFirewallRule | Remove-NetFirewallRule
    foreach ($Port in $ServicesInbound[$Service]) {
        Write-Host $Port
    }
}

if ($MyInvocation.MyCommand.Name -eq 'FirewallSetup.ps1') {
    Main
}