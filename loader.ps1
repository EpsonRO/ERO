Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== TOOL DATABASE =====
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"}
)

# ===== TEMP DIRECTORY =====
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) {
    Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $OutDir | Out-Null

# ===== DOWNLOAD FUNCTION =====
function Download-Run($tool) {

    $status.Text = "Downloading..."
    $OutFile = Join-Path $OutDir $tool.File

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -Headers @{ "User-Agent"="Mozilla/5.0" }
    } catch {
        $status.Text = "Download failed."
        return
    }

    $status.Text = "Extracting..."

    $ExtractDir = Join-Path $OutDir $tool.Model
    New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

    $exe = Get-ChildItem -Path $ExtractDir -Recurse |
           Where-Object { $_.Name -ieq $tool.Exe } |
           Select-Object -First 1

    if ($exe) {
        $status.Text = "Launching..."
        Start-Process $exe.FullName -Wait

        $status.Text = "Cleaning..."
        Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $OutFile -Force -ErrorAction SilentlyContinue

        $status.Text = "Done!"
    } else {
        $status.Text = "EXE not found."
    }
}

# ===== FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(420,260)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# ===== TITLE =====
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(55,20)
$form.Controls.Add($title)

# ===== LABEL =====
$label = New-Object System.Windows.Forms.Label
$label.Text = "Printer Model"
$label.ForeColor = [System.Drawing.Color]::Silver
$label.Location = New-Object System.Drawing.Point(30,80)
$form.Controls.Add($label)

# ===== TEXTBOX =====
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Size = New-Object System.Drawing.Size(340,28)
$textbox.Location = New-Object System.Drawing.Point(30,105)
$textbox.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$textbox.ForeColor = [System.Drawing.Color]::White
$textbox.BorderStyle = "FixedSingle"
$form.Controls.Add($textbox)

# ===== BUTTON =====
$button = New-Object System.Windows.Forms.Button
$button.Text = "START"
$button.Size = New-Object System.Drawing.Size(340,38)
$button.Location = New-Object System.Drawing.Point(30,145)
$button.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$button.ForeColor = [System.Drawing.Color]::White
$button.FlatStyle = "Flat"
$button.FlatAppearance.BorderSize = 0
$form.Controls.Add($button)

# ===== STATUS =====
$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready"
$status.ForeColor = [System.Drawing.Color]::Gray
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(30,190)
$form.Controls.Add($status)

# ===== COPYRIGHT =====
$copyright = New-Object System.Windows.Forms.Label
$copyright.Text = "© 2026 KLBSoft"
$copyright.ForeColor = [System.Drawing.Color]::Gray
$copyright.AutoSize = $true
$copyright.Location = New-Object System.Drawing.Point(250,190)
$form.Controls.Add($copyright)

# ===== AUTOFOCUS =====
$form.Add_Shown({
    $textbox.Focus()
})

# AUTO UPPERCASE
$textbox.Add_TextChanged({
    $pos = $textbox.SelectionStart
    $textbox.Text = $textbox.Text.ToUpper()
    $textbox.SelectionStart = $pos
})

# ===== START FUNCTION =====
function Start-Tool {
    $model = $textbox.Text.Trim()

    if (-not $model) {
        $status.Text = "Enter a model."
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        Download-Run $tool
    } else {
        $status.Text = "Model not added."
    }
}

# BUTTON
$button.Add_Click({ Start-Tool })

# ENTER KEY
$textbox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        Start-Tool
    }
})

# RUN
$form.ShowDialog()
