$SaveExecutionPolicy = Get-ExecutionPolicy
cmd /c "echo A | Powershell Set-ExecutionPolicy RemoteSigned"

function defaultMitigations {

    <#
    This section will enable mitigations for
        Intel® Transactional Synchronization Extensions (Intel® TSX) Transaction Asynchronous Abort vulnerability (CVE-2019-11135) 
        Microarchitectural Data Sampling (CVE-2018-11091
        CVE-2018-12126, CVE-2018-12127, CVE-2018-12130)
        Spectre (CVE-2017-5753 & CVE-2017-5715) 
        Meltdown (CVE-2017-5754) 
        Speculative Store Bypass Disable (SSBD) (CVE-2018-3639)
        L1 Terminal Fault (L1TF) (CVE-2018-3615, CVE-2018-3620, and CVE-2018-3646) without disabling Hyper-Threading
    #>
    cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`" /v FeatureSettingsOverride /t REG_DWORD /d 72 /f"
    cmd /c "reg add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f"

    # Check if Hyper-V is enabled on the system. If so, then apply the following registry key protections.
    $hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
    if ($hyperv.State -eq "Enabled") {
        cmd /c "reg add `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization`" /v MinVmVersionForCpuBasedMitigations /t REG_SZ /d `"1.0`" /f"
    } 

    
}

defaultMitigations

Set-ExecutionPolicy $SaveExecutionPolicy -Scope CurrentUser
