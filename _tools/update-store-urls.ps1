$ErrorActionPreference = 'Stop'

$appStoreUrl = Read-Host 'Enter APP_STORE_URL'
$googlePlayUrl = Read-Host 'Enter GOOGLE_PLAY_URL'

function To-JsString($value) {
    return ($value | ConvertTo-Json -Compress)
}

$values = @{
    APP_STORE_URL = To-JsString $appStoreUrl
    GOOGLE_PLAY_URL = To-JsString $googlePlayUrl
}

$files = Get-ChildItem -Path $PSScriptRoot -Recurse -File -Filter *.html

foreach ($file in $files) {
    $html = Get-Content -LiteralPath $file.FullName -Raw
    $original = $html
    $missing = @()

    foreach ($name in $values.Keys) {
        $value = $values[$name]
        $assignment = "window.$name = $value;"
        $patterns = @(
            "window\s*\.\s*$name\s*=\s*(['\""'])(?:(?!\1).)*\1\s*;?",
            "(?:const|let|var)\s+$name\s*=\s*(['\""'])(?:(?!\1).)*\1\s*;?"
        )

        $found = $false
        foreach ($pattern in $patterns) {
            if ($html -match $pattern) {
                $html = [regex]::Replace($html, $pattern, $assignment)
                $found = $true
            }
        }

        if (-not $found) {
            $missing += $assignment
        }
    }

    if ($missing.Count -gt 0) {
        $script = "<script>`n$($missing -join "`n")`n</script>"
        $headRegex = [regex]::new('</head>', 'IgnoreCase')
        if ($headRegex.IsMatch($html)) {
            $html = $headRegex.Replace($html, "$script`n</head>", 1)
        } else {
            $html = "$script`n$html"
        }
    }

    if ($html -ne $original) {
        Set-Content -LiteralPath $file.FullName -Value $html -Encoding UTF8
        Write-Host "Updated $($file.FullName)"
    }
}

Write-Host "Done. Scanned $($files.Count) html file(s)."
