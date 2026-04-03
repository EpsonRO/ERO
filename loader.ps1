# =========================
# Epson Resetter Console Downloader (Smart Version)
# =========================

# Output directory
$OutDir = "$env:TEMP\Epson-Resetter"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Define all known models (some may have links, some not)
$allModels = @{
    "L6190" = "https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"
    "L3150" = "https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?dl=1"
    "L8050" = $null   # Example of a model known but no resetter yet
    "L4550" = $null
}

# Prompt user
$model = Read-Host "Enter your printer model: "

# Logic check
if (-not $allModels.ContainsKey($model)) {
    Write-Host "`nNot a valid model." -ForegroundColor Red
    exit
}

# Model exists
$link = $allModels[$model]
if ([string]::IsNullOrEmpty($link)) {
    Write-Host "`nResetter not added yet for $model." -ForegroundColor Yellow
    exit
}

# Download and run
$zipFile = Join-Path $OutDir "$model.zip"
$extractDir = Join-Path $OutDir $model

# Clean previous files
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }

# Download
Write-Host "`nDownloading resetter for $model..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $link -OutFile $zipFile -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "Download failed! Check your internet connection or URL." -ForegroundColor Red
    exit
}

# Extract
Write-Host "Extracting..." -ForegroundColor Cyan
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractDir)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "ZIP extraction failed!" -ForegroundColor Red
    exit
}

# Launch executable
$exe = Get-ChildItem -Path $extractDir -Recurse -Filter "AdjProg.exe" | Select-Object -First 1
if ($exe) {
    Write-Host "Launching AdjProg.exe..." -ForegroundColor Cyan
    Start-Process $exe.FullName
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "AdjProg.exe not found in extracted files." -ForegroundColor Red
}
