# =========================
# Epson Resetter Console GUI
# =========================

# ---------- CONFIG ----------
$OutDir = "$env:TEMP\Epson-Resetter"
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="https://www.dropbox.com/scl/fi/yuscc3h8xmfetwb08wnfn/L3150.zip?dl=1"; File="L3150.zip"; Exe="AdjProg.exe"}
)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# ---------- ASCII ART HEADER ----------
$asciiHeader = @"
███████╗██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔══██╗██╔════╝
█████╗  ██████╔╝██████╔╝█████╗  
██╔══╝  ██╔═══╝ ██╔═══╝ ██╔══╝  
███████╗██║     ██║     ███████╗
╚══════╝╚═╝     ╚═╝     ╚══════╝
        EPSON RESETTER
"@

Write-Host $asciiHeader -ForegroundColor Cyan

# ---------- SELECT MODEL ----------
Write-Host "Available Printer Models:" -ForegroundColor Yellow
for ($i=0; $i -lt $tools.Count; $i++) {
    Write-Host "$($i+1)) $($tools[$i].Model)"
}

[int]$choice = Read-Host "Enter the number of your printer model"

if ($choice -lt 1 -or $choice -gt $tools.Count) {
    Write-Host "Invalid choice!" -ForegroundColor Red
    exit
}

$tool = $tools[$choice - 1]

if (-not $tool.Url) {
    Write-Host "Resetter not found for $($tool.Model)" -ForegroundColor Red
    exit
}

# ---------- PREPARE PATHS ----------
$OutFile = Join-Path $OutDir $tool.File
$ExtractDir = Join-Path $OutDir $tool.Model

if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

# ---------- DOWNLOAD ----------
Write-Host "Downloading $($tool.Model) resetter..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "Download failed! Check your internet connection or URL." -ForegroundColor Red
    exit
}

# ---------- EXTRACT ----------
Write-Host "Extracting ZIP..." -ForegroundColor Cyan
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "ZIP extraction failed!" -ForegroundColor Red
    exit
}

# ---------- LAUNCH EXECUTABLE ----------
$exe = Get-ChildItem -Path $ExtractDir -Recurse -Filter $tool.Exe | Select-Object -First 1
if ($exe) {
    Write-Host "Launching $($tool.Exe)..." -ForegroundColor Cyan
    Start-Process $exe.FullName
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "Executable not found!" -ForegroundColor Red
}
