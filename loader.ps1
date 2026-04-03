# =========================
# Epson Resetter Console Menu with ASCII Art (ERO)
# =========================

# Output directory
$OutDir = "$env:TEMP\Epson-Resetter"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Epson Models by Series
$allModels = @{
    "L Series" = @{
        "L6190" = "https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"
        "L3150" = "https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?dl=1"
        "L8050" = $null
        "L4550" = $null
    }
    "WF Series" = @{
        "WF-2860" = $null
        "WF-2850" = $null
    }
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
+++++++++++++++++++++
EPSON RESETTER ONLINE
+++++++++++++++++++++

"@ -ForegroundColor Cyan
}

# Download, extract and launch function
function Run-Resetter {
    param($model, $series)

    $link = $allModels[$series][$model]
    if ([string]::IsNullOrEmpty($link)) {
        Write-Host "`nResetter not added yet for $model." -ForegroundColor Yellow
        Start-Sleep 2
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
        Start-Sleep 2
        return
    }

    # ZIP extraction with fallback
    Write-Host "Extracting..." -ForegroundColor Cyan
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractDir)
        Write-Host "Extraction complete!" -ForegroundColor Green
    } catch {
        Write-Host "ZIP extraction failed! Trying Expand-Archive..." -ForegroundColor Yellow
        try {
            Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
            Write-Host "Extraction successful via Expand-Archive!" -ForegroundColor Green
        } catch {
            Write-Host "Failed to extract zip completely. Check the ZIP file." -ForegroundColor Red
            Start-Sleep 2
            return
        }
    }

    $exe = Get-ChildItem -Path $extractDir -Recurse -Filter "AdjProg.exe" | Select-Object -First 1
    if ($exe) {
        Write-Host "Launching AdjProg.exe..." -ForegroundColor Cyan
        Start-Process $exe.FullName -Wait
        Write-Host "`nAdjProg.exe closed. Returning to menu..." -ForegroundColor Green
        Start-Sleep 2
    } else {
        Write-Host "AdjProg.exe not found in extracted files." -ForegroundColor Red
        Start-Sleep 2
    }
}

# =========================
# Main Menu Loop
# =========================
while ($true) {
    Show-Banner
    Write-Host "Printer Series:" -ForegroundColor White
    $i = 1
    $seriesList = $allModels.Keys
    foreach ($s in $seriesList) { Write-Host "$i) $s"; $i++ }
    Write-Host "$i) Exit"

    $choice = Read-Host "`nSelect a series"
    if ($choice -eq $i) { 
        Write-Host "`nExiting... Goodbye!" -ForegroundColor Cyan
        break 
    }

    if ($choice -lt 1 -or $choice -gt ($i-1)) {
        Write-Host "`nInvalid choice!" -ForegroundColor Yellow
        Start-Sleep 1
        continue
    }

    $selectedSeries = $seriesList[$choice - 1]
    $models = $allModels[$selectedSeries].Keys
    Write-Host "`nAvailable models in $selectedSeries:" -ForegroundColor White
    $models | ForEach-Object { Write-Host "- $_" }

    $model = Read-Host "`nEnter your model"
    if (-not $allModels[$selectedSeries].ContainsKey($model)) {
        Write-Host "`nNot a valid model." -ForegroundColor Red
        Start-Sleep 1
        continue
    }

    Run-Resetter $model $selectedSeries
}
