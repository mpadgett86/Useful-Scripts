# Manual WFBS Uninstall Process from: https://success.trendmicro.com/solution/1117997-uninstalling-worry-free-business-security-services-wfbs-svc-agents#collapseThree
#$ErrorActionPreference = 'SilentlyContinue'
#########################################################################################
#########################################################################################
function step3 {
    # Stop WFBS services
    $services = 
        "Trend Micro Application Control Service (Agent)", "Trend Micro Client/Server Security Agent",
        "Trend Micro Common Client Solution Framework", "Trend Micro Endpoint Application Control Agent Service",
        "Trend Micro Endpoint Sensor Engine Wrapper", "Trend Micro Endpoint Sensor Service (Agent)",
        "Trend Micro Security Agent", "Trend Micro Security Agent Data Protection Service",
        "Trend Micro Security Agent Firewall", "Trend Micro Security Agent Listener",
        "Trend Micro Security Agent NT Proxy Service", "Trend Micro Security Agent RealTime Scan",
        "Trend Micro Unauthorized Change Prevention Service", "Worry-Free Business Security Services Windows Security Center Service"

            ForEach ($svc in $services) {
                $service = (Get-Service -Name $svc -ErrorAction SilentlyContinue)
                if ($null -ne $service) { Stop-Service $service -Force }
            }
}
#########################################################################################
#########################################################################################
function step4 {
    # Stop WFBS applications
    $processes = 
        "AcAgentService", "AcAgentUI", "Dsagent", "Dtoop", "ESClient", "ESEFrameworkHost",
        "ESEServiceShell", "HostedAgent", "logWriter", "Ntrtscan", "PccNT", "PccNtMon",
        "PccNTUpd", "TMBMSRV", "TmCCSF", "TMCPMAdapter", "TMiACAgentSvc", "TmListen",
        "TmPfw", "TmProxy", "TmWSCSvc", "svcGenericHost", "XPUpg"

        ForEach ($proc in $processes) {
            $process = (Get-Process $proc -ErrorAction SilentlyContinue)
            if ($null -ne $process) { Stop-Process -Id $process.Id -Force} 
        }
}
#########################################################################################
#########################################################################################
function step5 {
    # Unregister services for WFBS
    cmd.exe /c "regsvr32 /u /s `"C:\Program Files (x86)\Trend Micro\Client Server Security Agent\TmdShell_64x.dll`""
    cmd.exe /c "taskkill /F /IM explorer.exe"
    cmd.exe /c "start explorer.exe"
}
#########################################################################################
#########################################################################################
function step7 {
    $regpath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services"
    $regkeys =
        "AcAgentService", "AcDriver", "AcDriverHelper", "DiscSvc", "DSASvc", "Ntrtscan", "SvcGenericHost",
        "Tmactmon", "TMBMServer", "TmCCSF", "tmcfw", "tmcomm", "tmebc", "tmeevw", "TMESC", "Tmescore",
        "TMESE", "Tmesflt", "Tmesutil", "tmeext", "tmel", "tmevtmgr", "TmFilter", "TMiACAgentSvc", "Tmlisten",
        "tmlwf", "TmPfw", "TmPreFilter", "TmProxy", "tmtdi", "tmumh", "Tmusa", "Tmwfp", "TmWSCSvc", "VSApiNt"

        ForEach ($key in $regkeys) {
            if (Test-Path -Path $("$regpath\$key")) { 
                cmd.exe /c "reg delete `"HKLM\SYSTEM\CurrentControlSet\Services\$key`" /f"
            }
        }
}
#########################################################################################
#########################################################################################
function step8 {
    $regkey = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run\OfficeScanNT Monitor"
    if (Test-Path -Path $regkey) {
        cmd.exe /c "reg delete `"HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run\OfficeScanNT Monitor`" /f"
    }
}
#########################################################################################
#########################################################################################
function step9 {
    $regpath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $regkeys =
        "{A38F51ED-D01A-4CE4-91EB-B824A00A8BDF}", "{BED0B8A2-2986-49F8-90D6-FA008D37A3D2}", "HostedAgent"

        ForEach ($key in $regkeys) {
            if (Test-Path -Path $("$regpath\$key")) { 
                cmd.exe /c "reg delete `"HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$key`" /f"
            }
        }
}
#########################################################################################
#########################################################################################
function step1011 {
    $regpath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro"
    $regkeys =
        "AEGIS", "AMSP", "AMSPStatus", "ESC", "ESE", "ESEStatus", "Falcon", "iACAgent",
        "Endpoint Application Control Agent", "NSC", "Osprey", "TMESD", "WL", "Wofie"

        ForEach ($key in $regkeys) {
            if (Test-Path -Path $("$regpath\$key")) { 
                cmd.exe /c "reg delete `"HKLM\SOFTWARE\TrendMicro\$key`" /f"
            }
        }

    $regpath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TrendMicro"
    $regkeys =
        "AEGIS", "ClientStatus", "CPM", "NSC", "OEM", "OfcWatchDog", "Osprey", "Pc-cillinNTCorp", "WFBSSUpdater"

        ForEach ($key in $regkeys) {
            if (Test-Path -Path $("$regpath\$key")) { 
                cmd.exe /c "reg delete `"HKLM\SOFTWARE\Wow6432Node\TrendMicro\$key`" /f"
            }
        }

    $regpath = "Microsoft.PowerShell.Core\Registry::HKEY_CLASSES_ROOT\Installer"
    $regkeys =
        "Features\DE15F83AA10D4EC419BE8B420AA0B8FD", "Products\DE15F83AA10D4EC419BE8B420AA0B8FD", 
        "Products\2A8B0DEB68928F94096DAF00D8733A2D", "UpgradeCodes\8A88AE84D667B304CB368C99791A74A6"

        ForEach ($key in $regkeys) {
            if (Test-Path -Path $("$regpath\$key")) { 
                cmd.exe /c "reg delete `"HKCR\Installer\$key`" /f"
            }
        }
}
#########################################################################################
#########################################################################################
function step12 { cmd.exe /c "shutdown /r"}
#########################################################################################
#########################################################################################
Set-ExecutionPolicy Bypass -Scope Process -Force | Write-Host 'A'
step3
step4
step5
step7
step8
step9
step1011
step12