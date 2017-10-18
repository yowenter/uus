Set-ExecutionPolicy Unrestricted 

$myPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UTIL = Join-Path $myPath "util.ps1"
. $UTIL

$vmHostName = $args[0]
$runAsId = $args[1]
$vmServerUserName = $args[2]
$vmServerPassword = $args[3]
$vmHostUserName = $args[4]
$vmHostPassword = $args[5]
$sharePath = $args[6]
$taskId = $args[7]
$updateId = $args[8]
$ifdowngrade = $args[9]
$startTime = $args[10]


$loaded = loadScvmmPsm
if ($loaded -ne 0) {
    $vmsrv = Get-SCVMMServer -ComputerName localhost
    if ($vmsrv) {
        $runAs = Get-SCRunAsAccount -VMMServer $vmsrv -ID $runAsId
        if ($runAs) {
            $vmHost  = Get-SCVMHost -VMMServer $vmsrv -ComputerName $vmHostName
            if ($vmHost) {
                $servername = [System.Net.DNS]::GetHostByName('').HostName
                $serviceport = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Lenovo\UnifiedService" `Port).Port
                $rand = Get-Random
                #$date = Get-Date 
                #$userid = $args[2]
                $password = ConvertTo-SecureString  $vmHostPassword -AsPlainText -Force;
                $cred = New-Object System.Management.Automation.PSCredential($vmHostUserName, $password)
                $sysdrive = get-wmiobject -Credential $cred -Class win32_operatingsystem -ComputerName $vmHostName
                $sysuuid = get-wmiobject -Credential $cred -Class Win32_ComputerSystemProduct -ComputerName $vmHostName
                $drive = $sysdrive.SystemDirectory.Substring(0, 2)
                $uuid = $sysuuid.UUID.tostring().replace('-', '').ToLower()
                #$taskid = $taskId
                #$updateid = $updateId
                #$ifdowngrade = $args[6]
                Invoke-SCScriptCommand -Executable $drive'\UIM_RIM\UIM.IRM.OneCliManagement.exe' -TimeoutSeconds 300000 -CommandParameters "-update $uuid $servername $vmServerUserName $vmServerPassword $serviceport ""$sharePath"" $taskid $updateid $ifdowngrade $startTime $rand" -VMHost $VMHost -RunAsAccount $runAs -VMMServer $vmsrv
                
                $jobname = "Invoke script command ($drive\UIM_RIM\UIM.IRM.OneCliManagement.exe -update $uuid $servername $vmServerUserName $vmServerPassword $serviceport ""$sharePath"" $taskid $updateid $ifdowngrade $startTime $rand)"
                $job = Get-SCJob -VMMServer $vmsrv $jobname
                #Write-Output "$drive\UIM_RIM\UIM.IRM.OneCliManagement.exe -scan $uuid $servername $serviceport $date $rand"
                #Write-Output "Invoke script command ($drive\UIM_RIM\UIM.IRM.OneCliManagement.exe -scan $hostname $date)"
                do {
                    Start-Sleep -Seconds 3
                }
                While($job.status -eq 'Running')
                Write-Output $job.status
                if ($job.status -eq 'Failed')
                {
                    if ($job.errorinfo.DetailedCode -eq -2147024894)
                    {
                        Write-Error $job.errorinfo.Problem 'The system cannot find the file specified.'
                    }
                    else
                    {
                        Write-Error $job.errorinfo.Problem
                    }
                }
            }
        }
    }
}

