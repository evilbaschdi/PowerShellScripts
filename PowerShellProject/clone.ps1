﻿$Name = "evilbaschdi"
$Type = "users"

$Repos = (Invoke-RestMethod -uri https://api.github.com/$Type/$Name/repos)

foreach ($Repo in $Repos) {
    Write-Host $Repo.name
    git clone $Repo.git_url
    Write-Host ---
}

