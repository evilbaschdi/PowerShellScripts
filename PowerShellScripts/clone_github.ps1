$Name = Read-Host "Name"
if ([string]::IsNullOrWhiteSpace($Name)) { Write-Error "Name is required."; exit }

$Type = Read-Host "Type (users/orgs)"
if ([string]::IsNullOrWhiteSpace($Type)) { $Type = "users" }

$Repos = New-Object System.Collections.ArrayList
$PageNumber = 1
$MorePages = $true

Write-Host "Fetching repositories for $Type/$Name..." -ForegroundColor Cyan

while ($MorePages) {
    # Add per_page=100 to reduce number of requests
    $Uri = "https://api.github.com/$Type/$Name/repos?page=$PageNumber&per_page=10"

    try {
        # UseBasicParsing is required for non-interactive environments
        $ResultsPage = Invoke-WebRequest -Method GET -Uri $Uri -UseBasicParsing
        $ReposPage = ConvertFrom-Json $ResultsPage.Content

        if ($null -eq $ReposPage -or $ReposPage.Count -eq 0) {
            $MorePages = $false
        }
        else {
            foreach ($PageRepo in $ReposPage) {
                [void]$Repos.Add($PageRepo)
            }

            # Robust check for Link header and 'next' relation
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
        Write-Error "Failed to fetch page $PageNumber : $_"
        $MorePages = $false
    }
}

Write-Host "Found $($Repos.Count) repositories." -ForegroundColor Green

foreach ($Repo in $Repos) {
    Write-Output $Repo.name
    git clone $Repo.clone_url

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