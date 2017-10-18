
Function GetRegData64ThruWMI($reAppName) {
    $HKLM = "&h80000002"
    $keyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $objNamedValueSet = New-Object -COM "WbemScripting.SWbemNamedValueSet"
    $objNamedValueSet.Add("__ProviderArchitecture", 64) | Out-Null
    $objLocator = New-Object -COM "Wbemscripting.SWbemLocator"
    $objServices = $objLocator.ConnectServer("localhost","root\default","","","","","",$objNamedValueSet)
    $objStdRegProv = $objServices.Get("StdRegProv")
    
    # enum sub keys
    $Inparams = ($objStdRegProv.Methods_ | where {$_.name -eq "EnumKey"}).InParameters.SpawnInstance_()
    ($Inparams.Properties_ | where {$_.name -eq "Hdefkey"}).Value = $HKLM
    ($Inparams.Properties_ | where {$_.name -eq "Ssubkeyname"}).Value = $keyPath
    
    $Outparams = $objStdRegProv.ExecMethod_("EnumKey", $Inparams, "", $objNamedValueSet)
    if (($Outparams.Properties_ | where {$_.name -eq "ReturnValue"}).Value -ne 0) {
        return ""
    }
    
    $myKey = ""
    $subkeys = ($Outparams.Properties_ | where {$_.name -eq "sNames"}).Value
    $subkeys | where -FilterScript {$_.ToLower() -like $reAppName.ToLower()} | Select -First 1 | ForEach {
        $myKey = $_
    }
    if ("$myKey" -eq "") {
        return ""
    }
    
    # get reg data
    $Inparams = ($objStdRegProv.Methods_ | where {$_.name -eq "GetStringValue"}).InParameters.SpawnInstance_()
    ($Inparams.Properties_ | where {$_.name -eq "Hdefkey"}).Value = $HKLM
    ($Inparams.Properties_ | where {$_.name -eq "Ssubkeyname"}).Value = "$keyPath\$myKey"
    ($Inparams.Properties_ | where {$_.name -eq "Svaluename"}).Value = "UninstallString"
    
    $Outparams = $objStdRegProv.ExecMethod_("GetStringValue", $Inparams, "", $objNamedValueSet)
    if (($Outparams.Properties_ | where {$_.name -eq "ReturnValue"}).Value -ne 0) {
       return ""
    }
    
    $regData = ($Outparams.Properties_ | where {$_.name -eq "sValue"}).Value
    
    return $regData
}

Function getInstPath($reAppName, $reCutOff) {
    
    $instPath = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | where -FilterScript {$_.Name.ToLower() -like $reAppName.ToLower()} | ForEach -Process {$_.GetValue("UninstallString")}
    if ("$instPath" -eq "" -and [System.Runtime.InterOpServices.Marshal]::SizeOf([System.IntPtr]) -eq 4) {
        $instPath = GetRegData64ThruWMI "$reAppName"
    }
    if ("$instPath" -eq "") {
        return ""
    }
    $instPath = $instPath.trim(' "').ToLower()
    $idxCut = $instPath.IndexOf($reCutOff.ToLower())
    if ($idxCut -ge 0) {
        return $instPath.substring(0, $idxCut)
    }
    return ""
}

Function getScomPath() {
    
    return getInstPath '*System Center 2012*Operations Manager*' '\setup\'
}


Function getScvmmPath() {
    
    return getInstPath '*System Center 2012*Virtual Machine Manager*' '\setup\'
}


Function getScomPsmPath() {
    $myPath = getScomPath
    if ("$myPath" -eq "") {
        return ""
    }
    return $myPath + "\Powershell\OperationsManager"
}


Function getScvmmPsmPath() {
    
    $myPath = getScvmmPath
    if ("$myPath" -eq "") {
        return ""
    }
    return $myPath + "\bin\psModules\virtualmachinemanager"
}

Function loadScomPsm() {
    $modPath = getScomPsmPath
    if ("$modPath" -eq "") {
        $modPath = "OperationsManager"
    }
    $loaded = 1
    trap {
        $loaded = 0
        continue
    }
    import-module $modPath -ErrorAction SilentlyContinue
    
    return $loaded
}

Function loadScvmmPsm() {
    $modPath = getScvmmPsmPath
    if ("$modPath" -eq "") {
        $modPath = "virtualmachinemanager"
    }
    $loaded = 1
    trap {
        $loaded = 0
        continue
    }
    import-module $modPath -ErrorAction SilentlyContinue
    
    return $loaded
}

Function getMachineInfo($computerName, $username, $password) {
    if ("$computerName" -eq "" -or "$username" -eq "") {
        return ""
    }
    $password = ConvertTo-SecureString $password -AsPlainText -Force
    
    $cred     = New-Object System.Management.Automation.PSCredential($username, $password)
    
    trap {
        #$error = $_.Exception.GetType() 
        #Write-Host "Caught $error" 
        continue
    }
    
    $machineType = ""
    
    $system  = get-wmiobject -Class Win32_ComputerSystemProduct -ComputerName $computerName -Credential $cred -ErrorAction SilentlyContinue
    if ($system) {
        $system | Select -First 1 | select -Property Name, UUID  | ForEach {
            $machineType = ($_.Name -replace '^.*\-\[').Substring(0, 4)
        }
    }
    else {
        return ""
    }
    
    $osArch         = ""
    $osType         = ""
    $osName         = ""
    $osVersion      = ""
    $lastBootupTime = ""
    
    $system  = get-wmiobject -Class Win32_OperatingSystem -ComputerName $computerName -Credential $cred -ErrorAction SilentlyContinue
    if ($system) {
        $system | Select -First 1 | select -Property OSArchitecture, OSType, Name, Version, LastBootUpTime  | ForEach {
            $osArch         = $_.OSArchitecture.Substring(0, 2)
            $osType         = $_.OSType
            $osName         = $_.Name -replace '\|.*$'
            $osVersion      = $_.Version
            $lastBootupTime = $_.LastBootUpTime
        }
    }
    else {
        return ""
    }
    
    return "$machineType||$osArch||$osType||$osName||$osVersion||$lastBootupTime"
}


