# FORCE STA MODE
if ([Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
    powershell -STA -File $PSCommandPath
    exit
}

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
    $statusLabel.Text = "Downloading..."
    $OutFile = "$OutDir\$($tool.File)"

    try {
        Invoke-WebRequest -Uri $tool.Url -OutFile $OutFile
    } catch {
        $statusLabel.Text = "Download failed."
        return
    }

    $statusLabel.Text = "Extracting..."

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
        $statusLabel.Text = "Launching..."
        Start-Process $exe.FullName
        $statusLabel.Text = "Done!"
    } else {
        $statusLabel.Text = "EXE not found."
    }
}

# ===== UI DESIGN =====
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Epson Resetter"
        Height="320" Width="420"
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
                        BorderThickness="0"
                        Cursor="Hand"/>

                <TextBlock Name="StatusLabel"
                           Text="Ready"
                           Foreground="#aaaaaa"
                           Margin="0,15,0,0"
                           HorizontalAlignment="Center"/>

            </StackPanel>
        </Border>
    </Grid>
</Window>
"@

# ===== LOAD UI =====
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# ===== GET ELEMENTS =====
$modelBox = $window.FindName("ModelBox")
$startBtn = $window.FindName("StartBtn")
$statusLabel = $window.FindName("StatusLabel")

# ===== AUTO-FOCUS (NO CLICK NEEDED) =====
$window.Add_ContentRendered({
    $modelBox.Focus()
})

# ===== AUTO-SELECT TEXT =====
$modelBox.Add_GotFocus({
    $modelBox.SelectAll()
})

# ===== AUTO-UPPERCASE =====
$modelBox.Add_TextChanged({
    $cursor = $modelBox.CaretIndex
    $modelBox.Text = $modelBox.Text.ToUpper()
    $modelBox.CaretIndex = $cursor
})

# ===== START FUNCTION =====
function Start-Tool {
    $model = $modelBox.Text.Trim()

    if (-not $model) {
        $statusLabel.Text = "Enter a model."
        return
    }

    $tool = $tools | Where-Object { $_.Model -eq $model }

    if ($tool) {
        $statusLabel.Text = "Model found..."
        Download-Run $tool $statusLabel
    } else {
        $statusLabel.Text = "Model not added."
    }
}

# BUTTON CLICK
$startBtn.Add_Click({
    Start-Tool
})

# ENTER KEY SUPPORT
$modelBox.Add_KeyDown({
    if ($_.Key -eq "Return") {
        Start-Tool
    }
})

# ===== RUN APP =====
$window.ShowDialog() | Out-Null
