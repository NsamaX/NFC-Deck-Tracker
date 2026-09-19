$projectRoot = Split-Path -Parent $PSScriptRoot
$localSdk = Join-Path $projectRoot '.local/android-sdk'
$localJdk = Join-Path $projectRoot '.local/jdk'
if (Test-Path -LiteralPath $localSdk) {
    $env:ANDROID_HOME = $localSdk
    $env:ANDROID_SDK_ROOT = $localSdk
    $env:ANDROID_AVD_HOME = Join-Path $projectRoot '.local/avd'
    $env:PATH = "$localSdk/platform-tools;$localSdk/emulator;$env:PATH"
}
if (Test-Path -LiteralPath $localJdk) {
    $jdkDirectory = Get-ChildItem -LiteralPath $localJdk -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/java.exe') } |
        Select-Object -First 1
    if ($jdkDirectory) {
        $env:JAVA_HOME = $jdkDirectory.FullName
        $env:PATH = "$env:JAVA_HOME/bin;$env:PATH"
    }
}

$env:FLUTTER_WINDOWS = 'false'
