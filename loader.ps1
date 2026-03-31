Clear-Host

# ===== HEADER =====
Write-Host "=====================================" -ForegroundColor DarkCyan
Write-Host "         EPSON RESETTER ONLINE        " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor DarkCyan
Write-Host ""

# ===== CONFIG =====
$OutDir = "$env:USERPROFILE\Downloads\ERO-Tools"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Define tools: File, Type (exe/zip), and specific Exe to run inside zip if needed
$tools = @(
    @{Name="USBFix"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Type="zip"; Exe="AdjProg.exe"},
    @{Name="Tool2";  Url="https://github.com/<username>/<repo>/releases/download/v1.0/Tool2.zip";  File="Tool2.zip";  Type="zip"; Exe="Tool2.exe"}
)

# ===== FUNCTIONS =====
function Pause { Read-Host "Press Enter to continue..." }

function Download-Run($tool) {
    $OutFile = "$OutDir\$($tool.File)"

    Write-Host "[+] Downloading $($tool.Name)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -UseBasicParsing
        Write-Host "[+] Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "[!] Download failed." -ForegroundColor Red
        Pause
        return
    }

    if ($tool.Type -eq "exe") {
        Write-Host "[+] Running $($tool.Name)..." -ForegroundColor Cyan
        Start-Process -FilePath $OutFile -WorkingDirectory $OutDir -Wait
    }
    elseif ($tool.Type -eq "zip") {
        Write-Host "[+] Extracting archive..." -ForegroundColor Cyan
        $ExtractDir = "$OutDir\$($tool.File)-extracted"
        if (-not (Test-Path $ExtractDir)) { New-Item -ItemType Directory -Path $ExtractDir | Out-Null }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)
        Write-Host "[+] Extraction complete." -ForegroundColor Green

        # Run a specific executable inside the ZIP
        $exeName = $tool.Exe
        $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $exeName } | Select-Object -First 1

        if ($exe) {
            Write-Host "[+] Running $($exe.Name) from archive..." -ForegroundColor Cyan
            Start-Process -FilePath $exe.FullName -WorkingDirectory $ExtractDir -Wait
        } else {
            Write-Host "[!] Executable $exeName not found in the archive." -ForegroundColor Red
        }

        Pause
    }
}

# ===== MENU LOOP =====
while ($true) {
    Clear-Host
    Write-Host "================ TOOLS MENU ================" -ForegroundColor Green
    for ($i = 0; $i -lt $tools.Count; $i++) {
        Write-Host "$($i+1). $($tools[$i].Name)"
    }
    Write-Host "0. Exit" -ForegroundColor Yellow

    $choice = Read-Host "`nSelect tool"
    if ($choice -eq "0") { break }

    if ($choice -match "^\d+$") {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $tools.Count) {
            Download-Run $tools[$index]
        } else {
            Write-Host "[!] Invalid choice." -ForegroundColor Red
            Pause
        }
    } else {
        Write-Host "[!] Invalid input." -ForegroundColor Red
        Pause
    }
}
