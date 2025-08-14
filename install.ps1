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

# temporarily allow script execution
Set-ExecutionPolicy Bypass -Scope Process -Force

# install chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "installing chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "chocolatey is already installed."
}

# install ffmpeg via chocolatey
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "installing ffmpeg via chocolatey..."
    choco install ffmpeg -y
} else {
    Write-Host "ffmpeg is already installed."
}

# define the path to the conversion script
$scriptDir = "$env:LOCALAPPDATA\VDLL"
if (-not (Test-Path $scriptDir)) { New-Item -Path $scriptDir -ItemType Directory | Out-Null }
$cmdPath = Join-Path $scriptDir "vdll_convert.ps1"

# create vdll_convert.ps1 with the fixed content
$scriptContent = @'
param (
    [string]$InputFile,
    [string]$TargetFormat
)

$OutputFile = [System.IO.Path]::ChangeExtension($InputFile, $TargetFormat)

ffmpeg -i "`"$InputFile`"" "`"$OutputFile`""

Write-Host "`n`n`nConversion complete. Output file:" $OutputFile
Write-Host "Press a key to close this window..."

[void][System.Console]::ReadKey($true)
'@

Set-Content -Path $cmdPath -Value $scriptContent -Force

# create context-menu registry keys
$baseExts = @(".mp4",".mkv",".webm",".mov",".avi",".mp3")
foreach ($ext in $baseExts) {
    $root = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\vdll_convert"
    New-Item -Path $root -Force | Out-Null
    New-ItemProperty -Path $root -Name "MUIVerb" -Value "VDLL Convert" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $root -Name "SubCommands" -Value "" -PropertyType String -Force | Out-Null

    $sub = Join-Path $root "shell"
    New-Item -Path $sub -Force | Out-Null

    foreach ($fmt in @("mp4","mkv","webm","mov","avi","mp3")) {
        $fmtKey = Join-Path $sub $fmt
        New-Item -Path $fmtKey -Force | Out-Null
        New-ItemProperty -Path $fmtKey -Name "MUIVerb" -Value $fmt.ToUpper() -PropertyType String -Force | Out-Null

        $cmdKey = Join-Path $fmtKey "command"
        New-Item -Path $cmdKey -Force | Out-Null
        $command = "powershell -ExecutionPolicy Bypass -File `"$cmdPath`" -InputFile `"%1`" -TargetFormat $fmt"
        New-ItemProperty -Path $cmdKey -Name "(default)" -Value $command -PropertyType String -Force | Out-Null
    }
}

Write-Host "`n`n`nnote: on windows 11, it might be under the 'show more options' menu."
Write-Host "Installation complete. Press any key to continue..."
[void][System.Console]::ReadKey($true)
