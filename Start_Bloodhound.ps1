Start-Process python -ArgumentList "C:\Users\Administrator\AppData\Local\Temp\Modified_DBCreator.py" -Wait; 

Start-Process -FilePath "C:\Bloodhound\BloodHound-win32-x64\BloodHound.exe";
Start-Sleep 10
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("BloodHound")
Add-Type -AssemblyName System.Windows.Forms
Start-Sleep 4
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
