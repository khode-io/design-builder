---
title: Configuration
description: Learn how to configure Design Builder options for your project.
---

Design Builder can be customized through the `build.yaml` configuration file. This guide covers all available configuration options.

## Configuration File

Create a `build.yaml` file in your project root with the following structure:

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

## Build Options

### spec_path

**Type:** `string`  
**Default:** `lib/schema/theme-spec.schema.json`

Path to the JSON schema file that validates your token files. This ensures your tokens follow the correct structure.

```yaml
options:
  spec_path: "assets/schema.json"
```

### input_glob

**Type:** `string`  
**Default:** `lib/**.tokens.json`

Glob pattern to locate your token JSON files. Supports multiple files and nested directories.

```yaml
options:
  input_glob: "lib/**/*.tokens.json"
```

### output_path

**Type:** `string`  
**Default:** `design_tokens`

Directory where generated files will be placed, relative to the `lib` folder.

```yaml
options:
  output_path: "generated/themes"
```

### output_file_name

**Type:** `string`  
**Default:** `app_theme`

Name of the generated Dart file (without the `.dart` extension).

```yaml
options:
  output_file_name: "my_app_theme"
```

### class_name

**Type:** `string`  
**Default:** `AppTheme`

Name of the main generated class.

```yaml
options:
  class_name: "MyAppTheme"
```

## Complete Example

Here's a complete configuration for a production Flutter app:

```yaml
targets:
  $default:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          spec_path: "assets/schemas/theme-spec.json"
          input_glob: "lib/tokens/**/*.json"
          output_path: "theme"
          output_file_name: "theme_data"
          class_name: "ThemeData"
```

With this configuration:
- Token files are located in `lib/tokens/**/*.json`
- Schema is validated against `assets/schemas/theme-spec.json`
- Generated files go to `lib/theme/theme_data.dart`
- The main class is named `ThemeData`

## Environment-Specific Configurations

You can create different configurations for different environments:

```yaml
targets:
  development:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          input_glob: "lib/tokens/dev/*.json"
  production:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          input_glob: "lib/tokens/prod/*.json"
```

Run with a specific target:

```bash
dart run build_runner build --config=build.yaml -t production
```
