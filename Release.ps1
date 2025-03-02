# Run with PowerShell 7.4.X

$manifest = Get-Content "manifest.json" | ConvertFrom-Json
$currentLatestVersion = $manifest.version

Write-Host "Current latest version: v$currentLatestVersion"
$newVersion = Read-Host "Enter the new version (e.g. 1.0.1)"
$filename = "WWeb Improvements v$newVersion.zip"

$manifest.version = $newVersion
$manifest | ConvertTo-Json -Depth 100 | Set-Content "manifest.json"

$tempDir = ".\releases\temp"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# use robocopy to copy files and folders keeping the structure
robocopy "src\out\" "$tempDir\src\out\" /E | Out-Null
robocopy "images" "$tempDir\images" /E /XD "showcase" | Out-Null
robocopy "src\assets\inter" "$tempDir\src\assets\inter" /E | Out-Null
Copy-Item -Path "manifest.json" -Destination $tempDir

Compress-Archive -Path $tempDir\* -Destination .\releases\$filename -Force
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "New release file created: $filename"
