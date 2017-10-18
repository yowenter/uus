Set-ExecutionPolicy Unrestricted 


$myPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UTIL = Join-Path $myPath "util.ps1"
. $UTIL


$hosts  = $args[0] -split ';\s*'

$hosts | foreach {
    $hostInfo = $_ -split ':'
    
    $computerId   = $hostInfo[0]
    $computerName = $hostInfo[1]
    $username     = $hostInfo[2]
    $password     = $hostInfo[3]
    
    $machineInfo = getMachineInfo "$computerName" "$username" "$password"
    if ("$machineInfo" -ne "") {
        "$computerId||$machineInfo"
    }
}

# powershell -file getOSInfoEx.ps1 ""

