$projectsPath = "C:\Git"

# Define current SDK versions
$sdkPatchVersions = @{
    "8"  = "417"
    "9"  = "309"
    "10" = "102"
}

# Boolean flag to control major version upgrade
$upgradeMajorVersion = $false

# Target major version to upgrade to (used if $upgradeMajorVersion is true)
$targetMajorVersion = 10

# Get all global.json files under the root path and its subdirectories
$globalJsonFiles = Get-ChildItem -Path $projectsPath -Filter "global.json" -Recurse -File

# Loop through each global.json file
foreach ($file in $globalJsonFiles) {
    $fullName = $file.FullName
    try {
        Write-Host "Processing '$fullName'"
        $globalJson = Get-Content -Path $fullName -Raw | ConvertFrom-Json
        # 8.0.100
        $currentSdkVersion = $globalJson.sdk.version
        # 8
        $currentMajorVersion = [int]$currentSdkVersion.Split('.')[0]
        # 0
        $currentMinorVersion = $currentSdkVersion.Split('.')[1]
        # 100
        #$currentPatchVersion = $currentSdkVersion.Split('.')[2]

        # Determine the new major version based on the flag and target version
        $newMajorVersion = if ($upgradeMajorVersion) { $targetMajorVersion } else { $currentMajorVersion }

        # Determine the new patch version
        $newPatchVersion = $sdkPatchVersions[$newMajorVersion.ToString()]

        # Construct the new SDK version string
        $newSdkVersion = "$newMajorVersion.$currentMinorVersion.$newPatchVersion"

        Set-Location -Path $file.DirectoryName
        dotnet new globaljson --sdk-version $newSdkVersion --force

        Write-Host "Updated .NET SDK version in global.json '$fullName' from [$currentSdkVersion] to [$newSdkVersion]"
        Write-Host "-----------------------------------------------------------------------------------------------------------------------------------"
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }

    finally {
        Set-Location -Path $projectsPath
    }
}