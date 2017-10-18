Set-ExecutionPolicy Unrestricted 


$myPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UTIL = Join-Path $myPath "util.ps1"
. $UTIL


$hosts    = $args[0] -split '\s+'
$username = $args[1]
$password = ConvertTo-SecureString  $args[2] -AsPlainText -Force
$runAsId    = $args[3]


if ("$runAsId" -ne "") {
    $loaded = loadScvmmPsm
    if ($loaded -ne 0) {
        $vmsrv = Get-SCVMMServer -ComputerName localhost
        # $nrRunAs = Get-SCRunAsAccount -VMMServer $vmsrv | Select -property Name | Where -FilterScript {$_.Name -notlike 'NT*'} | Where -FilterScript {$_.Name -eq $runAsName} | Measure-Object | Select-Object -ExpandProperty Count
        $nrRunAs = Get-SCRunAsAccount -VMMServer $vmsrv | Select -property ID | Where -FilterScript {$_.ID -eq $runAsId} | Measure-Object | Select-Object -ExpandProperty Count
        if ($nrRunAs -gt 0) {
            "runAs"
        }
    }
}


if ("$username" -ne "") {
    $cred    = New-Object System.Management.Automation.PSCredential($username, $password)

    $hosts | foreach {
        $fields = $_ -split ','
        $hostName = $fields[0]
        $hostUuid = ""
        if ($fields.count -ge 2)
        {
            $hostUuid = $fields[1]
        }
        
        trap {
            continue
        }
        # $system  = get-wmiobject -Class Win32_OperatingSystem -ComputerName $host -Credential $cred -ErrorAction SilentlyContinue
        $system  = get-wmiobject -Class Win32_ComputerSystemProduct -ComputerName $hostName -Credential $cred -ErrorAction SilentlyContinue
        if ($system) {
            "$hostName,$hostUuid"
        }
    }
}
