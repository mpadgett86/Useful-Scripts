$local = (get-localuser | Select-Object Name)       # pipe the output of Get-LocalUser and select Name object
$RECORDS = "Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount"

$ret = ""

$x = 0
$y = 0

$space = 0
$words = 0
$char = ""

$fname = ""
$lname = ""

ForEach ($type in $local.Name) {
    if ($RECORDS -notcontains $type) { $ret = $type}    }

foreach ($char in $ret.ToCharArray()) {
    if ($char -match " ") { $space++; $words = ($space + 1)}    }
    

if ($words -gt 1) {
    
    $x = 0
    $y = $ret.IndexOf(" ")
    $fname = $ret.Substring($x, $y)

    $x = ($ret.LastIndexOf(" ") + 1)
    $lname = $ret.Substring($x)
} else { $fname = $ret }


write-host $fname
write-host $lname















<#$getPOS = ($tmp.indexof("Guest") + 6)               # find the position of Guest, which is the last record before 
                                                    # the local user record

$tmp = $tmp.substring($getPOS)                      # remove the Administrator, DefaultAccount, and Guest account records
                                                    # from the string

$parse_fpos = $rem.IndexOf(" ")                     # find the space between first and last name
$tmp = $tmp.Substring($parse_fpos + 1)              # change tmp = the beginning of last name
$parse_lpos = $tmp.IndexOf(" ")                     # See if anything else is after the last name

$fname = $rem.Substring(0, $parse_fpos)             # first name is from the start of the string 
                                                    # until the position of the first " " character
$lname = ""                                         # void

if ($parse_lpos -gt 0) {                            # if there is a space after the last name, then
    $lname = $tmp.Substring(0, $parse_lpos)         # extract the last name before the next record entry
} else { $lname = $tmp }                            # if there is nothing after, then set the last name without parsing.


Write-Host $fname                                   # output the first name
Write-Host $lname                                   # output the last name#>