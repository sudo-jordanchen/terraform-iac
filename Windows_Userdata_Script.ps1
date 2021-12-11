# Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force

# Define TEMP
$LocalTempDir = $env:TEMP; 

# Install Chrome because IE suck
$ChromeInstaller = "ChromeInstaller.exe"; (new-object System.Net.WebClient).DownloadFile("http://dl.google.com/chrome/install/375.126/chrome_installer.exe", "$LocalTempDir\$ChromeInstaller"); 

& "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; 

Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

# Download all the various programs needed
# Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; IEX ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

# Bloodhound
choco install python --version=3.9.9 -y;
choco install jre8 neo4j-community -y;

$NodeJS_Installer = "node-v16.13.1-x64.msi"; 
(new-object System.Net.WebClient).DownloadFile("https://nodejs.org/dist/v16.13.1/node-v16.13.1-x64.msi", "$LocalTempDir\$NodeJS_Installer") 

Start-Process $LocalTempDir\$NodeJS_Installer -Wait -ArgumentList "/qn"

# Check whether the installation of NodeJS is done
Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$NodeJS_Installer" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

# Install git
$GitInstaller = "Git-2.34.1-64-bit.exe"; 
(new-object System.Net.WebClient).DownloadFile("https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe", "$LocalTempDir\$GitInstaller"); & "$LocalTempDir\$GitInstaller" /VERYSILENT /NORESTART; 

$Process2Monitor =  "Git-2.34.1-64-bit.exe"; 

# Check whether the installation is done
Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$GitInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

$env:Path += ";C:\Program Files\Git\bin;C:\Program Files\nodejs;C:\Python39;C:\Python39\Scripts"

# Execute commands to install electron-packager
Start-Process npm "install -g electron-package" -Wait;
if (Get-Command electron-package -errorAction SilentlyContinue) {
    $electron_version = (electron-package -v)
}

$Bloodhound_Script = "Start_Bloodhound.ps1"; 
(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/sudo-jordanchen/terraform-iac/main/Start_Bloodhound.ps1", "$LocalTempDir\$Bloodhound_Script"); 

$DB_Creator = "Modified_DBCreator.py"; 
(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/sudo-jordanchen/terraform-iac/main/Create_DB/Modified_DBCreator.py", "$LocalTempDir\$DB_Creator"); 

$first_kpl = "first.pkl"; 
(new-object System.Net.WebClient).DownloadFile("https://github.com/sudo-jordanchen/terraform-iac/raw/main/Create_DB/first.pkl", "$LocalTempDir\$first_kpl"); 

$last_kpl = "last.pkl"; 
(new-object System.Net.WebClient).DownloadFile("https://github.com/sudo-jordanchen/terraform-iac/raw/main/Create_DB/last.pkl", "$LocalTempDir\$last_kpl"); 

Start-Process pip -ArgumentList "install neo4j" -Wait; 
Start-Process pip -ArgumentList "install selenium" -Wait;
Start-Process pip -ArgumentList "install chromedriver-binary-auto" -Wait;

$change_default_password_script = "Change_Default_Neo4j_Pw.py"; 
(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/sudo-jordanchen/terraform-iac/main/Change_Default_Neo4j_Pw.py", "$LocalTempDir\$change_default_password_script"); 

Start-Process python -ArgumentList "$LocalTempDir\$change_default_password_script" -Wait; 

[system.io.directory]::CreateDirectory("C:\Bloodhound");
[system.io.directory]::CreateDirectory("C:\ZipFolder");

$Url = "https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.3/BloodHound-win32-x64.zip";
$ZipFile = "C:\ZipFolder\" + $(Split-Path -Path $Url -Leaf);
$Destination= "C:\Bloodhound";

(new-object System.Net.WebClient).DownloadFile($Url, "$ZipFile");

$ExtractShell = New-Object -ComObject Shell.Application;
$Files = $ExtractShell.Namespace($ZipFile).Items();
$ExtractShell.NameSpace($Destination).CopyHere($Files); 

Remove-Item "C:\ZipFolder" -Recurse -Force -Confirm:$false;

Write-Host "First scheduled task";
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\Users\Administrator\AppData\Local\Temp\Start_Bloodhound.ps1";

$trigger =  New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(5));

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Bloodhound" -Description "Run Bloodhound Script";

Write-Host "Second scheduled task";
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\Users\Administrator\AppData\Local\Temp\Start_Bloodhound.ps1";

$trigger2 =  New-ScheduledTaskTrigger -Once -At LogOn -User "Administrator";

Register-ScheduledTask -Action $action2 -Trigger $trigger2 -TaskName "Bloodhound Log On" -Description "Run Bloodhound Script [On log on][Backup]";

# EC2 Script output here: C:\ProgramData\Amazon\EC2-Windows\Launch\Log\UserdataExecution.log

Write-Host "Script has completed running";