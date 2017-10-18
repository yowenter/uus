Param(
[Parameter(Mandatory=$false,HelpMessage='vmm server')][string]$vmmServerName='localhost',
[Parameter(Mandatory=$true,HelpMessage='vmm host')][string]$vmHostName
)
Set-ExecutionPolicy Unrestricted 
Import-Module -Name "virtualmachinemanager"	 
$vmsrv = Get-VMMServer -ComputerName $vmmServerName -errorAction SilentlyContinue;

function containHost()
{
	$VMHost = Get-VMHost -VMMServer $vmsrv -ComputerName $vmHostName;
	if ($VMHost.MaintenanceHost -eq $true)
	{
		$vms = $VMHost | get-vm
		foreach ($vm in $vms)
		{ 
			if ($vm.IsHighlyAvailable -eq $true)
			{
				write-host "The host contains highly available machines."
				return
			}
		}
		write-host "The host is in maintenance mode."
		return
	}
	else
	{
		write-host "The host is not in maintenance mode."
		return
	}
}

containHost