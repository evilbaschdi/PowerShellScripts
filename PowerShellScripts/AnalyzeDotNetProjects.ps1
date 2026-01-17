param(
    [string]$RootPath = "C:\Git",
    [string]$OutputFile = "DotNetProjectsAnalysis.md",
    [string]$TargetNetVersion = "net10.0"
)

function Get-GlobalJsonSdkVersion {
    param(
        [string]$ProjectPath
    )
    
    $projectDir = Split-Path $ProjectPath -Parent
    $currentDir = $projectDir
    
    while ($currentDir -and (Test-Path $currentDir)) {
        $globalJsonPath = Join-Path $currentDir "global.json"
        
        if (Test-Path $globalJsonPath) {
            try {
                $globalJson = Get-Content $globalJsonPath -Raw | ConvertFrom-Json
                if ($globalJson.sdk -and $globalJson.sdk.version) {
                    return $globalJson.sdk.version
                }
            }
            catch {
                Write-Error "Failed to parse global.json at $globalJsonPath: $_"
            }
        }
        
        if ($currentDir -eq (Split-Path $currentDir -Parent)) {
            break
        }
        $currentDir = Split-Path $currentDir -Parent
        
        if ($currentDir -notlike "$RootPath*") {
            break
        }
    }
    
    return $null
}

function Get-FrameworkFromXml {
    param(
        [System.Xml.XmlDocument]$xml
    )
    
    # Check modern SDK-style TargetFramework/TargetFrameworks
    $tf = $xml.Project.PropertyGroup.TargetFramework | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
    $tfs = $xml.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
    
    # Check old-style TargetFrameworkVersion (e.g., v4.8.1, v4.7.2)
    if (-not $tf -and -not $tfs) {
        $tfv = $xml.Project.PropertyGroup.TargetFrameworkVersion | Where-Object { $_ -ne $null } | Select-Object -First 1
        if ($tfv) {
            $tf = $tfv
        }
    }
    
    # Check inside Choose elements
    if (-not $tf -and -not $tfs -and $xml.Project.Choose) {
        foreach ($choose in $xml.Project.Choose) {
            if ($choose.When) {
                foreach ($when in $choose.When) {
                    $tf = $when.PropertyGroup.TargetFramework | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
                    $tfs = $when.PropertyGroup.TargetFrameworks | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
                    if (-not $tf -and -not $tfs) {
                        $tfv = $when.PropertyGroup.TargetFrameworkVersion | Where-Object { $_ -ne $null } | Select-Object -First 1
                        if ($tfv) { $tf = $tfv }
                    }
                    if ($tf -or $tfs) { break }
                }
            }
            if (-not $tf -and -not $tfs -and $choose.Otherwise) {
                $tf = $choose.Otherwise.PropertyGroup.TargetFramework | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
                $tfs = $choose.Otherwise.PropertyGroup.TargetFrameworks | Where-Object { $_ -ne $null -and $_ -notmatch 'net0\.0' } | Select-Object -First 1
                if (-not $tf -and -not $tfs) {
                    $tfv = $choose.Otherwise.PropertyGroup.TargetFrameworkVersion | Where-Object { $_ -ne $null } | Select-Object -First 1
                    if ($tfv) { $tf = $tfv }
                }
            }
            if ($tf -or $tfs) { break }
        }
    }
    
    return @{
        TargetFramework  = $tf
        TargetFrameworks = $tfs
    }
}

function Get-TargetFrameworks {
    param(
        [string]$ProjectPath
    )
    
    $result = @{
        TargetFrameworks = @()
        Source           = "Unknown"
        HasTargetNet     = $false
    }
    
    if (-not (Test-Path $ProjectPath)) {
        return $result
    }
    
    [xml]$projectXml = Get-Content $ProjectPath
    
    # Step 1: Check if .csproj has a non-0.0 version
    $frameworks = Get-FrameworkFromXml -xml $projectXml
    
    if ($frameworks.TargetFramework) {
        $result.TargetFrameworks = @($frameworks.TargetFramework)
        $result.Source = "Direct (.csproj)"
        $result.HasTargetNet = $frameworks.TargetFramework -match [regex]::Escape($TargetNetVersion)
        return $result
    }
    elseif ($frameworks.TargetFrameworks) {
        $result.TargetFrameworks = $frameworks.TargetFrameworks -split ';' | ForEach-Object { $_.Trim() }
        $result.Source = "Direct (.csproj)"
        $result.HasTargetNet = $result.TargetFrameworks | Where-Object { $_ -match [regex]::Escape($TargetNetVersion) } | Select-Object -First 1
        return $result
    }
    
    # Step 2: Check .props files for non-0.0 version
    $projectDir = Split-Path $ProjectPath -Parent
    $currentDir = $projectDir
    
    while ($currentDir -and (Test-Path $currentDir)) {
        $propsFiles = @()
        $propsFiles += Get-ChildItem -Path $currentDir -Filter "*.props" -File -ErrorAction SilentlyContinue
        $propsFiles += Get-ChildItem -Path $currentDir -Filter "Directory.Build.props" -File -ErrorAction SilentlyContinue
        
        foreach ($file in $propsFiles) {
            try {
                [xml]$xml = Get-Content $file.FullName
                $frameworks = Get-FrameworkFromXml -xml $xml
                
                if ($frameworks.TargetFramework) {
                    $result.TargetFrameworks = @($frameworks.TargetFramework)
                    $result.Source = "Indirect (.props: $($file.Name))"
                    $result.HasTargetNet = $frameworks.TargetFramework -match [regex]::Escape($TargetNetVersion)
                    return $result
                }
                elseif ($frameworks.TargetFrameworks) {
                    $result.TargetFrameworks = $frameworks.TargetFrameworks -split ';' | ForEach-Object { $_.Trim() }
                    $result.Source = "Indirect (.props: $($file.Name))"
                    $result.HasTargetNet = $result.TargetFrameworks | Where-Object { $_ -match [regex]::Escape($TargetNetVersion) } | Select-Object -First 1
                    return $result
                }
            }
            catch {
                continue
            }
        }
        
        if ($currentDir -eq (Split-Path $currentDir -Parent)) {
            break
        }
        $currentDir = Split-Path $currentDir -Parent
        
        if ($currentDir -notlike "$RootPath*") {
            break
        }
    }
    
    # Step 3: Check .targets files for non-0.0 version
    $currentDir = $projectDir
    
    while ($currentDir -and (Test-Path $currentDir)) {
        $targetsFiles = @()
        $targetsFiles += Get-ChildItem -Path $currentDir -Filter "*.targets" -File -ErrorAction SilentlyContinue
        $targetsFiles += Get-ChildItem -Path $currentDir -Filter "Directory.Build.targets" -File -ErrorAction SilentlyContinue
        
        foreach ($file in $targetsFiles) {
            try {
                [xml]$xml = Get-Content $file.FullName
                $frameworks = Get-FrameworkFromXml -xml $xml
                
                if ($frameworks.TargetFramework) {
                    $result.TargetFrameworks = @($frameworks.TargetFramework)
                    $result.Source = "Indirect (.targets: $($file.Name))"
                    $result.HasTargetNet = $frameworks.TargetFramework -match [regex]::Escape($TargetNetVersion)
                    return $result
                }
                elseif ($frameworks.TargetFrameworks) {
                    $result.TargetFrameworks = $frameworks.TargetFrameworks -split ';' | ForEach-Object { $_.Trim() }
                    $result.Source = "Indirect (.targets: $($file.Name))"
                    $result.HasTargetNet = $result.TargetFrameworks | Where-Object { $_ -match [regex]::Escape($TargetNetVersion) } | Select-Object -First 1
                    return $result
                }
            }
            catch {
                continue
            }
        }
        
        if ($currentDir -eq (Split-Path $currentDir -Parent)) {
            break
        }
        $currentDir = Split-Path $currentDir -Parent
        
        if ($currentDir -notlike "$RootPath*") {
            break
        }
    }
    
    return $result
}

Write-Host "Scanning for .NET projects in $RootPath..." -ForegroundColor Cyan

$projects = Get-ChildItem -Path $RootPath -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue

Write-Host "Found $($projects.Count) projects. Analyzing..." -ForegroundColor Cyan

$results = @()

foreach ($project in $projects) {
    Write-Host "Processing: $($project.FullName)" -ForegroundColor Gray
    
    $frameworks = Get-TargetFrameworks -ProjectPath $project.FullName
    $sdkVersion = Get-GlobalJsonSdkVersion -ProjectPath $project.FullName
    
    $results += [PSCustomObject]@{
        ProjectName      = $project.Name
        ProjectPath      = $project.FullName.Replace($RootPath, "").TrimStart('\')
        TargetFrameworks = ($frameworks.TargetFrameworks -join ', ')
        Source           = $frameworks.Source
        HasTargetNet     = $frameworks.HasTargetNet
        SdkVersion       = if ($sdkVersion) { $sdkVersion } else { "*Not found*" }
    }
}

$outputPath = Join-Path (Get-Location) $OutputFile

$markdown = @"
# .NET Projects Analysis

**Root Path:** `$RootPath`
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Total Projects:** $($results.Count)
**Projects with ${TargetNetVersion}:** $($results | Where-Object { $_.HasTargetNet } | Measure-Object | Select-Object -ExpandProperty Count)

---

## Projects

| Status | Project | Target Framework(s) | Source | SDK Version |
|--------|---------|---------------------|--------|-------------|

"@

foreach ($result in $results | Sort-Object ProjectPath) {
    $checkbox = if ($result.HasTargetNet) { "✅" } else { "❌" }
    $frameworks = if ($result.TargetFrameworks) { "``$($result.TargetFrameworks)``" } else { "*Not found*" }
    $projectName = "**$($result.ProjectName)**"
    $projectPath = "<br/><small>``$($result.ProjectPath)``</small>"
    $sdkVersion = if ($result.SdkVersion -ne "*Not found*") { "``$($result.SdkVersion)``" } else { $result.SdkVersion }
    
    $markdown += "| $checkbox | $projectName$projectPath | $frameworks | $($result.Source) | $sdkVersion |`n"
}

$markdown += @"

---

## Legend

- **✅** - Project targets $TargetNetVersion
- **❌** - Project does not target $TargetNetVersion
- **Direct (.csproj)** - TargetFramework defined directly in the project file
- **Indirect (.props)** - TargetFramework defined in a .props file
- **Indirect (.targets)** - TargetFramework defined in a .targets file
- **SDK Version** - .NET SDK version from global.json (searches up the directory tree)

"@

$markdown | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host ""
Write-Host "Analysis complete!" -ForegroundColor Green
Write-Host "Results written to: $outputPath" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Total projects: $($results.Count)" -ForegroundColor White
Write-Host "  Projects with $TargetNetVersion`: $($results | Where-Object { $_.HasTargetNet } | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
Write-Host "  Projects without target framework: $($results | Where-Object { -not $_.TargetFrameworks } | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor White
