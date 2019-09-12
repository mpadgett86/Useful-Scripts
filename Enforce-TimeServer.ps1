# This script will enforce the NIST 800-171 AU-8(1) Requirement of Synchronizing with time server: time.nist.gov (192.43.244.18)

$setval = "2"                               # 2 represents the default key name in windows 10, could be different if user has modified
$setstr = "time.nist.gov"                   # this is the main time server specified in 800-171 AU-8(1)
$found = 0                                  # void
$count = 0                                  # void

$key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"
$get_dval = (get-itemproperty -literalpath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers")."(Default)" # return the default key value

# if the default value is not equal to the time.nist.gov time server, then
if ($get_dval -ne $setstr) {
    $RegKey = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers')

    # create an object of RegKey and loop through each object
    $RegKey.PSObject.Properties | ForEach-Object {


        $name = $_.Name                     # reg key name
        $value = $_.Value                   # reg key value

        # if the returned key value is equal to the time server then
        #change the key to change (default) to and set found to true
        if ($value -eq $setstr) { 
            $setval = $name
            $found = 1 
        } 

        $count++                            # count the number of times looped. 
                                            # based on the PSObject implementation and the (Default) reg key,
                                            # there will be 6 erroneous objects, so count = (count - 6)
    }
}

    # if the time server was not found in the registry, then create the key
    if ($found -eq 0) {

        $count = (($count - 6) + 1)         # remove the erroneous PSObjects from the count
        $setval = "$count"                  # the new key name will be the correct count
        # Create the registry key with the correct name and data
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" -Name "$setval" -Type String -Value "$setstr" -Force

    }



# set the default time server to the correct key value
cmd.exe /c "reg add `"$key`" /ve /d $setval /f"
# update the registry
cmd.exe /c "rundll32.exe user32.dll, UpdatePerUserSystemParameters"

cmd.exe /c "sc stop W32Time"                # stop the time service in windows
cmd.exe /c "w32tm /register"                # register the time server
cmd.exe /c "sc start W32Time"               # start the time service in windows

# manually update the time server in the Control Panel > Date and Time > Internet Time > Internet Time Settings
cmd.exe /c "w32tm /config /update /manualpeerlist:`"time.nist.gov`""