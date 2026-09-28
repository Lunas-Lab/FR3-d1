Set-Location "$PSScriptRoot"

Import-Module ".\lib\Get-UserInput.psm1" -Force
Import-Module ".\lib\funcs.psm1" -Force

if (Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet) {
    Get-NewEpisodes
}

$LatestEpisodeNumber = Get-LatestEpisodeNumber

$MaxEpisode = Get-UserInput -Prompt "Please enter which tape you'd like to search up to" `
    -ErrorMessage "Please enter a number between 1 and $LatestEpisodeNumber (inclusive)" `
    -CheckMethod { (($args[0] -ge 1) -and ($args[0] -le $LatestEpisodeNumber)) } `
    -IsInt

Write-Host "Okay, no information past episode " -NoNewline
Write-Host $MaxEpisode -NoNewline -ForegroundColor Blue
Write-Host " will be shown."

Write-Host "Enter `"[f]ind`", `"[r]ead`", `"[l]ist`", `"[o]pen`" or `"[e]xit`" to either find text in The Archives, read an archive, list the tapes you've read so far, open a tape/the homepage in your browser or exit the program."

Do {
    $Command = Get-UserInput -ErrorMessage "Please only enter `"find`", `"exit`", `"read`", `"list`", `"open`", `"f`", `"e`", `"r`", `"l`" or `"o`"" `
        -CheckMethod { $args[0] -iin ("find", "exit", "read", "list", "open", "f", "e", "r", "l", "o") }

    switch ($Command[0]) {
        "f" {
            $SearchString = Get-UserInput -Prompt "Please enter the text you wish to search for"
            $SearchString = (Get-Culture).TextInfo.ToTitleCase($SearchString.ToLower())
            $SearchInMetadata = (Get-UserInput -Prompt "Would you like to search in episode metadata (y) or only in body text (n)?" `
                    -ErrorMessage "You may only enter a `"y`" or an `"n`"" `
                    -CheckMethod { $args[0] -iin "y", "n" }) -ieq "y"

            Write-Host "Okay, searching for " -NoNewline
            Write-Host $SearchString -ForegroundColor Blue -NoNewline
            Write-Host " in episodes up to " -NoNewline
            Write-Host $MaxEpisode -ForegroundColor Yellow -NoNewline
            if ($SearchInMetadata) {
                Write-Host " including" -ForegroundColor Green -NoNewline
            }
            else {
                Write-Host " excluding" -ForegroundColor Red -NoNewline
            }
            Write-Host " in metadata."
            Write-Host "Searching for " -NoNewline
            Write-Host $SearchString -ForegroundColor Blue -NoNewline
            Write-Host "..."
            $FoundTapes = Find-TapesContaining -SearchString $SearchString -MaxTape $MaxEpisode
            
            if (!$FoundTapes) {
                Write-Host "No episodes were found containing " -NoNewline
                Write-Host $SearchString -ForegroundColor Red
                break
            }


            $TapeCount = 0
            foreach ($Tape in $FoundTapes) {
                if ($SearchInMetadata -and ($Tape.MatchInMetadata -or $Tape.MatchInBody)) {
                    $TapeTitles += (Get-TapeContent -TapeNumber $Tape.Index -ContentType Title) + "`n"
                    $TapeCount++
                    continue
                }
                if (!$SearchInMetadata -and $Tape.MatchInBody) {
                    $TapeTitles += (Get-TapeContent -TapeNumber $Tape.Index -ContentType Title) + "`n"
                    $TapeCount++
                }
            }
            Write-Host $TapeCount -ForegroundColor Green -NoNewline
            Write-Host " matches to " -NoNewline
            Write-Host $SearchString -ForegroundColor Green -NoNewline
            Write-Host " found."
            Write-Host $TapeTitles

            $TapeTitles = ""
        }
        "e" {
            $Confirm = Get-UserInput -Prompt "Are you sure you wish to exit? (y/n)" `
                -ErrorMessage "You may only enter a `"y`" or an `"n`"" `
                -CheckMethod { $args[0] -iin "y", "n" }
            if ($Confirm -eq "y") {
                Write-Host "Exiting..." -ForegroundColor DarkMagenta
                Exit                     
            } 
        }
        "r" {
            $TapeNumber = Get-UserInput -Prompt "Please enter which episode number you wish to view" `
                -ErrorMessage "Spoilers! Only enter a number between 1 and $MaxEpisode." `
                -CheckMethod { (($args[0] -ge 1) -and ($args[0] -le $MaxEpisode)) } `
                -IsInt
            $ViewMetadata = (Get-UserInput -Prompt "Would you like metadata to be included at the top of the statement? (y/n)" `
                    -ErrorMessage "You may only enter a `"y`" or an `"n`"" `
                    -CheckMethod { $args[0] -iin "y", "n" }) -eq "y"
            if ($ViewMetadata) {
                Get-TapeContent -TapeNumber $TapeNumber -ContentType All | .\leaf.exe
            }
            else {
                Get-TapeContent -TapeNumber $TapeNumber -ContentType Body | .\leaf.exe
                
            }
        }
        "l" {
            for ($TapeIndex = 1; $TapeIndex -le $MaxEpisode; $TapeIndex++) {
                Get-TapeContent -TapeNumber $TapeIndex -ContentType Title
            }
        }

        "o" {
            $TapeIndex = Get-UserInput -Prompt "Please enter the number of the episode you wish to open in your browser, or just press enter to open the homepage" `
                            -ErrorMessage "Please only input a number or press enter, and ensure you're only looking for an episode you have listened to already" `
                            -CheckMethod {($args[0] -le $MaxEpisode)} `
                            -IsInt
            $TapeNumber = Get-TapeContent -TapeNumber $TapeIndex -ContentType Number
            if ($TapeIndex -eq 0) {Start-Process "https://ghostwires.github.io/transcripts/tmagp/"; break}
            else {Start-Process "https://ghostwires.github.io/transcripts/tmagp/$TapeNumber.html"}
            
        }
    }

} while ($true) 