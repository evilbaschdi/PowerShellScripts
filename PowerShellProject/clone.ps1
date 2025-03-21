$Name = "evilbaschdi"
$Type = "users"
$Repos = New-Object System.Collections.ArrayList @()
$PageNumber = 1

function RequestPage($Page) {
    $script:ResultsPage = Invoke-WebRequest -Method GET -Uri "https://api.github.com/$Type/$Name/repos?page=$Page"
    $ReposPage = ConvertFrom-Json $ResultsPage.Content

    foreach ($PageRepo in $ReposPage) {
        [void]$script:Repos.Add($PageRepo)
    }
}

do {
    RequestPage $PageNumber
    $PageNumber++
} while ($ResultsPage.Headers.Link.Contains('rel="next"'))

foreach ($Repo in $Repos) {
    Write-Output $Repo.name
    git clone $Repo.clone_url
    Write-Output ---
}
