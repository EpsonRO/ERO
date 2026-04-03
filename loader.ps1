Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"}
    @{Model="L3150"; Url="https://github.com/EpsonRO/L6190/releases/download/L3150/L3150.zip"; File="L3150.zip"; Exe="AdjProg.exe"}
)

# =========================
# TEMP DIR
# =========================
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# =========================
# DOWNLOAD FUNCTION (FIXED)
# =========================
function Download-Run($tool)
{
    $form.UseWaitCursor = $true
    $buttonDownload.Enabled = $false
    $progressBar.Value = 0
    $statusLabel.Text = "Downloading..."
    $form.Refresh()

    $OutFile = Join-Path $OutDir $tool.File
    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }

    try {
        $request = [System.Net.HttpWebRequest]::Create($tool.Url)
        $response = $request.GetResponse()
        $totalLength = $response.ContentLength

        $stream = $response.GetResponseStream()
        $fileStream = [System.IO.File]::Create($OutFile)

        $buffer = New-Object byte[] 8192
        $totalRead = 0

        while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {

            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read

            if ($totalLength -gt 0) {
                $percent = [int](($totalRead / $totalLength) * 100)
                if ($percent -le 100) {
                    $progressBar.Value = $percent
                    $statusLabel.Text = "Downloading... $percent%"
                }
            }

            # 🔥 FIX: keep UI responsive
            [System.Windows.Forms.Application]::DoEvents()
        }

        $fileStream.Close()
        $stream.Close()
        $response.Close()
    }
    catch {
        $statusLabel.Text = "Download failed."
        $buttonDownload.Enabled = $true
        $form.UseWaitCursor = $false
        return
    }

    # =========================
    # EXTRACT
    # =========================
    $statusLabel.Text = "Extracting..."
    $progressBar.Value = 0
    $form.Refresh()

    $ExtractDir = Join-Path $OutDir $tool.Model
    if (Test-Path $ExtractDir) {
        Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $ExtractDir | Out-Null

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

    # =========================
    # RUN EXE
    # =========================
    $exe = Get-ChildItem -Path $ExtractDir -Recurse |
           Where-Object { $_.Name -ieq $tool.Exe } |
           Select-Object -First 1

    if ($exe) {
        $statusLabel.Text = "Launching..."
        Start-Process $exe.FullName
        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "Executable not found."
    }

    $buttonDownload.Enabled = $true
    $form.UseWaitCursor = $false
}

# =========================
# FORM BUILD (UNCHANGED)
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
$form.Controls.Add($seriesCombo)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Text = "Search model..."
$searchBox.Location = New-Object System.Drawing.Point(270,80)
$searchBox.Size = New-Object System.Drawing.Size(250,30)
$form.Controls.Add($searchBox)

$modelList = New-Object System.Windows.Forms.ListBox
$modelList.Location = New-Object System.Drawing.Point(30,120)
$modelList.Size = New-Object System.Drawing.Size(490,200)
$form.Controls.Add($modelList)

$detailLabel = New-Object System.Windows.Forms.Label
$detailLabel.Text = "Model: (none selected)"
$detailLabel.Location = New-Object System.Drawing.Point(30,330)
$form.Controls.Add($detailLabel)

$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "LAUNCH"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30,420)
$progressBar.Size = New-Object System.Drawing.Size(490,20)
$form.Controls.Add($progressBar)

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusStrip.Items.Add($statusLabel)
$form.Controls.Add($statusStrip)

# =========================
# EVENTS
# =========================
$form.Add_Shown({
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
    $title.Top = 20
    $seriesCombo.SelectedItem = "L-Series"
    $seriesModels["L-Series"] | ForEach-Object { $modelList.Items.Add($_) }
})

$seriesCombo.Add_SelectedIndexChanged({
    $modelList.Items.Clear()
    $seriesModels[$seriesCombo.SelectedItem] | ForEach-Object { $modelList.Items.Add($_) }
})

$modelList.Add_SelectedIndexChanged({
    $sel = $modelList.SelectedItem
    if ($sel) {
        $detailLabel.Text = "Model: $sel"
        $tool = $tools | Where-Object { $_.Model -eq $sel }
        $buttonDownload.Enabled = $tool -ne $null
    }
})

$buttonDownload.Add_Click({
    $sel = $modelList.SelectedItem
    if ($sel) {
        $tool = $tools | Where-Object { $_.Model -eq $sel }
        if ($tool) { Download-Run $tool }
    }
})

$form.ShowDialog()
