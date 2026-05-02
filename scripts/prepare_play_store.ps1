$ErrorActionPreference = 'Stop'

Write-Host 'Preparing Finder Play Store assets...'

powershell -ExecutionPolicy Bypass -File scripts/generate_brand_assets.ps1
if ($LASTEXITCODE -ne 0) { throw 'brand assets generation failed' }

flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }

dart run flutter_launcher_icons
if ($LASTEXITCODE -ne 0) { throw 'flutter_launcher_icons failed' }

Write-Host ''
Write-Host 'Running checks...'
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }

flutter test
if ($LASTEXITCODE -ne 0) { throw 'flutter test failed' }

Write-Host ''
Write-Host 'Play Store assets and launcher icons are ready.'
