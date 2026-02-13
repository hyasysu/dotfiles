<#
.SYNOPSIS
    更新 dotfiles 仓库的子模块，并将配置文件链接至系统路径。
.DESCRIPTION
    1. 初始化/更新所有 Git 子模块（递归、跟踪远程分支）
    2. 将仓库内的 .config/wezterm 链接至 ~/.config/wezterm
    3. 将仓库内的 .config/nvim 链接至 $env:LOCALAPPDATA\nvim
#>

# ---------- 1. Git 子模块初始化与更新 ----------
Write-Host "========== 正在更新 Git 子模块 ==========" -ForegroundColor Cyan

# 切换到脚本所在目录（仓库根目录）
Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# 检查 Git 是否可用
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "系统中未找到 Git 命令。请安装 Git 并将其加入 PATH。"
    exit 1
}

# 子模块操作
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive 'git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@") || git checkout main || git checkout master'

# 恢复工作目录
Pop-Location

Write-Host "子模块更新完成。`n" -ForegroundColor Green

# ---------- 2. 创建配置文件链接（原脚本内容） ----------
Write-Host "========== 正在创建配置文件链接 ==========" -ForegroundColor Cyan

# 获取仓库根目录
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# 源路径（仓库内）
$srcWezterm = Join-Path $repoRoot ".config\wezterm"
$srcNvim    = Join-Path $repoRoot ".config\nvim"

# 目标路径（系统配置位置）
$dstWezterm = "$HOME\.config\wezterm"
$dstNvim    = "$env:LOCALAPPDATA\nvim"

# ---------- 辅助函数 ----------
# 确保目标父目录存在
function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path $Path -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "创建父目录: $parent"
    }
}

# 创建链接（符号链接 → 目录联结）
function New-ConfigLink {
    param(
        [string]$Link,   # 链接路径（目标位置）
        [string]$Target  # 源路径（仓库内配置）
    )

    # 检查源路径是否存在
    if (-not (Test-Path $Target)) {
        Write-Error "源路径不存在: $Target"
        return
    }

    # 检查链接路径是否已存在
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -in @('Junction', 'SymbolicLink')) {
            Write-Host "链接已存在: $Link"
            $choice = Read-Host "是否删除现有链接并重新创建? (y/n)"
            if ($choice -ne 'y') {
                Write-Host "跳过创建 $Link"
                return
            }
            Remove-Item $Link -Force
        } else {
            Write-Host "警告: $Link 已存在且不是链接。请手动处理，跳过此链接。"
            return
        }
    }

    # 确保父目录存在
    Ensure-ParentDirectory $Link

    # 尝试创建符号链接（需管理员/开发者模式）
    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -ErrorAction Stop | Out-Null
        Write-Host "已创建符号链接: $Link → $Target" -ForegroundColor Green
        return
    } catch {
        Write-Warning "创建符号链接失败，可能缺少权限。尝试创建目录联结..."
    }

    # 回退：创建目录联结（无需提权，仅适用于本地卷）
    try {
        New-Item -ItemType Junction -Path $Link -Value $Target -ErrorAction Stop | Out-Null
        Write-Host "已创建目录联结: $Link → $Target" -ForegroundColor Green
    } catch {
        Write-Error "创建链接失败: $_"
    }
}

# ---------- 执行链接 ----------
New-ConfigLink -Link $dstWezterm -Target $srcWezterm
New-ConfigLink -Link $dstNvim    -Target $srcNvim

Write-Host "========== 操作全部完成 ==========" -ForegroundColor Cyan