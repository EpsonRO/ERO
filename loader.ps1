Add-Type -AssemblyName PresentationFramework

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
function Download-Run($tool, $statusLabel) {
    $statusLabel.Content = "Downloading..."
    $OutFile = "$OutDir\$($tool.File)"

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile -UseBasicParsing
    } catch {
        $statusLabel.Content = "Download failed."
        return
    }

    $statusLabel.Content = "Extracting..."

    if ($tool.Type -eq "zip") {
        $ExtractDir = "$OutDir\$($tool.Model)"
        if (-not (Test-Path $ExtractDir)) {
            New-Item -ItemType Directory -Path $ExtractDir | Out-Null
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($OutFile, $ExtractDir, $true)

        $exe = Get-ChildItem -Path $ExtractDir -Recurse |
               Where-Object { $_.Name -ieq $tool.Exe } |
               Select-Object -First 1

        if ($exe) {
            $statusLabel.Content = "Launching tool..."
            Start-Process $exe.FullName
            $statusLabel.Content = "Done!"
        } else {
            $statusLabel.Content = "Executable not found."
        }
    }
}

# ===== WPF XAML UI =====
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Epson Resetter Tool"
        Height="300" Width="400"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#1e1e1e">

    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center">

            <TextBlock Text="EPSON RESETTER"
                       FontSize="22"
                       FontWeight="Bold"
                       Foreground="White"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,20"/>

            <TextBlock Text="Enter Printer Model"
                       Foreground="#cccccc"
                       Margin="0,0,0,5"/>

            <TextBox Name="ModelBox"
                     Height="30"
                     Background="#2d2d30"
                     Foreground="White"
                     BorderBrush="#444"
                     Padding="5"/>

            <Button Name="StartBtn"
                    Content="START"
                    Height="35"
                    Margin="0,15,0,10"
                    Background="#0078D7"
                    Foreground="White"
                    FontWeight="Bold"/>

            <Label Name="StatusLabel"
                   Content="Ready"
                   Foreground="#aaaaaa"
                   HorizontalAlignment="Center"/>

        </StackPanel>
    </Grid>
</Window>
"@

# ===== LOAD UI =====
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# ===== GET ELEMENTS =====
$modelBox = $window.FindName("ModelBox")
$startBtn = $window.FindName("StartBtn")
$statusLabel = $window.FindName("StatusLabel")

# ===== BUTTON EVENT =====
$startBtn.Add_Click({
    $model = $modelBox.Text.Trim().ToUpper()

    if ([string]::IsNullOrWhiteSpace($model)) {
        $statusLabel.Content = "Enter a model first."
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        $statusLabel.Content = "Model found."
        Download-Run $tool $statusLabel
    } else {
        $statusLabel.Content = "Model not added."
    }
})

# ===== RUN APP =====
$window.ShowDialog()
