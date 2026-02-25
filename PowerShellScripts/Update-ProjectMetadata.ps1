<#
.SYNOPSIS
    Updates LICENSE, README.md, and project files with correct copyright information based on git history.

.DESCRIPTION
    1. Ensures a LICENSE file (MIT) exists with the correct first commit year.
    2. Ensures README.md has an MIT license badge.
    3. Updates <Copyright> in .csproj and Directory.Build.props files.
#>

$licenseTemplate = @"
MIT License

Copyright (c) {0} - 2026 Sebastian Walter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@

$badge = "[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)"

$repos = Get-ChildItem -Path "C:\Git" -Directory | Where-Object { Test-Path (Join-Path $_.FullName ".git") }

foreach ($repo in $repos) {
    Write-Host "Processing repository: $($repo.Name)" -ForegroundColor Cyan

    # 1. Get first commit year
    $firstYear = git -C $repo.FullName log --reverse --format=%ad --date=format:%Y | Select-Object -First 1
    if (-not $firstYear) {
        Write-Warning "  Could not determine first commit year for $($repo.Name). Skipping metadata updates."
        continue
    }

    # 2. Manage LICENSE file
    $licensePath = Join-Path $repo.FullName "LICENSE"
    $expectedLicenseContent = $licenseTemplate -f $firstYear
    if (-not (Test-Path $licensePath)) {
        Write-Host "  Creating LICENSE file (Year: $firstYear)"
        [System.IO.File]::WriteAllText($licensePath, $expectedLicenseContent)
    }
    else {
        $currentLicense = [System.IO.File]::ReadAllText($licensePath)
        if ($currentLicense -notmatch "Copyright \(c\) $firstYear") {
            Write-Host "  Updating LICENSE year to $firstYear"
            $updatedLicense = $currentLicense -replace "Copyright \(c\) \d{4}", "Copyright (c) $firstYear"
            [System.IO.File]::WriteAllText($licensePath, $updatedLicense)
        }
    }

    # 3. Manage README.md badge
    $readmeFile = Get-ChildItem -Path $repo.FullName -Filter "README*" | Select-Object -First 1
    if ($readmeFile) {
        $content = [System.IO.File]::ReadAllText($readmeFile.FullName)
        if ($content -notmatch "License: MIT") {
            Write-Host "  Adding license badge to $($readmeFile.Name)"
            if ($content -match "(?m)^(#+ .*$)") {
                $regex = [regex]"(?m)^(#+ .*$)"
                $content = $regex.Replace($content, "`$1`r`n`r`n$badge", 1)
            }
            else {
                $content = "$badge`r`n`r`n$content"
            }
            [System.IO.File]::WriteAllText($readmeFile.FullName, $content)
        }
    }
    else {
        Write-Host "  Creating basic README.md with badge"
        $readmePath = Join-Path $repo.FullName "README.md"
        $readmeContent = "# $($repo.Name)`r`n`r`n$badge`r`n"
        [System.IO.File]::WriteAllText($readmePath, $readmeContent)
    }

    # 4. Update .csproj and Directory.Build.props
    $projectFiles = Get-ChildItem -Path $repo.FullName -Recurse -Include "*.csproj", "Directory.Build.props"
    foreach ($file in $projectFiles) {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        if ($content -match "<Copyright>Copyright © (\d{4}) - ") {
            $currentYear = $matches[1]
            if ($currentYear -ne $firstYear) {
                Write-Host "  Updating $($file.Name): $currentYear -> $firstYear"
                $newContent = $content -replace "<Copyright>Copyright © $currentYear - ", "<Copyright>Copyright © $firstYear - "
                [System.IO.File]::WriteAllText($file.FullName, $newContent)
            }
        }
    }
}
