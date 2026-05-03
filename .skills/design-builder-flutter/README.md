# Design Builder Flutter Skill

An [Agent Skills](https://agentskills.io) skill for working with the `design_builder_flutter` package - a Dart build_runner tool that generates type-safe Flutter ThemeExtension classes from W3C Design Tokens.

## What This Skill Provides

This skill helps AI agents (like Zed, Claude Code, Cursor, etc.) work effectively with the design_builder_flutter package by providing:

- **Setup guidance**: How to configure the package in your Flutter project
- **Token file creation**: Understanding the W3C Design Tokens format and variable injection
- **Schema guidance**: How to structure your JSON schema for validation
- **Code generation**: Running build_runner to generate theme classes
- **Usage patterns**: How to use the generated themes in Flutter widgets
- **Troubleshooting**: Common issues and their solutions

## Skill Structure

```
.skills/design-builder-flutter/
├── SKILL.md                           # Main skill instructions
├── README.md                          # This file
├── scripts/
│   ├── validate_tokens.dart          # Token file validation
│   └── generate_theme.dart           # Quick theme generation
└── references/
    ├── theme-spec.schema.json        # Full JSON schema example
    └── example.tokens.json           # Complete token file example
```

## Quick Start

### 1. Add to Your Project's Skills

If your project uses Agent Skills, simply ensure this skill is in your `.skills/` directory or add it to your skills configuration.

### 2. Reference the Skill

When working with design tokens in your Flutter project, mention the skill to get expert guidance:

```
"I'm setting up design_builder_flutter for my project. Can you help me create a token file?"
```

The agent will then:
- Guide you through the setup process
- Help create properly structured token files
- Show you how to configure build.yaml
- Explain how to use the generated themes

### 3. Use Helper Scripts

Validate your token files:

```bash
dart run .skills/design-builder-flutter/scripts/validate_tokens.dart \
  lib/theme/theme-spec.schema.json \
  "lib/theme/*.tokens.json"
```

Generate theme code:

```bash
dart run .skills/design-builder-flutter/scripts/generate_theme.dart
```

## What is design_builder_flutter?

The [design_builder_flutter](https://github.com/khode-io/design-builder) package is a code generation tool that:

- Converts W3C Design Tokens JSON files into type-safe Dart code
- Generates Flutter ThemeExtension classes
- Supports light/dark mode switching
- Enables server-side token overrides
- Provides O(1) token resolution via const lookup maps

### Key Features

- **W3C Standard**: Uses the standard W3C Design Tokens format
- **Variable Injection**: Define reusable values in `$variables` sections
- **Type Safety**: Generated code is fully typed with IDE autocomplete
- **Multi-Mode**: Built-in support for light/dark themes
- **Runtime Overrides**: Apply server-side token changes dynamically

## Token File Example

```json
{
  "$schemaVersion": "3.0",
  "$id": "my-theme",
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

See `references/example.tokens.json` for a complete, production-ready example.

## Generated Code Usage

```dart
// Wrap your app
void main() {
  runApp(
    AppThemeProvider(
      notifier: AppThemeNotifier(initialMode: AppThemeMode.light),
      child: MyApp(),
    ),
  );
}

// Use in widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      color: theme.colors.brand.primary,
      padding: EdgeInsets.all(theme.sizes.padding.md),
      child: Text('Hello', style: theme.typography.body.medium),
    );
  }
}
```

## Learn More

- [Agent Skills Specification](https://agentskills.io/specification)
- [design_builder_flutter Package](https://github.com/khode-io/design-builder)
- [W3C Design Tokens Format](https://design-tokens.github.io/community-group/format/)

## License

This skill follows the same license as the design_builder_flutter package (MIT).
