# ---------- 1. Git Submodule init and update ----------
Write-Host "========== Update Git Submodule ==========" -ForegroundColor Cyan

# Switch to shell directory
Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check git command
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Please install and push the path to environment."
    exit 1
}

git submodule init
git submodule update --recursive --remote
# checkout to default branch
git submodule foreach --recursive 'git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@") || git checkout main || git checkout master'

# Resume cwd
Pop-Location

Write-Host "Already update the git submodule\n" -ForegroundColor Green

# ---------- 2. Create config file link ----------
Write-Host "========== Creating the link ==========" -ForegroundColor Cyan

# Get actually path
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# source path
$srcWezterm = Join-Path $repoRoot ".config\wezterm"
$srcNvim    = Join-Path $repoRoot ".config\nvim"

# target path
$dstWezterm = "$HOME\.config\wezterm"
$dstNvim    = "$env:LOCALAPPDATA\nvim"

# ---------- assistant func ----------
# Ensure the parent path exist
function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path $Path -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "Created Parent directory: $parent"
    }
}

# Create link (Symbol link → target)
function New-ConfigLink {
    param(
        [string]$Link,   # target
        [string]$Target  # source
    )

    # Check the source path whether exist
    if (-not (Test-Path $Target)) {
        Write-Error "源路径不存在: $Target"
        return
    }

    # Check the link whether already exist
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -in @('Junction', 'SymbolicLink')) {
            Write-Host "Already exist the link: $Link"
            $choice = Read-Host "Delete the current link and recreate the link? (y/n)"
            if ($choice -ne 'y') {
                Write-Host "Jump to create link: $Link"
                return
            }
            Remove-Item $Link -Force
        } else {
            Write-Host "Warning: $Link already exist and is not link."
            return
        }
    }

    # Exsuer parent directory exist
    Ensure-ParentDirectory $Link

    # Try to create symbol link(Maybe need admin/develop mode)
    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -ErrorAction Stop | Out-Null
        Write-Host "Already create the symbol link: $Link → $Target" -ForegroundColor Green
        return
    } catch {
        Write-Warning "Failed to create symbol link, Maybe need admin/develop mode"
    }

    # Undo: Create directory junction (no need to elevate privileges, only applicable to local volumes)
    try {
        New-Item -ItemType Junction -Path $Link -Value $Target -ErrorAction Stop | Out-Null
        Write-Host "Already create the symbol link: $Link → $Target" -ForegroundColor Green
    } catch {
        Write-Error "Failed: $_"
    }
}

# ---------- Execute ----------
New-ConfigLink -Link $dstWezterm -Target $srcWezterm
New-ConfigLink -Link $dstNvim    -Target $srcNvim

Write-Host "========== Done ==========" -ForegroundColor Cyan