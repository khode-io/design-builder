---
title: Build Options
description: Configuration options for Design Builder build.yaml.
---

Reference for all available configuration options in the `build.yaml` file.

## Configuration Structure

```yaml
targets:
  $default:
    builders:
      design_builder|design_builder:
        enabled: true
        options:
          # Options go here
```

## Options Reference

### spec_path

**Type:** `string`  
**Default:** `lib/schema/theme-spec.schema.json`

Path to the JSON schema file that validates your token files.

```yaml
options:
  spec_path: "assets/schema.json"
```

### input_glob

**Type:** `string`  
**Default:** `lib/**.tokens.json`

Glob pattern to locate your token JSON files.

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

## Environment-Specific Configurations

Create different configurations for different environments:

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
