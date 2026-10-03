function Get-NewEpisodes {
    $RSSEpisodeNumbers = @()
    $RSSFeed = Invoke-RestMethod -Uri "https://ghostwires.github.io/transcripts/feed.xml"
    $RSSFeed |
    Where-Object -Property "title" -match "^MAGP \d* - .*$" |
    Select-Object -ExpandProperty "title" |
    Select-String -Pattern "^MAGP (\d{1-3}) - .*$" |
    ForEach-Object {
        $RSSEpisodeNumbers += $_.Matches.Groups[1].Value
    }
    
    $SavedEpisodeNumbers = @()
    Get-ChildItem .\transcripts\ |
    Select-Object -ExpandProperty Name |
    Select-String -Pattern "^\d{4}-\d{2}-\d{2}-(\d{3}).md$" |
    ForEach-Object {
        $SavedEpisodeNumbers += $_.Matches.Groups[1].Value.TrimStart('0')
    }

    $NewEpisodesNumbers = Compare-Object -ReferenceObject $SavedEpisodeNumbers -DifferenceObject $RSSEpisodeNumbers |
    Where-Object -Property SideIndicator -eq "=>" |
    Select-Object -ExpandProperty "InputObject"

    if ($NewEpisodesNumbers.Count -eq 0) { return $null }

    foreach ($Episode in $NewEpisodesNumbers) {
        $Date = ($RSSFeed | Where-Object -Property "title" -Match "^MAGP $Episode - .*$" |
            Select-Object -ExpandProperty "pubDate" |
            Select-String -Pattern "^(\d{4}-\d{2}-\d{2})T.*$").Matches.Groups[1].Value

        $FileName = "$Date-$($Episode.PadLeft(3, '0')).md"
        Invoke-WebRequest -Uri "https://github.com/ghostwires/transcripts/blob/main/_posts/$FileName" `
            -OutFile ".\transcripts\$FileName" -UseBasicParsing
    }
}

function Get-LatestEpisodeNumber {
    [int[]] $EpisodeNumbers = @()
    Get-ChildItem .\transcripts |
    Select-Object -ExpandProperty Name |
    ForEach-Object {
        $EpisodeNumbers += ($_ | Select-String -Pattern "^\d{4}-\d{2}-\d{2}-(\d{3}).md$").Matches.Groups[1].Value.TrimStart() -as [int]
    }

    $LatestEpisodeNumber = $EpisodeNumbers | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $LatestEpisodeNumber
}

function Select-MarkdownMetadata {
    <#
    .DESCRIPTION
    Extracts the YAML from a MarkDown-formatted string#
    .SYNOPSIS
    Takes Markdown-formatted string as an input and outputs YAML in it if present, otherwise throws System.ArgumentException and returns $null
    .PARAMETER Markdown
    Markdown-formatted string to have th YAML extracted from
    #>
    param (
        [string] $Markdown
    )

    $Metadata = ($Markdown | Select-String -Pattern "(?s)---\r?\n(.*?)\r?\n---\r?\n").Matches.Value
    if ($null -eq $Metadata) {
        throw [System.ArgumentException]"No YAML found in document"
    }
    $Metadata
}

function Find-TapesContaining {
    param (
        [string] $SearchString,
        [int] $MaxTape
    )
    
    $TapesContainingString = @()

    for ($TapeIndex = 1; $TapeIndex -le $MaxTape; $TapeIndex++) {
        $MatchObject = [pscustomobject]@{
            Index           = ($TapeIndex)
            MatchInBody     = $false
            MatchInMetadata = $false
        }

        if ((Get-TapeContent -TapeNumber $TapeIndex -ContentType Body) -like "*$SearchString*") {
            $MatchObject.MatchInBody = $true
        }
        if ((Get-TapeContent -TapeNumber $TapeIndex -ContentType Metadata) -like "*$SearchString*") {
            $MatchObject.MatchInMetadata = $true
        }

        if ($MatchObject.MatchInBody -or $MatchObject.MatchInMetadata) {
            $TapesContainingString += $MatchObject
        }
    }


    $TapesContainingString
}

function Get-TapeContent {
    param (
        [int] $TapeNumber,
        [ValidateSet('Body', 'Metadata', 'Title', 'All', 'Number')]
        [string] $ContentType
    )

    $TapeContent = (Get-ChildItem -Path ".\transcripts")[$TapeNumber - 1] | Get-Content -Raw

    switch ($ContentType) {
        'All' { $Return = $TapeContent }
        'Title' { $Return = ($TapeContent | Select-String -Pattern 'title: *"(.*)"').Matches.Groups[1].Value }
        'Metadata' { $Return = Select-MarkdownMetadata -Markdown $TapeContent }
        'Body' { $Return = ($TapeContent | Select-String -Pattern '(?s)\r?\n---\r?\n(.*)').Matches[0].Groups[1].Value }
        'Number' { $Return = ($TapeContent | Select-String -Pattern 'episode_number:.*(\d\d\d).*').Matches.Groups[1].Value }
    }

    $Return
}

function Install-Updates {
    $AppDataPath = [Environment]::GetFolderPath('LocalApplicationData')

    Import-Module ".\lib\version.psm1" -Force

    $Headers = @{
        "Cache-Control" = "no-cache, no-store, must-revalidate"
        "Pragma"        = "no-cache"
        "Expires"       = "0"
    }
    $Response = Invoke-WebRequest -Uri "https://github.com/Lunas-Lab/FR3-d1/raw/master/lib/version.psm1" -UseBasicParsing -Headers $Headers
    $RemoteVersion = $Response.Content.Split('"')[1]
    if ([version] $RemoteVersion -gt $Version) {
        Write-Host "There is an update for FR3-d1 available." -BackgroundColor DarkYellow -ForegroundColor White
        if (Get-UserInput -Prompt "Would you like to update now?" `
                -ErrorMessage "Please only enter `"y`" for `"yes`" or `"n`" for `"no`"" `
                -CheckMethod { $args[0] -iin "y", "n" } `
                -Type YesNo) {
            Write-Host "Installing version " -NoNewline
            Write-Host "$RemoteVersion" -ForegroundColor DarkMagenta -NoNewline
            Write-Host "..."
            & "$AppDataPath\FR3-d1_updater\updater.ps1" -HostProcessID $PID
            Exit
        }
    }
}