Set-ExecutionPolicy Unrestricted 

$myPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UTIL = Join-Path $myPath "util.ps1"
. $UTIL

$hostName = $args[0]
$runAsId  = $args[1]
$username = $args[2]
$password = $args[3]


$loaded = loadScvmmPsm
if ($loaded -ne 0) {
    $vmsrv = Get-SCVMMServer -ComputerName localhost
    if ($vmsrv) {
        $runAs = Get-SCRunAsAccount -VMMServer $vmsrv -ID $runAsId
        if ($runAs) {
            $vmHost  = Get-SCVMHost -VMMServer $vmsrv -ComputerName $hostName
            if ($vmHost) {
                $servername = $env:COMPUTERNAME
                $serviceport = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Lenovo\UnifiedService" `Port).Port
                $rand = Get-Random
                $date = Get-Date 
                $password = ConvertTo-SecureString  $password -AsPlainText -Force
                $cred = New-Object System.Management.Automation.PSCredential($username, $password)
                $sysdrive = get-wmiobject -Credential $cred -Class win32_operatingsystem -ComputerName $args[0]
                $sysuuid = get-wmiobject -Credential $cred -Class Win32_ComputerSystemProduct -ComputerName $args[0]
                $drive = $sysdrive.SystemDirectory.Substring(0, 2)
                $uuid = $sysuuid.UUID.tostring()
                Invoke-SCScriptCommand -Executable $drive'\UIM_RIM\UIM.IRM.OneCliManagement.exe' -TimeoutSeconds 1500 -CommandParameters "-scan $uuid $servername $serviceport $date $rand" -VMHost $vmHost -RunAsAccount $runAs -VMMServer $vmsrv
                
                $jobname = "Invoke script command ($drive\UIM_RIM\UIM.IRM.OneCliManagement.exe -scan $uuid $servername $serviceport $date $rand)"
                $job = Get-SCJob -VMMServer $vmsrv -Name $jobname
                Write-Output "$drive\UIM_RIM\UIM.IRM.OneCliManagement.exe -scan $uuid $servername $serviceport $date $rand"
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
