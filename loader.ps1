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
$form.Text = "Epson Resetter"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.Font = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(90,20)
$form.Controls.Add($title)

# LABEL
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter Printer Model:"
$label.Location = New-Object System.Drawing.Point(30,70)
$form.Controls.Add($label)

# TEXTBOX
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Size = New-Object System.Drawing.Size(320,25)
$textbox.Location = New-Object System.Drawing.Point(30,95)
$form.Controls.Add($textbox)

# BUTTON
$button = New-Object System.Windows.Forms.Button
$button.Text = "Start"
$button.Size = New-Object System.Drawing.Size(320,30)
$button.Location = New-Object System.Drawing.Point(30,130)
$form.Controls.Add($button)

# STATUS
$status = New-Object System.Windows.Forms.Label
$status.Text = ""
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(30,170)
$form.Controls.Add($status)

# ===== AUTOFOCUS (SIMPLE & RELIABLE) =====
$form.Add_Shown({
    $textbox.Select()
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
        Download-Run $tool
    } else {
        $status.Text = "Printer model not added."
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

# RUN
$form.ShowDialog()
