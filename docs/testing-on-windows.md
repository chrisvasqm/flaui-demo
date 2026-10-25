# Testing on Windows

FlaUI drives Windows UI Automation (`UIA3`), so the tests must run on Windows with an interactive desktop. Docker and Wine cannot run them.

## Local machine or VM

1. Install the .NET 10 SDK.
2. Clone the repository.
3. Run the suite:

```powershell
dotnet test tests/flaui-demo.Tests.csproj
```

The tests launch `flaui-demo.exe`, find its main window, and drive the controls. Keep the desktop session unlocked while the tests run; a disconnected RDP session or a locked screen can make UIA calls fail.

On Apple Silicon, a Windows 11 ARM VM (Parallels, VMware Fusion, or UTM) is the most reliable local option. A physical x64 Windows machine is the safest fallback.

## Build and pack anywhere

The library targets `net8.0-windows7.0` and sets `EnableWindowsTargeting`, so `dotnet build` and `dotnet pack` work on macOS and Linux. Only the UI tests require Windows:

```sh
dotnet pack src/FlaUI.Window.Extensions/FlaUI.Window.Extensions.csproj -c Release -o artifacts
```

## CI

`.github/workflows/windows-tests.yml` runs `CounterTests` on `windows-latest` for pushes to `main`, pull requests, and manual dispatches.

Hosted Windows runners usually provide an interactive desktop, but UI automation can still be flaky there. If the suite is unreliable in hosted CI, move the job to a self-hosted Windows runner with an unlocked desktop session.
