# PowerShell Scripts Collection

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This repository contains a collection of PowerShell scripts for various automation tasks.

## Table of Contents

- [.NET & Development](#net--development)
- [Git Operations](#git-operations)
- [Windows Management](#windows-management)
- [Media & File Management](#media--file-management)
- [Network & Remote Management](#network--remote-management)
- [IoT & Home Automation](#iot--home-automation)

---

## .NET & Development

### Analyze-DotNetProjects.ps1
Analyzes all .NET projects under a specified root path and generates a markdown report.

**Features:**
- Scans for `.csproj` files recursively
- Extracts `TargetFramework` or `TargetFrameworks` from projects
- Detects framework definitions in `.csproj`, `.props`, or `.targets` files
- Parses SDK version from `global.json` files
- Generates markdown report with checkboxes for target .NET version compatibility
- Supports both modern SDK-style and old-style .NET Framework projects

**Parameters:**
- `RootPath` - Root directory to scan (default: "C:\Git")
- `OutputFile` - Output markdown file name (default: "DotNetProjectsAnalysis.md")
- `TargetNetVersion` - Target .NET version to check (default: "net10.0")

**Usage:**
```powershell
.\Analyze-DotNetProjects.ps1
.\Analyze-DotNetProjects.ps1 -RootPath "C:\Git" -TargetNetVersion "net10.0"
```

### Invoke-BuildAndDeploy.ps1
Builds and deploys .NET projects.

### Get-DotNetVersions.ps1
Retrieves installed .NET versions on the system.

### Invoke-MigrateToSlnx.ps1
Migrates Visual Studio solution files (.sln) to the new .slnx format.

**Features:**
- Recursively finds all `.sln` files under C:\Git
- Runs `dotnet sln migrate` for each solution
- Displays progress and error messages

### Set-DotNetSdk.ps1
Sets or switches the .NET SDK version using global.json.

### Update-DotNetSDKs.ps1
Updates installed .NET SDKs to the latest versions.

### Update-ProjectMetadata.ps1
Updates project metadata and configuration files across projects.

---

## Git Operations

### Invoke-GitCommitLocalBranchesWithChanges.ps1
Commits changes in all local Git branches that have uncommitted changes.

### Get-GitLocalBranchesWithChanges.ps1
Lists all local Git branches that have uncommitted changes.

### Invoke-GitPullCleanTrees.ps1
Pulls latest changes from remote repositories for clean working trees.

### Invoke-GitPushCleanTrees.ps1
Pushes local commits to remote repositories for clean working trees.

### Rename-GitMasterToMain.ps1
Renames the `master` branch to `main` in Git repositories.

### Sync-GitRemotes.ps1
Synchronizes multiple Git remotes (e.g., GitHub and Azure DevOps).

**Features:**
- Fetches from multiple configured remotes
- Syncs tags between remotes
- Configurable remote names and paths

**Parameters:**
- `ProjectsPath` - Path containing Git repositories (default: "C:\Git")

**Configuration:**
- `$Remote1Name` - First remote name (default: "origin")
- `$Remote1Path` - First remote URL pattern
- `$Remote2Name` - Second remote name (default: "azuredevops")
- `$Remote2Path` - Second remote URL pattern

### Clone-GitHubRepo.ps1
Clones Git repositories from GitHub.

### Clone-AzureDevOpsRepo.ps1
Clones Git repositories from Azure DevOps (VSTS).

### Clone-AndSetupRemotes.ps1
Clones repositories and sets up multiple remotes automatically.

---

## Windows Management

### Add-Rsat.ps1
Adds Remote Server Administration Tools (RSAT) to Windows.

### New-FileExplorerVersionControlEntries.ps1
Creates context menu entries in File Explorer for version control operations.

### Get-InstalledWindowsVersions.ps1
Retrieves information about installed Windows versions.

### Get-PowerShellWithWindowsUpdate.ps1
Gets PowerShell modules related to Windows Update functionality.

**Note:** The original PSWindowsUpdate PowerShell module can be found on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSWindowsUpdate).

### Reset-WindowsUpdate.ps1
Resets Windows Update components to fix update issues.

### Test-SystemProperties.ps1
Checks and validates system properties and configurations.

### Update-ModernApps.ps1
Updates Windows Modern Apps (UWP apps).

### Invoke-WindowsUpdate.ps1
Manages Windows Update operations.

### Add-DefenderExclusions.ps1
Adds exclusions to Windows Defender for specified files or directories.

---

## Media & File Management

### Update-FileContent.ps1
Replaces content in files based on specified patterns.

### Sync-CarMp3List-Audi.ps1
Synchronizes MP3 playlist for Audi car systems.

### Sync-CarMp3List-Skoda.ps1
Synchronizes MP3 playlist for Skoda car systems.

### Sync-Mp3List.ps1
General MP3 playlist synchronization script.

---

## Network & Remote Management

### Invoke-PortScanner.ps1
Scans network ports to check availability and connectivity.

---

## IoT & Home Automation

This section is currently empty. No IoT automation scripts are available.

---

## General Usage

Most scripts can be executed directly or with parameters. Use `Get-Help` to see detailed information:

```powershell
Get-Help .\ScriptName.ps1 -Detailed
```

## Requirements

- PowerShell 5.1 or higher (some scripts may require PowerShell 7+)
- Appropriate permissions for system-level operations
- Git installed (for Git-related scripts)
- .NET SDK installed (for .NET-related scripts)

## Contributing

Feel free to submit issues or pull requests to improve these scripts.

## License

See the repository license for details.
