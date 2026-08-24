#requires -Version 5.1

$ErrorActionPreference = "Continue"

# ============================================================
# RAHPEYMAN FLUTTER BOT
# ============================================================
# Automatic Flutter / Android Emulator helper
# Project: D:\Projects\Rahpeyman
# ============================================================

$ProjectPath = "D:\Projects\Rahpeyman"
$PreferredAvd = "Pixel_7"

# ------------------------------------------------------------
# Console helpers
# ------------------------------------------------------------

function Write-Info {
    param([string]$Text)
    Write-Host "[INFO] $Text" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Text)
    Write-Host "[ OK ] $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "[WARN] $Text" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "[ERR ] $Text" -ForegroundColor Red
}

function Write-Title {
    param([string]$Text)

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host " $Text" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""
}

# ------------------------------------------------------------
# Pause
# ------------------------------------------------------------

function Pause-Bot {
    Write-Host ""
    Read-Host "Press ENTER to continue"
}

# ------------------------------------------------------------
# Check project
# ------------------------------------------------------------

function Test-Project {

    if (-not (Test-Path $ProjectPath)) {
        Write-Err "Project folder not found:"
        Write-Host $ProjectPath
        return $false
    }

    $pubspec = Join-Path $ProjectPath "pubspec.yaml"

    if (-not (Test-Path $pubspec)) {
        Write-Err "pubspec.yaml not found."
        return $false
    }

    return $true
}

# ------------------------------------------------------------
# Find Android SDK
# ------------------------------------------------------------

function Find-AndroidSdk {

    $candidates = @(
        "D:\AndroidSDK-Offline\TestSDK",
        "D:\Android\Sdk",
        "C:\Users\1403-07-17\AppData\Local\Android\Sdk"
    )

    foreach ($sdk in $candidates) {

        $adb = Join-Path $sdk "platform-tools\adb.exe"

        $emulator = Join-Path $sdk "emulator\emulator.exe"

        if ((Test-Path $adb) -or (Test-Path $emulator)) {
            return $sdk
        }
    }

    return $null
}

# ------------------------------------------------------------
# Find emulator
# ------------------------------------------------------------

function Find-Emulator {

    $sdk = Find-AndroidSdk

    if ($null -ne $sdk) {

        $path = Join-Path $sdk "emulator\emulator.exe"

        if (Test-Path $path) {
            return $path
        }
    }

    $extra = @(
        "D:\Program\نرم افزار مخصوص تست اندروید\tools\emulator.exe"
    )

    foreach ($path in $extra) {

        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

# ------------------------------------------------------------
# Find ADB
# ------------------------------------------------------------

function Find-Adb {

    $sdk = Find-AndroidSdk

    if ($null -ne $sdk) {

        $path = Join-Path $sdk "platform-tools\adb.exe"

        if (Test-Path $path) {
            return $path
        }
    }

    $adb = Get-Command adb -ErrorAction SilentlyContinue

    if ($null -ne $adb) {
        return $adb.Source
    }

    return $null
}

# ------------------------------------------------------------
# Find Flutter
# ------------------------------------------------------------

function Find-Flutter {

    $flutter = Get-Command flutter -ErrorAction SilentlyContinue

    if ($null -ne $flutter) {
        return $flutter.Source
    }

    $candidates = @(
        "C:\src\flutter\bin\flutter.bat",
        "D:\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "D:\Program\flutter\bin\flutter.bat"
    )

    foreach ($path in $candidates) {

        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

# ------------------------------------------------------------
# Configure Android environment
# ------------------------------------------------------------

function Configure-Environment {

    Write-Info "Detecting Android SDK..."

    $sdk = Find-AndroidSdk

    if ($null -eq $sdk) {
        Write-Err "Android SDK not found."
        return $false
    }

    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk

    Write-Ok "Android SDK:"
    Write-Host $sdk

    $flutter = Find-Flutter

    if ($null -eq $flutter) {
        Write-Err "Flutter was not found."
        return $false
    }

    Write-Ok "Flutter:"
    Write-Host $flutter

    return $true
}

# ------------------------------------------------------------
# Get available AVDs
# ------------------------------------------------------------

function Get-Avds {

    $emulator = Find-Emulator

    if ($null -eq $emulator) {
        return @()
    }

    $output = & $emulator -list-avds 2>$null

    if ($null -eq $output) {
        return @()
    }

    return @(
        $output |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        } |
        ForEach-Object {
            $_.Trim()
        }
    )
}

# ------------------------------------------------------------
# Select AVD
# ------------------------------------------------------------

function Get-BestAvd {

    $avds = Get-Avds

    if ($avds.Count -eq 0) {
        return $null
    }

    if ($avds -contains $PreferredAvd) {
        return $PreferredAvd
    }

    return $avds[0]
}

# ------------------------------------------------------------
# Check emulator state
# ------------------------------------------------------------

function Test-EmulatorRunning {

    $adb = Find-Adb

    if ($null -eq $adb) {
        return $false
    }

    $devices = & $adb devices 2>$null

    if ($null -eq $devices) {
        return $false
    }

    foreach ($line in $devices) {

        if ($line -match "^emulator-\d+\s+device$") {
            return $true
        }
    }

    return $false
}

# ------------------------------------------------------------
# Start emulator
# ------------------------------------------------------------

function Start-AndroidEmulator {

    Write-Title "START ANDROID EMULATOR"

    $emulator = Find-Emulator

    if ($null -eq $emulator) {
        Write-Err "emulator.exe was not found."
        return $false
    }

    Write-Ok "Emulator executable:"
    Write-Host $emulator

    $avd = Get-BestAvd

    if ($null -eq $avd) {
        Write-Err "No Android Virtual Device was found."
        return $false
    }

    Write-Ok "Selected AVD:"
    Write-Host $avd

    if (Test-EmulatorRunning) {

        Write-Ok "An Android emulator is already running."

        return Wait-ForAndroid
    }

    Write-Info "Starting Android emulator..."

    try {

        Start-Process `
            -FilePath $emulator `
            -ArgumentList "-avd `"$avd`"" `
            -WindowStyle Normal

    }
    catch {

        Write-Err "Could not start emulator."
        Write-Host $_.Exception.Message

        return $false
    }

    Write-Info "Waiting for Android to boot..."

    return Wait-ForAndroid
}

# ------------------------------------------------------------
# Wait for Android
# ------------------------------------------------------------

function Wait-ForAndroid {

    $adb = Find-Adb

    if ($null -eq $adb) {
        Write-Err "adb.exe was not found."
        return $false
    }

    Write-Info "Waiting for ADB..."

    for ($i = 1; $i -le 60; $i++) {

        Start-Sleep -Seconds 2

        $state = & $adb get-state 2>$null

        if ($state -match "device") {

            Write-Ok "ADB device detected."

            break
        }

        Write-Host "." -NoNewline
    }

    Write-Host ""

    for ($i = 1; $i -le 90; $i++) {

        $boot = & $adb shell getprop sys.boot_completed 2>$null

        if ($boot -match "1") {

            Write-Ok "Android boot completed."

            Start-Sleep -Seconds 3

            return $true
        }

        Start-Sleep -Seconds 2
    }

    Write-Warn "Android did not report boot_completed."

    return $false
}

# ------------------------------------------------------------
# Flutter command runner
# ------------------------------------------------------------

function Invoke-Flutter {

    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $flutter = Find-Flutter

    if ($null -eq $flutter) {

        Write-Err "Flutter executable was not found."

        return 1
    }

    Push-Location $ProjectPath

    try {

        Write-Info "Running:"
        Write-Host "flutter $($Arguments -join ' ')"

        & $flutter @Arguments

        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {

            Write-Ok "Flutter command completed successfully."

        }
        else {

            Write-Err "Flutter command failed."

            Write-Host "Exit code: $exitCode"
        }

        return $exitCode

    }
    finally {

        Pop-Location
    }
}

# ------------------------------------------------------------
# Flutter devices
# ------------------------------------------------------------

function Show-FlutterDevices {

    Write-Title "FLUTTER DEVICES"

    Invoke-Flutter @("devices")

    Pause-Bot
}

# ------------------------------------------------------------
# Clean
# ------------------------------------------------------------

function Run-Clean {

    Write-Title "FLUTTER CLEAN"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    Invoke-Flutter @("clean")

    Pause-Bot
}

# ------------------------------------------------------------
# Pub get
# ------------------------------------------------------------

function Run-PubGet {

    Write-Title "FLUTTER PUB GET"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    Invoke-Flutter @("pub", "get")

    Pause-Bot
}

# ------------------------------------------------------------
# Analyze
# ------------------------------------------------------------

function Run-Analyze {

    Write-Title "FLUTTER ANALYZE"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    Invoke-Flutter @(
        "analyze",
        "lib\modules\engineering_assistant\screens\concrete_calculator_screen.dart"
    )

    Pause-Bot
}

# ------------------------------------------------------------
# Full analyze
# ------------------------------------------------------------

function Run-FullAnalyze {

    Write-Title "FULL FLUTTER ANALYZE"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    Invoke-Flutter @("analyze")

    Pause-Bot
}

# ------------------------------------------------------------
# Run application
# ------------------------------------------------------------

function Run-App {

    Write-Title "RUN RAHPEYMAN"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    if (-not (Start-AndroidEmulator)) {

        Write-Err "Android emulator could not be started."

        Pause-Bot

        return
    }

    Write-Title "FLUTTER DEVICES"

    Invoke-Flutter @("devices")

    Write-Host ""
    Write-Info "Starting Rahpeyman..."

    Push-Location $ProjectPath

    try {

        $flutter = Find-Flutter

        if ($null -eq $flutter) {

            Write-Err "Flutter not found."

            return
        }

        & $flutter run -d emulator-5554

    }
    finally {

        Pop-Location
    }

    Pause-Bot
}

# ------------------------------------------------------------
# Full repair
# ------------------------------------------------------------

function Run-FullRepair {

    Write-Title "FULL PROJECT CHECK"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    if (-not (Configure-Environment)) {
        Pause-Bot
        return
    }

    Write-Title "ANDROID EMULATOR"

    if (-not (Start-AndroidEmulator)) {

        Write-Err "Emulator startup failed."

        Pause-Bot

        return
    }

    Write-Title "FLUTTER CLEAN"

    Invoke-Flutter @("clean")

    Write-Title "FLUTTER PUB GET"

    Invoke-Flutter @("pub", "get")

    Write-Title "FLUTTER ANALYZE"

    Invoke-Flutter @("analyze")

    Write-Title "FLUTTER DEVICES"

    Invoke-Flutter @("devices")

    Write-Ok "Project check completed."

    Pause-Bot
}

# ------------------------------------------------------------
# Run
# ------------------------------------------------------------

function Run-QuickStart {

    Write-Title "QUICK START"

    if (-not (Test-Project)) {
        Pause-Bot
        return
    }

    if (-not (Configure-Environment)) {
        Pause-Bot
        return
    }

    if (-not (Start-AndroidEmulator)) {

        Write-Err "Could not start Android emulator."

        Pause-Bot

        return
    }

    Write-Title "FLUTTER DEVICES"

    Invoke-Flutter @("devices")

    Write-Title "RUN APPLICATION"

    Push-Location $ProjectPath

    try {

        $flutter = Find-Flutter

        & $flutter run -d emulator-5554

    }
    finally {

        Pop-Location
    }

    Pause-Bot
}

# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------

function Run-Diagnostics {

    Write-Title "RAHPEYMAN DIAGNOSTICS"

    Write-Info "Project:"
    Write-Host $ProjectPath

    Write-Host ""

    $sdk = Find-AndroidSdk

    if ($sdk) {
        Write-Ok "Android SDK found:"
        Write-Host $sdk
    }
    else {
        Write-Err "Android SDK not found."
    }

    Write-Host ""

    $emulator = Find-Emulator

    if ($emulator) {
        Write-Ok "Emulator found:"
        Write-Host $emulator
    }
    else {
        Write-Err "Emulator not found."
    }

    Write-Host ""

    $adb = Find-Adb

    if ($adb) {
        Write-Ok "ADB found:"
        Write-Host $adb
    }
    else {
        Write-Err "ADB not found."
    }

    Write-Host ""

    $flutter = Find-Flutter

    if ($flutter) {
        Write-Ok "Flutter found:"
        Write-Host $flutter
    }
    else {
        Write-Err "Flutter not found."
    }

    Write-Host ""

    Write-Info "Available AVDs:"

    $avds = Get-Avds

    if ($avds.Count -eq 0) {

        Write-Warn "No AVD found."

    }
    else {

        foreach ($avd in $avds) {

            Write-Host " - $avd"
        }
    }

    Write-Host ""

    if (Test-EmulatorRunning) {
        Write-Ok "Android emulator appears to be running."
    }
    else {
        Write-Warn "Android emulator is not running."
    }

    Write-Host ""

    Pause-Bot
}

# ------------------------------------------------------------
# Main menu
# ------------------------------------------------------------

function Show-Menu {

    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "                 RAHPEYMAN FLUTTER BOT" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host " Project: $ProjectPath" -ForegroundColor White
    Write-Host ""

    Write-Host " [1] Quick Start        Emulator + Flutter Run"
    Write-Host " [2] Start Emulator     Start Pixel_7"
    Write-Host " [3] Run App            Flutter Run"
    Write-Host " [4] Clean              Flutter Clean"
    Write-Host " [5] Pub Get            Flutter Pub Get"
    Write-Host " [6] Analyze File       Analyze concrete calculator"
    Write-Host " [7] Full Analyze       Analyze entire project"
    Write-Host " [8] Full Repair        Clean + Pub Get + Analyze"
    Write-Host " [9] Devices            Show Flutter devices"
    Write-Host " [D] Diagnostics        Check environment"
    Write-Host " [0] Exit"
    Write-Host ""
}

# ------------------------------------------------------------
# Startup
# ------------------------------------------------------------

if (-not (Test-Project)) {

    Write-Err "Rahpeyman project was not found."

    Pause-Bot

    exit
}

Configure-Environment | Out-Null

while ($true) {

    Show-Menu

    $choice = Read-Host "Select an option"

    switch ($choice.ToUpper()) {

        "1" {
            Run-QuickStart
        }

        "2" {
            Start-AndroidEmulator | Out-Null
            Pause-Bot
        }

        "3" {
            Run-App
        }

        "4" {
            Run-Clean
        }

        "5" {
            Run-PubGet
        }

        "6" {
            Run-Analyze
        }

        "7" {
            Run-FullAnalyze
        }

        "8" {
            Run-FullRepair
        }

        "9" {
            Show-FlutterDevices
        }

        "D" {
            Run-Diagnostics
        }

        "0" {
            Write-Host ""
            Write-Host "Rahpeyman Bot closed." -ForegroundColor Green
            break
        }

        default {
            Write-Warn "Invalid option."
            Start-Sleep -Seconds 1
        }
    }
}