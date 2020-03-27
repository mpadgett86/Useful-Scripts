# This script will enforce NIST 800-171 AC-11(1) Pattern Hiding Displays

# Set the screen saver to Mystify -- can be changed to other graphics if needed.
cmd.exe /c "reg add `"HKEY_CURRENT_USER\Control Panel\Desktop`" /v SCRNSAVE.EXE /t REG_SZ /d C:\Windows\system32\Mystify.scr /f"

# Set the screen saver timeout to 10 minutes
cmd.exe /c "reg add `"HKEY_CURRENT_USER\Control Panel\Desktop`" /v ScreenSaveTimeOut /t REG_SZ /d 600 /f"

# Set the screen saver to not prompt for user login after wake up
cmd.exe /c "reg add `"HKEY_CURRENT_USER\Control Panel\Desktop`" /v ScreenSaverIsSecure /t REG_SZ /d 0 /f"

# Prevent user from disabling the screen saver
cmd.exe /c "reg add `"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System`" /v NoDispScrSavPage /t REG_DWORD /d 1 /f"

# Refresh the registry with the new settings
cmd.exe /c "rundll32.exe user32.dll, UpdatePerUserSystemParameters"