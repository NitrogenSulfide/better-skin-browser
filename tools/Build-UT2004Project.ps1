[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectDir,

    [Parameter(Mandatory = $true)]
    [string[]] $Packages,

    [Parameter(Mandatory = $true)]
    [string] $PrimaryPackage,

    [string[]] $ExtraEditPackages = @(),
    [string[]] $AdditionalDistFiles = @(),
    [string[]] $AdditionalPackageOutputs = @(),
    [string] $AdditionalPackageOutputDir,
    [string] $GameDir = $env:UT2004_GAME_DIR,
    [string] $ConfigDir = $env:UT2004_CONFIG_DIR,
    [string] $UccPath = $env:UT2004_UCC,
    [string] $BuildRoot = $env:TEMP
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RequiredPath {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Description
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Description was not configured."
    }

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($null -eq $resolved) {
        throw "$Description was not found: $Path"
    }
    return $resolved.Path
}

function New-RequiredJunction {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Target
    )

    try {
        New-Item -ItemType Junction -Path $Path -Target $Target -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Could not create an isolated directory junction from '$Path' to '$Target'. Enable Windows Developer Mode or place the build tree on a local NTFS volume. $($_.Exception.Message)"
    }
}

function Reset-StagingDirectory {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $AllowedParent
    )

    $fullPath = [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $fullParent = [IO.Path]::GetFullPath($AllowedParent).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $requiredPrefix = $fullParent + [IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to reset staging directory outside '$fullParent': $fullPath"
    }
    if (Test-Path -LiteralPath $fullPath) {
        Remove-Item -LiteralPath $fullPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

if ($Packages.Count -eq 0 -or $Packages -notcontains $PrimaryPackage) {
    throw "PrimaryPackage must also appear in Packages."
}
foreach ($package in $AdditionalPackageOutputs) {
    if ($Packages -notcontains $package) {
        throw "Additional output package '$package' must also appear in Packages."
    }
}
if ($AdditionalPackageOutputs.Count -gt 0 -and
    [string]::IsNullOrWhiteSpace($AdditionalPackageOutputDir)) {
    throw "AdditionalPackageOutputDir is required for additional package outputs."
}

$projectRoot = Resolve-RequiredPath -Path $ProjectDir -Description "Project directory"
$gameRoot = Resolve-RequiredPath -Path $GameDir -Description "UT2004_GAME_DIR"

if ($gameRoot -match '(?i)([\\/](steam|steamapps)[\\/]|proton)') {
    throw "Steam and Proton installations are not supported. Point UT2004_GAME_DIR at native OldUnreal UT2004."
}

$systemDir = Join-Path $gameRoot "System"
if ([string]::IsNullOrWhiteSpace($ConfigDir)) {
    $ConfigDir = $systemDir
}
$configRoot = Resolve-RequiredPath -Path $ConfigDir -Description "UT2004_CONFIG_DIR"

if ([string]::IsNullOrWhiteSpace($UccPath)) {
    $UccPath = Join-Path $systemDir "UCC.exe"
}
$ucc = Resolve-RequiredPath -Path $UccPath -Description "native OldUnreal UCC.exe"
if ($ucc -match '(?i)([\\/](steam|steamapps)[\\/]|proton)') {
    throw "Steam and Proton executables are not supported. Point UT2004_UCC at native OldUnreal UCC.exe."
}
$utIni = Resolve-RequiredPath -Path (Join-Path $configRoot "UT2004.ini") -Description "UT2004.ini"
$userIni = Resolve-RequiredPath -Path (Join-Path $configRoot "User.ini") -Description "User.ini"

if ([string]::IsNullOrWhiteSpace($BuildRoot)) {
    throw "TEMP is empty; pass an explicit -BuildRoot."
}
if (-not (Test-Path -LiteralPath $BuildRoot -PathType Container)) {
    New-Item -ItemType Directory -Path $BuildRoot | Out-Null
}

$buildDir = Join-Path $BuildRoot ("ut2004-{0}-build" -f $PrimaryPackage.ToLowerInvariant())
$buildSystem = Join-Path $buildDir "System"
$roundTripDir = Join-Path $buildDir "RoundTrip"
$distSystem = Join-Path $projectRoot "dist\System"

Reset-StagingDirectory -Path $buildDir -AllowedParent $BuildRoot
New-Item -ItemType Directory -Path $buildSystem, $roundTripDir, $distSystem -Force | Out-Null

$packageSources = @{}
foreach ($package in $Packages) {
    $candidates = @(
        (Join-Path $projectRoot $package),
        (Join-Path (Join-Path $projectRoot "tests") $package)
    )
    $source = $candidates | Where-Object { Test-Path -LiteralPath (Join-Path $_ "Classes") -PathType Container } | Select-Object -First 1
    if ($null -eq $source) {
        throw "Could not find $package\Classes under the project or its tests directory."
    }
    $packageSources[$package] = (Resolve-Path -LiteralPath $source).Path
}

# System dependencies are hard-linked when possible and copied as a safe
# fallback. Target outputs and writable configuration are never linked.
Get-ChildItem -LiteralPath $systemDir -File | ForEach-Object {
    $sourceFile = $_
    $skip = $sourceFile.Name -in @("UT2004.ini", "User.ini", "UCC.exe") -or $sourceFile.Extension -ieq ".log"
    foreach ($package in $Packages) {
        if ($sourceFile.Name -like "$package.*") {
            $skip = $true
        }
    }
    if ($skip) {
        return
    }

    $destination = Join-Path $buildSystem $sourceFile.Name
    # The engine may save mod settings and regenerate cache/localization files.
    # These must never share their writable file contents with the live game.
    if ($sourceFile.Extension -in @('.ini', '.ucl', '.int')) {
        Copy-Item -LiteralPath $sourceFile.FullName -Destination $destination
        return
    }
    try {
        New-Item -ItemType HardLink -Path $destination -Target $sourceFile.FullName -ErrorAction Stop | Out-Null
    }
    catch {
        Copy-Item -LiteralPath $sourceFile.FullName -Destination $destination
    }
}

$stagedUcc = Join-Path $buildSystem "UCC.exe"
Copy-Item -LiteralPath $ucc -Destination $stagedUcc
Copy-Item -LiteralPath $utIni -Destination (Join-Path $buildSystem "UT2004.ini") -Force
Copy-Item -LiteralPath $userIni -Destination (Join-Path $buildSystem "User.ini") -Force

Get-ChildItem -LiteralPath $gameRoot -Directory | Where-Object {
    $_.Name -ne "System" -and $Packages -notcontains $_.Name
} | ForEach-Object {
    New-RequiredJunction -Path (Join-Path $buildDir $_.Name) -Target $_.FullName
}
foreach ($package in $Packages) {
    New-RequiredJunction -Path (Join-Path $buildDir $package) -Target $packageSources[$package]
}

$buildIni = Join-Path $buildSystem "UT2004.ini"
$reader = [IO.StreamReader]::new($buildIni, $true)
try {
    $iniText = $reader.ReadToEnd()
    $iniEncoding = $reader.CurrentEncoding
}
finally {
    $reader.Dispose()
}

$editPackages = @($ExtraEditPackages) + @($Packages)
foreach ($package in $editPackages) {
    $escaped = [Regex]::Escape($package)
    $iniText = [Regex]::Replace($iniText, "(?im)^[ `t]*EditPackages=$escaped[ `t]*`r?`n", "")
}
$anchor = [Regex]::Match($iniText, '(?im)^\[UWeb\.WebServer\]')
if (-not $anchor.Success) {
    throw "UT2004.ini does not contain [UWeb.WebServer]; refusing to guess where EditPackages belongs."
}
$editBlock = (($editPackages | ForEach-Object { "EditPackages=$_" }) -join "`r`n") + "`r`n"
$iniText = $iniText.Insert($anchor.Index, $editBlock)
[IO.File]::WriteAllText($buildIni, $iniText, $iniEncoding)

function Invoke-Ucc {
    param([Parameter(Mandatory = $true)] [string[]] $CommandArguments)

    Push-Location $buildSystem
    try {
        & $stagedUcc @CommandArguments
        if ($LASTEXITCODE -ne 0) {
            throw "UCC.exe exited with status $LASTEXITCODE while running: $($CommandArguments -join ' ')"
        }
    }
    finally {
        Pop-Location
    }
}

$makeLog = Join-Path $buildDir "Make.log"
$exportLog = Join-Path $buildDir "BatchExport.log"
Invoke-Ucc -CommandArguments @("make", "-nohomedir", "-ini=UT2004.ini", "-userini=User.ini", "-log=$makeLog")

foreach ($package in $Packages) {
    $output = Join-Path $buildSystem "$package.u"
    if (-not (Test-Path -LiteralPath $output -PathType Leaf) -or (Get-Item -LiteralPath $output).Length -eq 0) {
        throw "UCC did not produce $package.u. Inspect $makeLog"
    }
}
if (-not (Select-String -LiteralPath $makeLog -SimpleMatch "Success - 0 error(s), 0 warning(s)" -Quiet)) {
    throw "UCC did not report a clean build. Inspect $makeLog"
}

Invoke-Ucc -CommandArguments @("batchexport", "$PrimaryPackage.u", "class", "uc", $roundTripDir, "-nohomedir", "-ini=UT2004.ini", "-userini=User.ini", "-log=$exportLog")
if (-not (Get-ChildItem -LiteralPath $roundTripDir -Filter "*.uc" -File)) {
    throw "Round-trip export produced no UnrealScript source. Inspect $exportLog"
}
if (-not (Select-String -LiteralPath $exportLog -SimpleMatch "Success - 0 error(s), 0 warning(s)" -Quiet)) {
    throw "UCC did not report a clean round-trip export. Inspect $exportLog"
}

Invoke-Ucc -CommandArguments @("dumpint", "$PrimaryPackage.u")
Invoke-Ucc -CommandArguments @("exportcache", "$PrimaryPackage.u")

foreach ($extension in @("u", "ucl", "int")) {
    $oldOutput = Join-Path $distSystem "$PrimaryPackage.$extension"
    if (Test-Path -LiteralPath $oldOutput) {
        Remove-Item -LiteralPath $oldOutput -Force
    }
    $newOutput = Join-Path $buildSystem "$PrimaryPackage.$extension"
    if (Test-Path -LiteralPath $newOutput -PathType Leaf) {
        Copy-Item -LiteralPath $newOutput -Destination $distSystem
    }
}

foreach ($relativeFile in $AdditionalDistFiles) {
    $source = Resolve-RequiredPath -Path (Join-Path $projectRoot $relativeFile) -Description "Additional dist file"
    Copy-Item -LiteralPath $source -Destination $distSystem
}

$additionalPackageFiles = @()
if ($AdditionalPackageOutputs.Count -gt 0) {
    if (-not (Test-Path -LiteralPath $AdditionalPackageOutputDir -PathType Container)) {
        New-Item -ItemType Directory -Path $AdditionalPackageOutputDir -Force | Out-Null
    }
    $additionalOutputRoot = (Resolve-Path -LiteralPath $AdditionalPackageOutputDir).Path
    foreach ($package in $AdditionalPackageOutputs) {
        $source = Resolve-RequiredPath -Path (Join-Path $buildSystem "$package.u") `
            -Description "compiled additional package $package.u"
        $destination = Join-Path $additionalOutputRoot "$package.u"
        Copy-Item -LiteralPath $source -Destination $destination -Force
        $additionalPackageFiles += Get-Item -LiteralPath $destination
    }
}

$additionalNames = @($AdditionalDistFiles | ForEach-Object { Split-Path -Leaf $_ })
$outputs = Get-ChildItem -LiteralPath $distSystem -File | Where-Object { $_.BaseName -eq $PrimaryPackage -or $additionalNames -contains $_.Name }
if (-not $outputs) {
    throw "No distributable files were produced."
}

Write-Host "Build directory: $buildDir"
$outputs | Sort-Object Name | ForEach-Object {
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName
    Write-Host ("{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $_.FullName)
}
$additionalPackageFiles | Sort-Object Name | ForEach-Object {
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName
    Write-Host ("{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $_.FullName)
}
