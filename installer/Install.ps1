function Install-BaseApp {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/archive/refs/heads/master.zip" `
                        -OutFile "$PSScriptRoot\Download.zip" `
                        -UseBasicParsing

    Expand-Archive -Path "$PSScriptRoot\Download.zip" `
                    -DestinationPath $AppDataPath

    Rename-Item -Path "$AppDataPath\FR3-d1-master" -NewName "FR3-d1"

    Remove-Item -Path "$PSScriptRoot\Download.zip"

}

function Get-Transcripts {
    param(
        [Parameter(Mandatory)]
        [string] $InstallPath
    )

    Invoke-WebRequest -Uri "https://downgit.github.io/#/home?url=https://github.com/ghostwires/transcripts/tree/main/_posts" `
                        -OutFile "$PSScriptRoot\Staging\Transcripts.zip"
}


Write-Host "Welcome to " -NoNewline
Write-Host "FR3-d1" -ForegroundColor DarkMagenta -NoNewline
Write-Host " installer."

do {
$InstallPath =  Read-Host "Would you like to install to the default location in %LOCALAPPDATA%, or somewhere else? Just press 'enter' if you want the default location (recommended)"
if ($InstallPath.Trim() -eq "") {
    $InstallPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\FR3-d1\"
    $ValidInstallPath = $true
} elseif (!(Test-Path $InstallPath)) {
    Write-Host "ERROR:" -BackgroundColor Red -ForegroundColor White -NoNewline
    Write-Host " The path you provided is invalid, please try again."
    $ValidInstallPath = $false
} else {
    $ValidInstallPath = $true
}
} while(!$ValidInstallPath)

Install-BaseApp