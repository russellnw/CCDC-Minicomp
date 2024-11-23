$ServicesInbound = @{
    "AD/DNS" = @(
        @(0,"ICMPv4","ICMPv6"),
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
    "ICMP" = @(
        @(0,"ICMPv4","ICMPv6")
    )
    "IIS" = @(
        @(80,"TCP"),
        @(443,"TCP")
    )
    "SMB" = @(
        @(445,"TCP")
    )
    "WinRM" = @(
        @(5985,"TCP"),
        @(5986,"TCP")
    )
}

function Main {
    $Service = Read-Host "Service Names"
    if ($ServicesInbound[$Service] -eq $null) {
        Write-Host "Invalid Service"
        exit
    }
    Get-NetFirewallRule | Where-Object {$_.Direction -eq "Inbound"} | Remove-NetFirewallRule
    foreach ($Port in $ServicesInbound[$Service]) {
        for ($i = 1; $i -lt $Port.Count; $i++) {
            if ($Port[0] -eq 0) {
                New-NetFirewallRule -Name "AllowInbound_$($Service)_$($Port[$i])" `
                    -DisplayName "AllowInbound_$($Service)_$($Port[$i])" `
                    -Direction "Inbound" `
                    -Protocol $Port[$i] `
                    -Action "Allow" `
                    -Profile "Any"
                continue
            }
            New-NetFirewallRule -Name "AllowInbound_$($Service)_$($Port[0])_$($Port[$i])" `
                -DisplayName "AllowInbound_$($Service)_$($Port[0])_$($Port[$i])" `
                -Direction "Inbound" `
                -Protocol $Port[$i] `
                -LocalPort $Port[0] `
                -Action "Allow" `
                -Profile "Any"
        }
    }
    Set-NetFirewallProfile -All -DefaultInboundAction Block
}

if ($MyInvocation.MyCommand.Name -eq 'FirewallSetup.ps1') {
    Main
}