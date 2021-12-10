$LocalTempDir = $env:TEMP; 
$DB_Creator = "Modified_DBCreator.py";

Start-Process python -ArgumentList "$LocalTempDir\$DB_Creator" -Wait; 

Start-Process -FilePath "C:\Bloodhound\BloodHound-win32-x64\BloodHound.exe";
Start-Sleep 5
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("BloodHound")
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait('{TAB}')
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait('{TAB}')
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait('neo4j')
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait('{TAB}')
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait('neo4jj')
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
