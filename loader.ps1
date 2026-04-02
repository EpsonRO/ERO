function Start-Tool {
    $model = $textbox.Text.Trim().ToUpper()

    if (-not $model) {
        $statusLabel.Text = "Enter a model."
        return
    }

    # CHECK IF VALID MODEL
    if ($models -notcontains $model) {
        $statusLabel.Text = "INVALID MODEL!"
        return
    }

    # CHECK IF TOOL EXISTS
    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        Download-Run $tool
    } else {
        $statusLabel.Text = "PRINTER MODEL NOT FOUND!"
    }
}
