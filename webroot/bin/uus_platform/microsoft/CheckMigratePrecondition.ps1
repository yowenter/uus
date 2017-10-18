Param(
[Parameter(Mandatory=$false,HelpMessage='vmm server')][string]$vmmServerName='localhost',
[Parameter(Mandatory=$true,HelpMessage='vmm host')][string]$vmHostName,
[Parameter(Mandatory=$true,HelpMessage='If check the status of EnableLiveMigration ')][string]$ifcheck
)
Set-ExecutionPolicy Unrestricted
Import-Module -Name "virtualmachinemanager"	 
$vmsrv = Get-VMMServer -ComputerName $vmmServerName -errorAction SilentlyContinue

function checkPrecondition()
{	 
	$VMHost = Get-VMHost -VMMServer $vmsrv -ComputerName $vmHostName
	if ($VMHost.HostCluster -eq $false)
	{
		write-host "The host is not a cluster member."
		return
	}
	if ($ifcheck -eq "True")
	{
		if ($VMHost.EnableLiveMigration -eq $false)
		{
			write-host "The host dose not enable live migration."
			return
		}
	}

	$vms = $VMHost | get-vm
#	$vmId = ""
	foreach ($vm in $vms)
	{ 
		if ($vm.IsHighlyAvailable -eq $false)
		{
			write-host "The host contains non-HighlyAvailable machines."
			return
		}
#		$vmId = $vmId + '||' + $vm.ID
	}
#	if ((Test-Path './temp') -eq $false)
#	{
#		new-item -path './temp' -type directory
#	}
#	$filename = $vmHostName + '.tmp'
#	out-file -filePath "./temp/$filename" -inputObject $vmId -encoding 'UTF8' | Out-Null
	write-host "The host passed the migration pre-check."
	return
}
checkPrecondition