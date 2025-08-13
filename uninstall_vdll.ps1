param([switch]$RevertFfmpegPath)

# check for admin privileges and relaunch as admin if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell"
    $psi.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Host "elevation canceled."
    }
    exit
}

$ErrorActionPreference = 'Stop'

# remove context-menu registry keys
$baseExts = @(".mp4",".mkv",".webm",".mov",".avi",".mp3")
foreach ($ext in $baseExts) {
    $root = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\vdll_convert"
    if (Test-Path $root) {
        Remove-Item -Path $root -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "vdll context-menu entries removed."

# remove vdll_convert.ps1 script
$scriptDir = "$env:LOCALAPPDATA\VDLL"
$cmdPath = Join-Path $scriptDir "vdll_convert.ps1"
if (Test-Path $cmdPath) {
    Remove-Item -Path $cmdPath -Force
    Write-Host "vdll conversion script removed."
}

# optionally remove ffmpeg
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $removeFfmpeg = Read-Host "do you want to uninstall ffmpeg? (y/n)"
    if ($removeFfmpeg -eq 'y') {
        choco uninstall ffmpeg -y
        Write-Host "ffmpeg uninstalled."
    }
} else {
    Write-Host "chocolatey not found, skipping ffmpeg and chocolatey removal."
}

Write-Host "uninstall complete. you may need to restart explorer for menus to refresh."

Write-Host "Press any key to continue..."
[void][System.Console]::ReadKey($true)
