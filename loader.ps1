# DOWNLOAD BUTTON
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Text = "Download & Run"
$buttonDownload.Location = New-Object System.Drawing.Point(30,370)  # moved up a bit from 390 to leave space below
$buttonDownload.Size = New-Object System.Drawing.Size(490,40)
$buttonDownload.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
$buttonDownload.ForeColor = [System.Drawing.Color]::White
$buttonDownload.FlatStyle = "Flat"
$buttonDownload.Enabled = $false
$form.Controls.Add($buttonDownload)

# STATUS BAR (default/light)
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusStrip.BackColor = [System.Drawing.SystemColors]::Control  # <-- makes it default light color
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
