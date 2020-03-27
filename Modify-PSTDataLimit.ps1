# This script will increase the size limit of the Outlook PST file.
# Users who reach the default limit will not be able to sync new messages
# without first deleting older messages.

# Change Max Size to 80 GB.
cmd.exe /c "reg add `"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\PST`" /v MaxLargeFileSize /t REG_DWORD /d 81920 /f"

# Warn user at 77 GB that they are about to run out of PST storage space.
cmd.exe /c "reg add `"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\PST`" /v WarnLargeFileSize /t REG_DWORD /d 77824 /f"
