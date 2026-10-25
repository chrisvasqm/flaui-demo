#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="${1:-0.1.0}"
artifacts="$repo_root/artifacts"
package="$artifacts/FlaUI.Window.Extensions.$version.nupkg"

dotnet pack "$repo_root/src/FlaUI.Window.Extensions/FlaUI.Window.Extensions.csproj" \
  -c Release \
  -o "$artifacts" \
  -p:Version="$version"

test -f "$package"
unzip -l "$package" | grep -q "lib/net8.0-windows7.0/FlaUI.Window.Extensions.dll"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/nuget.config" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="local" value="$artifacts" />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
EOF

cat > "$tmp/Smoke.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0-windows7.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="FlaUI.Window.Extensions" Version="$version" />
  </ItemGroup>
</Project>
EOF

cat > "$tmp/Program.cs" <<'EOF'
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Window.Extensions;

AutomationElement? root = null;
if (root is not null)
{
    Locator.DefaultTimeout = TimeSpan.FromSeconds(1);
    root.GetByTestId("Count").WaitFor();
    _ = root.GetByTestId("Count").Text();
    root.GetByRole(ControlType.Button, "Increment").Click();
    _ = root.GetByText("Increment").IsVisible();
    _ = root.FindElement("Increment").IsEnabled();
}
EOF

dotnet build "$tmp/Smoke.csproj" -c Release -p:EnableWindowsTargeting=true

echo "Package verified: $package"
