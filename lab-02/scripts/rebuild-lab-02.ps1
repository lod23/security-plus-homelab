# Lab 1.2 - Change Management: disable RDP, verify, roll back
# Run as Administrator on any Windows VM

Write-Host "=== BASELINE ===" -ForegroundColor Cyan
Get-NetFirewallRule -DisplayGroup "Remote Desktop" |
    Select DisplayName,Enabled,Direction,Action
Test-NetConnection -ComputerName localhost -Port 3389 |
    Select ComputerName,RemotePort,TcpTestSucceeded

Write-Host "=== CHANGE: disabling RDP rules ===" -ForegroundColor Yellow
Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Disable-NetFirewallRule

Write-Host "=== VERIFY: expect TcpTestSucceeded False ===" -ForegroundColor Cyan
Test-NetConnection -ComputerName localhost -Port 3389 |
    Select ComputerName,RemotePort,PingSucceeded,TcpTestSucceeded

Read-Host "Press Enter to roll back"

Write-Host "=== ROLLBACK ===" -ForegroundColor Green
Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Enable-NetFirewallRule

Write-Host "=== VERIFY ROLLBACK: expect True ===" -ForegroundColor Cyan
Test-NetConnection -ComputerName localhost -Port 3389 |
    Select ComputerName,RemotePort,TcpTestSucceeded
