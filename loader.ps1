# =========================
# EPSON RESETTER GUI (Universal, polished)
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
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="https://github.com/EpsonRO/L6190/releases/download/L3150/L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

# -----------------------
# GUI
# -----------------------
$form = New-Object System.Windows.Forms.Form
$form.Size = [System.Drawing.Size]::new(600,500)
$form.Text = "EPSON RESETTER ONLINE"
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Layout panel
$layout = New-Object System.Windows.Forms.TableLayoutPanel
$layout.Dock = "Fill"
$layout.RowCount = 6
$layout.ColumnCount = 1
$layout.Padding = 10
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 40)))
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 60)))
$form.Controls.Add($layout)

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Anchor = "None"
$layout.Controls.Add($title,0,0)

# Model List
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Dock = "Fill"
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$modelList.Font = New-Object System.Drawing.Font("Segoe UI",10)
$tools | ForEach-Object { $modelList.Items.Add($_.Model) }
$layout.Controls.Add($modelList,0,1)

# Detail Label
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.AutoSize = $true
$layout.Controls.Add($detailLabel,0,2)

# Download Button
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "DOWNLOAD & LAUNCH"
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Height = 40
$buttonDownload.Enabled = $false
$layout.Controls.Add($buttonDownload,0,3)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Style = 'Marquee'
$progressBar.MarqueeAnimationSpeed = 0
$progressBar.Dock = "Top"
$layout.Controls.Add($progressBar,0,4)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::White
$statusLabel.AutoSize = $true
$layout.Controls.Add($statusLabel,0,5)

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
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent","Mozilla/5.0")
        $wc.DownloadFile($tool.Url, $OutFile)
        $statusLabel.Text = "Download complete!"
    } catch {
        $statusLabel.Text = "Download failed! Check the URL or internet."
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
