# FlaUI.Window.Extensions

Playwright-style locators, auto-waiting actions, and state queries for [FlaUI](https://github.com/FlaUI/FlaUI).

## Install

```sh
dotnet add package FlaUI.Window.Extensions
```

The package targets `net8.0-windows7.0` and depends on `FlaUI.Core` 5.0.0. Bring your own automation implementation, such as `FlaUI.UIA3`.

## Usage

```csharp
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Window.Extensions;

var window = app.GetMainWindow(automation)!;

window.GetByTestId("Increment").Click();
window.GetByTestId("Count").WaitFor();
var count = window.GetByTestId("Count").Text();
```

Locators are lazy and chainable. They do not query the UI tree until an action or state query runs.

```csharp
var dialog = window.GetByRole(ControlType.Dialog);
dialog.GetByText("Save").Click();
dialog.GetByTestId("Name").Fill("Ada");
dialog.GetByTestId("Enabled").Check();
dialog.GetByRole(ControlType.ComboBox).SelectOption("Option 2");
```

Actions wait until the element is attached, visible, enabled, editable when entering text, and stable for click-style actions. Use `Locator.DefaultTimeout` to change the default timeout.

```csharp
Locator.DefaultTimeout = TimeSpan.FromSeconds(10);
```

## API

- Locators: `FindElement`, `GetByTestId`, `GetByText`, `GetByRole`
- Actions: `Click`, `DoubleClick`, `RightClick`, `Fill`, `Clear`, `Check`, `Uncheck`, `SelectOption`, `Press`, `Type`
- State and queries: `WaitFor`, `IsVisible`, `IsHidden`, `IsEnabled`, `IsChecked`, `Text`, `TextContent`, `InputValue`
- Configuration: `Locator.DefaultTimeout`

## License

MIT
