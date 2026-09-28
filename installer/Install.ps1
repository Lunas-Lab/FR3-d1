function Get-BaseAppFiles {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
                        -OutFile "$PSScriptRoot\base_app.zip" `
                        -UseBasicParsing

    Expand-Archive -Path "$PSScriptRoot\Download.zip" `
                    -DestinationPath $AppDataPath

    Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1"

    Remove-Item -Path "$PSScriptRoot\Download.zip"

}

function Get-Transcripts {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')
    
    Invoke-WebRequest -Uri "https://github.com/ghostwires/transcripts/archive/refs/heads/main.zip" `
                        -OutFile "$PSScriptRoot\transcript_repo.zip" `
                        -UseBasicParsing
    
    Expand-Archive -Path "$PSScriptRoot\transcript_repo.zip" `
                    -DestinationPath "$PSScriptRoot"

    Copy-item -Path "$PSScriptRoot\transcripts-main\_posts" -Recurse `
                -Destination "$AppDataPath\FR3-d1\transcripts"

    Get-ChildItem -Path "$AppDataPath\FR3-d1\transcripts" |
        ForEach-Object {
            if (($_.Name -notmatch "\d{4}-\d{2}-\d{2}-\d{3}\.md") `
                    -or (($_ | Get-Content -Raw) -notmatch "categories:.*tmagp.*")) {
                Remove-Item $_ -Force
            }
        }
    
    Remove-Item -Path "$PSScriptRoot\transcript_repo.zip", "$PSScriptRoot\transcripts-main" -Recurse -Force
}


Write-Host "Welcome to " -NoNewline
Write-Host "FR3-d1" -ForegroundColor DarkMagenta -NoNewline
Write-Host " installer."