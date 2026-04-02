Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# SERIES & MODELS DATA
# =========================
$seriesModels = @{
    "L-Series"   = @("L110","L120","L121","L125","L130","L132","L200","L210","L220","L222","L300","L301","L303","L310","L311","L312","L313","L315","L350","L351","L353","L355","L360","L361","L363","L365","L380","L382","L383","L405","L415","L6160","L6170","L6190")
    "EcoTank"    = @("ET-2650","ET-2750","ET-2850","ET-3600","ET-3700","ET-4750","ET-4800","ET-4850","ET-5800","ET-5850","ET-7700","ET-7750","ET-8500")
    "XP-Series"  = @("XP-2100","XP-3100","XP-4100","XP-5100","XP-6000")
    "WF-Series"  = @("WF-2830","WF-2850","WF-2860","WF-3730","WF-3750","WF-3800","WF-3820","WF-4010","WF-4830")
}

# =========================
# AVAILABLE TOOLS
# =========================
$tools = @(
    # L-Series
    # @{Model="L110"; Url=$null; File=$null; Exe=$null},
    # @{Model="L120"; Url=$null; File=$null; Exe=$null},
    # @{Model="L121"; Url=$null; File=$null; Exe=$null},
    # @{Model="L125"; Url=$null; File=$null; Exe=$null},
    # @{Model="L130"; Url=$null; File=$null; Exe=$null},
    # @{Model="L132"; Url=$null; File=$null; Exe=$null},
    # @{Model="L200"; Url=$null; File=$null; Exe=$null},
    # @{Model="L210"; Url=$null; File=$null; Exe=$null},
    # @{Model="L220"; Url=$null; File=$null; Exe=$null},
    # @{Model="L222"; Url=$null; File=$null; Exe=$null},
    # @{Model="L300"; Url=$null; File=$null; Exe=$null},
    # @{Model="L301"; Url=$null; File=$null; Exe=$null},
    # @{Model="L303"; Url=$null; File=$null; Exe=$null},
    # @{Model="L310"; Url=$null; File=$null; Exe=$null},
    # @{Model="L311"; Url=$null; File=$null; Exe=$null},
    # @{Model="L312"; Url=$null; File=$null; Exe=$null},
    # @{Model="L313"; Url=$null; File=$null; Exe=$null},
    # @{Model="L315"; Url=$null; File=$null; Exe=$null},
    # @{Model="L350"; Url=$null; File=$null; Exe=$null},
    # @{Model="L351"; Url=$null; File=$null; Exe=$null},
    # @{Model="L353"; Url=$null; File=$null; Exe=$null},
    # @{Model="L355"; Url=$null; File=$null; Exe=$null},
    # @{Model="L360"; Url=$null; File=$null; Exe=$null},
    # @{Model="L361"; Url=$null; File=$null; Exe=$null},
    # @{Model="L363"; Url=$null; File=$null; Exe=$null},
    # @{Model="L365"; Url=$null; File=$null; Exe=$null},
    # @{Model="L380"; Url=$null; File=$null; Exe=$null},
    # @{Model="L382"; Url=$null; File=$null; Exe=$null},
    # @{Model="L383"; Url=$null; File=$null; Exe=$null},
    # @{Model="L385"; Url=$null; File=$null; Exe=$null},
    # @{Model="L405"; Url=$null; File=$null; Exe=$null},
    # @{Model="L415"; Url=$null; File=$null; Exe=$null},
    # @{Model="L4160"; Url=$null; File=$null; Exe=$null},
    # @{Model="L450"; Url=$null; File=$null; Exe=$null},
    # @{Model="L455"; Url=$null; File=$null; Exe=$null},
    # @{Model="L456"; Url=$null; File=$null; Exe=$null},
    # @{Model="L475"; Url=$null; File=$null; Exe=$null},
    # @{Model="L485"; Url=$null; File=$null; Exe=$null},
    # @{Model="L486"; Url=$null; File=$null; Exe=$null},
    # @{Model="L5190"; Url=$null; File=$null; Exe=$null},
    # @{Model="L5290"; Url=$null; File=$null; Exe=$null},
    # @{Model="L550"; Url=$null; File=$null; Exe=$null},
    # @{Model="L555"; Url=$null; File=$null; Exe=$null},
    # @{Model="L565"; Url=$null; File=$null; Exe=$null},
    # @{Model="L575"; Url=$null; File=$null; Exe=$null},
    # @{Model="L605"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6160"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6170"; Url=$null; File=$null; Exe=$null},
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe";
    # @{Model="L6270"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6290"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6490"; Url=$null; File=$null; Exe=$null},
    # @{Model="L655"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6570"; Url=$null; File=$null; Exe=$null},
    # @{Model="L6580"; Url=$null; File=$null; Exe=$null},
    # @{Model="L805"; Url=$null; File=$null; Exe=$null},
    # @{Model="L810"; Url=$null; File=$null; Exe=$null},
    # @{Model="L850"; Url=$null; File=$null; Exe=$null},
    # @{Model="L1110"; Url=$null; File=$null; Exe=$null},
    # @{Model="L1118"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3110"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3115"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3116"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3150"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3151"; Url=$null; File=$null; Exe=$null},
    # @{Model="L3156"; Url=$null; File=$null; Exe=$null},
    # @{Model="L1300"; Url=$null; File=$null; Exe=$null},
    # @{Model="L1800"; Url=$null; File=$null; Exe=$null},

    # EcoTank
    # @{Model="ET-2650"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-2750"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-2850"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-3600"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-3700"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-4750"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-4800"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-4850"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-5800"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-5850"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-7700"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-7750"; Url=$null; File=$null; Exe=$null},
    # @{Model="ET-8500"; Url=$null; File=$null; Exe=$null},

    # XP-Series
    # @{Model="XP-2100"; Url=$null; File=$null; Exe=$null},
    # @{Model="XP-3100"; Url=$null; File=$null; Exe=$null},
    # @{Model="XP-4100"; Url=$null; File=$null; Exe=$null},
    # @{Model="XP-5100"; Url=$null; File=$null; Exe=$null},
    # @{Model="XP-6000"; Url=$null; File=$null; Exe=$null},

    # WF-Series
    # @{Model="WF-2830"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-2850"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-2860"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-3730"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-3750"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-3800"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-3820"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-4010"; Url=$null; File=$null; Exe=$null},
    # @{Model="WF-4830"; Url=$null; File=$null; Exe=$null}
)
# =========================
# TEMP OUTPUT DIRECTORY
# =========================
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# =========================
# DOWNLOAD FUNCTION (SAFE)
# =========================
function Download-Run($tool) {
    $form.UseWaitCursor = $true
    $form.Refresh()
    $statusLabel.Text = "Downloading..."
    $buttonDownload.Enabled = $false
    $form.Refresh()

    $OutFile = Join-Path $OutDir $tool.File
    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -Headers @{ "User-Agent"="Mozilla/5.0" }
    } catch {
        $statusLabel.Text = "Download failed."
        $buttonDownload.Enabled = $true
        $form.UseWaitCursor = $false
        return
    }

    $statusLabel.Text = "Cleaning previous extraction..."
    $form.Refresh()

    $ExtractDir = Join-Path $OutDir $tool.Model
    if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $ExtractDir | Out-Null

    $statusLabel.Text = "Extracting..."
    $form.Refresh()

    # Manual extraction to allow overwrite
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($OutFile)
    foreach ($entry in $zip.Entries) {
        $target = Join-Path $ExtractDir $entry.FullName
        $targetDir = Split-Path $target -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
        if (Test-Path $target) { Remove-Item $target -Force }
        $entryStream = $entry.Open()
        $fileStream = [System.IO.File]::OpenWrite($target)
        $entryStream.CopyTo($fileStream)
        $fileStream.Close()
        $entryStream.Close()
    }
    $zip.Dispose()

    $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
    if ($exe) {
        $statusLabel.Text = "Launching..."
        $form.Refresh()
        Start-Process $exe.FullName -Wait
        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "Executable not found."
    }

    $buttonDownload.Enabled = $true
    $form.UseWaitCursor = $false
}

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
$seriesCombo.Location = New-Object System.Drawing.Point(30,80)
$seriesCombo.Size = New-Object System.Drawing.Size(220,30)
$seriesCombo.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$seriesCombo.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($seriesCombo)

# SEARCH BOX
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Text = "Search model..."
$searchBox.ForeColor = [System.Drawing.Color]::Gray
$searchBox.Location = New-Object System.Drawing.Point(270,80)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($searchBox)
$searchBox.Add_GotFocus({ if ($searchBox.Text -eq "Search model...") { $searchBox.Text=""; $searchBox.ForeColor=[System.Drawing.Color]::White } })
$searchBox.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($searchBox.Text)) { $searchBox.Text="Search model..."; $searchBox.ForeColor=[System.Drawing.Color]::Gray } })

# LISTBOX
$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)

# DETAILS LABEL
$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$form.Controls.Add($detailLabel)

# DOWNLOAD BUTTON
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# STATUS BAR (light)
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.Color]::White
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

# =========================
# EVENTS
# =========================
$form.Add_Shown({
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
    $title.Top = 20

    # Preload L-Series models
    $seriesCombo.SelectedItem = "L-Series"
    $seriesModels["L-Series"] | ForEach-Object { $modelList.Items.Add($_) }

    $form.Activate()
    $form.BringToFront()
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
        $buttonDownload.Enabled = $false
        $foundTool = $tools | Where-Object { $_.Model -eq $selModel }
        if ($foundTool) { $statusLabel.Text = "RESETTER AVAILABLE!"; $buttonDownload.Enabled = $true }
        else { $statusLabel.Text = "RESETTER NOT AVAILABLE YET!" }
    }
})

$buttonDownload.Add_Click({
    $selModel = $modelList.SelectedItem
    if ($selModel) { $tool = $tools | Where-Object { $_.Model -eq $selModel }; if ($tool) { Download-Run $tool } }
})

$form.ShowDialog()
