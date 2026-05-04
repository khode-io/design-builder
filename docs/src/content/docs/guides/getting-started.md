---
title: Getting Started
description: Learn how to install and set up Design Builder in your Flutter project.
---

Design Builder Flutter is a build runner that generates type-safe Flutter ThemeExtension code from W3C Design Tokens JSON files.

## Requirements

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

## Installation

### 1. Add Dependencies

Add `design_builder` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  design_builder: ^1.0.1
```

Then run:

```bash
dart pub get
```

### 2. Configure build.yaml

Create a `build.yaml` file in your project root:

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

Create a JSON token file (e.g., `lib/theme.tokens.json`):

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

Run the build runner:

```bash
dart run build_runner build
```

For continuous generation during development:

```bash
dart run build_runner watch
```

### 5. Use in Your App

Import the generated theme and wrap your app with the provider:

```dart
import 'package:your_app/design_tokens/app_theme.dart';

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

## Next Steps

- Learn about [Configuration Options](/design_builder/guides/configuration/)
- Understand the [Token Format](/design_builder/guides/token-format/)
- Explore the [AppTheme API](/design_builder/reference/app-theme/)
