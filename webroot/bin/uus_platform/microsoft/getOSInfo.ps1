Set-ExecutionPolicy Unrestricted 


$myPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UTIL = Join-Path $myPath "util.ps1"
. $UTIL


$loaded = loadScomPsm
if ($loaded -ne 0) {
    Get-SCOMClass -Name IBM.WinComputer | Get-SCOMClassInstance | ForEach-Object {
        $_.Values | ForEach-Object {
            if($_.Type.Name -eq "DisplayName") {
                $DisplayName = $_.Value
            }
            if($_.Type.Name -eq "SystemUUID") {
                $SystemUUID =$_.Value
            }
        }
        $DisplayName + "||" + $SystemUUID + "||SCOM||()||"
    }
}

$loaded = loadScvmmPsm
if ($loaded -ne 0) {
    $vmsrv = Get-SCVMMServer -ComputerName localhost
    $clusters = Get-SCVMHostCluster -VMMServer $vmsrv | Select -property Name, ID
    Get-SCVMHost -VMMServer $vmsrv | select -Property FQDN, PhysicalMachine, HostCluster, OperatingSystem, OperatingSystemVersion, RunAsAccount, MigrationSubnet  | ForEach {
        $clusterName = $_.HostCluster
        $clusterId   = ""
        $osName      = $_.OperatingSystem
        $osVersion   = $_.OperatingSystemVersion
        $runAs       = $_.RunAsAccount
        $ipAddr      = $_.MigrationSubnet[0] -replace '/.*$'
        if ("$clusterName" -ne "") {
            $clusters | Where -FilterScript {$_.Name -eq $clusterName} | Select -First 1 | ForEach {
                $clusterId = $_.ID
            }
        }
        $_.FQDN + "||" + $_.PhysicalMachine + "||SCVMM" + "||" + $clusterId + "(" + $clusterName + ")||$ipAddr"
    }
}

