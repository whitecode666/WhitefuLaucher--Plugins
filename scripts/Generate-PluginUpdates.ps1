param(
    [string]$RootDir = (Split-Path $PSScriptRoot -Parent)
)

$RepoRawBase = 'https://raw.githubusercontent.com/whitecode666/WhitefuLaucher--Plugins/main'

$known = @(
    @{ Id = 'WhiteFuPlugin'; Zip = 'WhiteFuPlugin.zip'; Dll = 'WhitefuLaucher.UnlockerIsland.dll' }
)

$shortSha = git -C $RootDir rev-parse --short HEAD 2>$null
if (-not $shortSha) { $shortSha = 'local' }

$entries = @()
foreach ($k in $known) {
    $zip = Join-Path $RootDir $k.Zip
    if (-not (Test-Path -LiteralPath $zip)) {
        Write-Warning "Thieu $($k.Zip) - bo qua"
        continue
    }
    $hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
    $size = (Get-Item -LiteralPath $zip).Length
    $entries += [ordered]@{
        id            = $k.Id
        version       = "auto-$shortSha"
        install_type  = 'zip'
        download_url  = "$RepoRawBase/$($k.Zip)"
        dll_file_name = $k.Dll
        file_hash     = $hash
        size_bytes    = $size
    }
}

$manifest = [ordered]@{ schema_version = 1; plugins = $entries }
$json = $manifest | ConvertTo-Json -Depth 5
$out = Join-Path $RootDir 'plugin-updates.json'
[System.IO.File]::WriteAllText($out, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "Da ghi $out ($($entries.Count) entries)"