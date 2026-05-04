# Design Builder

[![CI](https://github.com/khode-io/design-builder/actions/workflows/ci.yaml/badge.svg)](https://github.com/khode-io/design-builder/actions/workflows/ci.yaml)
[![pub package](https://img.shields.io/pub/v/design_builder.svg)](https://pub.dev/packages/design_builder)

Transform your design tokens into production-ready Flutter themes. Generate type-safe ThemeExtension classes from W3C-standard JSON files with zero runtime overhead, adaptive theming, and live server-side updates.

It also works with [Google Labs Design Tokens](https://github.com/google-labs-code/design.md).

## Features

- **Design Tokens First** — Define your design system in JSON using the W3C standard. No more scattered hardcoded values across your codebase.
- **Adaptive by Default** — Built-in light/dark mode support with automatic theme switching. One source of truth, infinite variations.
- **Live Theme Updates** — Push design changes server-side and watch your app adapt in real-time. Perfect for A/B testing and seasonal campaigns.
- **Lightning fast lookups** — Theme values are stored in compile-time const maps for instant access with minimal overhead.
- **Type-Safe & Autocompleted** — Generated ThemeExtension classes give you full IDE support. Catch design errors before they reach production.
- **Smart Variable System** — Define reusable design primitives in `$variables` and reference them anywhere with `$variable.path` syntax. Change once, propagate everywhere.

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

Create token files (e.g., `lib/theme/app.tokens.json`) following the W3C Design Tokens format. Token files define:

- **Metadata** — `$schemaVersion`, `$id`, `$version`, `$name`
- **Variables** — Reusable primitives in `$variables` section
- **Themes** — `light` (required) and `dark` (optional) appearances

See the [example token file](example/lib/theme/app.tokens.json) for a complete reference.

### Token Group Types

The schema defines the following token group hierarchy:

| Group | Subgroups | Token Types |
|-------|-----------|-------------|
| `color` | brand, foreground, icon, input, action, canvas, surface, stroke, feedback, indicator | color |
| `sizes` | padding, spacing, radius, icon, font, motion, blur | number |
| `typography` | display, headline, title, body, label, caption | typography |

Each color group contains specific semantic tokens (e.g., `color.brand.primary`, `color.foreground.subtle`).

> **Note:** Token groups are defined by the schema and cannot be changed, but you have full flexibility to modify, add, or remove individual tokens within each group based on your design system needs.

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
