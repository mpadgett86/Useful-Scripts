$sku = "((Get-WmiObject -Namespace root\wmi -Class MS_SystemInformation | Select-Object -ExpandProperty SystemSKU) -as [string])"

$z = ($sku.Substring($sku.IndexOf(' ') + 1))
$y = $z.IndexOf(' ')

if ($y -gt 0) {
    $model = $z.Substring(0, $y)
} else { $model = $z }

write-host $model

