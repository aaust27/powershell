
#$host.ui.RawUI.WindowTitle = "PowerShell 11.01"


<#function global:prompt
{
    $runTime = '[00:00:000]' 
    $LastCmd = get-history -count 1
    if($LastCmd)
    {
        $runTime = '[{0:mm\:ss\.fff}]' -f   ($LastCmd.EndExecutionTime - $LastCmd.StartExecutionTime)
    }

    $arrows = '>'
    if ($NestedPromptLevel -gt 0) 
    {
        $arrows = $arrows * $NestedPromptLevel
    }
    $currentDirectory = Get-Location
    Write-Host "$runTime" -ForegroundColor Yellow -NoNewline
    Write-Host ' PS' -NoNewline
    Write-Host " $currentDirectory$arrows" -NoNewline
    ' '

}#> 


Clear-Host
Set-Location \
if(Get-Command Out-GridView -ErrorAction SilentlyContinue) {
    # This key handler shows the entire or filtered history using Out-GridView. The
    # typed text is used as the substring pattern for filtering. A selected command
    # is inserted to the command line without invoking. Multiple command selection
    # is supported, e.g. selected by Ctrl + Click.
    $ShowCommandHistoryScriptBlock = {
        $Pattern = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Pattern, [ref]$null)
        if($Pattern) {
            $Pattern = [regex]::Escape($Pattern)
        }

        $Last = ""
        $Lines = ""

        $History = [System.Collections.ArrayList]@(
            foreach($Line in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath)) {
                if($Line.EndsWith('`')) {
                    $Line = $Line.Substring(0, $Line.Length - 1)
                    $Lines = if($Lines) {
                        "$Lines`n$Line"
                    } else {
                        $Line
                    }

                    continue
                }

                if($Lines) {
                    $Line = "$Lines`n$Line"
                    $Lines = ""
                }

                if(($Line -cne $Last) -and (-not $Pattern -or ($Line -match $Pattern))) {
                    $Last = $Line
                    $Line
                }
            }
        )

        $History.Reverse()
        # $Command = $History | Select-Object @{ Name = "Command"; Expression = { $_ } } | Out-GridView -Title History -PassThru | Select-Object -ExpandProperty Command
        $Command = $History | Out-GridView -Title History -PassThru

        if($Command) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($Command -join "`n"))
        }
    }

    $ShowCommandHistorySplat = @{
        Key              = "F7"
        BriefDescription = "History"
        LongDescription  = "Show command history"
        ScriptBlock      = $ShowCommandHistoryScriptBlock
    }
    Set-PSReadlineKeyHandler @ShowCommandHistorySplat
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin