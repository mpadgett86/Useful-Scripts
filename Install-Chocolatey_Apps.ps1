######################################################################################################################################################################
# | Global Environment Variables | ###################################################################################################################################
######################################################################################################################################################################

# If any errors are encountered during the script execution, ignore it and contine to the next line
# Similar to VBS: On Error Resume Next
$ErrorActionPreference = 'SilentlyContinue'

# Get the System Default Execution Policy
$ExecPolicy = Get-ExecutionPolicy

# Define the applications to be installed on the machine
$chocoApps = 
    "git",
    "openssl",
    "notepadplusplus",
    "notepadplusplus.install"

######################################################################################################################################################################
# | Verify Chocolatey Installation | #################################################################################################################################
######################################################################################################################################################################
function checkCmd([string]$cmdName){ 
    
    # Verify that Chocolatey is installed on the machine and return the findings
    return [bool](Get-Command -Name $cmdName -ErrorAction SilentlyContinue)
}

######################################################################################################################################################################
# | Install Routine for Choclatey | ##################################################################################################################################
######################################################################################################################################################################
function installChocolatey {

    # Change the Default Execution Policy to Bypass in order to download and install Chocolatey
    cmd.exe /c "echo A | Powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force"

    # Download and install Chocolatey from chocolatey.org
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Return the System to the Default Execution Policy from Line #10
    cmd.exe /c "echo A | Powershell.exe Set-ExecutionPolicy $ExecPolicy -Scope Process -Force"
}

######################################################################################################################################################################
# | Install Chocolatey Applications | ################################################################################################################################
######################################################################################################################################################################
function installApps {

    # Loop through the defined apps to be installed and then execute their install scripts
    ForEach ($app in $chocoApps) {
        Start-Process -FilePath choco -ArgumentList "install $app -y" -Wait
    }
}

######################################################################################################################################################################
# | Main Script Routine | ############################################################################################################################################
######################################################################################################################################################################
function do_mainRoutine {

    # If Chocolatey is already installed, then just install the apps
    if (checkCmd "choco" -eq $true) { 
        installApps
    }
    # If Chocolatey is not installed, install it, wait 120 seconds for it to finish the process,
    # and then begin the app install process.
    elseif (checkCmd "choco" -eq $false) { 
        installChocolatey 
        Start-Sleep -Seconds 120
        installApps
    }
}

# Run the Main script routine
do_mainRoutine

# Return the system's PowerShell environment variable to the Default Error interaction/verbosity setting
$ErrorActionPreference = 'Continue'