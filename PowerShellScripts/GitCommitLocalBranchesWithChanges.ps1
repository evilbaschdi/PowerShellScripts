Param(
    [string]$ProjectsPath = 'C:\Git',
    [string]$Model = 'qwen2.5:1.5b'
)

# --- PROMPTS -------------------------------------------------------------

$analysisPrompt = @"
You are an expert developer generating commit summaries.
Analyze the provided `git diff` and output ONE ultra‑concise sentence describing the main change.

Rules:
- No code snippets, file paths, or bullet points.
- Do not mention filenames.
- Use present tense and imperative mood.
- Be specific, avoid vague terms like "update" or "change".
- When multiple changes occur, prioritize the most significant structural or behavioral change. 
  Ignore minor edits like formatting, removed usings, or adding ToLowerInvariant if larger logic changes exist.
- If the diff contains changes to NuGet or npm package versions, extract the version numbers explicitly. 
  Look for patterns like:
  - <PackageReference Include="X" Version="Y" />
  - <PackageVersion Include="X" Version="Y" />
  - "X": "Y" in package.json
  - <Version>Y</Version>
  - X = Y in .csproj or props files
- Output only the summary sentence.
"@

$subjectPrompt = @"
You are an expert developer generating a single commit message.

Based on the summarized changes, output ONE commit message in the format:
{type}: {message}

Rules:
- Determine {type} using:
  feat, fix, docs, style, test, chore, revert, refactor.
- Message must be under 50 characters.
- No explanations, no issue numbers.
- If NuGet or npm package versions changed, include the version numbers.
- Output only the final commit message.
"@

# --- MAIN LOOP -----------------------------------------------------------

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {

    if (-not $Directory.PSIsContainer) { continue }

    Set-Location $Directory.FullName

    if (-not (Test-Path .\.git)) { continue }

    # Check if HEAD exists (repo has at least one commit)
    $headExists = git rev-parse HEAD 2>$null
    if (-not $headExists) {
        Write-Host "Skipping $(Split-Path $Directory.FullName -Leaf): No commits yet" -ForegroundColor Gray
        continue
    }

    # Check both staged and unstaged changes
    $GitDiff = git diff HEAD; git diff --cached; git ls-files --others --exclude-standard

    if ([string]::IsNullOrWhiteSpace($GitDiff)) { continue }

    Write-Host "Processing repo: $($Directory.FullName)" -ForegroundColor Cyan

    # --- STEP 1: ANALYZE DIFF -------------------------------------------

    $analysisBody = @{
        model  = $Model
        prompt = "$analysisPrompt`n`nDIFF:`n$GitDiff"
        stream = $false
    } | ConvertTo-Json -Depth 10

    try {
        $analysisResult = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" `
            -Method Post -Body $analysisBody -ContentType "application/json"
    }
    catch {
        Write-Host "ERROR: Ollama service not accessible at http://localhost:11434/api/generate" -ForegroundColor Red
        continue
    }

    $summary = $analysisResult.response.Trim()
    Write-Host "Summary: $summary" -ForegroundColor Yellow

    # --- STEP 2: GENERATE COMMIT SUBJECT --------------------------------

    $subjectBody = @{
        model  = $Model
        prompt = "$subjectPrompt`n`nSUMMARY:`n$summary"
        stream = $false
    } | ConvertTo-Json -Depth 10

    try {
        $subjectResult = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" `
            -Method Post -Body $subjectBody -ContentType "application/json"
    }
    catch {
        Write-Host "ERROR: Ollama service not accessible at http://localhost:11434/api/generate" -ForegroundColor Red
        continue
    }

    $commitMessage = $subjectResult.response.Trim()
    Write-Host "Commit: $commitMessage" -ForegroundColor Green

    # --- STEP 3: COMMIT --------------------------------------------------

    git add -A
    git commit -m "$commitMessage"
}

# --- END ----------------------------------------------------------------

Set-Location $PSScriptRoot
Write-Host "Script completed." -ForegroundColor Green
