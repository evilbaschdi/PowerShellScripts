
$Preview = Read-Host "Preview Mode (y/n)?"
if ([string]::IsNullOrWhiteSpace($Preview)) { $Preview = "y" }

# CloneAndSetupRemotes.ps1
# Clones from GitHub and sets up Azure DevOps as a secondary remote ('azuredevops')

if ($Preview -eq "y") {
    Write-Host "!!! PREVIEW MODE - No changes will be made !!!" -ForegroundColor Magenta
}

$isPreview = ($Preview -eq "y")

# --- GitHub Configuration ---
Write-Host "--- GitHub Configuration ---" -ForegroundColor Cyan
$GhName = Read-Host "GitHub User/Org Name"
if ([string]::IsNullOrWhiteSpace($GhName)) { Write-Error "GitHub Name is required."; exit }

$GhType = Read-Host "Type (users/orgs)"
if ([string]::IsNullOrWhiteSpace($GhType)) { $GhType = "users" }

# --- Azure DevOps Configuration ---
Write-Host "`n--- Azure DevOps Configuration ---" -ForegroundColor Cyan
$AdoOrg = Read-Host "Organization"
if ([string]::IsNullOrWhiteSpace($AdoOrg)) { Write-Error "Organization is required."; exit }

$AdoProject = Read-Host "Project"
if ([string]::IsNullOrWhiteSpace($AdoProject)) { $AdoProject = "DefaultCollection" }

$AdoPat = Read-Host "Personal Access Token (PAT) [Leave empty to launch browser]" -AsSecureString
if ($null -eq $AdoPat) {
    $patUrl = "https://dev.azure.com/$AdoOrg/_usersSettings/tokens"
    Write-Host "Opening PAT creation page: $patUrl" -ForegroundColor Cyan
    Start-Process $patUrl
    $AdoPat = Read-Host "Please paste your PAT here" -AsSecureString
}

if ($null -eq $AdoPat) {
    Write-Error "A PAT is required to continue."
    exit
}

# --- Fetch GitHub Repositories ---
Write-Host "`nFetching GitHub repositories..." -ForegroundColor Cyan
$GhRepos = New-Object System.Collections.ArrayList
$PageNumber = 1
$MorePages = $true

while ($MorePages) {
    $Uri = "https://api.github.com/$GhType/$GhName/repos?page=$PageNumber&per_page=100"
    try {
        $ResultsPage = Invoke-WebRequest -Method GET -Uri $Uri -UseBasicParsing
        $ReposPage = ConvertFrom-Json $ResultsPage.Content

        if ($null -eq $ReposPage -or $ReposPage.Count -eq 0) {
            $MorePages = $false
        }
        else {
            foreach ($PageRepo in $ReposPage) {
                [void]$GhRepos.Add($PageRepo)
            }
            # Check Link header for pagination
            $LinkHeader = $ResultsPage.Headers['Link']
            if ($null -ne $LinkHeader -and ($LinkHeader -match 'rel="next"')) {
                $PageNumber++
            }
            else {
                $MorePages = $false
            }
        }
    }
    catch {
        Write-Error "Failed to fetch GitHub page $PageNumber : $_"
        $MorePages = $false
    }
}
Write-Host "Found $($GhRepos.Count) GitHub repositories." -ForegroundColor Green

# --- Fetch Azure DevOps Repositories ---
Write-Host "`nFetching Azure DevOps repositories..." -ForegroundColor Cyan
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AdoPat | ConvertFrom-SecureString -AsPlainText)"))
$headers = @{ Authorization = "Basic $base64AuthInfo" }
$apiVersion = "7.1"
$AdoUrl = "https://dev.azure.com/$AdoOrg/$AdoProject/_apis/git/repositories?api-version=$apiVersion"

$AdoRepoMap = @{} # Map Name -> RemoteUrl

try {
    $AdoReposList = (Invoke-RestMethod -Uri $AdoUrl -Headers $headers).value
    Write-Host "Found $($AdoReposList.Count) Azure DevOps repositories." -ForegroundColor Green

    foreach ($repo in $AdoReposList) {
        $AdoRepoMap[$repo.name] = $repo.remoteUrl
    }
}
catch {
    Write-Error "Failed to fetch Azure DevOps repositories. Error: $_"
    exit
}

# --- Process Repositories ---
Write-Host "`n--- Processing Repositories ---" -ForegroundColor Cyan

foreach ($GhRepo in $GhRepos) {
    $RepoName = $GhRepo.name
    Write-Host "Processing $RepoName..." -NoNewline

    $isCloned = Test-Path "$RepoName\.git"

    # 1. Clone if not exists
    if (-not $isCloned) {
        if ($isPreview) {
            Write-Host " [PREVIEW] Would clone from $($GhRepo.clone_url)" -ForegroundColor Magenta
        }
        else {
            Write-Host " Cloning from GitHub..." -ForegroundColor Yellow
            git clone $GhRepo.clone_url
            $isCloned = Test-Path "$RepoName\.git" # Re-check if clone succeeded
        }
    }
    else {
        Write-Host " Already exists." -ForegroundColor Gray
    }

    # 2. Configure Remotes (Azure DevOps)
    if ($AdoRepoMap.ContainsKey($RepoName)) {
        $targetAdoUrl = $AdoRepoMap[$RepoName]

        if ($isCloned) {
            # Folder exists (either previously or just cloned)
            Push-Location $RepoName
            $currentRemotes = git remote -v

            if ($currentRemotes -notmatch "azuredevops") {
                if ($isPreview) {
                    Write-Host "  -> [PREVIEW] Would add 'azuredevops' remote: $targetAdoUrl" -ForegroundColor Magenta
                }
                else {
                    Write-Host "  -> Adding 'azuredevops' remote..." -ForegroundColor Cyan
                    git remote add azuredevops $targetAdoUrl
                }
            }

            # 3. Setup Git Flow / Develop Branch
            $branches = git branch -a
            $hasDevelop = $branches -match "develop"

            if ($hasDevelop) {
                if ($isPreview) {
                    Write-Host "  -> [PREVIEW] Would checkout 'develop' branch" -ForegroundColor Magenta
                    Write-Host "  -> [PREVIEW] Would initialize git flow (if not already set)" -ForegroundColor Magenta
                }
                else {
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
            }

            Pop-Location
        }
        elseif ($Preview -eq "y") {
            # Folder doesn't exist, but we are in preview mode, so report what we WOULD do
            Write-Host "  -> [PREVIEW] Would add 'azuredevops' remote: $targetAdoUrl" -ForegroundColor Magenta
            Write-Host "  -> [PREVIEW] Would checkout 'develop' branch (if available)" -ForegroundColor Magenta
            Write-Host "  -> [PREVIEW] Would initialize git flow (if available)" -ForegroundColor Magenta
        }
    }
}

Write-Host "`nDone." -ForegroundColor Green