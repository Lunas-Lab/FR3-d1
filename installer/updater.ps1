param (
    [Parameter(Mandatory)]
    [int] $HostProcessID
)

do {

} while ($null -ne (Get-Process | Where-Object -Property ID -eq $HostProcessID))

$AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

Write-Host "Saving transcript folder..."
Move-Item -Path "$AppDataPath\FR3-d1\transcripts" `
    -Destination "$AppDataPath\FR3-d1_updater"

Write-Host "Downloading update..."
Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
    -OutFile "$PSScriptRoot\base_app.zip" `
    -UseBasicParsing

Write-Host "Extracting update..."
Expand-Archive -Path "$PSScriptRoot\base_app.zip" `
    -DestinationPath $AppDataPath -Force

Write-Host "Installing update..."
Remove-Item -Path "$AppdataPath\FR3-d1" -Recurse -Force
Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1" -Force

Write-Host "Cleaning up install..."
Remove-Item -Path "$PSScriptRoot\base_app.zip"

Write-Host "Restoring transcripts folder..."
Move-Item -Path "$AppDataPath\FR3-d1_updater\transcripts" `
    -Destination "$AppDataPath\FR3-d1\"

Write-Host "Returning to main Fr3-d1 program..."
Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$AppDataPath\FR3-d1\FR3-d1.ps1`""

Exit