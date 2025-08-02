# ██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ████████╗███████╗
# ██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║   ██║   ███████╗
# ██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║   ██║   ╚════██║
# ╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝   ██║   ███████║
#  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if it is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges."
    exit 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set working directory
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install Fonts
$fontZipPath = Join-Path (Get-Location) "../Source/font/"
$tempExtractPath = Join-Path $env:TEMP "FontInstallTemp"
$zipFiles = Get-ChildItem -Path $fontZipPath -Filter "*.zip" -File

if ($zipFiles.Count -eq 0) {
    Write-Host "No font zip files found in $fontZipPath."
} else {
    foreach ($zipFile in $zipFiles) {
        if (Test-Path $tempExtractPath) {
            Remove-Item $tempExtractPath -Recurse -Force
        }
        Write-Host "Extracting $($zipFile.Name)..."
        Expand-Archive -Path $zipFile.FullName -DestinationPath $tempExtractPath -Force
        $fontFiles = Get-ChildItem -Path $tempExtractPath -Filter "*.ttf" -File
        if ($fontFiles.Count -gt 0) {
            Write-Host "Installing fonts from $($zipFile.Name)..."
            foreach ($fontFile in $fontFiles) {
                Copy-Item -Path $fontFile.FullName -Destination "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -Force
            }
        } else {
            Write-Host "No font files found in $($zipFile.Name)."
        }
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# configuration folder path
$SourcePath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)) "Source"
$ConfigPath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)) "Config"

if (-not (Test-Path $ConfigPath)) {
    Write-Error ".config folder not found"
    exit 1
}

# Set the XDG_CONFIG_HOME environment variable
if (-not $env:XDG_CONFIG_HOME) {
    $env:XDG_CONFIG_HOME = Join-Path $env:USERPROFILE ".config"
    Write-Host "XDG_CONFIG_HOME set to: $env:XDG_CONFIG_HOME"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$configs = @(
    # AltSnap
    @{
        SourcePath = "$ConfigPath\altsnap\AltSnap.ini"
        LinkPath   = "$HOME\AppData\Roaming\AltSnap\AltSnap.ini"
    },
    # bat
    @{
        SourcePath = "$ConfigPath\bat"
        LinkPath   = "$env:SCOOP\persist\bat"
    },
    # bat - config
    @{
        SourcePath = "$env:SCOOP\persist\bat\config"
        LinkPath   = "$env:SCOOP\apps\bat\current\config"
    },
    # fastfetch
    @{
        SourcePath = "$ConfigPath\fastfetch"
        LinkPath   = "$env:XDG_CONFIG_HOME\fastfetch"
    },
    # git
    @{
        SourcePath = "$ConfigPath\git"
        LinkPath   = "$env:XDG_CONFIG_HOME\git"
    },
    # glazewm
    @{
        SourcePath = "$ConfigPath\glazewm"
        LinkPath   = "$HOME\.glzr\glazewm"
    },
    # nvim
    @{
        SourcePath = "$ConfigPath\nvim"
        LinkPath   = "$env:XDG_CONFIG_HOME\nvim"
    },
    # starship
    @{
        SourcePath = "$ConfigPath\starship\starship.toml"
        LinkPath   = "$env:XDG_CONFIG_HOME\starship.toml"
    },
    # wezterm
    @{
        SourcePath = "$ConfigPath\wezterm"
        LinkPath   = "$ENV:PROGRAMFILES\WezTerm\wezterm_modules"
    },
    # yasb
    @{
        SourcePath = "$ConfigPath\yasb"
        LinkPath   = "$env:XDG_CONFIG_HOME\yasb"
    },
    # Wallpapers
    @{
        SourcePath = "$SourcePath\Wallpapers"
        LinkPath   = "$HOME\Pictures\Wallpapers"
    },
    # Terminal
    @{
        SourcePath = "$ConfigPath\terminal\settings.json"
        LinkPath   = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    },
    # Powershell
    @{
        SourcePath = "$ConfigPath\WindowsPowershell\Microsoft.PowerShell_profile.ps1"
        LinkPath   = "~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    }
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create symbolic links function
function Set-ConfigFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [string]$LinkPath
    )
    try {
        if (-not (Test-Path $SourcePath)) {
            Write-Warning "Source path does not exist: $SourcePath"
            return
        }
        $LinkParentPath = Split-Path -Parent $LinkPath
        if (-not (Test-Path $LinkParentPath)) {
            Write-Host "Creating parent directory: $LinkParentPath"
            New-Item -ItemType Directory -Path $LinkParentPath -Force | Out-Null
        }
        if (Test-Path $LinkPath) {
            $item = Get-Item $LinkPath -Force -ErrorAction Stop
            if ($item.LinkType -eq "SymbolicLink") {
                if ($item.Target -eq $SourcePath) {
                    Write-Host "Symbolic link already exists and is correct: $LinkPath"
                    return
                }
                else {

                    Write-Host "Removing incorrect symbolic link: $LinkPath"
                    Remove-Item $LinkPath -Force -ErrorAction Stop
                }
            }
            else {
                $backupPath = "$LinkPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Write-Host "Backing up existing item to: $backupPath"
                Move-Item $LinkPath $backupPath -Force -ErrorAction Stop
            }
        }
        Write-Host "Creating symbolic link: $LinkPath -> $SourcePath"
        $sourceItem = Get-Item $SourcePath
        if ($sourceItem.PSIsContainer) {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $SourcePath -Force | Out-Null
        }
        else {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $SourcePath -Force | Out-Null
        }
    }
    catch {
        Write-Error "Failed to create symbolic link for $LinkPath : $_"
    }
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create Symbolic Links
Write-Host "Starting configuration setup..."
foreach ($config in $configs) {
    Set-ConfigFile -SourcePath $config.SourcePath -LinkPath $config.LinkPath
}
Write-Host "Configuration setup completed."
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Persist Environment Variables
[System.Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', "$PSScriptRoot\wezterm\wezterm.lua", [System.EnvironmentVariableTarget]::User)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
.\altsnap\createTask.ps1 | Out-Null
# Install bat themes
bat cache --clear
bat cache --build


