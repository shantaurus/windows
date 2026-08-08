# Run Sysprep for EC2Launch v2 / v1
if (Test-Path "C:\Program Files\Amazon\EC2Launchv2\EC2Launch.exe") {
    & "C:\Program Files\Amazon\EC2Launchv2\EC2Launch.exe" reset
    & "C:\Program Files\Amazon\EC2Launchv2\EC2Launch.exe" sysprep
} else {
    Start-Process -FilePath "C:\Windows\System32\Sysprep\Sysprep.exe" -ArgumentList "/generalize /oobe /quiet /quit" -Wait
}