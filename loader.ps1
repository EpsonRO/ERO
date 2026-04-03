# =========================
# ADD REQUIRED ASSEMBLIES
# =========================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# =========================
# DATA
# =========================
$seriesModels = @{
    "L-Series" = @("L6190","L3150")
}

$tools = @(
    @{Model="L6190"; Url="YOUR_DIRECT_LINK_L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="YOUR_DIRECT_LINK_L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# =========================
# GUI SETUP
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

# Model ListBox
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)

# Detail Label
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$form.Controls.Add($detailLabel)

# Download Button
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "DOWNLOAD & LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,420)
$progressBar.Size = New-Object System.Drawing.Size(490,20)
$form.Controls.Add($progressBar)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::White
$statusLabel.Location = New-Object System.Drawing.Point(30,450)
$statusLabel.Size = New-Object System.Drawing.Size(490,30)
$form.Controls.Add($statusLabel)

# =========================
# GUI EVENTS
# =========================
$form.Add_Shown({
    $title.Left = ($form.ClientSize.Width - $title.Width)/2
    $title.Top = 20
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
    $text = $searchBox.Text
    $modelList.Items.Clear()
    $seriesModels[$seriesCombo.SelectedItem] | Where-Object { $_ -like "*$text*" } | ForEach-Object { $modelList.Items.Add($_) }
})

$modelList.Add_SelectedIndexChanged({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $detailLabel.Text = "Model: $selModel"
        $foundTool = $tools | Where-Object { $_.Model -eq $selModel }
        $buttonDownload.Enabled = $foundTool -ne $null
        if ($foundTool) { $statusLabel.Text = "RESETTER AVAILABLE!" } else { $statusLabel.Text = "RESETTER NOT AVAILABLE YET!" }
    }
})

# =========================
# DOWNLOAD & LAUNCH FUNCTION USING JOB
# =========================
$buttonDownload.Add_Click({
    $tool = $tools | Where-Object { $_.Model -eq $modelList.SelectedItem }
    if ($tool) {
        $buttonDownload.Enabled = $false
        $progressBar.Style = 'Marquee'
        $progressBar.MarqueeAnimationSpeed = 30
        $statusLabel.Text = "Downloading..."

        # Remove old files
        if (Test-Path (Join-Path $OutDir $tool.File)) { Remove-Item (Join-Path $OutDir $tool.File) -Force }
        if (Test-Path (Join-Path $OutDir $tool.Model)) { Remove-Item (Join-Path $OutDir $tool.Model) -Recurse -Force }

        # Start download job
        $job = Start-Job -ScriptBlock {
            param($Url,$OutFile)
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent","Mozilla/5.0")
            $wc.DownloadFile($Url, $OutFile)
        } -ArgumentList $tool.Url,(Join-Path $OutDir $tool.File)

        # Wait & update GUI
        while ($job.State -eq 'Running') {
            Start-Sleep -Milliseconds 200
            [System.Windows.Forms.Application]::DoEvents()
        }

        Receive-Job $job | Out-Null
        Remove-Job $job

        # Extract
        try {
            $ExtractDir = Join-Path $OutDir $tool.Model
            [System.IO.Compression.ZipFile]::ExtractToDirectory((Join-Path $OutDir $tool.File), $ExtractDir)
            $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
            if ($exe) { Start-Process $exe.FullName; $statusLabel.Text="Done! Launched." }
            else { $statusLabel.Text="Executable not found." }
        } catch { $statusLabel.Text="Error extracting ZIP." }

        $progressBar.Style = 'Blocks'
        $buttonDownload.Enabled = $true
    }
})

# =========================
# SHOW GUI
# =========================
$form.ShowDialog()
