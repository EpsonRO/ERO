# =========================
# Epson Resetter Console Downloader
# =========================

# Output directory
$OutDir = "$env:TEMP\Epson-Resetter"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Available tools (model -> direct download link)
$tools = @{
    "L6190" = "https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"
    "L3150" = "https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?dl=1"
}

# Prompt user for model
$model = Read-Host "Enter your printer model (e.g., L6190, L3150)"

# Check if link exists
if (-not $tools.ContainsKey($model)) {
    Write-Host "Resetter not found for $model" -ForegroundColor Red
    exit
}

$url = $tools[$model]
$zipFile = Join-Path $OutDir "$model.zip"
$extractDir = Join-Path $OutDir $model

# Remove old files
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }

# Download
Write-Host "Downloading resetter for $model..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "Download failed! Check your internet connection or URL." -ForegroundColor Red
    exit
}

# Extract ZIP
Write-Host "Extracting..." -ForegroundColor Cyan
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractDir)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "ZIP extraction failed!" -ForegroundColor Red
    exit
}

# Run executable
$exe = Get-ChildItem -Path $extractDir -Recurse -Filter "AdjProg.exe" | Select-Object -First 1
if ($exe) {
    Write-Host "Launching AdjProg.exe..." -ForegroundColor Cyan
    Start-Process $exe.FullName
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "AdjProg.exe not found in extracted files." -ForegroundColor Red
}
