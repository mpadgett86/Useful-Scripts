# This script will add the necessary registry entry to allow camera use via Skype/Teams/etc.

cmd.exe /c "reg add `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Media Foundation\Platform`" /v EnableFrameServerMode /t REG_DWORD /d 0 /f"