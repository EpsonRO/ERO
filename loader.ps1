Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 🔥 FORCE FOREGROUND (WINAPI)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# ===== ALL L-SERIES MODELS =====
$models = @(
    "L100","L110","L1110","L1118","L120","L121","L1216","L1250","L1251","L1256",
    "L130","L132","L1320","L1300","L1455","L1800","L18050",
    "L200","L210","L220","L222",
    "L300","L301","L303",
    "L310","L311","L3110","L3115","L3116","L312","L313","L315","L3150","L3151","L3156",
    "L3210","L3211","L3215","L3216","L3250","L3251","L3252","L3256","L3260",
    "L350","L351","L353","L355","L3550","L3556","L3560",
    "L360","L361","L363","L365","L380","L382","L383","L385",
    "L405","L415","L4160","L4260","L4360","L4366","L450","L455","L456","L475",
    "L485","L486","L5190","L5290","L5296","L550","L555","L565","L575",
    "L605","L6160","L6170","L6190","L6260","L6270","L6290","L6370","L6390",
    "L6460","L6490","L655","L6570","L6580",
    "L805","L8050","L810","L8100","L850",
    "L1210","L14150","L15150","L15160","L15180"
)

# ===== AVAILABLE TOOLS =====
$tools = @(
    @{Model="L6190"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Exe="AdjProg.exe"}
)

# ===== TEMP DIRECTORY =====
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $OutDir | Out-Null

# ===== DOWNLOAD FUNCTION =====
function Download-Run($tool) {

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

# ===== FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "EPSON RESETTER ONLINE"
$form.Size = New-Object System.Drawing.Size(420,300)
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
$form.Controls.Add($title)

# ===== LABEL =====
$label = New-Object System.Windows.Forms.Label
$label.Text = "Printer Model"
$label.ForeColor = [System.Drawing.Color]::Silver
$label.Location = New-Object System.Drawing.Point(30,90)
$form.Controls.Add($label)

# ===== TEXTBOX =====
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Size = New-Object System.Drawing.Size(340,28)
$textbox.Location = New-Object System.Drawing.Point(30,115)
$textbox.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)
$textbox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($textbox)

# ===== BUTTON =====
$button = New-Object System.Windows.Forms.Button
$button.Text = "START"
$button.Size = New-Object System.Drawing.Size(340,38)
$button.Location = New-Object System.Drawing.Point(30,155)
$button.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$button.ForeColor = [System.Drawing.Color]::White
$button.FlatStyle = "Flat"
$button.FlatAppearance.BorderSize = 0
$form.Controls.Add($button)

# ===== STATUS BAR =====
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.Color]::FromArgb(45,45,48)

$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::White

$spacer = New-Object System.Windows.Forms.ToolStripStatusLabel
$spacer.Spring = $true

$copyright = New-Object System.Windows.Forms.ToolStripStatusLabel
$copyright.Text = "© 2026 KLBSoft"
$copyright.ForeColor = [System.Drawing.Color]::Gray

$statusStrip.Items.Add($statusLabel) | Out-Null
$statusStrip.Items.Add($spacer) | Out-Null
$statusStrip.Items.Add($copyright) | Out-Null

$form.Controls.Add($statusStrip)

# ===== CENTER + FORCE FOCUS =====
$form.Add_Shown({

    # Center title
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
    $title.Top = ($textbox.Top / 2) - ($title.Height / 2)

    # 🔥 FORCE WINDOW TO FRONT
    $form.TopMost = $true
    $form.Activate()
    $form.Focus()
    [Win32]::SetForegroundWindow($form.Handle)

    Start-Sleep -Milliseconds 200
    $form.TopMost = $false

    # Focus textbox
    $textbox.Focus()
})

# ===== EVENTS =====
$textbox.Add_TextChanged({
    $pos = $textbox.SelectionStart
    $textbox.Text = $textbox.Text.ToUpper()
    $textbox.SelectionStart = $pos
})

function Start-Tool {
    $model = $textbox.Text.Trim()

    if (-not $model) {
        $statusLabel.Text = "Enter a model."
        return
    }

    if ($models -notcontains $model) {
        $statusLabel.Text = "INVALID MODEL!"
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        Download-Run $tool
    } else {
        $statusLabel.Text = "PRINTER MODEL NOT FOUND!"
    }
}

$button.Add_Click({ Start-Tool })

$textbox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        Start-Tool
    }
})

$form.ShowDialog()
