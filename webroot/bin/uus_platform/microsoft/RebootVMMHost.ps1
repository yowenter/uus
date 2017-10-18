Param(
[Parameter(Mandatory=$false,HelpMessage='vmm server')][string]$vmmServerName='localhost',
[Parameter(Mandatory=$true,HelpMessage='vmm host')][string]$vmHostName
)
Set-ExecutionPolicy Unrestricted 
Import-Module -Name "virtualmachinemanager"
$vmsrv = Get-VMMServer -ComputerName $vmmServerName -errorAction SilentlyContinue;
Get-SCVMHost -VMMServer $vmsrv -ComputerName $vmHostName | Restart-SCVMHost -Confirm:$false

# start cluster service in win2008r2
#if ($ifStartService -eq "True")
#{
#$password = ConvertTo-SecureString  $vmHostPassword -AsPlainText -Force;
#$cred = New-Object System.Management.Automation.PSCredential($vmHostUserName, $password)
#$clusterserv = get-wmiobject -Credential $cred -ComputerName $vmHostName -Class win32_service | where-object {$_.Name -eq "ClusSvc"}
#$clusterserv.StartService()
#}