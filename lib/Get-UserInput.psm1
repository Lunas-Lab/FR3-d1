function Get-UserInput {
    <#
    .SYNOPSIS
    Gets and checks input from user
    .DESCRIPTION
    Prompts the user for input with the message provided, checks the input with the function provided and will write the error message provided to the console if the check fails. Sends response to pipeline once user gives valid input. Optional switch to return an integer
    .PARAMETER Prompt
    What you'd like for the function to prompt the user with
    .PARAMETER ErrorMessage
    What you'd like for the function to prompt the user with if they provide invalid input
    .PARAMETER CheckMethod
    The function you'd like to be used to check if input is valid - pass by value
    .PARAMETER IsInt
    Optional switch to make the function convert input to an integer
    .EXAMPLE
    $Text = Get-UserInput -Prompt "Please choose if you'd like [r]ed, [g]reen or [b]lue" `
                          -ErrorMessage "Please only input `"r`", `"g`" or `"b`"."
                          -CheckMethod {$args[0] -iin "r", "g", "b"}
    #>
    param (
        [string] $Prompt = " ",
        [string] $ErrorMessage = "Input invalid, please try again",
        [scriptblock] $CheckMethod = { $true }, # Use $args[0] for the variable to check
        [ValidateSet("String", "Integer", "YesNo")]
        [string] $Type = "String"
    )

    switch ($Type) {
        "String" { 
            Do {
                $Answer = Read-Host -Prompt $Prompt
                if (!(& $CheckMethod $Answer)) {
                    Write-Host "ERROR:" -NoNewline -ForegroundColor White -BackgroundColor Red
                    Write-Host " " $ErrorMessage
                }
                $Result = $Answer
            } Until (& $CheckMethod $Answer)
        }

        "Integer" {
            Do {
                $Answer = (Read-Host -Prompt $Prompt) -as [int]

                if ((!(& $CheckMethod $Answer)) -or ($null -eq $Answer)) {
                    Write-Host "ERROR:" -NoNewline -ForegroundColor White -BackgroundColor Red
                    Write-Host " " $ErrorMessage
                }
                $Result = $Answer
            } Until ((& $CheckMethod $Answer) -and ($null -ne $Answer))
        }

        "YesNo" {
            Do {
                if ($Prompt -notmatch "(?i).*\(y\/n\)$") {$Prompt = "$($Prompt.Trim()) (y/n)"}
                $Answer = Read-Host -Prompt $Prompt
                if ($Answer -notin "yes", "y", "no", "n") {
                    Write-Host "ERROR:" -NoNewline -ForegroundColor White -BackgroundColor Red
                    Write-Host " Please only enter `"[y]es`" or `"[n]o`""
                }
                if ($Answer -in "yes", "y") {
                    $Result = $true
                }
                else {
                    $Result = $false
                }
            } Until ($Answer -in "yes", "y", "no", "n")
        }
    }
    
    $Result
}