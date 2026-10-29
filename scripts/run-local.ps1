param([string]$Device = 'emulator-5554')
$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter.bat -ErrorAction SilentlyContinue)) {
    throw 'Flutter is missing from PATH. See FIREBASE_EMULATOR.md.'
}
$connection = Test-NetConnection -ComputerName 127.0.0.1 -Port 8080 -WarningAction SilentlyContinue
if (-not $connection.TcpTestSucceeded) {
    throw 'Start scripts/start-firestore.ps1 in another terminal first.'
}
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    & flutter.bat run --debug -d $Device --dart-define=USE_FIRESTORE_EMULATOR=true
    if ($LASTEXITCODE -ne 0) { throw "Flutter exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
