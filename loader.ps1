Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===================
# SERIES & MODELS DATA
# ===================
$seriesModels = @{
    "L-Series" = @(
        "L110","L120","L121","L125","L130","L132","L200","L210","L220",
        "L222","L300","L301","L303","L310","L311","L312","L313","L315",
        "L350","L351","L353","L355","L360","L361","L363","L365","L380",
        "L382","L383","L405","L415","L6160","L6170","L6190"
    )
    "EcoTank" = @(
        "ET-2650","ET-2750","ET-2850","ET-3600","ET-3700","ET-4750",
        "ET-4800","ET-4850","ET-5800","ET-5850","ET-7700","ET-7750","ET-8500"
    )
    "XP-Series" = @(
        "XP-2100","XP-3100","XP-4100","XP-5100","XP-6000"
    )
    "WorkForce" = @(
        "WF-2630","WF-2850","WF-2860","WF-3620","WF-3640","WF-3820",
        "WF-4830"
    )
    "SureColor" = @(
        "SC-P400","SC-P600","SC-P800","SC-T3100","SC-T5100"
    )
    "Expression" = @(
        "XP-33","XP-55","XP-15000"
    )
    "Artisan" = @(
        "Artisan 1430","Artisan 1500"
    )
}

# ===================
# AVAILABLE TOOLS (WITH DOWNLOAD LINKS)
# ===================
# Add tools here as they become available
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"}
)

# ===================
# TEMP OUTPUT DIRECTORY
# ===================
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) {
    Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $OutDir | Out-Null

# ===================
# DOWNLOAD + RUN FUNCTION
# ===================
function Download-Run($tool) {
    $statusLabel.Text = "Downloading..."
    $buttonDownload.Enabled = $false
    $form.Refresh()

    $OutFile = Join-Path $OutDir $tool.File

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -Headers @{ "User-Agent"="Mozilla/5.0" }
    } catch {
        $statusLabel.Text = "Download failed."
        $buttonDownload.Enabled = $true
        return
    }

    $statusLabel.Text = "Extracting..."
    $form.Refresh()

    $ExtractDir = Join-Path $OutDir $tool.Model
    New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

    $exe = Get-ChildItem -Path $ExtractDir -Recurse |
           Where-Object { $_.Name -ieq $tool.Exe } |
           Select-Object -First 1

    if ($exe) {
        $statusLabel.Text = "Launching..."
        Start-Process $exe.FullName -Wait

        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "Executable not found."
    }

    $buttonDownload.Enabled = $true
}

# ===================
# UI BUILD
# ===================
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(580,650)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$form.Controls.Add($title)

# SERIES COMBOBOX
$seriesCombo = New-Object System.Windows.Forms.ComboBox
$seriesCombo.DropDownStyle = 'DropDownList'
$seriesCombo.Items.AddRange($seriesModels.Keys)
$seriesCombo.Location = New-Object System.Drawing.Point(30,100)
$seriesCombo.Size = New-Object System.Drawing.Size(220,30)
$form.Controls.Add($seriesCombo)

# SEARCH BOX
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.PlaceholderText = "Search model..."
$searchBox.Location = New-Object System.Drawing.Point(270,100)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$form.Controls.Add($searchBox)

# LISTBOX
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,150)
$modelList.Size = New-Object System.Drawing.Size(490,320)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)

# DETAILS LABEL
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = New-Object System.Drawing.Point(30,490)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$form.Controls.Add($detailLabel)

# DOWNLOAD BUTTON
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "Download & Run"
$buttonDownload.Location = New-Object System.Drawing.Point(30,530)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# STATUS BAR
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"

$spacer = New-Object System.Windows.Forms.ToolStripStatusLabel
$spacer.Spring = $true

$copyright = New-Object System.Windows.Forms.ToolStripStatusLabel
$copyright.Text = "© 2026 KLBSoft"

$statusStrip.Items.Add($statusLabel)
$statusStrip.Items.Add($spacer)
$statusStrip.Items.Add($copyright)
$form.Controls.Add($statusStrip)

# ===================
# UI BEHAVIOR EVENTS
# ===================

# Center title on show
$form.Add_Shown({
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
})

# Series selection
$seriesCombo.Add_SelectedIndexChanged({
    $selectedSeries = $seriesCombo.SelectedItem
    $modelList.Items.Clear()
    if ($selectedSeries) {
        $seriesModels[$selectedSeries] | ForEach-Object { $modelList.Items.Add($_) }
        $statusLabel.Text = "Showing models for $selectedSeries"
    }
    $detailLabel.Text = "Model: (none selected)"
    $buttonDownload.Enabled = $false
})

# Live search within selected series
$searchBox.Add_TextChanged({
    $query = $searchBox.Text.ToUpper()
    $modelList.Items.Clear()
    $selected = $seriesCombo.SelectedItem
    if ($selected) {
        $seriesModels[$selected] |
            Where-Object { $_.ToUpper() -like "*$query*" } |
            ForEach-Object { $modelList.Items.Add($_) }
        $statusLabel.Text = "Filter: '$query'"
    }
})

# Listbox selection -> show detail
$modelList.Add_SelectedIndexChanged({
    $selModel = $modelList.SelectedItem
    if ($selModel) {

        $detailLabel.Text = "Model: $selModel"
        $buttonDownload.Enabled = $false

        # Check tool availability
        $foundTool = $tools | Where-Object { $_.Model -eq $selModel }
        if ($foundTool) {
            $statusLabel.Text = "Tool available!"
            $buttonDownload.Enabled = $true
        } else {
            $statusLabel.Text = "Tool not available yet."
        }
    }
})

# Download & Run button click
$buttonDownload.Add_Click({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $tool = $tools | Where-Object { $_.Model -eq $selModel }
        if ($tool) {
            Download-Run $tool
        }
    }
})

# Allow Enter to trigger download
$modelList.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        if ($buttonDownload.Enabled) { $buttonDownload.PerformClick() }
    }
})

# ===================
# SHOW UI
# ===================
$form.ShowDialog()
