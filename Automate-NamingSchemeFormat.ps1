# This script automates the process of formating a computer name
# USE:
# For SCCM/Intune deployment to enforce a naming scheme across an AD

function fixUserName {

    $sku = ((Get-WmiObject -Namespace root\wmi -Class MS_SystemInformation | Select-Object -ExpandProperty SystemSKU) -as [string])
    $local = (get-localuser | Select-Object Name)       
    $RECORDS = "Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount"

    $ret = ""
    $x = 0; $y = 0
    $space = 0; $words = 0

    $fname = ""; $lname = ""

    $tmp = ($sku.Substring($sku.IndexOf(' ') + 1))
    $n = $tmp.IndexOf(' ')

    if ($n -gt 0) { $model = $tmp.Substring(0, $n) } 
    else { $model = $tmp }
    
    # compare the input string against the RECORDS list
    ForEach ($type in $local.Name) {
        if ($RECORDS -notcontains $type) { $ret = $type }    }

    # loop through $ret and count how many individual words are present
    foreach ($char in $ret.ToCharArray()) {
        if ($char -match " ") { $space++; $words = ($space + 1) }    }
    

    # Make sure that there are more than one words
    # If there are more than one words, then there is a 
    # first and last name, so extract those names
    if ($words -gt 1) {
        
        $x = 0
        $y = $ret.IndexOf(" ")
        $fname = $ret.Substring($x, $y)

        $x = ($ret.LastIndexOf(" ") + 1)
        $lname = $ret.Substring($x)

    }
    # If not, don't worry about parsing, just return $ret
    else { $fname = $ret }

    # Format the input strings
    # If last name doesn't exist, split remainder of first name to be formatted
    if ($lname.Length -eq 0) { $lname = $fname.Substring(1, $fname.Length - 1) + ".PC" }
        
    $fl = $fname.Substring(0, 1)
    $ll = $lname.Substring(0, 1)
    $fl = $fl.ToUpper()
    $ll = $ll.ToUpper()

    # Computer name format FLast-Model#
    # e.g. John Doe model 12345 = JDoe-1234
    $frmt = "$($fl)$($ll)$($lname.Substring(1, $lname.Length - 1))-$($model)"

    # Change the computer name
    Rename-Computer -NewName $frmt -Force | Out-Null

    # Remove this to have a silent process
    write-host "Computer name has been changed to $frmt. This change will not take effect until the machine restarts."    

}