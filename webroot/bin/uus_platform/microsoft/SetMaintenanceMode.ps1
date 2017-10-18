Param(
[Parameter(Mandatory=$false,HelpMessage='vmm server')][string]$vmmServerName='localhost',
[Parameter(Mandatory=$true,HelpMessage='vmm host')][string]$vmHostName
)


#$VMMServer = Get-VMMServer -ComputerName "VMMServer01.Contoso.com"
#$Cluster = Get-VMHostcluster -Name "Cluster01"
#$VMHosts = Get-VMHost -VMHostCluster $Cluster

Import-Module -Name "virtualmachinemanager"
$vmsrv = Get-VMMServer -ComputerName $vmmServerName -errorAction SilentlyContinue;			 
$VMHost = Get-VMHost -VMMServer $vmsrv -ComputerName $vmHostName;
if ($VMHost.HostCluster)
{
	Write-Host "Placing host" $VMHost "into maintenance mode."
	if ($VMHost.MaintenanceHost -eq $false)
	{
		Disable-SCVMHost $VMHost -MoveWithinCluster;
	}
	else
	{
		$VMs = $VMHost | Get-SCVirtualMachine
		foreach ($VM in $VMs)
		{   
			if ($vm.IsHighlyAvailable -eq $true)
			{
				$VMHostTarget = $VMHost.hostcluster | Get-SCVMHost | where {$_.ComputerName -ne $VMHost.ComputerName} | Sort-Object AvailableMemory -Descending | Select-Object -First 1  
				Move-SCVirtualMachine -VM $VM -VMHost $VMHostTarget
			}
		}
	}
}
else
{
    Disable-SCVMHost $VMHost;
}


