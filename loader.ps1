# ===== LOAD GUI LIBRARIES =====
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
function Download-Run($tool, $statusLabel) {

    $statusLabel.Text = "Downloading..."
    $OutFile = Join-Path $OutDir $tool.File

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -Headers @{ "User-Agent"="Mozilla/5.0" }
    } catch {
        $statusLabel.Text = "Download failed."
        return
    }

    $statusLabel.Text = "Extracting..."

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

        $statusLabel.Text = "Cleaning..."
        Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $OutFile -Force -ErrorAction SilentlyContinue

        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "EXE not found."
    }
}

# ===== CREATE FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "Epson Resetter"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1b1b1b"

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER"
$title.ForeColor = "White"
$title.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(100,20)
$form.Controls.Add($title)

# LABEL
$label = New-Object System.Windows.Forms.Label
$label.Text = "Printer Model"
$label.ForeColor = "LightGray"
$label.Location = New-Object System.Drawing.Point(30,70)
$form.Controls.Add($label)

# TEXTBOX
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Size = New-Object System.Drawing.Size(320,25)
$textbox.Location = New-Object System.Drawing.Point(30,95)
$form.Controls.Add($textbox)

# BUTTON
$button = New-Object System.Windows.Forms.Button
$button.Text = "START"
$button.Size = New-Object System.Drawing.Size(320,35)
$button.Location = New-Object System.Drawing.Point(30,130)
$form.Controls.Add($button)

# STATUS
$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready"
$status.ForeColor = "Gray"
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(150,180)
$form.Controls.Add($status)

# ===== AUTOFOCUS (WORKS 100%) =====
$form.Add_Shown({
    $textbox.Focus()
})

# AUTO UPPERCASE
$textbox.Add_TextChanged({
    $pos = $textbox.SelectionStart
    $textbox.Text = $textbox.Text.ToUpper()
    $textbox.SelectionStart = $pos
})

# START FUNCTION
function Start-Tool {
    $model = $textbox.Text.Trim()

    if (-not $model) {
        $status.Text = "Enter a model."
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        Download-Run $tool $status
    } else {
        $status.Text = "Model not added."
    }
}

# BUTTON CLICK
$button.Add_Click({ Start-Tool })

# ENTER KEY
$textbox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        Start-Tool
    }
})

# RUN APP
$form.ShowDialog()
