# compact-project.ps1 — zip the Cocos project, excluding generated/temp/AI folders.
# Uses native tar.exe (Windows 10 1803+). Output: <project>_YYYYMMDD-HHmm.zip next to this file.
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot   # project root (script lives in tools/)
$zip  = Join-Path $root ('Tomb-of-the-Mask_' + (Get-Date -Format 'yyyyMMdd-HHmm') + '.zip')

$excludes = @(
  '.git', '.creator', '.vscode', '.idea',
  'library', 'temp', 'local', 'build', 'native',
  'profiles', 'node_modules', '_TASK',
  '*.zip', 'compact-project.ps1', '__GIT_EXPORT',
  '*AGENTS.md*', 'CONTEXT.md', 'CLAUDE.md', '*.cursorrules',
  '.pi', '.claude', '.cursor'
)

$tarArgs = @('-a', '-c', '-f', $zip)
foreach ($e in $excludes) { $tarArgs += '--exclude=' + $e }
$tarArgs += '.'

Push-Location $root
try {
  & tar @tarArgs
  if ($LASTEXITCODE -ne 0) { throw "tar failed (exit $LASTEXITCODE)" }
} finally { Pop-Location }

Write-Host "Created $zip ($([math]::Round((Get-Item $zip).Length / 1MB, 1)) MB)"
