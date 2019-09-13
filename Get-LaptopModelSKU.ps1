# Works for Lenovo ThinkPad devices

$sku = ((Get-WmiObject -Namespace root\wmi -Class MS_SystemInformation | Select-Object -ExpandProperty SystemSKU) -as [string])

$tmp = ($sku.Substring($sku.IndexOf(' ') + 1))
$n = $tmp.IndexOf(' ')

if ($n -gt 0) {
    $model = $tmp.Substring(0, $n)
} 
else { $model = $tmp }

write-host $model
