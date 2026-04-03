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
# ORIGINAL GUI
# =========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(580,520)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$form.Controls.Add($title)

$seriesCombo = New-Object System.Windows.Forms.ComboBox
$seriesCombo.DropDownStyle = 'DropDownList'
$seriesCombo.Items.AddRange($seriesModels.Keys)
$seriesCombo.Location = New-Object System.Drawing.Point(30,80)
$seriesCombo.Size = New-Object System.Drawing.Size(220,30)
$seriesCombo.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$seriesCombo.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($seriesCombo)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Text = "Search model..."
$searchBox.ForeColor = [System.Drawing.Color]::Gray
$searchBox.Location = New-Object System.Drawing.Point(270,80)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$form.Controls.Add($searchBox)
$searchBox.Add_GotFocus({ if ($searchBox.Text -eq "Search model...") { $searchBox.Text=""; $searchBox.ForeColor=[System.Drawing.Color]::White } })
$searchBox.Add_LostFocus({ if ([string]::IsNullOrWhiteSpace($searchBox.Text)) { $searchBox.Text="Search model..."; $searchBox.ForeColor=[System.Drawing.Color]::Gray } })

$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$modelList.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$modelList.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($modelList)

$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.ForeColor = [System.Drawing.Color]::White
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$detailLabel.Size = New-Object System.Drawing.Size(450,30)
$form.Controls.Add($detailLabel)

$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204) # Blue
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,420)
$progressBar.Size = New-Object System.Drawing.Size(490,20)
$form.Controls.Add($progressBar)

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.Color]::White
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::Black
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
# DOWNLOAD FUNCTION USING RUNSPACE
# =========================
function Start-Download($tool) {
    $buttonDownload.Enabled = $false
    $progressBar.Value = 0
    $statusLabel.Text = "Downloading..."

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions = "ReuseThread"
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs

    $ps.AddScript({
        param($tool,$OutDir)

        $OutFile = Join-Path $OutDir $tool.File
        if (Test-Path $OutFile) { Remove-Item $OutFile -Force }

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent","Mozilla/5.0")

        $wc.DownloadProgressChanged.Add({
            param($s,$ev)
            $progress = $ev.ProgressPercentage
            [System.Windows.Forms.Application]::Invoke({
                $script:progressBar.Value = $progress
                $script:statusLabel.Text = "Downloading... $progress%"
            })
        })

        $wc.DownloadFile($tool.Url, $OutFile)

        $ExtractDir = Join-Path $OutDir $tool.Model
        if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
        New-Item -ItemType Directory -Path $ExtractDir | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

        $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
        if ($exe) { Start-Process $exe.FullName }
    }).AddArgument($tool).AddArgument($OutDir)

    $asyncResult = $ps.BeginInvoke()
    Register-ObjectEvent -InputObject $ps -EventName "Disposed" -Action {
        [System.Windows.Forms.Application]::Invoke({
            $progressBar.Value = 100
            $statusLabel.Text = "Done!"
            $buttonDownload.Enabled = $true
        })
    }
}

$buttonDownload.Add_Click({
    $tool = $tools | Where-Object { $_.Model -eq $modelList.SelectedItem }
    if ($tool) { Start-Download $tool }
})

$form.ShowDialog()
