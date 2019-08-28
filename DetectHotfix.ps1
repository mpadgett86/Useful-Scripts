# The purpose of this script is to check a remote system via MDM deployment,
# to determine if security hotfixes are found on a system.

# Useful as a detection script when deploying hotfixes via Intune.

# Return 0 if true, return 1 if false.

# Append hotfixes ids to list
$hotfixes = 
    "KB4511553",
    "KB4511553"

# Loop through list and check if hotfix is present
foreach ($fix in $hotfixes) {
    if (get-hotfix -id $fix) { return 0 } else { return 1 }
}
