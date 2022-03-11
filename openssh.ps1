if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}
echo " "

$host.ui.RawUI.WindowTitle = "OpenSSH Installer by Kiddo"
Set-PSDebug -Off
Write-Host " ____  __.__    .___  .___     " -ForegroundColor magenta
Write-Host "|   |/ _|__| __| _/__| _/____  " -ForegroundColor magenta
Write-Host "|     < |  |/ __ |/ __ |/  _ \ " -ForegroundColor magenta
Write-Host "|   |  \|  / /_/ / /_/ (  <_> )" -ForegroundColor magenta
Write-Host "|___|__ \__\____ \____ |\____/ " -ForegroundColor magenta
Write-Host "        \/       \/    \/      " -ForegroundColor magenta
echo " "
Write-Host "Info: Running as Adminstrator..." -ForegroundColor red
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗"
Write-Host "║       OpenSSH Installer for Shutdown-on-LAN         ║"
Write-Host "║                    Author: Kiddo                    ║"
Write-Host "║                 Discord: @Kiddo#1600                ║"    
Write-Host "╠═════════════════════════════════════════════════════╣" 
Write-Host "║       Press Enter to start the installation!        ║"
Write-Host "╚═════════════════════════════════════════════════════╝"
pause

##Stages

#Stage 1: Download
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor darkgreen
Write-Host "║                Required file retrieval              ║" -ForegroundColor darkgreen
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor darkgreen
Write-Host "Downloading... " -NoNewline
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
$request = [System.Net.WebRequest]::Create($url)
$request.AllowAutoRedirect=$false
$response=$request.GetResponse()
$source = $([String]$response.GetResponseHeader("Location")).Replace('tag','download') + '/OpenSSH-Win64.zip'
$webClient = [System.Net.WebClient]::new()
$webClient.DownloadFile($source, (Get-Location).Path + '\OpenSSH-Win64.zip')
Write-Host "Done! " -ForegroundColor yellow

#Stage 2: Validate
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor darkgreen
Write-Host "║                      Validation                     ║" -ForegroundColor darkgreen
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor darkgreen
Get-ChildItem *.zip

#Stage 3: Install
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor darkgreen
Write-Host "║                     Installation                    ║" -ForegroundColor darkgreen
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor darkgreen
Write-Host "Installing..."
Expand-Archive -Path .\OpenSSH-Win64.zip -DestinationPath ($env:temp) -Force
Move-Item "$($env:temp)\OpenSSH-Win64" -Destination "C:\Program Files\OpenSSH\" -Force
Get-ChildItem -Path "C:\Program Files\OpenSSH\" | Unblock-File
& 'C:\Program Files\OpenSSH\install-sshd.ps1'
Write-Host "Installation done!" -ForegroundColor yellow

#Stage 4: Firewall rules register
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor darkgreen
Write-Host "║  Inbound and Outbound Firewall rules registration   ║" -ForegroundColor darkgreen
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor darkgreen
Write-Host "Rules registering..."
New-NetFirewallRule -Name sshd -DisplayName 'Allow SSH' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
Write-Host "Success!" -ForegroundColor yellow

#Stage 5: Daemon setup
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor darkgreen
Write-Host "║      OpenSSH Daemon startup && Autorun setup        ║" -ForegroundColor darkgreen
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor darkgreen
Write-Host "Starting OpenSSH service... " -NoNewline
Start-Service sshd
Write-Host "Success!" -ForegroundColor yellow
Write-Host "Telling OpenSSH service to automatically start itself... " -NoNewline
Set-Service sshd -StartupType Automatic
Write-Host "Success!" -ForegroundColor yellow

#Stage 6: Finished
echo " "
Write-Host "╔═════════════════════════════════════════════════════╗" -ForegroundColor DarkYellow
Write-Host "║      All finished! Now have some information!       ║" -ForegroundColor DarkYellow
Write-Host "╚═════════════════════════════════════════════════════╝" -ForegroundColor DarkYellow

Write-Host "Your OpenSSH username is: " -NoNewline
$usr = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Host "$usr" -ForegroundColor yellow 
Write-Host "Your OpenSSH password is the same with your system password!" -ForegroundColor red
$ip = (Test-Connection -ComputerName (hostname) -Count 1).IPV4Address.IPAddressToString
Write-Host "Your OpenSSH Host IP is: " -ForegroundColor white -NoNewline
Write-Host "$ip" -ForegroundColor yellow
Write-Host "OpenSSH listening port is 22!" -ForegroundColor red

echo " "
echo " "
Write-Host "OpenSSH installation succeeded!" -ForegroundColor DarkGreen

pause
