#$ErrorActionPreference = 'SilentlyContinue'

$log_file = "C:\wupdate.log"
$answer = 'A'
$default_EP = (Get-ExecutionPolicy)


#TODO check for available drive space

Start-Transcript -Path $log_file
#############################################################################################################
function writeLog() {

    param ( 
        [string]$strInfo = ""
    )

    $date = Get-Date
    $logFormat = "$date --- $strInfo"
    Add-Content $log_file "$logFormat`n"
}
#############################################################################################################
function checkCmd([string]$cmdName){ return [bool](Get-Command -Name $cmdName -ErrorAction SilentlyContinue) }
#############################################################################################################
#############################################################################################################
function loadModule ( $module) {
    if (!(Get-Module | Where-Object {$_.Name -eq $module} )) {
        if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $module}) {
            Import-Module $module -Force | Write-Host $answer
            Start-Sleep -Seconds 15
        }
        else {
            if (Find-Module -Name $module | Where-Object {$_.Name -eq $module }) {
                Install-Module -Name $module -Force -Scope CurrentUser | Write-Host $answer
                Import-Module $module | Write-Host $answer
                Start-Sleep -Seconds 15
            }
        }
    }
    <#else {
        ISSUE: Modules can only be updated if they were installed with Install-Module
        TODO: Need to figure out how to find Win10 ported modules, remove, and replace them so they can be managed.
        Update-Module -Name $module -Force
    }#>
}
#############################################################################################################
function initExecutionPolicy ($policy) {
    Set-ExecutionPolicy $policy -Scope Process -Force | Write-Host $answer
}
#############################################################################################################
function initRepository {
    if ([bool](Get-PSRepository *PSGallery*) -eq $false) {
        Register-PSRepository -Default
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Start-Sleep -Seconds 15
    }
}
#############################################################################################################
function initNuget {
    if ([bool](Get-PackageProvider -Name nuget) -eq $false) { 
        cmd.exe /c "echo Y | Powershell.exe Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Scope CurrentUser -Force"
        Start-Sleep -Seconds 15
    }
}
#############################################################################################################
function doUpdateInstall {
    if ((checkCmd -cmdName Get-WindowsUpdate) -eq $true) { 
        Start-Sleep -Seconds 30
        Get-WindowsUpdate
        Start-Sleep -Seconds 30
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll
        Start-Sleep -Seconds 60
    }

    if ((checkCmd -cmdName Get-WUList) -eq $true) { 
        Start-Sleep -Seconds 30
        Get-WUList
        Start-Sleep -Seconds 30

        if ((Get-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d) -eq 0) {
            cmd.exe /c "echo A | Powershell.exe Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d"
        }
        if ((Get-WUServiceManager -ServiceID 9482f4b4-e343-43b6-b170-9a65bc822c77) -eq 0) {
            cmd.exe /c "echo A | Powershell.exe Add-WUServiceManager -ServiceID 9482f4b4-e343-43b6-b170-9a65bc822c77"
        }
        if ((Get-WUServiceManager -ServiceID 855e8a7c-ecb4-4ca3-b045-1dfa50104289) -eq 0) {
            cmd.exe /c "echo A | Powershell.exe Add-WUServiceManager -ServiceID 855e8a7c-ecb4-4ca3-b045-1dfa50104289"
        }

        Get-WUInstall -MicrosoftUpdate -AcceptAll
        Start-Sleep -Seconds 60
    }
}
#############################################################################################################
#############################################################################################################
#############################################################################################################
initExecutionPolicy Bypass

initNuget
initRepository
loadModule PowerShellGet
loadModule PSWindowsUpdate

doUpdateInstall

initExecutionPolicy -policy $default_EP

Stop-Transcript