# Design Builder

A multi-platform build tool that generates platform-specific theme code from W3C Design Tokens. Transform JSON token files into type-safe code for Flutter, iOS, and Android with support for light/dark modes, server-side overrides, and lightning fast const lookup maps.

## Overview

This monorepo contains platform-specific **design_builder** packages - code generation tools for theming that:

- Parses W3C Design Tokens JSON format
- Generates type-safe theme code for each platform
- Supports multiple theme modes (light/dark)
- Enables runtime token overrides
- Provides lightning fast lookups via compile-time const maps

## Packages

| Package | Description | Version | Status |
|---------|-------------|---------|--------|
| [design_builder_flutter](packages/design_builder_flutter) | Build runner for generating Flutter ThemeExtension | 1.0.1 | ✅ Available |
| design_builder_ios | Swift code generation for iOS | - | 🚧 Planned |
| design_builder_android | Kotlin code generation for Android | - | 🚧 Planned |

## Features

- **W3C Design Tokens Format** - Uses standard W3C Design Tokens JSON format
- **Light/Dark Mode Support** - Built-in support for multiple theme modes
- **Variable Injection** - Define reusable variables in `$variables` section and reference them with `$variable.path` syntax
- **Typography Support** - Full text style tokens with fontSize, fontWeight, height, letterSpacing, fontFamily, and color
- **Dimension Tokens** - Support for padding, spacing, radius, and custom sizes
- **Server-Side Overrides** - Apply runtime token overrides for dynamic theming
- **Lightning fast lookups** - Instant theme access via compile-time const maps
- **Type-Safe API** - Generated ThemeExtension classes with full IDE autocomplete
- **Build Runner Integration** - Automatic regeneration on token file changes

## Quick Start (Flutter)

### 1. Add Dependency

Add `design_builder` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  design_builder: ^1.0.1
```

*Note: iOS and Android native packages coming soon.*

### 2. Configure build.yaml

```yaml
targets:
  $default:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          spec_path: "lib/schema/theme-spec.schema.json"
          input_glob: "lib/**.tokens.json"
          output_path: "design_tokens"
          output_file_name: "app_theme"
          class_name: "AppTheme"
```

### 3. Create Token Files

Create JSON token files following the W3C Design Tokens format:

```json
{
  "$schemaVersion": "3.0",
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E"
        }
      }
    },
    "color": {
      "brand": {
        "primary": {
          "$type": "color",
          "$value": "$color.brand.primary"
        }
      }
    }
  },
  "dark": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#2D3A8C"
        }
      }
    }
  }
}
```

### 4. Generate Code

```bash
dart run build_runner build
```

### 5. Use in Your App

```dart
void main() {
  runApp(
    AppThemeProvider(
      notifier: AppThemeNotifier(initialMode: AppThemeMode.light),
      child: MyApp(),
    ),
  );
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      color: theme.colors.brand.primary,
      child: Text('Hello', style: theme.typography.body.large),
    );
  }
}
```

## Documentation

- [Package README](packages/design_builder_flutter/README.md) - Detailed usage guide
- [Contributing](CONTRIBUTING.md) - Contribution guidelines
- [Changelog](packages/design_builder_flutter/CHANGELOG.md) - Version history
- [Example](packages/design_builder_flutter/example) - Example usage

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) for details.

Copyright (c) khode-io 2026
