$ErrorActionPreference = 'Stop'

Write-Host 'Finder release build starting...'

powershell -ExecutionPolicy Bypass -File scripts/preflight.ps1
if ($LASTEXITCODE -ne 0) { throw 'preflight failed' }

Write-Host ''
Write-Host 'Building Android App Bundle (release)...'
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) { throw 'flutter build appbundle failed' }

$bundlePath = 'build/app/outputs/bundle/release/app-release.aab'
if (Test-Path $bundlePath) {
  Write-Host ''
  Write-Host "Build OK: $bundlePath"
} else {
  throw 'AAB not found after build'
}
