####################################################################
##############
############## Update VMs IP address 
##############
####################################################################
#Created by: Eric Neudorfer
#Created on: 09202016
#Dependency: PowerCLI (Tested in Powershellv4.0)

##################################
##############
############## Load Modules
##############
##################################
<#
$MyCredentials=GET-CREDENTIAL
Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"
Connect-VIServer -vcenter2, sd-mgt-sso-1-1, dr-vcenter2, az-mgt-sso-1-1 -Credential $MyCredentials
#>

##################################
##############
############## Variables
##############
##################################

$vm = Read-Host -Prompt 'Input your server name'
$ip = Read-Host -Prompt 'Input your IP Address'
#$gw = Read-Host -Prompt 'Input your IP Address' 

#########Take IP address and Configure Gateway by converting 4th octate to a 1
$gw = "$([Regex]::Matches($ip, '(\d{1,3}\.\d{1,3}\.\d{1,3}\.)').groups[0].value)1" 
#$gw = Get-WmiObject -Class Win32_IP4RouteTable | where { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} | Sort-Object metric1 | select nexthop

##################################
##############
############## Program
##############
##################################

#Invoke script in VM to get the network adapter
$Network = Invoke-VMScript -VM $vm -ScriptType Powershell -ScriptText "(gwmi Win32_NetworkAdapter -filter 'netconnectionid is not null').netconnectionid" 
$NetworkName = $Network.ScriptOutput

#netsh commands to change IP address, Gateway, subnet mask, and DNS.
$netsh = "c:\windows\system32\netsh.exe interface ip set address  static $ip 255.255.255.0 $gw name=""$NetworkName"""
$netsh2 = "c:\windows\system32\netsh.exe interface ip set dnsservers static 10.150.2.101 name=""$Networkname"""
$netsh3 = "c:\windows\system32\netsh.exe interface ip add dnsservers 10.150.2.100 index=2 name=""$Networkname"""
Invoke-VMScript -vm $vm -scripttype bat -scripttext $netsh
Invoke-VMScript -vm $vm -scripttype bat -scripttext $netsh2
Invoke-VMScript -vm $vm -scripttype bat -scripttext $netsh3

Write-Host "Setting IP address completed." -ForegroundColor Green
Write-Host "Virtual Machine: $vm" -ForegroundColor Yellow
Write-Host "IP address: $ip" -ForegroundColor Yellow
Write-Host "Default Gateway: $gw" -ForegroundColor Yellow
Write-Host "Subnet Mask: 255.255.255.0" -ForegroundColor Yellow
Write-Host "DNS 1: 10.150.2.101" -ForegroundColor Yellow
Write-Host "DNS 2: 10.150.2.100" -ForegroundColor Yellow

Pause

##################################
##############
############## Troubleshooting
##############
##################################

<#
 $vm = "bofi-sd-wrix"
$ip = 10.150.2.32

#$gw = Get-WmiObject -Class Win32_IP4RouteTable | where { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} | Sort-Object metric1 | select nexthop
$ip = "10.150.2.33"
$gw = "$([Regex]::Matches($ip, '(\d{1,3}\.\d{1,3}\.\d{1,3}\.)').groups[0].value)1" 
write-output $gw

$Network = Invoke-VMScript -VM $vm -ScriptType Powershell -ScriptText "(gwmi Win32_NetworkAdapter -filter 'netconnectionid is not null').netconnectionid" 
$NetworkName = $Network.ScriptOutput

$netsh = "c:\windows\system32\netsh.exe interface ip set address static $ip 255.255.255.0 $gw name=""$NetworkName"""
write-output $netsh

Invoke-VMScript -vm $vm -scripttype bat -scripttext $netsh

 #>
