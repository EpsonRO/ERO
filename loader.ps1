# =========================
# Epson Resetter - Console Version
# =========================

$OutDir = "$env:TEMP\ERO-Tools"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Define printer models
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="https://github.com/EpsonRO/L3150/releases/download/L3150/L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

# ----------------------
# Select model
# ----------------------
Write-Host "Available Models:" -ForegroundColor Cyan
for ($i=0; $i -lt $tools.Count; $i++) {
    Write-Host "$($i+1)) $($tools[$i].Model)"
}

[int]$choice = Read-Host "Enter the number of your printer model"
if ($choice -lt 1 -or $choice -gt $tools.Count) {
    Write-Host "Invalid choice!" -ForegroundColor Red
    exit
}

$tool = $tools[$choice - 1]
$OutFile = Join-Path $OutDir $tool.File
$ExtractDir = Join-Path $OutDir $tool.Model

# ----------------------
# Download ZIP with progress
# ----------------------
if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

Write-Host "Downloading $($tool.Model)..."

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent","Mozilla/5.0")

# Progress event
$wc.DownloadProgressChanged += {
    param($sender, $e)
    Write-Progress -Activity "Downloading $($tool.Model)" -Status "$($e.ProgressPercentage)% complete" -PercentComplete $e.ProgressPercentage
}

# Download
try {
    $wc.DownloadFile($tool.Url, $OutFile)
    Write-Host "`nDownload complete!" -ForegroundColor Green
} catch {
    Write-Host "`nDownload failed! Check your URL or internet." -ForegroundColor Red
    exit
}

# ----------------------
# Extract ZIP
# ----------------------
Write-Host "Extracting ZIP..."
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile,$ExtractDir)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "Error extracting ZIP!" -ForegroundColor Red
    exit
}

# ----------------------
# Launch EXE
# ----------------------
$exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
if ($exe) {
    Write-Host "Launching $($tool.Exe)..." -ForegroundColor Cyan
    Start-Process $exe.FullName
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "Executable not found!" -ForegroundColor Red
}
