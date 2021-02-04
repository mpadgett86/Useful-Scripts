# Set the environment to skip errors and continue
$ErrorActionPreference = 'SilentlyContinue'
# Get the default execution policy of the machine

function [string]execPolicy { return Get-ExecutionPolicy }

write-host $execPolicy

$logfile = "C:\Users\MattPadgett\Desktop\log.log"

Start-Transcript $logfile

# Function to check if a command is present on the system, so that commands do not fail
function checkCmd([string]$cmdName){ 
    return [bool](Get-Command -Name $cmdName -ErrorAction SilentlyContinue)
}

# Function to check if a PS module is installed so that commands do not fail
function checkMod([string]$modName) {
    return [bool](Get-Package -Name $modName -ErrorAction SilentlyContinue)
}

# Set the Execution-Policy to Bypass so that the PSGallery Module can be downloaded and imported to the machine
cmd.exe /c "echo A | Powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force"

write-host $execPolicy

# Check if NuGet is installed on the machine and install it if it is not already present.
# This is needed to properly import PSWindowsUpdate
if (checkCmd "nuget" -eq $false) {
    cmd.exe /c "echo A | Powershell.exe Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force" 
              # echo Y | ...
}

# Check if the command WindowsUpdate is present, if not, set the trust level of PSGallery to Trusted so that the end-user doesn't have to interact with this script
# Then, install the PSWindowsUpdate module to the system
if (checkCmd "Get-WindowsUpdate" -eq $false) {
    cmd.exe /c "echo A | Powershell.exe Set-PSRepository -Name `"PSGallery`" -InstallationPolicy Trusted"
    cmd.exe /c "echo A | Powershell.exe Import-Module PowerShellGet -Force"
    cmd.exe /c "echo A | Powershell.exe Install-Module PSWindowsUpdate -Force"
    cmd.exe /c "echo A | Powershell.exe Import-Module `"PSWindowsUpdate`" -Force"
}

# Wait for 30 seconds to let the system finish any install/import steps
Start-Sleep -Seconds 30

# Make sure that the PSWindowsUpdate module was installed
if (checkMod "PSWindowsUpdate" -eq $true) {
    # If PSWindowsUpdate was installed, then

    # Make sure that WindowsUpdate command is present before checking for a Windows Update
    if (checkCmd "Get-WindowsUpdate" -eq $true) { cmd.exe /c "Powershell.exe Get-WindowsUpdate" }

    # This is added as a check in case WindowsUpdate command fails
    # WUList will reach out to update server and get all KBs for the system
    if (checkCmd "Get-WUList" - eq $true) { cmd.exe /c "Powershell.exe Get-WUList" }
    
    # Install all the updates from either WindowsUpdate or WUList, or both, if present
    cmd.exe /c "echo A | Powershell.exe Install-WindowsUpdate -AcceptAll -MicrosoftUpdate"
}

Stop-Transcript

# Return the system to its default security settings policies
cmd.exe /c "echo A | Powershell.exe Set-ExecutionPolicy $ExecPolicy -Scope Process -Force"
$ErrorActionPreference = 'Continue'

