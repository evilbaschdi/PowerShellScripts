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

        $branches = git branch -a
        $hasDevelop = $branches -match "develop"

        if ($hasDevelop) {
            # Check if we are already on develop
            $currentBranch = git rev-parse --abbrev-ref HEAD
            if ($currentBranch -ne "develop") {
                Write-Host "  -> Checking out 'develop' branch..." -ForegroundColor Cyan
                git checkout develop 2>&1 | Out-Null
            }

            # Initialize Git Flow if not present
            $gitFlowConfig = git config --get gitflow.branch.master
            if (-not $gitFlowConfig) {
                Write-Host "  -> Initializing Git Flow..." -ForegroundColor Cyan
                # Force defaults (-d) to avoid interactive prompts
                git flow init -d 2>&1 | Out-Null
            }
        }

        Write-Output "---"
    }
}
catch {
    Write-Error "Failed to fetch repositories. Please check your PAT and organization details. Error: $_"
}