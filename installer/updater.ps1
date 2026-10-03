function Update-BaseAppFiles {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
        -OutFile "$PSScriptRoot\base_app.zip" `
        -UseBasicParsing

    Expand-Archive -Path "$PSScriptRoot\base_app.zip" `
        -DestinationPath $AppDataPath -Force

    Remove-Item -Path "$AppdataPath\FR3-d1" -Recurse -Force
    
    Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1" -Force

    Remove-Item -Path "$PSScriptRoot\base_app.zip"

}

Update-BaseAppFiles