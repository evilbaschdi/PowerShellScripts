$projectsPath = "C:\Git"

# Fetch Online Metadata
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

#{
#    "channel-version": "10.0",
#    "latest-release": "10.0.3",
#    "latest-release-date": "2026-02-10",
#    "security": true,
#    "latest-runtime": "10.0.3",
#    "latest-sdk": "10.0.103",
#    "product": ".NET",
#    "support-phase": "active",
#    "eol-date": "2028-11-14",
#    "release-type": "lts",
#    "releases.json": "https://builds.dotnet.microsoft.com/dotnet/release-metadata/10.0/releases.json",
#    "supported-os.json": "https://builds.dotnet.microsoft.com/dotnet/release-metadata/10.0/supported-os.json"
#}


# Define current SDK versions
$sdkVersions = @{}

foreach ($channel in $activeChannels) {
    $latestOnlineSdk = $channel.'latest-sdk'
    # 10
    $majorVersion = $latestOnlineSdk.Split('.')[0]
    $sdkVersions.Add($majorVersion, $latestOnlineSdk)
}

# Boolean flag to control major version upgrade
$upgradeMajorVersion = $false

# Target major version to upgrade to (used if $upgradeMajorVersion is true)
$targetMajorVersion = 10

# Get all global.json files under the root path and its subdirectories
$globalJsonFiles = Get-ChildItem -Path $projectsPath -Filter "global.json" -Recurse -File

Write-Host "`n--- Starting .NET SDK Update Process ---" -ForegroundColor Cyan
Write-Host "Found $($globalJsonFiles.Count) global.json file(s)" -ForegroundColor Gray

# Loop through each global.json file
foreach ($file in $globalJsonFiles) {
    $fullName = $file.FullName
    try {
        Write-Host "`n>>> Processing: $fullName" -ForegroundColor Yellow
        $globalJson = Get-Content -Path $fullName -Raw | ConvertFrom-Json
        # 8.0.100
        $currentSdkVersion = $globalJson.sdk.version
        # 8
        $currentMajorVersion = [int]$currentSdkVersion.Split('.')[0]

        # Determine the new major version based on the flag and target version
        $newMajorVersion = if ($upgradeMajorVersion) { $targetMajorVersion } else { $currentMajorVersion }

        # Determine the new patch version
        $newSdkVersion = $sdkVersions[$newMajorVersion.ToString()]

        if ([version]$currentSdkVersion -lt [version]$newSdkVersion) {
            Write-Host "Status: Update available! ($currentSdkVersion → $newSdkVersion)" -ForegroundColor Green
            Write-Host "Action: Upgrading SDK version..." -ForegroundColor Gray

            Set-Location -Path $file.DirectoryName
            dotnet new globaljson --sdk-version $newSdkVersion --force

            Write-Host "✓ Successfully updated global.json from [$currentSdkVersion] to [$newSdkVersion]" -ForegroundColor Green
        }
        else {
            Write-Host "Status: Up to date ($currentSdkVersion)." -ForegroundColor DarkGreen
        }
    }
    catch {
        Write-Error "✗ An error occurred: $($_.Exception.Message)"
    }

    finally {
        Set-Location -Path $projectsPath
    }
}

Write-Host "`n--- .NET SDK Update Process Complete ---" -ForegroundColor Cyan