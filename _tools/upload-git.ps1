# upload-git.ps1 — compact project, extract to __GIT_EXPORT, push to git repo.
# Usage: .\tools\upload-git.ps1 -RepoUrl https://github.com/user/repo.git
# If direct push fails, prints a big manual-upload guide (use GitHub web UI).

param(
  [Parameter(Mandatory = $true, HelpMessage = 'Target git repo URL (https://...)')]
  [string]$RepoUrl
)
$ErrorActionPreference = 'Stop'
$env:GIT_TERMINAL_PROMPT = '0'   # fail fast on auth prompts instead of hanging

# --- 0. validate URL first (fail fast before slow work) ---
try {
  $u = [Uri]$RepoUrl
  $valid = $u.IsAbsoluteUri -and ($u.Scheme -eq 'https' -or $u.Scheme -eq 'http') `
       -and $u.Host -and -not [string]::IsNullOrWhiteSpace($u.AbsolutePath.Trim('/'))
} catch { $valid = $false }
if (-not $valid) { throw "Invalid git URL (use https://...): $RepoUrl" }

# --- 1. compact ---
& (Join-Path $PSScriptRoot 'compact-project.ps1')

# --- 2. extract newest archive into a clean __GIT_EXPORT ---
$root   = Split-Path -Parent $PSScriptRoot
$zip    = Get-ChildItem (Join-Path $root 'Tomb-of-the-Mask_*.zip') |
          Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $zip) { throw 'No Tomb-of-the-Mask_*.zip archive found after compact.' }
$export = Join-Path $root '__GIT_EXPORT'
if (Test-Path $export) { Remove-Item $export -Recurse -Force }
New-Item -ItemType Directory -Path $export | Out-Null
Expand-Archive -Path $zip.FullName -DestinationPath $export
Write-Host "Extracted $($zip.Name) to __GIT_EXPORT"

# --- 3. push ---
Push-Location $export
try {
  git init -q; if ($LASTEXITCODE -ne 0) { throw 'git init failed' }
  git add -A; if ($LASTEXITCODE -ne 0) { throw 'git add failed' }
  if (-not (git config user.name)) {   # local identity fallback so commit works
    git config user.name  "$($env:USERNAME)"
    git config user.email "$($env:USERNAME)@localhost"
  }
  git commit -q -m "Project export $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
  if ($LASTEXITCODE -ne 0) { throw 'git commit failed' }
  git branch -M main
  git remote remove origin 2>$null
  git remote add origin $RepoUrl
  git push -u origin main
  if ($LASTEXITCODE -ne 0) { throw "git push failed (exit $LASTEXITCODE)" }

  Write-Host ''
  Write-Host "PUSH OK -> $RepoUrl" -ForegroundColor Green
  Write-Host "Local copy: $export"
} catch {
  Write-Host ''
  $w = 66
  Write-Host ('#' * $w) -ForegroundColor Red
  Write-Host ('#' * $w) -ForegroundColor Red
  Write-Host ('##  ' + (' ' * 62) + '##') -ForegroundColor Red
  Write-Host ('##  !!!!!  UPLOAD FAILED — CANNOT PUSH DIRECTLY  !!!!!') -ForegroundColor Red
  Write-Host ('##  ' + $_.Exception.Message) -ForegroundColor Red
  Write-Host ('##  ' + (' ' * 62) + '##') -ForegroundColor Red
  Write-Host ('##  Upload manually via GitHub web UI:') -ForegroundColor Red
  Write-Host ('##    open https://github.com/new , create an EMPTY repo,') -ForegroundColor Red
  Write-Host ('##    copy its URL (e.g. https://github.com/user/repo.git),') -ForegroundColor Red
  Write-Host ('##    then run these commands:') -ForegroundColor Red
  Write-Host ('##') -ForegroundColor Red
  Write-Host ('##      cd __GIT_EXPORT') -ForegroundColor Red
  Write-Host ('##      git init') -ForegroundColor Red
  Write-Host ('##      git add -A') -ForegroundColor Red
  Write-Host ('##      git commit -m "export"') -ForegroundColor Red
  Write-Host ('##      git branch -M main') -ForegroundColor Red
  Write-Host ('##      git remote add origin ' + $RepoUrl) -ForegroundColor Red
  Write-Host ('##      git push -u origin main') -ForegroundColor Red
  Write-Host ('##') -ForegroundColor Red
  Write-Host ('##  or use the GitHub web "upload files" button on __GIT_EXPORT contents.') -ForegroundColor Red
  Write-Host ('##  ' + (' ' * 62) + '##') -ForegroundColor Red
  Write-Host ('#' * $w) -ForegroundColor Red
  Write-Host ('#' * $w) -ForegroundColor Red
  Write-Host ''
  Read-Host 'Press Enter to exit'
} finally {
  Pop-Location
}
