function Download-Tool {
    param($tool)

    $buttonDownload.Enabled = $false
    $progressBar.Value = 0
    $statusLabel.Text = "Downloading..."

    $OutFile = Join-Path $OutDir $tool.File
    $ExtractDir = Join-Path $OutDir $tool.Model

    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

    try {
        $wc = [System.Net.Http.HttpClient]::new()
        $response = $wc.GetAsync($tool.Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        $total = $response.Content.Headers.ContentLength
        $stream = $response.Content.ReadAsStreamAsync().Result

        $fileStream = [System.IO.File]::OpenWrite($OutFile)
        $buffer = New-Object byte[] 8192
        $read = 0

        while (($count = $stream.Read($buffer,0,$buffer.Length)) -gt 0) {
            $fileStream.Write($buffer,0,$count)
            $read += $count
            $percent = [int](($read / $total) * 100)
            $progressBar.Value = [Math]::Min($percent,100)
            $statusLabel.Text = "Downloading $percent%"
            Start-Sleep -Milliseconds 10
        }

        $fileStream.Close()

        # Extract ZIP
        $statusLabel.Text = "Extracting..."
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir)

        # Launch EXE
        $exe = Get-ChildItem -Path $ExtractDir -Recurse | Where-Object { $_.Name -ieq $tool.Exe } | Select-Object -First 1
        if ($exe) { Start-Process $exe.FullName; $statusLabel.Text = "Done!" }
        else { $statusLabel.Text = "Executable not found." }

    } catch {
        $statusLabel.Text = "Error: $($_.Exception.Message)"
    }

    $progressBar.Value = 100
    $buttonDownload.Enabled = $true
}
