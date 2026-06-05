# ===== THONG TIN NGUOI DUNG =====

$fullName = "__FULLNAME__"

$department = "__DEPARTMENT__"

# ===== WINDOWS =====

$os = Get-CimInstance Win32_OperatingSystem

# ===== CPU =====

$cpuInfo = Get-CimInstance Win32_Processor

$cpu = $cpuInfo.Name.Trim()

$core = $cpuInfo.NumberOfCores

$thread = $cpuInfo.NumberOfLogicalProcessors

# ===== RAM =====

$ram = [math]::Round(
(
Get-CimInstance Win32_ComputerSystem
).TotalPhysicalMemory / 1GB,
2
)

# ===== O CUNG =====

$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

$diskTotal = [math]::Round(
$disk.Size / 1GB,
2
)

$diskFree = [math]::Round(
$disk.FreeSpace / 1GB,
2
)

# ===== LOAI O CUNG =====

try {
$diskType = (
Get-PhysicalDisk |
Select-Object -First 1
).MediaType
}
catch {
$diskType = "Unknown"
}

# ===== MODEL & SERIAL =====

$product = Get-CimInstance Win32_ComputerSystemProduct

$model = $product.Name

$serial = $product.IdentifyingNumber

# ===== MAINBOARD =====

$mainboard = (
Get-CimInstance Win32_BaseBoard
).Product

# ===== IP =====

$ip = (
Get-NetIPAddress |
Where-Object {
$_.AddressFamily -eq "IPv4" -and
$_.IPAddress -notlike "169.*"
} |
Select-Object -First 1
).IPAddress

# ===== MAC =====

$mac = (
Get-NetAdapter |
Where-Object { $_.Status -eq "Up" } |
Select-Object -First 1
).MacAddress

# ===== LICENSE =====

$license = Get-CimInstance SoftwareLicensingProduct |
Where-Object {
$_.PartialProductKey -and
$_.Name -like "*Windows*"
} |
Select-Object -First 1

if ($license.LicenseStatus -eq 1) {
$licenseStatus = "Activated"
}
else {
$licenseStatus = "Not Activated"
}

$licenseChannel = $license.Description

$productKey = $license.PartialProductKey

$kmsServer = (
Get-ItemProperty `    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"`
-ErrorAction SilentlyContinue
).KeyManagementServiceName

if ($licenseChannel -match "OEM") {
$licenseType = "OEM"
}
elseif ($licenseChannel -match "Retail") {
$licenseType = "Retail"
}
elseif ($licenseChannel -match "MAK") {
$licenseType = "MAK"
}
elseif ($licenseChannel -match "KMS") {
$licenseType = "KMS"
}
else {
$licenseType = "Unknown"
}

if (
$licenseType -eq "OEM" -and
[string]::IsNullOrEmpty($kmsServer)
) {
$licenseAssessment = "OEM Hop Le"
}
elseif (
$licenseType -eq "Retail" -and
[string]::IsNullOrEmpty($kmsServer)
) {
$licenseAssessment = "Retail Hop Le"
}
elseif ($licenseType -eq "MAK") {
$licenseAssessment = "MAK Hop Le"
}
elseif ($licenseType -eq "KMS") {
$licenseAssessment = "KMS"
}
else {
$licenseAssessment = "Can Kiem Tra"
}

# ===== JSON =====

$data = @{

fullName = $fullName

department = $department

computerName = $env:COMPUTERNAME

model = $model

serial = $serial

mainboard = $mainboard

windows = $os.Caption

cpu = $cpu

core = $core

thread = $thread

ram = $ram

disk = $diskTotal

free = $diskFree

diskType = $diskType

licenseStatus = $licenseStatus

licenseType = $licenseType

licenseChannel = $licenseChannel

productKey = $productKey

kmsServer = $kmsServer

licenseAssessment = $licenseAssessment

ip = $ip

mac = $mac

}

$json = $data | ConvertTo-Json

$json

# ===== GUI VE SERVER =====

Invoke-RestMethod `
    -Uri "https://script.google.com/macros/s/AKfycbw_eiRsYKCvGJ103gFnvGLu_NEPd-zgDZPh1TjW1O1HkR56W6nLmc3E2rDms5KAWJ0O/exec" `
    -Method Post `
    -Body $json `
    -ContentType "application/json"

Write-Host ""
Write-Host "=================================="
Write-Host "DA GUI THANH CONG"
Write-Host "=================================="

Pause
