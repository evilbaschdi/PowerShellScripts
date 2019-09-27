$Name = "evilbaschdi"
$Type = "users"

$Repos = (Invoke-RestMethod -uri https://api.github.com/$Type/$Name/repos)

foreach ($Repo in $Repos) {
    Write-Output $Repo.name
    git clone $Repo.clone_url
    Write-Output ---
}