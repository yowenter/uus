Param(
[Parameter(Mandatory=$false,HelpMessage='vmm server')][string]$vmmServerName='localhost',
[Parameter(Mandatory=$true,HelpMessage='vmm host')][string]$vmHostName
)

Set-ExecutionPolicy Unrestricted 
Import-Module -Name "virtualmachinemanager"
$vmsrv = Get-VMMServer -ComputerName "$vmmServerName" -errorAction SilentlyContinue;
$VMHost = Get-VMHost -VMMServer $vmsrv -ComputerName "$vmHostName"
$clusterName = $vmhost.HostCluster.Name
Enable-SCVMHost -VMHost $VMHost | Out-Null
return 'True'
#$fileName = "./temp/$vmHostName" + '.tmp'
#if ((Test-Path $fileName) -eq $false)
#{
#	return 'False'
#}
#$vmList = (get-content $fileName).split('||')
#foreach ($vmNode in $vmList)
#{
#	if($vmNode)
#	{
#		$VM = Get-SCVirtualMachine -ID $vmNode.Trim()
#		Move-SCVirtualMachine -VM $VM -VMHost $VMHost -HighlyAvailable $true | Out-Null
#	}
#}

#Remove-Item $fileName

#$node = Get-ClusterNode -Name "$vmHostName" -Cluster "$clusterName"
#write-host $node
#if ($node.state -ne "up")
#{
#	Start-ClusterNode -Name "$vmHostName" -FixQuorum
#}

# start cluster service if it not started

#$password = ConvertTo-SecureString  $vmHostPassword -AsPlainText -Force;
#$cred = New-Object System.Management.Automation.PSCredential($vmHostUserName, $password)
#$clusterserv = get-wmiobject -Credential $cred -ComputerName $vmHostName -Class win32_service | where-object {$_.Name -eq "ClusSvc"}
#Try
#{    
#if ($clusterserv.State -eq "Stopped")
#{
#	$ret = $clusterserv.StartService()
#	if ($ret -ne 0)
#	{
#		write-host "Failed to start the cluster service."
#	}
#}
#}
#Catch
#{    
#	Write-Host "Failed to start cluster service："$Error[0]
#}



