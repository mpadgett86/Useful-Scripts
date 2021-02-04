<#
    This function can be placed within any PowerShell script and invoked to
    send data back for analysis.

    ** The purpose of this process is to retrieve data such as return codes from a script run.

    ** The reason this is needed is because Intune only tells an Admin
        whether or not a script failed. Unless the Admin has remote or direct
        physical access to the machine, it becomes very difficult to diagnose bugs
        in PowerShell scripts.

#>


function Send-Data ($DataToSend){

 <#   add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy#>

    # Force TLS version
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # $name is to be used as the file name for the data.
    $name = $env:computername                       

    # $date is for log analysis
    $date = Get-Date -format "dd-MMM-yyyy HH:mm"
    
    # $postParams encapsulates data to be send to the server
    $postParams = @{name = $name } + @{date = $date } + @{data = $DataToSend }
    
    # Data is sent to IP:PORT
    Invoke-WebRequest -Uri https://debug-server.localhost/server.php -Method POST -Body $postParams

}

Send-Data "This is some *NEW* test data that represents another Return = 0 Success Code."