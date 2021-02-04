# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This script will automatically run the steps outline in the laptop build 
# Procedure references in https://swishdata.sharepoint.com/sites/IT/SitePages/Building%20a%20New%20Win10%20Laptop.aspx 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
<# 
    Script execution timeline:
    1) DebloatWindows - Will remove unecessary bloatware that accompanies Windows 10 during the intial OS setup.
    2) *OPTIONAL* - Install Chocolatey, which is a Windows PowerShell package manager similar to dpkg or apt-get
                  - Source: https://chocolatey.org/docs/installation
                  - Usage: PowerShell choco install sudo -y
                           PowerShell sudo choco upgrade all -y
                           PowerShell <sudo> choco install <packagename> -y

#>
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                                       [Global Variables]
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
    # This variable is for switching on or off the installation of the Chocolatey package manager
    # Default installation value is set to False. To install Chocolatey, switch the variable to $true
    [bool]$do_Optional_Choco_Install = $false  

    # This variable is to completely disable Cortana - Default is true
    # (* Warning * If issues with search function arise, re-enable Cortana)
    [bool]$disable_Cortana = $true           
    
    # This variable is to determine the type of laptop setup for application installation
    # If this variable is false, then this script will run as normal and only install necessary software and Office 365
    # If this variable is true, then this script will install Engineer software packages as well as the normal Office 365 apps.
    [bool]$is_EngineeringLaptop = $true

    # This variable is the current working directory of this script and all of the associated dependencies that are used for the 
    # installation process.
    [string]$dir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
    if ($dir.Substring($dir.Length - 1, 1) -ne "\") { $dir += "\" }

    # This variable is the name of this script
    [string]$me = $MyInvocation.MyCommand.Name

    # Locations of log and PowerShell transcript files.
    [string]$transcript_file = "$($dir)transcript.txt"
    [string]$log_file = "$($dir)script_log.txt"
# -------------------------------------------------------------------------------------------------------------------------------------
Start-Transcript -Path $transcript_file
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                                          [Function Lists]
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function is used as the downloader/installer for packages

function dl_Install([string]$packageURL, [string]$install_params = "" ) {

    # Pase packagename from URL
    [string]$packageName = $packageURL.Substring($packageURL.LastIndexOf("/") + 1)
    # File path is this script's location\install\
    [string]$dl_location = "$($dir)install\"
    [string]$out_file = "$($dl_location)$($packageName)"

    writeLog "Beginning download and install process of $packageName from $packageURL..."

    # Check to see if the path for the install packages already exists,
    # if not, create it
    if (!(Test-Path -Path $dl_location -PathType Container)) {
        writeLog "$dl_location was not found... creating..."
        New-Item -Path $dl_location -ItemType Directory -Force
        writeLog "$dl_location created."
    }

    # Check if Invoke-Webrequest exists otherwise execute WebClient
    if (Get-Command 'Invoke-Webrequest')
    {
        Invoke-WebRequest $packageURL -OutFile $out_file
        writeLog "Downloading with WebRequest applet..."
    }
    else
    {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($packageURL, $out_file)
        writeLog "Downloading with WebClient..."
    }

    # Begin the installation of the package
    writeLog "Attempting install of $packageName"

    $extension = $out_file.Substring($out_file.LastIndexOf('.') + 1, 3)

    if ($extension.ToUpper() -eq "MSI") {
        try {
            Start-Process 'msiexec.exe' "/i `"$($out_file)`" $($install_params)" -Wait | Out-Null
        }
        catch {
            writeLog "msiexec.exe returned an error $_"
            throw "Aborted msiexec returned $_"
        }
    }
    elseif ($extension.ToUpper() -eq "EXE") {
        try {
            Start-Process -FilePath $out_file -Wait | Out-Null
        }
        catch {
            writeLog "$out_file returned an error $_"
            throw "Aborted $out_file returned &_"
        }
    }
    # Wait for installer to finish
    Start-Sleep -s 35

    # Remove the installer
    Remove-Item -Force $out_file
    writeLog "$out_file installer removed from system."
    writeLog "Process completed."

}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function is used to determine the software packages to be installed based on whether or not this build is an Engineering laptop
# Depends on the value assigned in the global variable $is_EngineeringLaptop
function installApplications {

    if ($is_EngineeringLaptop -eq $true) {

        # If optional install of Chocolatey is approved, this section will install: 
            # Engineering Essentials
            # --------------------------------------------------------------------
            # 01) Chocolatey
            # 02) Adobe Acrobat Reader DC
            # 03) Flash Player Plugin 32.0.0.207
            # 04) Flash Player PPAPI 32.0.0.207
            # 05) Flash Player ActiveX 32.0.0.207
            # 06) Java SE Runtime Environment 8.0.211
            # 07) Mozilla Firefox 67.0.2
            # 08) 7-Zip 19.0
            # 09) WinRAR 5.71
            # 10) Git 2.22.0
            # 11) PuTTY 0.71
            # 12) Windows Mgmt Framework and PowerShell 5.1.14409.20180811
            # 13) Microsoft Visual C++ Redistributable for Visual Studio 2015-2019 14.21.27702.2
            # 14) Python 3.7.3
            # 15) AWS Command Line Interface (Install) 1.16.180
            # 16) VirtualBox 6.0.8
            # 17) Wireshark 3.0.2
            # 18) FileZilla 3.42.1
            # 19) WinPcap 4.1.3.20161116

            # Productive Essentials
            # --------------------------------------------------------------------
            # 01) Office 365 Business 11309.33604
            # 02) Microsoft Teams Desktop App 1.2.00.13765
            # 03) Dropbox 75.3.115
            # 04) TeamViewer 14.3.4730
            # 05) Skype For Business 11107.33602 
            # 06) Microsoft OneNote (Install) 16.0.11629.20246
            # 07) OneDrive 17.3.6798.0207

        if ($do_Optional_Choco_Install -eq $true) {
            # This section of code will trigger UAC elevation prompt, requiring user interaction to continue install process
            InstallChocolatey
            # Install Engineering essentials
            Start-Sleep -s 35
            Start-Process "choco" -ArgumentList "install adobereader flashplayerplugin flashplayerppapi flashplayeractivex jre8 firefox 7zip.install winrar git.install putty powershell vcredist140 python awscli virtualbox wireshark filezilla winpcap -y" -Wait | Out-Null
            # Install Office 365 apps 
            Start-Process "choco" -ArgumentList "install office365business microsoft-teams dropbox teamviewer skypeforbusiness onenote onedrive -y" -Wait | Out-Null

            Start-Sleep -s 35
            # Ensure all packages are up to date
            Start-Process "choco" -ArgumentList "upgrade all -y" -Wait | Out-Null
            break

        }
        # If Chocolatey is not set for install, then this section will install 
        # Engineering Essentials (see above list; versions may vary) through MSI, EXE, or PowerShell methods
        else {
            
            $EngAppURLs = 
                "https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe",
                "https://2.na.dl.wireshark.org/win64/Wireshark-win64-3.0.2.exe",                                                                # Wireshark
                "https://download.virtualbox.org/virtualbox/6.0.8/VirtualBox-6.0.8-130520-Win.exe",                                             # Virtualbox
                "https://download.filezilla-project.org/client/FileZilla_3.42.1_win64_sponsored-setup.exe",                                     # FileZilla FTP
                "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.71-installer.msi",                                               # PuTTy
                "https://www.python.org/ftp/python/3.7.3/python-3.7.3-amd64.exe",                                                               # Pyton 3
                "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi",                                                                             # AWS CLI 
                "https://download.microsoft.com/download/9/B/A/9BAEFFEF-1A68-4102-8CDF-5D28BFFE6A61/PBIDesktop_x64.msi",                        # PowerBl
                "https://github.com/greenshot/greenshot/releases/download/Greenshot-RELEASE-1.2.10.6/Greenshot-INSTALLER-1.2.10.6-RELEASE.exe", # GreenShot
                "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1901220034/AcroRdrDC1901220034_en_US.exe"                                   # Acrobat Reader DC
                
                ForEach ($AppURL in $EngAppURLs) {

                    # ###########################################################################################################
                    # Call download and installation routine
                    # These applications will not be installed silently, so they will take no install parameters by default
                    dl_Install($AppURL)
                    # -----------------------------------------------------------------------------------------------------------
                }
            
        }

    }
  
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function is used to print event logs to the terminal window
function writeLog() {

    param ( 
        [string]$strInfo = ""
    )

    $date = Get-Date
    $logFormat = "$date --- $strInfo"
    
    # Output event info to terminal
    Write-Host $logFormat

    # Append event info to log file
    # Log file located in the same directory as this script.
    Add-Content $log_file "$logFormat`n"
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function validates the presence of necessary registry paths in order to make changes to the system 
# that are consistent with the Laptop Build guide's privacy settings.
function validateRegistryEntry {

    # This variable contains all of the registry paths whose presence must be validated in order to make changes in function "enforcePrivacySettings"
    # To add to this, first add registry path to $regPaths, then add registry key modification in function "enforcePrivacySettings"
    $regPaths = 
        "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto",
        "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation",
        "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting",
        "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots",
        "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location",
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}\SensorPermissionState",
        "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration\Status",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\LetAppsAccessLocation",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocation",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps\AllowUntriggeredNetworkTrafficOnSettingsPage",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps\AutoDownloadAndUpdateMapData",
        "HKLM:\SYSTEM\Maps\AutoUpdateEnabled",
        "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\DoNotTrack",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo",
        "HKLM:\Software\Policies\Microsoft\InputPersonalization\RestrictImplicitInkCollection",
        "HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Preferences\ModelDownloadAllowed",
        "HKLM:\SOFTWARE\Microsoft\Windows\AppPrivacy",
        "HKCU:\SOFTWARE\Microsoft\Siuf\Rules",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\DoNotShowFeedbackNotifications",
        "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent",
        "HKCU:\SOFTWARE\Microsoft\Input\TIPC",
        "HKCU:\Software\Microsoft\Siuf\Rules",
        "HKCU:\SOFTWARE\Microsoft\Personalization\Settings",
        "HKCU:\SOFTWARE\Microsoft\InputPersonalization",
        "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"

        # Loop through library of regPaths and check for existence
        # if not found, then create the registry path for modification.
        ForEach ($regItem in $regPaths) {
            if (!(Test-Path -Path $regItem)) {
                New-Item -Path $regItem -Force | Out-Null  
                writeLog "Added registry path $regItem"             
            }
        }
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will ensure that this device is compliant with Swish privacy settings
function enforcePrivacySettings {

    writeLog "Initializing enforement of Privacy Requirements..."

    validateRegistryEntry                                           # Validate registry paths before writing values

    # Disable services               
        Set-Service WerSvc -StartupType Disabled                    # Disable Windows Error Reporting Service
        Set-Service XblAuthManager -StartupType Disabled            # Disable Xbox Live Auth Manager Service
        Set-Service XblGameSave -StartupType Disabled               # Disable Xbox Live Game Save Service
        Set-Service XboxNetApiSvc -StartupType Disabled             # Disable Xbox Live Networking Service Service
        Set-Service XboxGipSvc -StartupType Disabled                # Disable Xbox Accessory Management Service

            writeLog "Services: DISABLED."
    # ---------------------------------------------------------------------------------------------------------------------------------
    # Disable scheduled tasks
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyMonitor"
        Disable-ScheduledTask -TaskName "\Microsoft\Windows\Feedback\Siuf\DmClient"
    	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
    	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
        Disable-ScheduledTask -TaskName "\Microsoft\XblGameSave\XblGameSaveTask"

            writeLog "Scheduled Tasks: DISABLED."
    # ---------------------------------------------------------------------------------------------------------------------------------
    # Security Settings
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

            writeLog ".NET strong crypto: ENABLED."
    # ---------------------------------------------------------------------------------------------------------------------------------
    # Privacy settings

        # check to see if this script allows for Cortana to be disabled
        # ** if Cortana is disabled, it could cause issues with Windows Search functionality **
        if ($disable_Cortana -eq $true) { 
            DisableCortana 
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation" -Name "Enabled" -Type DWord -Value 0 -Force
            
                writeLog "Cortana disabled from using search location."
        }
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Disable Wi-Fi Sense
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

        if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM")) {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0 -Force
        }
        else {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
        }

        if (!(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\WiFISenseAllowed")) {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0 -Force
        }
        else {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0 -Force
        }
            writeLog "Wi-Fi Sense: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Enable Smart-Screen Filter
        if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen") {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -ErrorAction SilentlyContinue 
        }
        if (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9") {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -ErrorAction SilentlyContinue 
        }

            writeLog "SmartSceen Filter: ENABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
        
        # Disable App Suggestions
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0    
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1

            writeLog "App Suggestions: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Disable Location Tracking
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessLocation" -PropertyType DWORD -Value 0 -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -PropertyType DWORD -Value 0 -Force

            writeLog "Location Tracking: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Turn off unsolicited network traffic on the Offline Maps settings page
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AllowUntriggeredNetworkTrafficOnSettingsPage" -PropertyType DWORD -Value 0 -Force

            writeLog "Unsolicited network traffic in offline maps: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
    
        # Turn off Automatic Download and Update of Map Data
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" -Name "AutoDownloadAndUpdateMapData" -PropertyType DWORD -Value 0 -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0

            writeLog "Automatic download of Map data: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
    
        # Microsoft Edge - Enable Do Not Track in Microsoft Edge
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "DoNotTrack" -PropertyType DWORD -Value 1 -Force

            writeLog "Do not track in Microsoft Edge: ENABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
    
        # ** Turn off the advertising ID
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1

            writeLog "Advertising ID: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Turn of Getting to Know me (Automatic learning)
        New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -PropertyType DWORD -Value 1 -Force
        
            writeLog "Automatic Learning: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Turn off updates to the speech recognition and speech synthesis models
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Preferences" -Name "ModelDownloadAllowed" -PropertyType DWORD -Value 0 -Force
        
            writeLog "Updates to speech recognition and synthesis: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Disallow Windows apps to access account information
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\AppPrivacy" -Name "AppPrivacy" -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessAccountInfo" -PropertyType DWORD -Value 2 -Force
        
            writeLog "Allow apps to access account information: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Disable all feedback and notifications
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1

        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
        Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null

            writeLog "All feedback notifications: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
        
        # Disable Tailored Experiences
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

            writeLog "Tailored Experiences: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------
            
        # Disable inking and typing data sent to Micrsoft
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Input" -Name "TIPC" -Force
        New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Name "Enabled" -PropertyType DWORD -Value 0 -Force

            writeLog "Inking and typing data sent to Microsoft: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

        # Set feedback frequency to 0 - User is never prompted to send data to Microsoft
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -PropertyType DWORD -Value 0 -Force
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -PropertyType DWORD -Value 0 -Force

            writeLog "Prompt user to send data to Microsoft: DISABLED."
        # ---------------------------------------------------------------------------------------------------------------------------------

    writeLog "Privacy Requirements have been enforced."

    # Update group policy after changes
    writeLog "Updating Group Policy..."
    if (Test-Path -path "$env:SystemRoot\System32\gpupdate.exe") { 
        gpupdate.exe /force 
        writeLog "Group Policy updated on local machine."
    } 
    else { 
        writeLog "GPUpdate was not found. Cannot update Group Policy!"
    }
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will disable Cortana
function DisableCortana {  
    writeLog "Disabling Cortana..."

	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1

	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
    
    # Restart Explorer to change it immediately    
    writeLog "Restarting Process Explorer to make changes..."
    Stop-Process -Name explorer

    writeLog "Cortana: DISABLED."
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will install Chocolatey and the sudo command for elevated privileges UAC prompt
function InstallChocolatey {

    writeLog "Chocolatey Package Manager has been selected for installation..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
    Start-Process "choco" -ArgumentList "install sudo -y" -Wait | Out-Null
    writeLog "Chocolatey install complete."

}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will remove bloatware from inital Windows installation
# Additional Apps to be removed can be added by package name to the $AppList library as needed.
function DebloatWindows {

    writeLog "Debloating Windows 10..."

    $AppsList = 
        "Microsoft.3DBuilder",
        "Microsoft.AppConnector",
        "Microsoft.BingFinance",
        "Microsoft.BingNews",
        "Microsoft.BingSports",
        "Microsoft.BingTranslator",
        "Microsoft.BingWeather",
        "Microsoft.CommsPhone",
        "Microsoft.ConnectivityStore",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftPowerBIForWindows",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.MinecraftUWP",
        "Microsoft.NetworkSpeedTest",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.Wallet",
        "Microsoft.WindowsCamera",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsPhone",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.XboxApp",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.XboxIdentityProvider"

    $3rdPartyBloatApps = 
        "2414FC7A.Viber",
        "41038Axilesoft.ACGMediaPlayer",
        "46928bounde.EclipseManager",
        "4DF9E0F8.Netflix",
        "64885BlueEdge.OneCalendar",
        "7EE7776C.LinkedInforWindows",
        "828B5831.HiddenCityMysteryofShadows",
        "89006A2E.AutodeskSketchBook",
        "9E2F88E3.Twitter",
        "A278AB0D.DisneyMagicKingdoms",
        "A278AB0D.MarchofEmpires",
        "ActiproSoftwareLLC.562882FEEB491",
        "AdobeSystemsIncorporated.AdobePhotoshopExpress",
        "CAF9E577.Plex",
        "D52A8D61.FarmVille2CountryEscape",
        "D5EA27B7.Duolingo-LearnLanguagesforFree",
        "DB6EA5DB.CyberLinkMediaSuiteEssentials",
        "DolbyLaboratories.DolbyAccess",
        "Drawboard.DrawboardPDF",
        "Facebook.Facebook",
        "flaregamesGmbH.RoyalRevolt2",
        "GAMELOFTSA.Asphalt8Airborne",
        "KeeperSecurityInc.Keeper",
        "king.com.BubbleWitch3Saga",
        "king.com.CandyCrushSodaSaga",
        "PandoraMediaInc.29680B314EFC2",
        "SpotifyAB.SpotifyMusic",
        "WinZipComputing.WinZipUniversal",
        "XINGAG.XING"


    # Remove Microsoft's Bloatware
	ForEach ($App in $AppsList) {
		$PackageFullName = (Get-AppxPackage $App).PackageFullName
		$ProPackageFullName = (Get-AppxProvisionedPackage -Online | Where-Object {$_.Displayname -eq $App}).PackageName
		Write-Host $PackageFullName
		Write-Host $ProPackageFullName

		if ($PackageFullName) {
			writeLog "Removing Package: $App"
			remove-AppxPackage -Package $PackageFullName
		}
		else {
			writeLog "Unable to find package: $App"
		}
		
		if ($ProPackageFullName) {
			writeLog "Removing Provisioned Package: $ProPackageFullName"
			Remove-AppxProvisionedPackage -Online -packagename $ProPackageFullName
		}
		else {
			writeLog "Unable to find provisioned package: $App"
		}
    }
    
    # Remove 3rd Party Bloatware
    ForEach ($App in $3rdPartyBloatApps) {
		$PackageFullName = (Get-AppxPackage $App).PackageFullName
		$ProPackageFullName = (Get-AppxProvisionedPackage -Online | Where-Object {$_.Displayname -eq $App}).PackageName
		Write-Host $PackageFullName
		Write-Host $ProPackageFullName

		if ($PackageFullName) {
			writeLog "Removing 3rd Party Package: $App"
			remove-AppxPackage -Package $PackageFullName
		}
		else {
			writeLog "Unable to find 3rd Party package: $App"
		}
		
		if ($ProPackageFullName) {
			writeLog "Removing 3rd Party Package: $ProPackageFullName"
			Remove-AppxProvisionedPackage -Online -packagename $ProPackageFullName
		}
		else {
			writeLog "Unable to find 3rd Party package: $App"
		}
	}

}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function is used to generate an elevated command window to run Escalated Privilege Commands
# Any commands need to be called directly from this function"s .RUN section
function elevateCmd {
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

    # Get the security principal for the administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

    # Check to see if we are currently running as an administrator
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        # We are running as an administrator, so change the title and background colour to indicate this
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
        #$Host.UI.RawUI.BackgroundColor = "DarkBlue";
        Clear-Host;
    }
    else {
        # We are not running as an administrator, so relaunch as administrator

        # Create a new process object that starts PowerShell
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

        # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it"s path
        $newProcess.Arguments = "& "" + $script:MyInvocation.MyCommand.Path + """

        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";

        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);

        # Exit from the current, unelevated, process
        Exit;
    }

    # .RUN

    #validateRegistryEntry                                           # This will check for missing registry entries, and if not found, add them ** REQUIRES ELEVATED COMMAND **

    # Update changes to group policy on local machine

    
    Write-Host -NoNewLine "Press any key to continue...";                             
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");    
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will return the environment to Windows security default settings for script execution
function clean_up { writeLog "Returning Windows Script Execution Policy to Default."; Set-ExecutionPolicy Default -Scope Process -Force }
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will prompt for user name and change the computername to the Swish naming convention
function fixUserName {
    ########################################################################################
    ########################################################################################
    $SKUS = "-P", "-T", "-X1", "-20A", "-VM"
    $RECORDS = "Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount"
    $DELIMS = @(" ", ".", "-", "_")

    $sku = ((Get-WmiObject -Namespace root\wmi -Class MS_SystemInformation | Select-Object -ExpandProperty SystemSKU) -as [string])
    $local = (get-localuser | Select-Object Name) 
    $delim = 0

    $ret = ""
    $x = 0; $y = 0
    $space = 0; $words = 1

    $fname = ""; $lname = ""
    $uchars = 0; $upos = @(0 , 0)
    ########################################################################################
    ########################################################################################
    $tmp = ($sku.Substring($sku.IndexOf(' ') + 1))
    $n = $tmp.IndexOf(' ')
    ########################################################################################
    ########################################################################################
    if ($n -gt 0) { $model = $tmp.Substring(0, $n) } 
    else { $model = $tmp }
    ########################################################################################
    ########################################################################################
    # compare the input string against the RECORDS list
    ForEach ($type in $local.Name) {
        if ($RECORDS -notcontains $type) { $ret = $type}    
    } 

    if ($ret.Length -eq 0) { $ret = "Laptop" }
    if ($ret.Substring($ret.Length - 3).ToUpper() -eq "-VM") { 
        $ret = $ret.Substring(0, $ret.Length - 3)
        $model = "VM"
    }
 
    ########################################################################################
    ########################################################################################
    if ($ret.ToUpper() | Select-String -Pattern $SKUS -AllMatches) {
        foreach ($z in $SKUS) {
            $i = $ret.IndexOf($z)
            if ($i -ge 0) {
                $ret = $ret.Substring(0,$i); break
            }
        }
        if ($i -gt 0) { $ret = $ret.Substring(0,$i) }
    }
    ########################################################################################
    ########################################################################################
    do {
        if (($DELIMS | select-string -pattern $ret.Substring(0, 1) -AllMatches) -or
            ($ret.Substring(0, 1) -match "^\d+$")) {
            
            $ret = $ret.Substring(1)  
        }
    }
    while (($DELIMS | select-string -pattern $ret.Substring(0, 1) -AllMatches) -or
            ($ret.Substring(0, 1) -match "^\d+$"))
    ########################################################################################
    ########################################################################################
    do {
        if (($DELIMS | Select-String -Pattern $ret.Substring($ret.Length - 1) -AllMatches) -or
            ($ret.Substring($ret.Length - 1) -match "^\d+$")) {
                
            $ret = $ret.Substring(0, $ret.Length - 1)    
        }
    }
    while (($DELIMS | Select-String -Pattern $ret.Substring($ret.Length - 1) -AllMatches) -or
            ($ret.Substring($ret.Length - 1) -match "^\d+$"))
    ########################################################################################
    ########################################################################################
    # loop through $ret and count how many individual words are present
    foreach ($char in $ret.ToCharArray()) {
        if ($DELIMS | Select-String -Pattern $char) { 
            $space++
            $words = ($space + 1)
            $delim = $DELIMS.IndexOf($("$char"))
           
            $count_char = ($ret.ToCharArray() | Where-Object { $_ -eq $char } | Measure-Object).Count
            
            if ($ret.Contains($char)) {
                if ($count_char -gt 1) {
                    $ret = $ret.Substring(0,$ret.IndexOf($char)) + $ret.Substring($ret.IndexOf($char) + 1)
                }
            }
        }
        
        if (([char]::IsUpper($char -as [char])) -and ($uchars -lt 2) -and ($char -ne $DELIMS)) { 
            $upos[$uchars] = $ret.IndexOf($char) - ($space)
            $uchars++
        }
    }
    ########################################################################################
    ########################################################################################

    # Make sure that there are more than one words
    # If there are more than one words, then there is a 
    # first and last name, so extract those names
    if ($words -ne 1) {
        
            $x = 0
            $y = $ret.IndexOf($DELIMS[$delim]) + 1 
                $fname = $ret.Substring($x, $y) 
            $x = ($ret.LastIndexOf($DELIMS[$delim]) + 1)  
                $lname = $ret.Substring($y)
    
    }
    # If not, don't worry about parsing, just return $ret
    else { $fname = $ret }
    ########################################################################################
    ########################################################################################
    # Format the input strings
    # If last name doesn't exist, split remainder of first name to be formatted
            
    if ($uchars -ne 2) {

        if (($fname.Length -gt 0) -and ($lname.Length -gt 0)) {
            $fl = $fname.Substring(0, 1)
            $ll = $lname.Substring(0, 1)
            $fl = $fl.ToUpper()
            $ll = $ll.ToUpper()
        }
        elseif (($fname.Length -eq 0) -and ($lname.Length -gt 0)) {
            $fl = $lname.Substring(0, 1).ToUpper()
        }
        else { 
            $lname = $fname.Substring(0).ToLower() + ".PC"
            $fl = $fname.Substring(0, 1).ToUpper()
        } 
    }
    elseif (($uchars -eq 2) -and ($words -eq 1)) {
        
        $fl = $fname.Substring($upos[0], 1).ToUpper()
        $ll = $fname.Substring($upos[1], 1).ToUpper()
        
        $lname = $fname.Substring($upos[1])
        $fname = $fname.Substring($upos[0], $upos[1])
    }
    else {
        $fl = $fname.Substring(0, 1)
        $ll = $lname.Substring(0, 1)
        $fl = $fl.ToUpper()
        $ll = $ll.ToUpper()
    }
    ########################################################################################
    ########################################################################################
    $frmt = "$($fl)$($ll)$($lname.Substring(1, $lname.Length - 1).ToLower())-$($model)"

    if ($frmt.Substring(0,3) -eq ".PC") { $frmt = "Laptop$model"}

    try
        {
        # Change the computer name
        if ($frmt -ne $env:COMPUTERNAME) { 
            if ($frmt.Length -gt 15) { $frmt = $frmt.Substring(0, 14) } 
            Rename-Computer -NewName $frmt -Force | Out-Null 
            writeLog "Computer name has been changed to $frmt. This change will not take effect until the machine restarts."
        } 
        else { break }

        # Remove this to have a silent process
           
    }
    catch {
        break
    } 
    ########################################################################################
    ########################################################################################

}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will prompt the user to restart the machine not, or manually restart at a later point
function doRestart {
    $restart = $false
    $choice = "N"

    do {
        $choice = Read-Host -Prompt "Do you want to restart the machine now? (y/n)"
    }
    until ($("Y","N","y","n").Contains($choice))
    

    if ($null -ne $choice -and $choice.Substring(0,1) -eq 'Y') { 
        $restart = $true 
    } 
    elseif ($null -ne $choice -and $choice.Substring(0,1) -eq 'N') { 
        $restart = $false 
    }

    if ($restart -eq $true) { 
        writeLog "Computer will restart now!"
        Restart-Computer -Force
    }
    elseif ($restart -eq $false) {
        writeLog "Some changes will not take effect until a restart has occurred."
    }
    Stop-Transcript
    clean_up
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function will install Nessus and TrendMicro on the System
function setupSecurity {

    writeLog "Attempting to install Nessus and Trend Micro..."
    $nessus = "$($dir)NessusAgent-7.4.1-x64.msi"
    $trendmicro = "$($dir)WFBS-SVC_Agent_Installer.msi"

    if (Test-Path -Path $nessus -PathType Leaf) { 
        #try {
            Start-Process "msiexec.exe"  -ArgumentList "/i `"$($nessus)`" NESSUS_GROUPS=`"Windows Laptops`" NESSUS_SERVER=`"cloud.tenable.com:443`" NESSUS_KEY=fbb19690d22b2ae2a9f6c75fcb9938ec1402cc95277f5607178d087a55a8b3d8 /qn" -Wait | Out-Null
        #}
        #catch {
           # writeLog "NessusAgent-7.4.1-x64.msi returned an error $_"
            #throw "Aborted NessusAgent-7.4.1-x64.msi returned &_"
        #}
    }
    else { writeLog "Nessus-8.4.0-x64.msi was not found! Please manually install Nessus agent!" }

    if (Test-Path -Path $trendmicro -PathType Leaf) { 
       # try {
            Start-Process "msiexec.exe" -ArgumentList "/i `"$($trendmicro)`"" -Wait | Out-Null
      # }
       # catch {
            #writeLog "WFBS-SVC_Agent_Installer.msi returned an error $_"
            #throw "WFBS-SVC_Agent_Installer.msi returned &_"
        #}
    }
    else { writeLog "WFBS-SVC_Agent_Installer.msi was not found! Please manually install Trend Micro Security Agent!" }
    # Wait for installer to finish
    Start-Sleep -s 35
    writeLog "Install procedure has terminated."
}
# -------------------------------------------------------------------------------------------------------------------------------------

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Main run script to call other functions
function Main {

    writeLog "$me is running from directory $dir `n`nSwish Laptop Build script will now begin setting up $env:COMPUTERNAME`n"
    writeLog "Accept the Elevated Command Window to continue..."
    
    fixUserName
    setupSecurity
    DebloatWindows
    enforcePrivacySettings
    installApplications

    writeLog "$me has finished running. Please refer to the $($dir)script_log.txt for further event details."
    writeLog "A verbose transcript has been saved to $transcript_file. Please refer to this for debugging."
    # -------------------------------------------------------------------------------------------------------------------------------------
    doRestart
    
}
# -------------------------------------------------------------------------------------------------------------------------------------
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Main                                        # Main function invokation
# -------------------------------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------------------------------

# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{ 
    Write-Host "Press any key to continue..."
    # Make sure buffered input doesn't "press a key" and skip the ReadKey().
    $Host.UI.RawUI.FlushInputBuffer()                              
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
# -------------------------------------------------------------------------------------------------------------------------------------