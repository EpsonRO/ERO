# =========================
# EPSON RESETTER GUI (Universal)
# =========================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# -----------------------
# Settings
# -----------------------
$OutDir = "$env:TEMP\ERO-Tools"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$tools = @(
    @{Model="L6190"; Url="DIRECT_LINK_L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="DIRECT_LINK_L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

# -----------------------
# GUI
# -----------------------
$form = New-Object System.Windows.Forms.Form
$form.Size = [System.Drawing.Size]::new(580,520)
$form.Text = "EPSON RESETTER ONLINE"
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = [System.Drawing.Point]::new(30,20)
$form.Controls.Add($title)

# Model selection
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = [System.Drawing.Point]::new(30,80)
$modelList.Size = [System.Drawing.Size]::new(520,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)
$tools | ForEach-Object { $modelList.Items.Add($_.Model) }

# Detail Label
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = [System.Drawing.Point]::new(30,290)
$detailLabel.Size = [System.Drawing.Size]::new(520,30)
$form.Controls.Add($detailLabel)

# Download Button
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "DOWNLOAD & LAUNCH"
$buttonDownload.Location = [System.Drawing.Point]::new(30,330)
$buttonDownload.Size = [System.Drawing.Size]::new(520,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = [System.Drawing.Point]::new(30,380)
$progressBar.Size = [System.Drawing.Size]::new(520,20)
$progressBar.Style = 'Marquee'
$progressBar.MarqueeAnimationSpeed = 0
$form.Controls.Add($progressBar)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::White
$statusLabel.Location = [System.Drawing.Point]::new(30,410)
$statusLabel.Size = [System.Drawing.Size]::new(520,30)
$form.Controls.Add($statusLabel)

# -----------------------
# GUI Events
# -----------------------
$modelList.Add_SelectedIndexChanged({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $detailLabel.Text = "Model: $selModel"
        $buttonDownload.Enabled = $true
    } else {
        $buttonDownload.Enabled = $false
    }
})

$buttonDownload.Add_Click({
    $selModel = $modelList.SelectedItem
    $tool = $tools | Where-Object { $_.Model -eq $selModel }
    if (-not $tool) { return }

    $buttonDownload.Enabled = $false
    $progressBar.MarqueeAnimationSpeed = 30
    $statusLabel.Text = "Downloading..."

    $OutFile = Join-Path $OutDir $tool.File
    $ExtractDir = Join-Path $OutDir $tool.Model

    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

    try {
        # Download synchronously
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent","Mozilla/5.0")
        $wc.DownloadFile($tool.Url, $OutFile)
        $statusLabel.Text = "Download complete!"
    } catch {
        $statusLabel.Text = "Download failed!"
        $buttonDownload.Enabled = $true
        $progressBar.MarqueeAnimationSpeed = 0
        return
    }

    # Extract ZIP
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile,$ExtractDir)
        $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
        if ($exe) { Start-Process $exe.FullName; $statusLabel.Text="Done! Launched." }
        else { $statusLabel.Text="Executable not found." }
    } catch {
        $statusLabel.Text = "Error extracting ZIP!"
    }

    $progressBar.MarqueeAnimationSpeed = 0
    $buttonDownload.Enabled = $true
})

# -----------------------
# Show GUI
# -----------------------
$form.ShowDialog()
