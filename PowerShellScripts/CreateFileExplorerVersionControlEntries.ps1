Param([string]$ProjectsPath = 'C:\Git')

# Define the base path for the registry key and ensure it exists
$baseRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\PerFolderRoots"
if (-not (Test-Path -LiteralPath $baseRegistryPath)) {
    New-Item -Path $baseRegistryPath -Force | Out-Null
}

# Define the properties (value names, data, and types) to be set.
$properties = @(
    @{ Name = "FolderType"; Value = "{69F1E26B-EC64-4280-BC83-F1EB887EC35A}"; Type = "String" },
    @{ Name = "PropertyProvider"; Value = "{1212F95B-257E-414E-B44F-F26634BD2627}"; Type = "String" },
    @{ Name = "RegisteredAppID"; Value = "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"; Type = "String" }
)

Get-ChildItem -Path $ProjectsPath -Directory | ForEach-Object {
    $Directory = $_

    if (Test-Path -LiteralPath "$($Directory.FullName)\.git") {
        Write-Output $Directory.Name

        # Create registry entry with new GUID
        $customGuid = "{$([guid]::NewGuid().ToString())}"
        $registryPath = "$baseRegistryPath\$customGuid"

        New-Item -Path $registryPath -Force | Out-Null

        # Set properties
        $properties | ForEach-Object {
            Set-ItemProperty -LiteralPath $registryPath -Name $_.Name -Value $_.Value -Type $_.Type -Force
        }

        # Set the path property
        Set-ItemProperty -LiteralPath $registryPath -Name "Path" -Value $Directory.FullName -Type "String" -Force
    }
}


Write-Output "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
