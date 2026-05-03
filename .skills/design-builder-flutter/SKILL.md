# SKILL.md for design-builder-flutter

## Metadata

name: design-builder-flutter  
description: Work with design_builder_flutter to generate Flutter ThemeExtension classes from W3C Design Tokens. Helps with setup, token file creation, code generation, and theme usage in Flutter apps.  
version: 1.0.0  

---

## Instructions

You are an expert in using the design_builder_flutter package - a Dart build_runner tool that generates type-safe Flutter ThemeExtension classes from W3C Design Tokens JSON files.

### Overview

design_builder_flutter converts JSON token files into:
- Type-safe ThemeExtension classes
- Light/dark mode support with runtime switching
- Const lookup maps for O(1) token resolution
- Server-side override capabilities for dynamic theming

### Token Types Supported

1. **Color tokens**: `{ "$type": "color", "$value": "$color.brand.primary" }`
2. **Number/Dimension tokens**: `{ "$type": "number", "$value": 16 }`
3. **Typography tokens**: `{ "$type": "typography", "$value": { "fontSize": 16, "fontWeight": 400, ... } }`
4. **String tokens**: `{ "$type": "string", "$value": "Inter" }`

### Setup Workflow

#### 1. Add Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  design_builder:
    git:
      url: https://github.com/khode-io/design-builder.git
      path: packages/design_builder_flutter
```

#### 2. Create JSON Schema

Create a schema file (e.g., `lib/theme/theme-spec.schema.json`) that defines your token structure. The schema must define:
- Token types (color, number, typography, string)
- Theme modes (light, dark)
- Variable injection patterns
- Token hierarchy

Key schema sections:
- `definitions.colorToken`: Color token format
- `definitions.numberToken`: Number/dimension token format
- `definitions.textStyleToken`: Typography token format with fontSize, fontWeight, height, letterSpacing, color, fontFamily
- `definitions.scaleSpacing`/`scaleRadius`: Standard spacing/radius scales (xs, sm, md, lg, xl, x2l-x7l, pill)
- `definitions.typographyWeight`: Font weight variants (thin to black)

#### 3. Configure build.yaml

```yaml
targets:
  $default:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          spec_path: "lib/theme/theme-spec.schema.json"  # Required: schema path
          input_glob: "lib/theme/*.tokens.json"          # Required: token files pattern
          output_path: "theme"                           # Optional: output directory
          output_file_name: "app_theme"                  # Optional: output file name
          class_name: "AppTheme"                        # Optional: generated class name
```

#### 4. Create Token Files

Create JSON token files (e.g., `app.tokens.json`) following W3C Design Tokens format:

```json
{
  "$schemaVersion": "3.0",
  "$id": "app-theme",
  "$version": "1.0.0",
  "$name": "App Theme",
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
    "sizes": {
      "padding": {
        "sm": { "$type": "number", "$value": 8 },
        "md": { "$type": "number", "$value": 16 },
        "lg": { "$type": "number", "$value": 24 }
      }
    },
    "typography": {
      "body": {
        "medium": {
          "$type": "typography",
          "$value": {
            "fontSize": 16,
            "fontWeight": 400,
            "height": 1.5,
            "fontFamily": "$font.family.primary",
            "color": "$color.brand.primary"
          }
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

Key patterns:
- Use `$variables` section to define reusable values
- Reference variables with `$variable.path` syntax (e.g., `$color.brand.primary`)
- Variables in `dark` mode only need to override changed values
- The `$type` field determines token type: "color", "number", "typography", "string"

#### 5. Generate Code

Run build_runner:

```bash
# One-time generation
dart run build_runner build

# Continuous rebuild during development
dart run build_runner watch

# Delete conflicting outputs and rebuild
dart run build_runner build --delete-conflicting-outputs
```

### Using Generated Themes

#### 1. Wrap App with AppThemeProvider

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

#### 2. Access Theme in Widgets

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
        style: theme.typography.body.medium,
      ),
    );
  }
}
```

#### 3. Access Theme Notifier

```dart
// Toggle between light and dark
context.themeNotifier.toggleMode();

// Set specific mode
context.themeNotifier.mode = AppThemeMode.dark;

// Check current mode
final isDark = context.themeNotifier.mode == AppThemeMode.dark;
```

#### 4. Apply Server Overrides

```dart
// Override specific tokens dynamically
context.themeNotifier.applyOverrides({
  'dark.color.brand.primary': Color(0xFFFF0000),
  'dark.sizes.padding.md': 20.0,
});

// Clear all overrides
context.themeNotifier.clearOverrides();
```

### Typography Token Structure

Typography tokens support these properties:

```json
{
  "$type": "typography",
  "$value": {
    "fontSize": 16,        // Required: number
    "fontWeight": 400,     // Required: 100-900
    "height": 1.5,         // Optional: line height multiplier
    "letterSpacing": 0.5,  // Optional: letter spacing
    "fontFamily": "Inter", // Optional: font family name
    "color": "$color.brand.primary" // Optional: color reference
  }
}
```

Common fontWeight values:
- 100: thin
- 200: extraLight
- 300: light
- 400: regular
- 500: medium
- 600: semiBold
- 700: bold
- 800: extraBold
- 900: black

### Standard Token Categories

Based on the schema, standard token categories include:

**Colors:**
- `brand`: primary, container
- `foreground`: primary, subtle, title, body, disabled, placeholder, inverse, success, info, warning, error
- `icon`: primary, subtle, title, body, disabled, inverse, success, info, warning, error
- `input`: primary, label, value, placeholder, disabled, fill, outline, focus, error
- `action`: filledPrimary, filledHover, ghostPrimary, ghostHover, outline, disabled, filledDanger
- `canvas`: primary, secondary, tertiary, error, info, warning, success, neutral, brand
- `surface`: card
- `stroke`: emphasis, primary, divider, inverse, error
- `feedback`: warning, danger, success, info
- `indicator`: urgent, pending, inReview, interview, offer, hired, rejected

**Sizes:**
- `padding`: xs, sm, md, lg, xl, x2l-x7l
- `spacing`: xs, sm, md, lg, xl, x2l-x7l
- `radius`: xs, sm, md, lg, xl, x2l-x7l, pill
- `icon`: xs, sm, md, lg, xl, x2l
- `font`: xs, sm, md, lg, xl, x2l, x3l
- `motion`: duration values
- `blur`: blur values

**Typography:**
- `display`: bold, semiBold, medium, regular
- `headline`: bold, semiBold, medium, regular
- `title`: bold, semiBold, medium, regular
- `body`: bold, medium, regular
- `label`: bold, medium, regular
- `caption`: bold, medium, regular

### Troubleshooting

**Build fails with "spec_path is required"**
- Ensure `spec_path` is set in `build.yaml` options
- Verify the schema file exists at the specified path

**Token files not found**
- Check that `input_glob` pattern matches your token file locations
- Ensure token files have `.tokens.json` extension

**Variables not resolving**
- Verify variable paths use `$` prefix (e.g., `$color.brand.primary`)
- Check that variables are defined in the `$variables` section
- Variable references must match the structure: `$category.subcategory.name`

**Generated code has errors**
- Validate your JSON token files against the schema
- Ensure all required fields (`$type`, `$value`) are present
- Check that color values are valid hex codes

**Theme not updating**
- Run `dart run build_runner build` after token file changes
- Check that the generated file is being imported correctly
- Verify `AppThemeProvider` is wrapping your app

### Best Practices

1. **Organize tokens by feature**: Group related tokens (colors, typography, sizes) in the same file or logical sections
2. **Use variables for consistency**: Define colors/fonts once in `$variables` and reference throughout
3. **Document with $description**: Add descriptions to tokens for team context
4. **Version your tokens**: Use `$version` field to track token file iterations
5. **Generate during CI**: Add build_runner to your CI pipeline to catch token errors early
6. **Use semantic names**: Name tokens by purpose (e.g., `primary`, `error`) not value (e.g., `red`)

### Reference Files

- `references/theme-spec.schema.json` - Full JSON schema for token validation
- `references/example.tokens.json` - Complete example token file

---

## Scripts

### validate-tokens

Validate token files against the schema:

```bash
# Usage: dart run .skills/design-builder-flutter/scripts/validate_tokens.dart <schema_path> <token_glob>
dart run .skills/design-builder-flutter/scripts/validate_tokens.dart lib/theme/theme-spec.schema.json "lib/theme/*.tokens.json"
```

This script checks:
- JSON syntax validity
- Schema compliance
- Variable reference resolution
- Required field presence

### generate-theme

Quick command to generate theme with common options:

```bash
# Usage: dart run .skills/design-builder-flutter/scripts/generate_theme.dart
dart run .skills/design-builder-flutter/scripts/generate_theme.dart
```

Runs `dart run build_runner build --delete-conflicting-outputs` with proper error handling.
