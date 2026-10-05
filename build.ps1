[CmdletBinding()]
param(
    [string] $GameDir = $env:UT2004_GAME_DIR,
    [string] $ConfigDir = $env:UT2004_CONFIG_DIR,
    [string] $UccPath = $env:UT2004_UCC
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$packageName = "BetterSkinBrowser"
$builder = Join-Path $PSScriptRoot "tools\Build-UT2004Project.ps1"

& $builder `
    -ProjectDir $PSScriptRoot `
    -Packages @($packageName) `
    -PrimaryPackage $packageName `
    -GameDir $GameDir `
    -ConfigDir $ConfigDir `
    -UccPath $UccPath

$distDir = Join-Path $PSScriptRoot "dist"
$distSystem = Join-Path $distDir "System"
$distReadme = Join-Path $distDir "README.txt"
$distLicense = Join-Path $distDir "LICENSE.txt"
$archive = Join-Path $distDir "BetterSkinBrowser-v1.0.zip"
$checksums = Join-Path $distDir "SHA256SUMS.txt"
$releaseStage = Join-Path $env:TEMP ("better-skin-browser-release-{0}" -f [Guid]::NewGuid().ToString("N"))
$releaseSystem = Join-Path $releaseStage "System"

$requiredSystemFiles = @(
    (Join-Path $distSystem "$packageName.u"),
    (Join-Path $distSystem "$packageName.int"),
    (Join-Path $distSystem "$packageName.ucl")
)
foreach ($requiredFile in $requiredSystemFiles) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required release file was not produced: $requiredFile"
    }
}

Copy-Item -LiteralPath (Join-Path $PSScriptRoot "release\README.txt") -Destination $distReadme -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "LICENSE") -Destination $distLicense -Force

New-Item -ItemType Directory -Path $releaseSystem | Out-Null
foreach ($requiredFile in $requiredSystemFiles) {
    Copy-Item -LiteralPath $requiredFile -Destination $releaseSystem
}
Copy-Item -LiteralPath $distReadme, $distLicense -Destination $releaseStage

if (Test-Path -LiteralPath $archive) {
    Remove-Item -LiteralPath $archive -Force
}
Compress-Archive -LiteralPath `
    (Join-Path $releaseStage "System"), `
    (Join-Path $releaseStage "README.txt"), `
    (Join-Path $releaseStage "LICENSE.txt") `
    -DestinationPath $archive -CompressionLevel Optimal

$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $expectedEntries = @(
        "System/BetterSkinBrowser.u",
        "System/BetterSkinBrowser.int",
        "System/BetterSkinBrowser.ucl",
        "README.txt",
        "LICENSE.txt"
    )
    $actualEntries = @($zip.Entries | ForEach-Object { $_.FullName.Replace("\", "/") })
    foreach ($entry in $expectedEntries) {
        if ($actualEntries -notcontains $entry) {
            throw "Release archive is missing $entry"
        }
    }
}
finally {
    $zip.Dispose()
}

$checksumTargets = $requiredSystemFiles + @($archive)
$checksumLines = foreach ($target in $checksumTargets) {
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $target
    $relativeName = [IO.Path]::GetRelativePath($distDir, $target).Replace("\", "/")
    "{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $relativeName
}
[IO.File]::WriteAllLines($checksums, $checksumLines, [Text.Encoding]::ASCII)

Write-Host "Release archive: $archive"
Get-Content -LiteralPath $checksums
