Param([string]$ProjectsPath = 'C:\Git')

# Define the base path for the registry key.
$baseRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\PerFolderRoots"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        Write-Output $Directory.Name
        If (Test-Path .\.git) {
            #Create Registry Entry
            $GitPath = $Directory.FullName
            # Generate a new custom GUID for the subkey.
            $customGuid = "{" + [guid]::NewGuid().ToString() + "}"
            $registryPath = Join-Path -Path $baseRegistryPath -ChildPath $customGuid

            # Define the properties (value names, data, and types) to be set.
            $properties = @(
                @{
                    Name  = "FolderType";
                    Value = "{69F1E26B-EC64-4280-BC83-F1EB887EC35A}";
                    Type  = "String"
                },
                @{
                    Name  = "PropertyProvider";
                    Value = "{1212F95B-257E-414E-B44F-F26634BD2627}";
                    Type  = "String"
                },
                @{
                    Name  = "RegisteredAppID";
                    Value = "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel";
                    Type  = "String"
                },
                @{
                    Name  = "Path";
                    Value = $GitPath;
                    Type  = "String"
                }
            )

            # Check if the base registry path exists. If not, create it.
            if (-not (Test-Path $baseRegistryPath)) {
                New-Item -Path $baseRegistryPath -Force | Out-Null
                Write-Host "Base registry key '$baseRegistryPath' created."
            }
            else {
                Write-Host "Base registry key '$baseRegistryPath' already exists."
            }

            # Create the new GUID subkey.
            New-Item -Path $registryPath -Force | Out-Null
            Write-Host "Registry key '$registryPath' (with new GUID) created."

            # Set each defined property within the newly created GUID subkey.
            foreach ($prop in $properties) {
                Set-ItemProperty -Path $registryPath -Name $prop.Name -Value $prop.Value -Type $prop.Type -Force
                Write-Host "  - Set property '$($prop.Name)' to '$($prop.Value)' (Type: $($prop.Type))."
            }
        }
    }
}


Set-Location $PSScriptRoot
Write-Output
Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
