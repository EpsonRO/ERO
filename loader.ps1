# =========================
# Download & Run Epson L3150 Resetter (PowerShell Console)
# =========================

# --- SETTINGS ---
$dropboxUrl = "https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?rlkey=6hem5wrgingwyyly8kng7l6r2&st=t7n6eqj2&dl=1"
$OutDir = "$env:TEMP\Epson-L3150"
$zipFile = Join-Path $OutDir "L3150.zip"
$extractDir = Join-Path $OutDir "L3150"

# Create output directory
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

# Remove old files if present
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }

# --- DOWNLOAD ---
Write-Host "Downloading L3150 Resetter..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $dropboxUrl -OutFile $zipFile -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "Download failed! Check the link or your internet connection." -ForegroundColor Red
    exit
}

# --- EXTRACT ZIP ---
Write-Host "Extracting Resetter ZIP..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $extractDir)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "ZIP extraction failed!" -ForegroundColor Red
    exit
}

# --- RUN EXECUTABLE ---
Write-Host "Searching for AdjProg.exe..." -ForegroundColor Cyan

$exe = Get-ChildItem -Path $extractDir -Recurse -Filter "AdjProg.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($exe) {
    Write-Host "Launching AdjProg.exe..." -ForegroundColor Cyan
    Start-Process $exe.FullName
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "AdjProg.exe not found in the extracted files." -ForegroundColor Red
}

exit
