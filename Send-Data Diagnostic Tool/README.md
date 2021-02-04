The purpose of this implementation is to make it easier for an Azure/Intune Admin to diagnose
failures or successes from deployed PowerShell scripts.

This is a basic proof of concept - encryption or other security measures should be taken to 
secure this process.

* SEND-PHP.ps1 contains the function Send-Data($DataToSend)
--- This function can be placed in any PowerShell script that needs to be tested via Intune.
--- $DataToSend will be sent back to the Azure/Intune Admin for analysis.

* server.php resides on a Linux box with PHP installed.
--- server.php is placed within <DIRECTORY>
--- The command "sudo php -t <DIRECTORY> -S <IP>:<PORT>" is issued.
--- The server listens for a connection and when one is made from the PowerShell function,
    PHP logs the connection, and the server.php file takes the data and appends it to a log
    file denoted as the USERNAME.txt
