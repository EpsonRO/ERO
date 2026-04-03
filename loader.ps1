# =========================
# Epson Resetter Console Menu with ASCII Art (ERO)
# =========================

# Output directory
$OutDir = "$env:TEMP\Epson-Resetter"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Known models (some may have links, some not)
$allModels = @{
    "L6190" = "https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"
    "L3150" = "https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?dl=1"
    "L8050" = $null
    "L4550" = $null
}

# ASCII Art Banner
function Show-Banner {
    Clear-Host
    Write-Host @"
 ______ ____   ____  
|  ____|  _ \ / __ \ 
| |__  | |_) | |  | |
|  __| |  _ <| |  | |
| |____| |_) | |__| |
|______|____/ \____/ 
      ERO Resetters
"@ -ForegroundColor Cyan
}

# Download, extract and launch function
function Run-Resetter {
    param($model)

    $link = $allModels[$model]
    if ([string]::IsNullOrEmpty($link)) {
        Write-Host "`nResetter not added yet for $model." -ForegroundColor Yellow
        return
    }

    $zipFile = Join-Path $OutDir "$model.zip"
    $extractDir = Join-Path $OutDir $model

    if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
    if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }

    Write-Host "`nDownloading resetter for $model..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $link -OutFile $zipFile -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
        Write-Host "Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "Download failed! Check your internet connection or URL." -ForegroundColor Red
        return
    }

    Write-Host "Extracting..." -ForegroundColor Cyan
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractDir)
        Write-Host "Extraction complete!" -ForegroundColor Green
    } catch {
        Write-Host "ZIP extraction failed!" -ForegroundColor Red
        return
    }

    $exe = Get-ChildItem -Path $extractDir -Recurse -Filter "AdjProg.exe" | Select-Object -First 1
    if ($exe) {
        Write-Host "Launching AdjProg.exe..." -ForegroundColor Cyan
        Start-Process $exe.FullName -Wait
        Write-Host "`nAdjProg.exe closed. Returning to menu..." -ForegroundColor Green
    } else {
        Write-Host "AdjProg.exe not found in extracted files." -ForegroundColor Red
    }
}

# =========================
# Main Menu Loop
# =========================
while ($true) {
    Show-Banner
    Write-Host "Available actions:" -ForegroundColor White
    Write-Host "1) Run Epson Resetter"
    Write-Host "2) Exit"
    $choice = Read-Host "`nEnter choice"

    switch ($choice) {
        "1" {
            $model = Read-Host "`nEnter your printer model (e.g., L6190, L3150)"
            if (-not $allModels.ContainsKey($model)) {
                Write-Host "`nNot a valid model." -ForegroundColor Red
            } else {
                Run-Resetter $model
            }
        }
        "2" {
            Write-Host "`nExiting... Goodbye!" -ForegroundColor Cyan
            break
        }
        default {
            Write-Host "`nInvalid choice!" -ForegroundColor Yellow
        }
    }
}
