# Design Builder

A Dart build_runner package that generates Flutter `ThemeExtension` classes from W3C Design Tokens. It converts JSON token files into type-safe Dart code with support for light/dark modes, server-side overrides, and const lookup maps for O(1) token resolution.

## Features

- **W3C Design Tokens Format** - Uses standard W3C Design Tokens JSON format
- **Light/Dark Mode Support** - Built-in support for multiple theme modes
- **Variable Injection** - Define reusable variables in `$variables` section and reference them with `$variable.path` syntax
- **Typography Support** - Full text style tokens with fontSize, fontWeight, height, letterSpacing, fontFamily, and color
- **Dimension Tokens** - Support for padding, spacing, radius, and custom sizes
- **Server-Side Overrides** - Apply runtime token overrides for dynamic theming
- **Const Lookup Maps** - O(1) token resolution via generated const maps
- **Type-Safe API** - Generated ThemeExtension classes with full IDE autocomplete
- **Build Runner Integration** - Automatic regeneration on token file changes

## Getting Started

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

### 2. Configure build.yaml

Add the design_builder configuration to your `build.yaml` file:

```yaml
targets:
  $default:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          # Required: Path to your JSON schema file
          spec_path: "lib/schema/theme-spec.schema.json"
          # Required: Glob pattern for token files
          input_glob: "lib/**.tokens.json"
          # Optional: Output directory (relative to lib/)
          output_path: "design_tokens"
          # Optional: Output file name (without extension)
          output_file_name: "app_theme"
          # Optional: Class name for the generated theme
          class_name: "AppTheme"
          # Optional: Generate const constructors
          const_constructors: true
          # Optional: Generate fromJson/toJson methods
          generate_json_methods: true
```

**Note:** The `spec_path` option is **required** in build.yaml.

### 3. Create JSON Schema

Create a JSON schema file (e.g., `lib/schema/theme-spec.schema.json`) that defines your token structure. See the `schema/theme-spec.schema.json` file in this package for a complete schema example.

### 4. Create Token Files

Create token files following the W3C Design Tokens format with support for `$variables`:

```json
{
  "$schemaVersion": "3.0",
  "$id": "theme-tokens",
  "$version": "1.0.0",
  "$name": "App Theme Tokens",
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E",
          "container": "#F8F9FA"
        }
      },
      "font": {
        "family": {
          "primary": "Inter"
        }
      }
    },
    "color": {
      "brand": {
        "primary": {
          "$type": "color",
          "$value": "$color.brand.primary",
          "$description": "Primary brand color"
        },
        "container": {
          "$type": "color",
          "$value": "$color.brand.container"
        }
      }
    },
    "typography": {
      "display": {
        "bold": {
          "$type": "typography",
          "$value": {
            "fontSize": 32,
            "fontWeight": 700,
            "height": 1.2,
            "fontFamily": "$font.family.primary"
          }
        }
      }
    }
  },
  "dark": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#2D3A8C",
          "container": "#1E1E2E"
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
  }
}
```

## Usage

### Generate Code

Run the build_runner to generate the theme file:

```bash
dart run build_runner build
```

For continuous rebuilding during development:

```bash
dart run build_runner watch
```

### Use in Your App

1. **Wrap your app with AppThemeProvider:**

```dart
void main() {
  runApp(
    AppThemeProvider(
      notifier: AppThemeNotifier(initialMode: AppThemeMode.light),
      child: MyApp(),
    ),
  );
}
```

2. **Access theme in widgets:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      color: theme.colors.brand.primary,
      padding: EdgeInsets.all(theme.sizes.padding.md),
      child: Text(
        'Hello',
        style: theme.typography.display.bold,
      ),
    );
  }
}
```

3. **Toggle modes:**

```dart
// Toggle between light and dark
context.themeNotifier.toggleMode();

// Set specific mode
context.themeNotifier.mode = AppThemeMode.dark;
```

4. **Apply server overrides:**

```dart
// Override specific tokens dynamically
context.themeNotifier.applyOverrides({
  'dark.color.brand.primary': Color(0xFFFF0000),
  'dark.sizes.padding.md': 20.0,
});

// Clear all overrides
context.themeNotifier.clearOverrides();
```

## Variable Injection

Design Builder supports variable injection from the `$variables` section:

### Define Variables

```json
{
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E",
          "container": "#F8F9FA"
        }
      },
      "font": {
        "family": {
          "primary": "Inter"
        }
      }
    }
  }
}
```

### Reference Variables

Use `$variable.path` syntax to reference variables:

```json
{
  "$type": "color",
  "$value": "$color.brand.primary"
}
```

```json
{
  "$type": "typography",
  "$value": {
    "fontSize": 16,
    "fontWeight": 400,
    "fontFamily": "$font.family.primary"
  }
}
```

Variables are resolved at build time and injected into the generated Dart code as literal values.

## Configuration Options

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `spec_path` | Yes | - | Path to JSON schema file |
| `input_glob` | Yes | `lib/**.tokens.json` | Glob pattern for token files |
| `output_path` | No | `design_tokens` | Output directory (relative to lib/) |
| `output_file_name` | No | `app_theme` | Output file name (without extension) |
| `class_name` | No | `AppTheme` | Generated class name |
| `const_constructors` | No | `true` | Generate const constructors |
| `generate_json_methods` | No | `true` | Generate fromJson/toJson methods |

## Token Format

### Color Tokens

```json
{
  "$type": "color",
  "$value": "$color.brand.primary",
  "$description": "Optional description"
}
```

### Dimension Tokens

```json
{
  "$type": "number",
  "$value": 16
}
```

### Typography Tokens

```json
{
  "$type": "typography",
  "$value": {
    "fontSize": 16,
    "fontWeight": 400,
    "height": 1.5,
    "letterSpacing": 0.5,
    "fontFamily": "$font.family.primary",
    "color": "$color.brand.primary"
  }
}
```

## Additional Information

For more detailed information, see:
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [example/](example/) - Example usage

## License

See [LICENSE](LICENSE) for details.
