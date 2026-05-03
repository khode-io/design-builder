# Design Builder - Setup Guide

## Overview

Design Builder is a Dart build_runner package that generates Flutter `ThemeExtension` classes from W3C Design Tokens. It converts JSON token files into type-safe Dart code with support for light/dark modes, server-side overrides, and const lookup maps for O(1) token resolution.

## Installation

### 1. Add Dependency

Add `design_builder` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  design_builder:
    path: ../packages/design_builder_flutter # or use git/pub.dev when published
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

Create a JSON schema file (e.g., `lib/schema/theme-spec.schema.json`) that defines your token structure:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "theme-spec",
  "definitions": {
    "colors": {
      "type": "object",
      "properties": {
        "brand": { "$ref": "#/definitions/colorGroup" },
        "background": { "$ref": "#/definitions/colorGroup" },
        "text": { "$ref": "#/definitions/colorGroup" }
      }
    },
    "colorGroup": {
      "type": "object",
      "additionalProperties": { "$ref": "#/definitions/colorToken" }
    },
    "colorToken": {
      "type": "object",
      "properties": {
        "$type": { "const": "color" },
        "$value": { "type": "string" },
        "$description": { "type": "string" }
      },
      "required": ["$type", "$value"]
    },
    "appearance": {
      "type": "object",
      "properties": {
        "sizes": {
          "type": "object",
          "properties": {
            "padding": { "$ref": "#/definitions/sizeScale" },
            "spacing": { "$ref": "#/definitions/sizeScale" },
            "radius": { "$ref": "#/definitions/sizeScale" }
          }
        }
      }
    },
    "sizeScale": {
      "type": "object",
      "additionalProperties": { "$ref": "#/definitions/numberToken" }
    },
    "numberToken": {
      "type": "object",
      "properties": {
        "$type": { "const": "number" },
        "$value": { "type": "number" }
      },
      "required": ["$type", "$value"]
    },
    "typography": {
      "type": "object",
      "properties": {
        "display": { "$ref": "#/definitions/typographyStyle" },
        "headline": { "$ref": "#/definitions/typographyStyle" },
        "body": { "$ref": "#/definitions/typographyStyle" }
      }
    },
    "typographyStyle": {
      "type": "object",
      "additionalProperties": { "$ref": "#/definitions/textStyleToken" }
    },
    "textStyleToken": {
      "type": "object",
      "properties": {
        "$type": { "const": "typography" },
        "$value": {
          "type": "object",
          "properties": {
            "fontSize": { "type": "number" },
            "fontWeight": { "type": "integer" },
            "height": { "type": "number" },
            "letterSpacing": { "type": "number" },
            "fontFamily": { "type": "string" },
            "color": { "type": "string" }
          }
        }
      },
      "required": ["$type", "$value"]
    },
    "typographyWeight": {
      "type": "object",
      "properties": {
        "black": { "type": "object" },
        "extraBold": { "type": "object" },
        "bold": { "type": "object" },
        "semiBold": { "type": "object" },
        "medium": { "type": "object" },
        "regular": { "type": "object" },
        "light": { "type": "object" },
        "extraLight": { "type": "object" },
        "thin": { "type": "object" }
      }
    }
  }
}
```

### 4. Create Token Files

Create token files (e.g., `lib/theme.tokens.json`) following the W3C Design Tokens format with support for the `$variables` section:

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
          "secondary": "#E94560",
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
          "$description": "Primary brand color - deep navy"
        },
        "secondary": {
          "$type": "color",
          "$value": "$color.brand.secondary",
          "$description": "Secondary brand color - coral"
        },
        "container": {
          "$type": "color",
          "$value": "$color.brand.container",
          "$description": "Surface color for primary tinted backgrounds"
        }
      },
      "background": {
        "surface": {
          "$type": "color",
          "$value": "#FFFFFF"
        },
        "canvas": {
          "$type": "color",
          "$value": "#F5F5F5"
        }
      }
    },
    "sizes": {
      "padding": {
        "xs": { "$type": "number", "$value": 4 },
        "sm": { "$type": "number", "$value": 8 },
        "md": { "$type": "number", "$value": 16 },
        "lg": { "$type": "number", "$value": 24 },
        "xl": { "$type": "number", "$value": 32 }
      },
      "spacing": {
        "xs": { "$type": "number", "$value": 4 },
        "sm": { "$type": "number", "$value": 8 },
        "md": { "$type": "number", "$value": 16 }
      },
      "radius": {
        "sm": { "$type": "number", "$value": 4 },
        "md": { "$type": "number", "$value": 8 },
        "lg": { "$type": "number", "$value": 16 }
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
            "letterSpacing": -0.5,
            "fontFamily": "$font.family.primary"
          }
        },
        "regular": {
          "$type": "typography",
          "$value": {
            "fontSize": 32,
            "fontWeight": 400,
            "height": 1.2,
            "fontFamily": "$font.family.primary"
          }
        }
      },
      "body": {
        "regular": {
          "$type": "typography",
          "$value": {
            "fontSize": 16,
            "fontWeight": 400,
            "height": 1.5,
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
          "secondary": "#FF6B6B",
          "container": "#1E1E2E"
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
          "$description": "Primary brand color - deep blue (dark mode)"
        },
        "secondary": {
          "$type": "color",
          "$value": "$color.brand.secondary",
          "$description": "Secondary brand color - coral (dark mode)"
        },
        "container": {
          "$type": "color",
          "$value": "$color.brand.container",
          "$description": "Surface color for primary tinted backgrounds (dark)"
        }
      },
      "background": {
        "surface": {
          "$type": "color",
          "$value": "#1A1A1A"
        },
        "canvas": {
          "$type": "color",
          "$value": "#0D0D0D"
        }
      }
    },
    "sizes": {
      "padding": {
        "xs": { "$type": "number", "$value": 4 },
        "sm": { "$type": "number", "$value": 8 },
        "md": { "$type": "number", "$value": 16 },
        "lg": { "$type": "number", "$value": 24 },
        "xl": { "$type": "number", "$value": 32 }
      },
      "spacing": {
        "xs": { "$type": "number", "$value": 4 },
        "sm": { "$type": "number", "$value": 8 },
        "md": { "$type": "number", "$value": 16 }
      },
      "radius": {
        "sm": { "$type": "number", "$value": 4 },
        "md": { "$type": "number", "$value": 8 },
        "lg": { "$type": "number", "$value": 16 }
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
            "letterSpacing": -0.5,
            "color": "#FFFFFF",
            "fontFamily": "$font.family.primary"
          }
        }
      },
      "body": {
        "regular": {
          "$type": "typography",
          "$value": {
            "fontSize": 16,
            "fontWeight": 400,
            "height": 1.5,
            "color": "#E0E0E0",
            "fontFamily": "$font.family.primary"
          }
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

1. **Import the generated file:**

```dart
import 'design_tokens/app_theme.g.dart';
```

2. **Wrap your app with AppThemeProvider:**

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

3. **Access theme in widgets:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access via extension
    final theme = context.theme;
    final notifier = context.themeNotifier;

    return Container(
      color: theme.colors.brand.primary,
      padding: EdgeInsets.all(theme.sizes.padding.md),
      child: Text(
        'Hello',
        style: theme.typography.display.h1.bold,
      ),
    );
  }
}
```

4. **Toggle modes:**

```dart
// Toggle between light and dark
context.themeNotifier.toggleMode();

// Set specific mode
context.themeNotifier.mode = AppThemeMode.dark;
```

5. **Apply server overrides:**

```dart
// Override specific tokens dynamically
context.themeNotifier.applyOverrides({
  'dark.colors.brand.primary': Color(0xFFFF0000),
  'dark.sizes.padding.md': 20.0,
});

// Clear all overrides
context.themeNotifier.clearOverrides();
```

## File Structure

```
lib/
├── schema/
│   └── theme-spec.schema.json      # JSON schema (required)
├── design_tokens/
│   └── app_theme.g.dart             # Generated file (auto-created)
├── theme.tokens.json                # Your token file(s)
└── main.dart                        # Your app entry

build.yaml                           # Builder configuration (required)
pubspec.yaml
```

## Configuration Options

| Option                  | Required | Default              | Description                          |
| ----------------------- | -------- | -------------------- | ------------------------------------ |
| `spec_path`             | Yes      | -                    | Path to JSON schema file             |
| `input_glob`            | Yes      | `lib/**.tokens.json` | Glob pattern for token files         |
| `output_path`           | No       | `design_tokens`      | Output directory (relative to lib/)  |
| `output_file_name`      | No       | `app_theme`          | Output file name (without extension) |
| `class_name`            | No       | `AppTheme`           | Generated class name                 |
| `const_constructors`    | No       | `true`               | Generate const constructors          |
| `generate_json_methods` | No       | `true`               | Generate fromJson/toJson methods     |

## Token Format

### Color Tokens

```json
{
  "$type": "color",
  "$value": "#FF5733",
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

Or with units (parsed automatically):

```json
{
  "$type": "number",
  "$value": "16px"
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

## Variable Injection

Design Builder supports variable injection from the `$variables` section. This allows you to define reusable values once and reference them throughout your token files.

### Defining Variables

Define variables in the `$variables` section of each mode:

```json
{
  "light": {
    "$variables": {
      "color": {
        "brand": {
          "primary": "#1A1A2E",
          "secondary": "#E94560",
          "container": "#F8F9FA"
        },
        "semantic": {
          "error": "#EF4444",
          "success": "#10B981",
          "warning": "#F59E0B"
        }
      },
      "font": {
        "family": {
          "primary": "Inter",
          "secondary": "Roboto"
        }
      }
    }
  }
}
```

### Referencing Variables

Use the `$variable.path` syntax to reference variables:

```json
{
  "$type": "color",
  "$value": "$color.brand.primary"
}
```

Variables can also be referenced within typography values:

```json
{
  "$type": "typography",
  "$value": {
    "fontSize": 16,
    "fontWeight": 400,
    "height": 1.5,
    "fontFamily": "$font.family.primary",
    "color": "$color.semantic.error"
  }
}
```

### How It Works

1. Variables are defined in the `$variables` section as nested objects
2. The path to a variable uses dot notation (e.g., `color.brand.primary`)
3. Reference variables using `$` prefix followed by the path
4. Variables are resolved at build time and injected as literal values into the generated Dart code
5. Each mode (light/dark) can have its own `$variables` section with different values

### Benefits

- **Consistency**: Define values once, use everywhere
- **Maintainability**: Update a value in one place
- **Mode-specific values**: Different values for light/dark modes while maintaining the same references
- **Type safety**: Variables are resolved to their actual values at build time

## Troubleshooting

### Schema Not Found

Verify `spec_path` in `build.yaml` points to a valid JSON schema file.

### No Token Files Found

Check that your `input_glob` pattern matches your token file locations.

### Generated File Not Updating

Run with `--delete-conflicting-outputs` flag:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## API Reference

### AppTheme

The main theme extension class with factory constructors:

- `AppTheme.dark()` - Creates dark mode theme
- `AppTheme.light()` - Creates light mode theme
- `AppTheme.of(context)` - Retrieves from BuildContext

Properties:

- `colors` - Access color tokens
- `sizes` - Access dimension tokens
- `typography` - Access text style tokens

### AppThemeNotifier

ChangeNotifier for theme state management:

- `theme` - Current AppTheme instance
- `themeData` - Material ThemeData
- `mode` - Current theme mode (getter/setter)
- `toggleMode()` - Toggle between light/dark
- `applyOverrides(map)` - Apply server-side overrides
- `clearOverrides()` - Remove all overrides

### BuildContext Extensions

- `context.theme` - Get AppTheme
- `context.themeNotifier` - Get AppThemeNotifier
- `context.themeNotifierMaybe` - Get AppThemeNotifier (nullable)

## License

See [LICENSE](LICENSE) for details.
