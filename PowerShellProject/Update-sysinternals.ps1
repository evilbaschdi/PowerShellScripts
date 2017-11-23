﻿$folder = "\progs n drivers\SysinternalsSuite"

function Update-SysinternalsHTTP ($ToolsLocalDir) { 
    if (Test-Path $ToolsLocalDir) { 
        Set-Location $ToolsLocalDir
        $DebugPreference = "SilentlyContinue"
        $wc = new-object System.Net.WebClient
        $userAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)"
        $wc.Headers.Add("user-agent", $userAgent)
        $ToolsUrl = "http://live.sysinternals.com/tools"
        $toolsBlock = "<pre>.*</pre>"
        $WebPageCulture = New-Object System.Globalization.CultureInfo("en-us")
        $Tools = @{}
        $ToolsPage = $wc.DownloadString($ToolsUrl)
        $matches = [string] $ToolsPage |select-string -pattern  "$ToolsBlock" -AllMatches
        foreach ($match in $matches.Matches) {	
            $txt = ( ($match.Value -replace "</A><br>", "`r`n") -replace "<[^>]*?>", "")
            foreach ($lines in $txt.Split("`r`n")) {
                $line = $lines|select-string  -NotMatch -Pattern "To Parent|^$|&lt;dir&gt;"
                if ($line -ne $null) {
                    $date = (([string]$line).substring(0, 38)).trimstart(" ") -replace "  ", " "
                    $file = ([string]$line).substring(52, (([string]$line).length - 52))
                    #Friday, May 30, 2008  4:55 PM          668 About_This_Site.txt
                    $Tools["$file"] = [datetime]::ParseExact($date, "f", $WebPageCulture)
                }
            }
        }

        $Tools.keys|
            ForEach-Object {
            $NeedUpdate = $false
            if (Test-Path $_) {
                $SubtractSeconds = New-Object System.TimeSpan 0, 0, 0, ((Get-ChildItem $_).lastWriteTime).second, 0
                $LocalFileDate = ( (Get-ChildItem $_).lastWriteTime ).Subtract( $SubtractSeconds )
                $needupdate = (($tools[$_]).touniversaltime() -lt $LocalFileDate.touniversaltime())
            }
            else {$NeedUpdate = $true}
            if ( $NeedUpdate ) {
                Try {
                    write-host $_
                    $wc.DownloadFile("$ToolsUrl/$_", "$ToolsLocalDir\$_" )
                    $f = Get-ChildItem "$ToolsLocalDir\$_"
                    $f.lastWriteTime = ($tools[$_])
                    "Updated $_"
                }
                catch { Write-host "An error occurred: $_" }
            } 
        } 
    }
}

Clear-Host

"Update started..."
write-host $env:dropbox$folder
Get-ChildItem $env:dropbox$folder | Remove-Item
Update-SysinternalsHTTP -ToolsLocalDir $env:dropbox$folder

"The End"