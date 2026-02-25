# 1. Fetch Online Metadata
$indexUrl = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json"
Write-Host "Fetching .NET Release Metadata..." -ForegroundColor Cyan

try {
    $metadata = Invoke-RestMethod -Uri $indexUrl
}
catch {
    Write-Error "Failed to download metadata."
    return
}

# Filter for active support phases
$activeChannels = $metadata.'releases-index' | Where-Object {
    $_.'support-phase' -eq 'active'
}

# Get the absolute highest version currently installed on the machine
$allLocalSdks = dotnet --list-sdks
$highestInstalledVersion = $allLocalSdks | ForEach-Object { ($_ -split ' ')[0] } | Sort-Object { [version]$_ } -Descending | Select-Object -First 1
Write-Host "Highest SDK version installed locally: $highestInstalledVersion" -ForegroundColor Gray

$missingActiveChannels = @()

foreach ($channel in $activeChannels) {
    $majorMinor = $channel.'channel-version' # e.g. "10.0"
    $latestOnlineSdk = $channel.'latest-sdk'
    $majorOnly = $majorMinor.Split('.')[0]
    $wingetId = "Microsoft.DotNet.SDK.$majorOnly"

    # Check if this specific channel is installed (e.g., matches "10.0.")
    $localSdksInChannel = $allLocalSdks | Where-Object { $_ -match "^$majorMinor\." }

    if ($null -ne $localSdksInChannel) {
        # CASE 1: Channel exists -> Update within the channel
        Write-Host "`n>>> Checking installed channel .NET $majorMinor <<<" -ForegroundColor Yellow
        $latestLocal = $localSdksInChannel | ForEach-Object { ($_ -split ' ')[0] } | Sort-Object { [version]$_ } -Descending | Select-Object -First 1

        if ([version]$latestLocal -lt [version]$latestOnlineSdk) {
            Write-Host "Status: Update available! ($latestLocal -> $latestOnlineSdk)" -ForegroundColor Green
            Write-Host "Action: Cleaning up old versions of $wingetId..." -ForegroundColor Gray
            winget uninstall --id $wingetId --silent --accept-source-agreements

            Write-Host "Action: Installing latest version $latestOnlineSdk..." -ForegroundColor Green
            winget install --id $wingetId --version $latestOnlineSdk --silent --accept-package-agreements --accept-source-agreements
        }
        else {
            Write-Host "Status: Up to date ($latestLocal)." -ForegroundColor DarkGreen
        }
    }
    else {
        # CASE 2: Channel is missing -> Candidate for "Only install if higher than current system max"
        if ([version]$majorMinor -gt [version]($highestInstalledVersion.Split('.')[0] + "." + $highestInstalledVersion.Split('.')[1])) {
            $missingActiveChannels += $channel
        }
        else {
            Write-Host "`n>>> Skipping older active channel .NET $majorMinor (Not installed and newer version exists) <<<" -ForegroundColor Gray
        }
    }
}

# 2. Handle missing active channels (Install ONLY the absolute highest available)
if ($missingActiveChannels.Count -gt 0) {
    $highestMissing = $missingActiveChannels | Sort-Object { [version]$_.'channel-version' } -Descending | Select-Object -First 1

    $hmVersion = $highestMissing.'channel-version'
    $hmSdk = $highestMissing.'latest-sdk'
    $hmMajor = $hmVersion.Split('.')[0]
    $hmWingetId = "Microsoft.DotNet.SDK.$hmMajor"

    Write-Host "`n>>> New Major Version Found <<<" -ForegroundColor Yellow
    Write-Host "Highest missing active channel: .NET $hmVersion" -ForegroundColor Gray
    Write-Host "Action: Installing $hmWingetId (Version $hmSdk)..." -ForegroundColor Green

    winget install --id $hmWingetId --version $hmSdk --silent --accept-package-agreements --accept-source-agreements
}

Write-Host "`n--- Verification Complete ---" -ForegroundColor Cyan
