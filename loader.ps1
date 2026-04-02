# FORCE STA MODE
if ([Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
    powershell -STA -File $PSCommandPath
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Net

# ===== TOOL DATABASE =====
$tools = @(
    @{Model="L6190"; Name="USBFix"; Url="https://github.com/EpsonRO/L6190/releases/download/L6190/L6190.zip"; File="L6190.zip"; Type="zip"; Exe="AdjProg.exe"}
)

# TEMP DIRECTORY
$OutDir = Join-Path $env:TEMP "ERO-Tools"
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

# ===== DOWNLOAD WITH PROGRESS =====
function Download-File($url, $outFile, $progressBar, $statusLabel) {

    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")

    $done = $false

    $wc.DownloadProgressChanged += {
        $progressBar.Value = $_.ProgressPercentage
        $statusLabel.Text = "Downloading... $($_.ProgressPercentage)%"
    }

    $wc.DownloadFileCompleted += {
        $done = $true
    }

    $wc.DownloadFileAsync($url, $outFile)

    while (-not $done) {
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.Application]::DoEvents()
    }
}

# ===== MAIN FUNCTION =====
function Download-Run($tool, $progressBar, $statusLabel) {

    $OutFile = Join-Path $OutDir $tool.File

    Download-File $tool.Url $OutFile $progressBar $statusLabel

    $statusLabel.Text = "Extracting..."

    $ExtractDir = Join-Path $OutDir $tool.Model
    if (Test-Path $ExtractDir) {
        Remove-Item $ExtractDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Path $ExtractDir | Out-Null

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

        $progressBar.Value = 0
        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "EXE not found."
    }
}

# ===== UI =====
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Epson Resetter"
        Height="360" Width="420"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#1b1b1b">

    <Grid>
        <Border Background="#252526" CornerRadius="10" Padding="20" Margin="10">
            <StackPanel>

                <TextBlock Text="EPSON RESETTER"
                           FontSize="20"
                           FontWeight="Bold"
                           Foreground="White"
                           HorizontalAlignment="Center"
                           Margin="0,0,0,20"/>

                <TextBlock Text="Printer Model"
                           Foreground="#cccccc"/>

                <TextBox Name="ModelBox"
                         Height="32"
                         Margin="0,5,0,15"
                         Background="#2d2d30"
                         Foreground="White"
                         BorderThickness="0"
                         Padding="8"/>

                <Button Name="StartBtn"
                        Content="START"
                        Height="40"
                        Background="#0078D7"
                        Foreground="White"
                        FontWeight="Bold"
                        BorderThickness="0"/>

                <ProgressBar Name="ProgressBar"
                             Height="20"
                             Margin="0,15,0,5"
                             Minimum="0" Maximum="100"/>

                <TextBlock Name="StatusLabel"
                           Text="Ready"
                           Foreground="#aaaaaa"
                           HorizontalAlignment="Center"/>

            </StackPanel>
        </Border>
    </Grid>
</Window>
"@

# LOAD UI
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$modelBox = $window.FindName("ModelBox")
$startBtn = $window.FindName("StartBtn")
$statusLabel = $window.FindName("StatusLabel")
$progressBar = $window.FindName("ProgressBar")

# AUTOFOCUS (REAL FIX)
$window.Dispatcher.InvokeAsync({
    $modelBox.Focus()
    [System.Windows.Input.Keyboard]::Focus($modelBox)
})

# AUTO UPPERCASE
$modelBox.Add_TextChanged({
    $pos = $modelBox.CaretIndex
    $modelBox.Text = $modelBox.Text.ToUpper()
    $modelBox.CaretIndex = $pos
})

# START FUNCTION
function Start-Tool {
    $model = $modelBox.Text.Trim()

    if (-not $model) {
        $statusLabel.Text = "Enter a model."
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        Download-Run $tool $progressBar $statusLabel
    } else {
        $statusLabel.Text = "Model not added."
    }
}

# BUTTON
$startBtn.Add_Click({ Start-Tool })

# ENTER KEY
$modelBox.Add_KeyDown({
    if ($_.Key -eq "Return") {
        Start-Tool
    }
})

# RUN
$window.ShowDialog() | Out-Null
