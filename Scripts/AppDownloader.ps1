# ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ████████╗███████╗
# ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║   ██║   ███████╗
# ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║   ██║   ╚════██║
# ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝   ██║   ███████║
#  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install the application via curl
$targetDir = "../Source/app"
$apps = @(
    @{Name="Spotify"; Url="https://download.scdn.co/SpotifySetup.exe"; OutFile="SpotifySetup.exe"},
    @{Name="VSCode"; Url="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"; OutFile="VSCodeUserSetup-x64.exe"},
    @{Name="ZenBrowser"; Url="https://github.com/zen-browser/desktop/releases/latest/download/zen.installer.exe"; OutFile="ZenSetup.exe"}
)
foreach ($app in $apps) {
    $outputPath = Join-Path -Path $targetDir -ChildPath $app["OutFile"]
    Write-Host "Downloading $($app["Name"]) to $outputPath..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $app["Url"] -OutFile $outputPath -UseBasicParsing
        Write-Host "$($app["Name"]) Download successful" -ForegroundColor Green
    } catch {
        Write-Host "$($app["Name"]) Download failed: $_" -ForegroundColor Red
    }
}