<powershell>
# 1. Set local Administrator password to match your Packer variable
$admin = [adsi]"WinNT://./Administrator,user"
$admin.SetPassword("YourKnownAdminPassword123!")

# 2. Quickconfig & Enable Unencrypted Basic Auth for WinRM
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'

# 3. Open Firewall Port 5985
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM 5985" dir=in action=allow protocol=TCP localport=5985

# 4. Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force

# 5. Prevent registry hive unload during long WinRM Ansible updates
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "System" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableForceUnload" -Value 1 -Type DWord

# 6. Restart WinRM service to apply configuration updates
Restart-Service WinRM
</powershell>