# =========================
# Epson Resetter - Pure PowerShell Console
# =========================

$OutDir = "$env:TEMP\ERO-Tools"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Printer models and URLs
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
# Remove old files
# ----------------------
if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

# ----------------------
# Download with manual progress
# ----------------------
Write-Host "Downloading $($tool.Model)..."

try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent","Mozilla/5.0")

    $response = $wc.OpenRead($tool.Url)
    $total = $response.Length
    $buffer = New-Object byte[] 8192
    $read = 0
    $fileStream = [System.IO.File]::OpenWrite($OutFile)

    while (($count = $response.Read($buffer,0,$buffer.Length)) -gt 0) {
        $fileStream.Write($buffer,0,$count)
        $read += $count
        $percent = [int](($read / $total) * 100)
        Write-Progress -Activity "Downloading $($tool.Model)" -Status "$percent% complete" -PercentComplete $percent
    }

    $fileStream.Close()
    $response.Close()
    Write-Host "`nDownload complete!" -ForegroundColor Green
} catch {
    Write-Host "Download failed! Check your internet connection or URL." -ForegroundColor Red
    exit
}

# ----------------------
# Extract ZIP
# ----------------------
Write-Host "Extracting ZIP..."
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)
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
    Write-Host "Launching $($tool.Exe)..."
    Start-Process $exe.FullName
    Write-Host "Done!"
} else {
    Write-Host "Executable not found!" -ForegroundColor Red
}
