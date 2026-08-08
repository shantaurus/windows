<powershell>
# Enable WinRM HTTP Listener & Allow Unencrypted Auth (for Packer setup)
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Open Windows Firewall for WinRM HTTP (5985)
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh advfirewall firewall add rule name="WinRM 5985" dir=in action=allow protocol=TCP localport=5985

# Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
</powershell>