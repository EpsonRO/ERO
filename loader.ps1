Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# =========================
# SERIES & MODELS DATA
# =========================
$seriesModels = @{
    "L-Series" = @("L6190","L3150")
}

$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"},
    @{Model="L3150"; Url="https://github.com/EpsonRO/L6190/releases/download/L3150/L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# =========================
# GUI SETUP
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(580,550)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(37,37,38)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold",18,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(0,122,204)
$title.AutoSize = $true
$form.Controls.Add($title)

$seriesCombo = New-Object System.Windows.Forms.ComboBox
$seriesCombo.DropDownStyle = 'DropDownList'
$seriesCombo.Items.AddRange($seriesModels.Keys)
$seriesCombo.Location = New-Object System.Drawing.Point(30,80)
$seriesCombo.Size = New-Object System.Drawing.Size(220,30)
$seriesCombo.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$seriesCombo.ForeColor = [System.Drawing.Color]::White
$seriesCombo.Font = New-Object System.Drawing.Font("Segoe UI",10)
$seriesCombo.FlatStyle = "Flat"
$form.Controls.Add($seriesCombo)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Text = "Search model..."
$searchBox.ForeColor = [System.Drawing.Color]::Gray
$searchBox.Location = New-Object System.Drawing.Point(270,80)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI",10)
$searchBox.BorderStyle = "FixedSingle"
$form.Controls.Add($searchBox)
$searchBox.Add_GotFocus({ if ($searchBox.Text -eq "Search model...") { $searchBox.Text=""; $searchBox.ForeColor=[System.Drawing.Color]::White } })
$searchBox.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($searchBox.Text)) { $searchBox.Text="Search model..."; $searchBox.ForeColor=[System.Drawing.Color]::Gray } })

$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$modelList.ForeColor = [System.Drawing.Color]::White
$modelList.Font = New-Object System.Drawing.Font("Segoe UI",10)
$modelList.BorderStyle = "FixedSingle"
$modelList.SelectionMode = 'One'
$modelList.HorizontalScrollbar = $true
$form.Controls.Add($modelList)

$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::LightGray
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$detailLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$form.Controls.Add($detailLabel)

$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(235,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Font = New-Object System.Drawing.Font("Segoe UI Semibold",11)
$buttonDownload.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Text = "CANCEL"
$buttonCancel.Location = New-Object System.Drawing.Point(285,370)
$buttonCancel.Size = New-Object System.Drawing.Size(235,40)
$buttonCancel.BackColor = [System.Drawing.Color]::DarkRed
$buttonCancel.ForeColor = [System.Drawing.Color]::White
$buttonCancel.FlatStyle = "Flat"
$buttonCancel.Font = New-Object System.Drawing.Font("Segoe UI Semibold",11)
$buttonCancel.Cursor = [System.Windows.Forms.Cursors]::Hand
$buttonCancel.Enabled = $false
$form.Controls.Add($buttonCancel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,420)
$progressBar.Size = New-Object System.Drawing.Size(490,20)
$progressBar.Style = 'Continuous'
$progressBar.ForeColor = [System.Drawing.Color]::FromArgb(0,122,204)
$form.Controls.Add($progressBar)

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.Color]::White
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::Black
$statusStrip.SizingGrip = $false
$statusStrip.Items.Add($statusLabel)
$form.Controls.Add($statusStrip)

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
    $buttonCancel.Enabled = $false
})

$modelList.Add_SelectedIndexChanged({
    $selModel = $modelList.SelectedItem
    if ($selModel) {
        $detailLabel.Text = "Model: $selModel"
        $foundTool = $tools | Where-Object { $_.Model -eq $selModel }
        $buttonDownload.Enabled = $foundTool -ne $null
        $buttonCancel.Enabled = $false
        if ($foundTool) { $statusLabel.Text = "RESETTER AVAILABLE!" } else { $statusLabel.Text = "RESETTER NOT AVAILABLE YET!" }
    }
})

# =========================
# ASYNC DOWNLOAD FUNCTION WITH CANCEL
# =========================
$global:wc = $null

function Download-Run($tool) {
    $buttonDownload.Enabled = $false
    $buttonCancel.Enabled = $true
    $progressBar.Value = 0
    $statusLabel.Text = "Downloading..."
    $global:wc = New-Object System.Net.WebClient
    $global:wc.Headers.Add("User-Agent","Mozilla/5.0")

    $global:wc.DownloadProgressChanged.Add({
        param($sender,$e)
        $progressBar.Invoke([Action]{ 
            $progressBar.Value = $e.ProgressPercentage
            $statusLabel.Text="Downloading... $($e.ProgressPercentage)%"
        })
    })

    $global:wc.DownloadFileCompleted.Add({
        param($sender,$e)
        if ($e.Cancelled) {
            $statusLabel.Invoke([Action]{ $statusLabel.Text = "Download Cancelled" })
        } elseif ($e.Error) {
            $statusLabel.Invoke([Action]{ $statusLabel.Text = "Error downloading file" })
        } else {
            $statusLabel.Invoke([Action]{ $statusLabel.Text = "Extracting..." })

            $OutFile = Join-Path $env:TEMP "ERO-Tools" $tool.File
            $ExtractDir = Join-Path $env:TEMP "ERO-Tools" $tool.Model
            if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
            New-Item -ItemType Directory -Path $ExtractDir | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

            $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
            if ($exe) { Start-Process $exe.FullName; $statusLabel.Invoke([Action]{ $statusLabel.Text = "Done!" }) }
            else { $statusLabel.Invoke([Action]{ $statusLabel.Text = "Executable not found." }) }
            $progressBar.Invoke([Action]{ $progressBar.Value = 100 })
        }
        $buttonDownload.Invoke([Action]{ $buttonDownload.Enabled = $true })
        $buttonCancel.Invoke([Action]{ $buttonCancel.Enabled = $false })
    })

    $OutFile = Join-Path $env:TEMP "ERO-Tools" $tool.File
    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    $global:wc.DownloadFileAsync($tool.Url, $OutFile)
}

$buttonDownload.Add_Click({
    $tool = $tools | Where-Object { $_.Model -eq $modelList.SelectedItem }
    if ($tool) { Download-Run $tool }
})

$buttonCancel.Add_Click({
    if ($global:wc) { $global:wc.CancelAsync() }
})

$form.ShowDialog()
