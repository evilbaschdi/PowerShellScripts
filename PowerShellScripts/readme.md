# PowerShell Scripts Collection

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

### AnalyzeDotNetProjects.ps1
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
.\AnalyzeDotNetProjects.ps1
.\AnalyzeDotNetProjects.ps1 -RootPath "C:\Git" -TargetNetVersion "net10.0"
```

### BuildAndDeploy.ps1
Builds and deploys .NET projects.

### GetDotNetVersions.ps1
Retrieves installed .NET versions on the system.

### MigrateToSlnx.ps1
Migrates Visual Studio solution files (.sln) to the new .slnx format.

**Features:**
- Recursively finds all `.sln` files under C:\Git
- Runs `dotnet sln migrate` for each solution
- Displays progress and error messages

### SetDotNetSdk.ps1
Sets or switches the .NET SDK version using global.json.

---

## Git Operations

### GitCommitLocalBranchesWithChanges.ps1
Commits changes in all local Git branches that have uncommitted changes.

### GitListLocalBranchesWithChanges.ps1
Lists all local Git branches that have uncommitted changes.

### GitPullCleanTrees.ps1
Pulls latest changes from remote repositories for clean working trees.

### GitPushCleanTrees.ps1
Pushes local commits to remote repositories for clean working trees.

### GitRenameMasterToMain.ps1
Renames the `master` branch to `main` in Git repositories.

### GitSyncRemotes.ps1
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

### clone.ps1
Clones Git repositories from a specified source.

### clone_vsts.ps1
Clones Git repositories from Azure DevOps (VSTS).

---

## Windows Management

### AddRsatToWindows.ps1
Adds Remote Server Administration Tools (RSAT) to Windows.

### CreateFileExplorerVersionControlEntries.ps1
Creates context menu entries in File Explorer for version control operations.

### GetInstalledWindowsVersions.ps1
Retrieves information about installed Windows versions.

### GetPowerShellWithWindowsUpdate.ps1
Gets PowerShell modules related to Windows Update functionality.

**Note:** The original PSWindowsUpdate PowerShell module can be found on the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSWindowsUpdate).

### RefreshStartmenuTiles.ps1
Refreshes Windows Start Menu tiles.

### reset_windows_update.ps1
Resets Windows Update components to fix update issues.

### SystemPropertiesChecker.ps1
Checks and validates system properties and configurations.

### UpdateModernApps.ps1
Updates Windows Modern Apps (UWP apps).

### WindowsUpdate.ps1
Manages Windows Update operations.

### winupdatefornano.ps1
Windows Update script specifically for Windows Nano Server.

---

## Media & File Management

### ReplaceFileContent.ps1
Replaces content in files based on specified patterns.

### SyncCarMp3List_Audi.ps1
Synchronizes MP3 playlist for Audi car systems.

### SyncCarMp3List_Skoda.ps1
Synchronizes MP3 playlist for Skoda car systems.

### SyncMp3List.ps1
General MP3 playlist synchronization script.

---

## Network & Remote Management

### ConnectViaRemoteManagement.ps1
Connects to remote systems using Windows Remote Management (WinRM).

### portscanner.ps1
Scans network ports to check availability and connectivity.

---

## IoT & Home Automation

### iobroker_UpdateHost.ps1
Updates ioBroker host system.

### iobroker_UpdateNodeJs.ps1
Updates Node.js installation for ioBroker.

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
