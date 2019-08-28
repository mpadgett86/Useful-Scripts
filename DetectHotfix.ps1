# The purpose of this script is to check a remote system via MDM deployment,
# to determine if security hotfixes are found on a system.
# Return 1 if found, return 0 if not present.

# Append hotfixes ids to list
$hotfixes = 
    "KB4511553",
    "KB4511553"

# Loop through list and check if hotfix is present
foreach ($fix in $hotfixes) {
    if (get-hotfix -id $fix) { return 1 } else { return 0 }
}
