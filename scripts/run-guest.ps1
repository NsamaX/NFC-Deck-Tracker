param(
    [string]$DeviceId = 'emulator-5554',
    [string]$AvdName = 'NFC_Deck_API_35',
    [switch]$NoWindow,
    [switch]$BuildOnly
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/android-env.ps1"
Push-Location $projectRoot
try {
    if (-not (Test-Path -LiteralPath '.env')) {
        Copy-Item -LiteralPath '.env.example' -Destination '.env'
    }
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency setup failed.' }

    if ($BuildOnly) {
        & flutter build apk --debug --target-platform android-x64 --dart-define=GUEST_MODE=true --no-pub
        if ($LASTEXITCODE -ne 0) { throw 'Guest APK build failed.' }
    } else {
        $devices = & adb devices
        if (-not ($devices -match ('^' + [regex]::Escape($DeviceId) + '\s+device$'))) {
            if ($DeviceId -ne 'emulator-5554') {
                throw "Connect device $DeviceId first, or omit -DeviceId to start the local emulator."
            }
            if (-not ($devices -match '^emulator-5554\s+offline$')) {
                $emulatorArguments = @('-avd', $AvdName, '-port', '5554', '-gpu', 'software', '-no-audio')
                if ($NoWindow) { $emulatorArguments += '-no-window' }
                Start-Process -FilePath (Get-Command emulator).Source -ArgumentList $emulatorArguments -WindowStyle Hidden
            }
        }

        $bootDeadline = (Get-Date).AddMinutes(5)
        do {
            $ErrorActionPreference = 'Continue'
            $booted = & adb -s $DeviceId shell getprop sys.boot_completed 2>$null
            $ErrorActionPreference = 'Stop'
            if ($booted -match '^1') { break }
            if ((Get-Date) -gt $bootDeadline) { throw "Timed out waiting for $DeviceId to boot." }
            Start-Sleep -Seconds 2
        } while ($true)

        & flutter run -d $DeviceId --dart-define=GUEST_MODE=true --no-pub
        if ($LASTEXITCODE -ne 0) { throw 'Flutter could not run the Guest app.' }
    }
} finally {
    Pop-Location
}
