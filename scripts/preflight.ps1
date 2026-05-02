$ErrorActionPreference = 'Stop'

Write-Host 'Finder preflight check...'

$checks = @(
  @{ Name = 'google-services.json'; Path = 'android/app/google-services.json'; Required = $true },
  @{ Name = 'firebase.json'; Path = 'firebase.json'; Required = $true },
  @{ Name = 'Firestore rules'; Path = 'firestore.rules'; Required = $true },
  @{ Name = 'Storage rules'; Path = 'storage.rules'; Required = $true },
  @{ Name = 'Functions package.json'; Path = 'functions/package.json'; Required = $true },
  @{ Name = 'Pubspec'; Path = 'pubspec.yaml'; Required = $true }
)

$failed = $false
foreach ($check in $checks) {
  if (Test-Path $check.Path) {
    Write-Host "[OK] $($check.Name)"
  } else {
    Write-Host "[MISSING] $($check.Name) -> $($check.Path)"
    if ($check.Required) { $failed = $true }
  }
}

Write-Host ''
Write-Host 'Running Flutter quality checks...'
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'flutter test failed' }

Write-Host ''
Write-Host 'Checking Functions dependencies...'
Push-Location functions
npm ci
if ($LASTEXITCODE -ne 0) { throw 'npm ci (functions) failed' }
Pop-Location

Write-Host ''
if ($failed) {
  Write-Host 'Preflight finished with missing required files.'
  exit 2
}

Write-Host 'Preflight OK. Ready for beta build.'
