# ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ████████╗███████╗
# ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║   ██║   ███████╗
# ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║   ██║   ╚════██║
# ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝   ██║   ███████║
#  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install Scoop with custom path
$scoopPath = if (Test-Path -Path "D:\") { "D:\Scoop" } else { "$env:USERPROFILE\Scoop" }
$env:SCOOP = $scoopPath
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

# Create Scoop directory
if (-not (Test-Path -Path $env:SCOOP)) {
    Write-Host "Creating Scoop directory at $env:SCOOP..."
    New-Item -ItemType Directory -Path $env:SCOOP -Force | Out-Null
}

# Install Scoop if not already installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop to $env:SCOOP..."
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "https://get.scoop.sh" | Invoke-Expression
    }
    catch {
        Write-Error "Failed to install Scoop: $_"
        exit 1
    }
}
else {
    Write-Host "Scoop is already installed."
}

# Install Scoop add Bucket dependence
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    try {
        scoop install git
    } catch {
        Write-Host "Git Installation failed: $_"
        exit 1
    }
}

# Add buckets
$buckets = @(
    @{ Name = "ScoopBucket"; Url = "https://github.com/xfoxolx/ScoopBucket" },
    @{ Name = "extras" },
)
foreach ($bucket in $buckets) {
    if (-not (scoop bucket list | Select-String $bucket.Name)) {
        Write-Host "Adding bucket $($bucket.Name)..."
        if ($bucket.Url) {
            scoop bucket add $bucket.Name $bucket.Url
        }
        else {
            scoop bucket add $bucket.Name
        }
    }
    else {
        Write-Host "Bucket $($bucket.Name) is already added."
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Scoop Install software
$apps = @(
    "altsnap",
    "bat",
    "cava",
    "clash-verge-rev",
    "eza",
    "fastfetch",
    "fd",
    "flow-launcher",
    "fzf",
    "gawk",
    "glazewm",
    "lazygit",
    "neovim",
    "ripgrep",
    "sed",
    "starship",
    "wezterm",
    "yasb", 
    "yazi",
    "zoxide"
)

Write-Host "Installing applications..."
foreach ($app in $apps) {
    if (-not (scoop list | Select-String $app)) {
        Write-Host "Installing $app..."
        scoop install $app
    }
    else {
        Write-Host "$app is already installed."
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install PS Modules
$psModules = @(
    "CompletionPredictor"
    "PSScriptAnalyzer"
    "ps-arch-wsl"
    "ps-color-scripts"
)

foreach ($psModule in $psModules) {
    if (!(Get-Module -ListAvailable -Name $psModule)) {
        Install-Module -Name $psModule -Force -AcceptLicense -Scope CurrentUser
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete OOTB Nvim Shortcuts (including QT)
if (Test-Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\") {
    Remove-Item "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\" -Recurse -Force
}

