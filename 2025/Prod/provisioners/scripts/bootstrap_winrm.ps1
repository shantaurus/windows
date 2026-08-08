<powershell>
# 1. Set local Administrator password to match your Packer variable
$admin = [adsi]"WinNT://./Administrator,user"
$admin.SetPassword("YourKnownAdminPassword123!")

# 2. Quickconfig & Enable Unencrypted Basic Auth for WinRM
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# 3. Open Firewall Port 5985
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM 5985" dir=in action=allow protocol=TCP localport=5985

# 4. Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
</powershell>