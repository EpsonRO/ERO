# =========================
# PROFESSIONAL GUI ADJUSTMENTS
# =========================

$form.BackColor = [System.Drawing.Color]::FromArgb(37,37,38) # Slightly softer dark

# Title styling
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold",18,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(0,122,204) # Blue accent
$title.Top = 20
$title.Left = ($form.ClientSize.Width - $title.Width)/2

# ComboBox professional styling
$seriesCombo.Font = New-Object System.Drawing.Font("Segoe UI",10)
$seriesCombo.FlatStyle = "Flat"
$seriesCombo.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$seriesCombo.ForeColor = [System.Drawing.Color]::White
$seriesCombo.IntegralHeight = $true

# Search box professional styling
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI",10)
$searchBox.BorderStyle = "FixedSingle"

# ListBox professional styling
$modelList.Font = New-Object System.Drawing.Font("Segoe UI",10)
$modelList.BorderStyle = "FixedSingle"
$modelList.SelectionMode = 'One'
$modelList.HorizontalScrollbar = $true

# Details label
$detailLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$detailLabel.ForeColor = [System.Drawing.Color]::LightGray

# Download button styling
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,122,204) # Blue
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Font = New-Object System.Drawing.Font("Segoe UI Semibold",11)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.Cursor = [System.Windows.Forms.Cursors]::Hand

# Progress bar styling
$progressBar.Style = 'Continuous'
$progressBar.ForeColor = [System.Drawing.Color]::FromArgb(0,122,204)

# Status strip
$statusStrip.BackColor = [System.Drawing.Color]::White
$statusLabel.ForeColor = [System.Drawing.Color]::Black
$statusStrip.SizingGrip = $false
