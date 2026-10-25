# FlaUI Demo

Minimal WPF desktop application and UI automation test suite demonstrating a Playwright-inspired locator and action layer over [FlaUI](https://github.com/FlaUI/FlaUI) (`UIA3`).

The locator layer is also packaged from this repository as the `FlaUI.Window.Extensions` NuGet package.

## Getting Started

Prerequisites: .NET 10 SDK on Windows.

```powershell
# Run the WPF app
dotnet run

# Run the UI automation tests
dotnet test tests/flaui-demo.Tests.csproj

# Build the NuGet package
dotnet pack src/FlaUI.Window.Extensions/FlaUI.Window.Extensions.csproj -c Release -o artifacts
```

The package targets `net8.0-windows7.0` and can be built on macOS or Linux with `EnableWindowsTargeting`, which the project sets. UI automation tests require an interactive Windows desktop; see [Testing on Windows](docs/testing-on-windows.md).

## Folder Structure

```text
flaui-demo/
├── App.xaml / App.xaml.cs               # WPF application entry point
├── MainWindow.xaml / MainWindow.xaml.cs # Counter UI and click handlers
├── flaui-demo.csproj                    # WPF app project (net10.0-windows)
├── LICENSE                              # MIT license
├── src/
│   └── FlaUI.Window.Extensions/
│       ├── WindowExtensions.cs          # Locators & actions library
│       ├── README.md                    # NuGet package README
│       └── FlaUI.Window.Extensions.csproj
└── tests/
    ├── CounterTests.cs                  # NUnit UI automation tests
    ├── PageObjects/Counter.cs           # Counter page object
    └── flaui-demo.Tests.csproj          # Test project (NUnit + NExpect + FlaUI.UIA3)
```

## Overview

### Counter App (`MainWindow`)
A simple WPF window with:
- `Heading` (`TextBlock`): title text.
- `Decrement` (`Button`): decrements the counter, floored at `0`.
- `Count` (`Label`): displays the current count (`0` initially).
- `Increment` (`Button`): increments the counter by `1`.

Each control sets `x:Name`, which WPF exposes as the UI Automation `AutomationId`.

### Extensions Design (`src/FlaUI.Window.Extensions`)
Raw UI Automation tests are often flaky or verbose because elements render asynchronously, animate, or require different UIA patterns (`Invoke`, `Value`, `Toggle`, `SelectionItem`). `FlaUI.Window.Extensions` brings Playwright's ergonomics and reliability model to FlaUI.

1. **Package-owned namespace (`FlaUI.Window.Extensions`)**
   - The package does not add types to `FlaUI.Core.AutomationElements`. Consumers add `using FlaUI.Window.Extensions;` to light up locators on `Window` and `AutomationElement`.
   - Install with `dotnet add package FlaUI.Window.Extensions`.

2. **Lazy, Chainable Locators (`GetByTestId`, `GetByText`, `GetByRole`, `FindElement`)**
   - Calling `window.GetByTestId("Increment")` or chaining `parent.GetByRole(ControlType.Button, "+")` does not touch the UI tree. Resolution is deferred until an action or query executes, so chained locators never go stale if a parent container re-renders.

3. **Playwright Auto-Waiting & Backoff Polling**
   - **Actions** (`Click`, `DoubleClick`, `RightClick`, `Fill`, `Clear`, `Check`, `Uncheck`, `SelectOption`, `Press`, `Type`, `WaitFor`) poll with Playwright's backoff schedule (`[20, 50, 100, 100, 500, ...]` ms up to `30s` default) and verify actionability inside the retry loop:
     - **Attached**: present in the UIA tree.
     - **Visible**: not offscreen and has a non-zero bounding box.
     - **Stable**: bounding rectangle is unchanged across consecutive checks (`Click`, `DoubleClick`, `RightClick`, `Check`, `Uncheck`, `SelectOption`).
     - **Enabled & Editable**: `IsEnabled` (and not `IsReadOnly` for `Fill`/`Clear`).
   - **State Queries** (`IsVisible`, `IsHidden`) return immediately (`0ms` wait), while `Element`, `Text()` / `TextContent()`, `InputValue()`, `IsEnabled()`, and `IsChecked()` wait for attachment and read once, pairing cleanly with `NExpect` (`Expect(window.GetByTestId("Count").Text()).To.Equal("1")`).

4. **Pattern-First Interaction with Mouse/Control Fallbacks**
   - `Click()`, `Check()`, and `Uncheck()` prefer UIA patterns (`Invoke`, `Toggle`, `SelectionItem`) for fast, deterministic execution even when another window is in the foreground, falling back to physical mouse clicks (`forceMouse: true` or when no pattern applies) or control wrappers.
   - `Fill()` and `TextContent()` check `ValuePattern` and `TextPattern` before falling back to control wrappers or `Name`.
