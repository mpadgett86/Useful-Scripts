$ErrorActionPreference = 'SilentlyContinue'

if ((Test-Path -LiteralPath "C:\Windows\System32\msxml4.dll") -eq $true) { 
    cmd.exe /c "regsvr32.exe /u C:\Windows\System32\msxml4.dll"
    cmd.exe /c "MsiExec.exe /uninstall {716E0306-8318-4364-8B8F-0CC4E9376BAC} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {A9CF9052-F4A0-475D-A00F-A8388C62DD63} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {37477865-A3F1-4772-AD43-AAFC6BCFF99F} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {C04E32E0-0416-434D-AFB9-6969D703A9EF} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {86493ADD-824D-4B8E-BD72-8C5DCDC52A71} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {F662A8E6-F4DC-41A2-901E-8C11F044BDEC} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {196467F1-C11F-4F76-858B-5812ADC83B94} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {859DFA95-E4A6-48CD-B88E-A3E483E89B44} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {355B5AC0-CEEE-42C5-AD4D-7F3CFD806C36} /quiet"
    cmd.exe /c "MsiExec.exe /uninstall {1D95BA90-F4F8-47EC-A882-441C99D30C1E} /quiet"
    cmd.exe /c "del /f C:\Windows\System32\msxml4.dll"
    cmd.exe /c "del /f C:\Windows\System32\msxml4.inf"
    cmd.exe /c "del /f C:\Windows\System32\msxml4a.dll"
    cmd.exe /c "del /f C:\Windows\System32\msxml4r.dll"
}
else {
    return 
}

$ErrorActionPreference = 'Continue'