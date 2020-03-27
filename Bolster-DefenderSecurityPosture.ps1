# This script will turn on Windows Defender Application Guard, and;
# Enable Controlled Folder Access for Windows Defender, to protect against Ransomware.

Enable-WindowsOptionalFeature -online -FeatureName Windows-Defender-ApplicationGuard
Set-MpPreference -EnableControlledFolderAccess Enabled