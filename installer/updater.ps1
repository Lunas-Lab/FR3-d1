param (
    [Parameter(Mandatory)]
    [int] $HostProcessID
)

do {

} while ($null -ne (Get-Process | Where-Object -Property ID -eq $HostProcessID))

$AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

Move-Item -Path "$AppDataPath\FR3-d1\transcripts" `
    -Destination "$AppDataPath\FR3-d1_updater"
Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
    -OutFile "$PSScriptRoot\base_app.zip" `
    -UseBasicParsing
Expand-Archive -Path "$PSScriptRoot\base_app.zip" `
    -DestinationPath $AppDataPath -Force
Remove-Item -Path "$AppdataPath\FR3-d1" -Recurse -Force
Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1" -Force
Remove-Item -Path "$PSScriptRoot\base_app.zip"
Move-Item -Path "$AppDataPath\FR3-d1_updater\transcripts" `
    -Destination "$AppDataPath\FR3-d1\"

Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$AppDataPath\FR3-d1\FR3-d1.ps1`""

Exit