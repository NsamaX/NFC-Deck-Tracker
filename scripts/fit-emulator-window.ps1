param(
    [int]$TimeoutSeconds = 60
)

# The emulator can open its window above the top edge of the screen (for
# example after a second monitor was disconnected). Move it back onto the
# primary screen and keep it within the working area.
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class EmulatorWindow {
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
do {
    $window = Get-Process qemu-system-* -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($window) { break }
    Start-Sleep -Seconds 1
} while ((Get-Date) -lt $deadline)
if (-not $window) { throw 'No emulator window found.' }

$area = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$rect = New-Object EmulatorWindow+RECT
[EmulatorWindow]::GetWindowRect($window.MainWindowHandle, [ref]$rect) | Out-Null
$height = $rect.Bottom - $rect.Top
$width = $rect.Right - $rect.Left
$x = [Math]::Max($area.Left, [Math]::Min($rect.Left, $area.Right - $width))
$y = [Math]::Max($area.Top, [Math]::Min($rect.Top, $area.Bottom - $height))

$noSize = 0x0001
$noZOrder = 0x0004
[EmulatorWindow]::SetWindowPos($window.MainWindowHandle, [IntPtr]::Zero, $x, $y, 0, 0, $noSize -bor $noZOrder) | Out-Null
Write-Output "Emulator window at ($x, $y), size ${width}x${height}"
