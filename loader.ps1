Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.ComponentModel

# =========================
# SERIES & MODELS DATA
# =========================
$seriesModels = @{
    "L-Series"   = @("L110","L120","L121","L125","L130","L132","L200","L210","L220","L222","L300","L301","L303","L310","L311","L312","L313","L315","L350","L351","L353","L355","L360","L361","L363","L365","L380","L382","L383","L405","L415","L6160","L6170","L6190","L3150")
    "EcoTank"    = @("ET-2650","ET-2750","ET-2850","ET-3600","ET-3700","ET-4750","ET-4800","ET-4850","ET-5800","ET-5850","ET-7700","ET-7750","ET-8500")
    "XP-Series"  = @("XP-2100","XP-3100","XP-4100","XP-5100","XP-6000")
    "WF-Series"  = @("WF-2830","WF-2850","WF-2860","WF-3730","WF-3750","WF-3800","WF-3820","WF-4010","WF-4830")
}

# =========================
# TOOLS
# =========================
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="https://github.com/EpsonRO/L6190/releases/download/L3150/L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

# =========================
# TEMP DIR
# =========================
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# =========================
# FORM BUILD
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(580,520)
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
$form.Controls.Add($title)

# Series ComboBox
$seriesCombo = New-Object System.Windows.Forms.ComboBox
$seriesCombo.DropDownStyle = 'DropDownList'
$seriesCombo.Items.AddRange($seriesModels.Keys)
$seriesCombo.Location = New-Object System.Drawing.Point(30,80)
$seriesCombo.Size = New-Object System.Drawing.Size(220,30)
$seriesCombo.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$seriesCombo.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($seriesCombo)

# Search Box
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Text = "Search model..."
$searchBox.ForeColor = [System.Drawing.Color]::Gray
$searchBox.Location = New-Object System.Drawing.Point(270,80)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($searchBox)
$searchBox.Add_GotFocus({ if ($searchBox.Text -eq "Search model...") { $searchBox.Text=""; $searchBox.ForeColor=[System.Drawing.Color]::White } })
$searchBox.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($searchBox.Text)) { $searchBox.Text="Search model..."; $searchBox.ForeColor=[System.Drawing.Color]::Gray } })

# ListBox
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)

# Details Label
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$form.Controls.Add($detailLabel)

# Download Button (blue)
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204) # bright blue
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,420)
$progressBar.Size = New-Object System.Drawing.Size(490,20)
$form.Controls.Add($progressBar)

# Status Strip (light)
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.Color]::White
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::Black
$statusStrip.Items.Add($statusLabel)
$form.Controls.Add($statusStrip)

# =========================
# EVENTS
# =========================
$form.Add_Shown({
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
    $title.Top = 20
    # Preload L-Series
    $seriesCombo.SelectedItem = "L-Series"
    $seriesModels["L-Series"] | ForEach-Object { $modelList.Items.Add($_) }
})

$seriesCombo.Add_SelectedIndexChanged({
    $selectedSeries = $seriesCombo.SelectedItem
    $modelList.Items.Clear()
    if ($selectedSeries) { $seriesModels[$selectedSeries] | ForEach-Object { $modelList.Items.Add($_) } }
    $detailLabel.Text = "Model: (none selected)"
    $buttonDownload.Enabled = $false
})

$searchBox.Add_TextChanged({
    if ($searchBox.Text -eq "Search model...") { return }
    $query = $searchBox.Text.ToUpper()
    $modelList.Items.Clear()
    $selected = $seriesCombo.SelectedItem
    if ($selected) { $seriesModels[$selected] | Where-Object { $_.ToUpper() -like "*$query*" } | ForEach-Object { $modelList.Items.Add($_) } }
})

$modelList.Add_SelectedIndexChanged({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $detailLabel.Text = "Model: $selModel"
        $foundTool = $tools | Where-Object { $_.Model -eq $selModel }
        $buttonDownload.Enabled = $foundTool -ne $null
        if ($foundTool) { $statusLabel.Text = "RESETTER AVAILABLE!" }
        else { $statusLabel.Text = "RESETTER NOT AVAILABLE YET!" }
    }
})

# =========================
# BACKGROUNDWORKER DOWNLOAD
# =========================
$bgWorker = New-Object System.ComponentModel.BackgroundWorker
$bgWorker.WorkerReportsProgress = $true

$toolToDownload = $null

$bgWorker.DoWork += {
    param($sender, $e)
    $tool = $e.Argument

    $OutFile = Join-Path $OutDir $tool.File
    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }

    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent","Mozilla/5.0")
    $wc.DownloadProgressChanged += { param($s,$p) $bgWorker.ReportProgress($p.ProgressPercentage,"Downloading... $($p.ProgressPercentage)%") }
    $wc.DownloadFile($tool.Url, $OutFile)

    # Extract
    $ExtractDir = Join-Path $OutDir $tool.Model
    if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
    New-Item -ItemType Directory -Path $ExtractDir | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

    # Run EXE
    $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
    if ($exe) { Start-Process $exe.FullName }
}

$bgWorker.ProgressChanged += {
    param($s,$e)
    $progressBar.Value = $e.ProgressPercentage
    $statusLabel.Text = $e.UserState
}

$bgWorker.RunWorkerCompleted += {
    param($s,$e)
    $statusLabel.Text = "Done!"
    $buttonDownload.Enabled = $true
}

$buttonDownload.Add_Click({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $toolToDownload = $tools | Where-Object { $_.Model -eq $selModel }
        if ($toolToDownload) {
            $buttonDownload.Enabled = $false
            $progressBar.Value = 0
            $statusLabel.Text = "Starting..."
            $bgWorker.RunWorkerAsync($toolToDownload)
        }
    }
})

$form.ShowDialog()
