function Get-BaseAppFiles {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Write-Host "Downloading repository..."
    Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
        -OutFile "$PSScriptRoot\base_app.zip" `
        -UseBasicParsing

    Write-Host "Extracting repository..."
    Expand-Archive -Path "$PSScriptRoot\base_app.zip" `
        -DestinationPath $AppDataPath -Force

    Write-Host "Cleaning up..."
    Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1" -Force

    Remove-Item -Path "$PSScriptRoot\base_app.zip"

}

function Get-Transcripts {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')
    
    Write-Host "Downloading transcripts..."
    Invoke-WebRequest -Uri "https://github.com/ghostwires/transcripts/archive/refs/heads/main.zip" `
        -OutFile "$PSScriptRoot\transcript_repo.zip" `
        -UseBasicParsing
    
    Write-Host "Extracting transcripts"
    Expand-Archive -Path "$PSScriptRoot\transcript_repo.zip" `
        -DestinationPath "$PSScriptRoot"

    Write-Host "Installing transcripts"
    Copy-item -Path "$PSScriptRoot\transcripts-main\_posts" -Recurse `
        -Destination "$AppDataPath\FR3-d1\transcripts"

    Write-Host "Filtering out non-Magnus Protocol transcripts"
    Get-ChildItem -Path "$AppDataPath\FR3-d1\transcripts" |
    ForEach-Object {
        if (($_.Name -notmatch "\d{4}-\d{2}-\d{2}-\d{3}\.md") `
                -or (($_ | Get-Content -Raw) -notmatch "categories:.*tmagp.*")) {
            Remove-Item "$AppDataPath\FR3-d1\transcripts\$($_.Name)" -Force
        }
    }
    
    Write-Host "Cleaning up..."
    Remove-Item -Path "$PSScriptRoot\transcript_repo.zip", "$PSScriptRoot\transcripts-main" -Recurse -Force
}

function Install-Shortcuts {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')
    
    Write-Host "Creating Desktop shortcut..."
    $WScriptShell = New-Object -ComObject WScript.Shell
    $DesktopShortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\FR3-d1.lnk")
    $DesktopShortcut.TargetPath = "$AppDataPath\FR3-d1\FR3-d1.bat"
    $DesktopShortcut.WorkingDirectory = "$AppDataPath\FR3-d1\"
    $DesktopShortcut.IconLocation = "$AppDataPath\FR3-d1\installer\Angel.ico, 0"
    $DesktopShortcut.Description = "Launch FR3-d1"
    $DesktopShortcut.Save()

    Write-Host "Creating Start Menu shortcut..."
    $StartMenuShortcut = $WScriptShell.CreateShortcut("$env:AppData\Microsoft\Windows\Start Menu\Programs\FR3-d1.lnk")
    $StartMenuShortcut.TargetPath = "$AppDataPath\FR3-d1\FR3-d1.bat"
    $StartMenuShortcut.WorkingDirectory = "$AppDataPath\FR3-d1\"
    $StartMenuShortcut.IconLocation = "$AppDataPath\FR3-d1\installer\Angel.ico, 0"
    $StartMenuShortcut.Description = "Launch FR3-d1"
    $StartMenuShortcut.Save()
}

function Install-Updater {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Write-Host "Installing updater module..."
    New-Item -Path "$AppDataPath\FR3-d1_Updater\" `
                -ItemType Directory | Out-Null
    Copy-Item -Path "$PSScriptRoot\updater.ps1" `
                -Destination "$AppDataPath\FR3-d1_Updater\"
}


Write-Host "Welcome to " -NoNewline
Write-Host "FR3-d1" -ForegroundColor DarkMagenta -NoNewline
Write-Host " installer."
Read-Host "Press Enter to begin installation"

Get-BaseAppFiles
Get-Transcripts
Install-Shortcuts

Install-Updater

Write-Host "Installation complete!" -ForegroundColor Green

do {
$Open = Read-Host "Would you like to open FR3-d1? (y/n)"
} while ($Open -notin 'y', 'n')

switch ($Open) {
    'y' { Invoke-Item "$AppDataPath\FR3-d1\FR3-d1.ps1" }
    'n' {exit}
}