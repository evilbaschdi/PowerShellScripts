$projectsPath = "C:\Git"

# Define current SDK versions

$sdkPatchVersions = @{
    "8"  = "411"
    "9"  = "301"
    "10" = "10.0.100-preview.5.25277.114"
}

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
        $currentMajorVersion = $currentSdkVersion.Split('.')[0]
        # 0
        $currentMinorVersion = $currentSdkVersion.Split('.')[1]
        # 100
        #$currentPatchVersion = $currentSdkVersion.Split('.')[2]

        # Increment the minor version
        $newPatchVersion = $sdkPatchVersions[$currentMajorVersion]

        # Construct the new SDK version string
        $newSdkVersion = "$currentMajorVersion.$currentMinorVersion.$newPatchVersion"

        Set-Location -Path $file.DirectoryName
        dotnet new globaljson --sdk-version $newSdkVersion --force

        Write-Host "Updated .NET SDK version in global.json '$fullName' from [$currentSdkVersion] to [$newSdkVersion]"
        Write-Host "----------------------------------------------------------------------------------------------------------------"
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }

    finally {
        Set-Location -Path $projectsPath
    }
}