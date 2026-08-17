# 1. Reset EC2Launch v2 so UserData executes on every future instance launch
$ec2launch = "C:\Program Files\Amazon\EC2Launch\EC2Launch.exe"

if (Test-Path $ec2launch) {
    Write-Output "Configuring EC2Launch v2 to run UserData on next boot..."
    
    # Reset EC2Launch state (ensures user-data / bootstrap scripts fire again)
    & $ec2launch reset --clean
    
    # Execute EC2Launch Sysprep workflow
    & $ec2launch sysprep
} else {
    Write-Output "EC2Launch v2 executable not found, falling back to standard Sysprep..."
    
    # Fallback standard sysprep
    & C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown /quiet
}