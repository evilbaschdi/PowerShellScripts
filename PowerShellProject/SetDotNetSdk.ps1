# Define current SDK versions

$sdkPatchVersions = @{
    "8" = "407"
    "9" = "202"
}

# Get all global.json files under the root path and its subdirectories
$globalJsonFiles = Get-ChildItem -Path $rootPath -Filter "global.json" -Recurse -File

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

        # Update the global.json object
        $globalJson.sdk.version = $newSdkVersion

        # Convert the object back to JSON and write to file
        $globalJson | ConvertTo-Json | Out-File -FilePath $fullName -Encoding UTF8

        Write-Host "Updated .NET SDK version in global.json '$fullName' from [$currentSdkVersion] to [$newSdkVersion]"
    }
    catch {
        code $fullName
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
}