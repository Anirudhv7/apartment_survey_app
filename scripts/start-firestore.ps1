$ErrorActionPreference = 'Stop'
foreach ($command in @('node', 'java', 'firebase.cmd')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Missing $command. See FIREBASE_EMULATOR.md for prerequisites."
    }
}
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    & firebase.cmd emulators:start --only firestore --project demo-apartment-survey --config firebase.emulators.json
    if ($LASTEXITCODE -ne 0) { throw "Emulator exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
