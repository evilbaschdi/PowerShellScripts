$organization = Read-Host "Organization"
if ([string]::IsNullOrWhiteSpace($organization)) { Write-Error "Organization is required."; exit }

$project = Read-Host "Project"
if ([string]::IsNullOrWhiteSpace($project)) { $project = "DefaultCollection" }

$pat = Read-Host "Personal Access Token (PAT)" -AsSecureString
if ($null -eq $pat) {
    $patUrl = "https://dev.azure.com/$organization/_usersSettings/tokens"
    Write-Host "Opening PAT creation page: $patUrl" -ForegroundColor Cyan
    Start-Process $patUrl
    $pat = Read-Host "Please paste your PAT here" -AsSecureString
}

if ($null -eq $pat) {
    Write-Error "A PAT is required to continue."
    exit
}

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat | ConvertFrom-SecureString -AsPlainText)"))
$headers = @{ Authorization = "Basic $base64AuthInfo" }

$apiVersion = "7.1"
$url = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=$apiVersion"

try {
    Write-Host "Fetching repositories from $organization/$project..." -ForegroundColor Cyan
    $repos = (Invoke-RestMethod -Uri $url -Headers $headers).value
    Write-Host "Found $($repos.Count) repositories." -ForegroundColor Green

    foreach ($repo in $repos) {
        Write-Output "Cloning: $($repo.name)"
        git clone $repo.remoteUrl
        Write-Output "---"
    }
}
catch {
    Write-Error "Failed to fetch repositories. Please check your PAT and organization details. Error: $_"
}