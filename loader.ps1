Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== TOOL DATABASE =====
$tools = @(
    @{Model="L6190"; Name="USBFix"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Type="zip"; Exe="AdjProg.exe"},
    @{Model="L3110"; Name="Resetter"; Url="https://example.com/L3110.zip"; File="L3110.zip"; Type="zip"; Exe="AdjProg.exe"}
)

$OutDir = "$env:USERPROFILE\Downloads\ERO-Tools"
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

# ===== DOWNLOAD FUNCTION =====
function Download-Run($tool) {
    $OutFile = "$OutDir\$($tool.File)"

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -UseBasicParsing
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Download failed!", "Error", "OK", "Error")
        return
    }

    if ($tool.Type -eq "zip") {
        $ExtractDir = "$OutDir\$($tool.Model)"
        if (-not (Test-Path $ExtractDir)) {
            New-Item -ItemType Directory -Path $ExtractDir | Out-Null
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

        $exe = Get-ChildItem -Path $ExtractDir -Recurse |
               Where-Object { $_.Name -ieq $tool.Exe } |
               Select-Object -First 1

        if ($exe) {
            Start-Process $exe.FullName
        } else {
            [System.Windows.Forms.MessageBox]::Show("Executable not found!", "Error")
        }
    }
}

# ===== GUI FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON Resetter Tool"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"

# TITLE
$title = New-Object System.Windows.Forms.Label
$title.Text = "EPSON RESETTER ONLINE"
$title.Font = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(60,20)
$form.Controls.Add($title)

# INPUT LABEL
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter Printer Model:"
$label.Location = New-Object System.Drawing.Point(30,80)
$form.Controls.Add($label)

# TEXTBOX
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(30,110)
$textbox.Size = New-Object System.Drawing.Size(320,20)
$form.Controls.Add($textbox)

# BUTTON
$button = New-Object System.Windows.Forms.Button
$button.Text = "Start"
$button.Location = New-Object System.Drawing.Point(140,150)
$form.Controls.Add($button)

# BUTTON CLICK EVENT
$button.Add_Click({
    $inputModel = $textbox.Text.Trim().ToUpper()

    if ([string]::IsNullOrWhiteSpace($inputModel)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a printer model.")
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $inputModel }

    if ($tool) {
        [System.Windows.Forms.MessageBox]::Show("Model found! Starting tool...")
        Download-Run $tool
    } else {
        [System.Windows.Forms.MessageBox]::Show("Printer model not added.", "Not Found")
    }
})

# RUN GUI
$form.ShowDialog()
