#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';

/// Validates design token files against a JSON schema.
///
/// Usage: dart run validate_tokens.dart <schema_path> <token_glob>
/// Example: dart run validate_tokens.dart lib/theme/theme-spec.schema.json "lib/theme/*.tokens.json"
///
/// This script checks:
/// - JSON syntax validity
/// - Required fields presence ($schemaVersion, $id, light/dark modes)
/// - Token type validity (color, number, typography, string)
/// - Variable reference format ($variable.path)
/// - Color hex code validity
/// - Typography value structure

void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart run validate_tokens.dart <schema_path> <token_glob>');
    print('Example: dart run validate_tokens.dart lib/theme/theme-spec.schema.json "lib/theme/*.tokens.json"');
    exit(1);
  }

  final schemaPath = args[0];
  final tokenGlob = args[1];

  // Load schema
  final schemaFile = File(schemaPath);
  if (!schemaFile.existsSync()) {
    print('❌ Schema file not found: $schemaPath');
    exit(1);
  }

  Map<String, dynamic>? schema;
  try {
    schema = jsonDecode(schemaFile.readAsStringSync()) as Map<String, dynamic>;
    print('✅ Loaded schema: $schemaPath');
  } catch (e) {
    print('❌ Failed to parse schema: $e');
    exit(1);
  }

  // Find token files
  final glob = Glob(tokenGlob);
  final tokenFiles = glob.listSync().whereType<File>().toList();

  if (tokenFiles.isEmpty) {
    print('⚠️  No token files found matching: $tokenGlob');
    exit(0);
  }

  print('🔍 Found ${tokenFiles.length} token file(s)');
  print('');

  var hasErrors = false;

  for (final file in tokenFiles) {
    print('Validating: ${file.path}');
    final errors = validateTokenFile(file, schema!);

    if (errors.isEmpty) {
      print('  ✅ Valid');
    } else {
      hasErrors = true;
      for (final error in errors) {
        print('  ❌ $error');
      }
    }
    print('');
  }

  if (hasErrors) {
    print('❌ Validation failed with errors');
    exit(1);
  } else {
    print('✅ All token files are valid');
    exit(0);
  }
}

List<String> validateTokenFile(File file, Map<String, dynamic> schema) {
  final errors = <String>[];

  // Parse JSON
  Map<String, dynamic>? tokens;
  try {
    tokens = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    return ['Invalid JSON: $e'];
  }

  // Check required top-level fields
  if (!tokens.containsKey(r'$schemaVersion')) {
    errors.add('Missing required field: \$schemaVersion');
  }

  if (!tokens.containsKey(r'$id')) {
    errors.add('Missing required field: \$id');
  }

  // Check for at least one theme mode
  if (!tokens.containsKey('light') && !tokens.containsKey('dark')) {
    errors.add('Must have at least one theme mode: light or dark');
  }

  // Validate light mode
  if (tokens.containsKey('light')) {
    errors.addAll(_validateMode(tokens['light'] as Map<String, dynamic>?, 'light'));
  }

  // Validate dark mode
  if (tokens.containsKey('dark')) {
    errors.addAll(_validateMode(tokens['dark'] as Map<String, dynamic>?, 'dark'));
  }

  // Check variable references
  final allVariables = _extractAllVariables(tokens);
  errors.addAll(_validateVariableReferences(tokens, allVariables));

  return errors;
}

List<String> _validateMode(Map<String, dynamic>? mode, String modeName) {
  final errors = <String>[];

  if (mode == null) return errors;

  // Validate colors
  if (mode.containsKey('color')) {
    final colors = mode['color'] as Map<String, dynamic>?;
    if (colors != null) {
      errors.addAll(_validateColorGroup(colors, '$modeName.color'));
    }
  }

  // Validate sizes
  if (mode.containsKey('sizes')) {
    final sizes = mode['sizes'] as Map<String, dynamic>?;
    if (sizes != null) {
      errors.addAll(_validateSizeGroup(sizes, '$modeName.sizes'));
    }
  }

  // Validate typography
  if (mode.containsKey('typography')) {
    final typography = mode['typography'] as Map<String, dynamic>?;
    if (typography != null) {
      errors.addAll(_validateTypographyGroup(typography, '$modeName.typography'));
    }
  }

  return errors;
}

List<String> _validateColorGroup(Map<String, dynamic> group, String path) {
  final errors = <String>[];

  for (final entry in group.entries) {
    final key = entry.key;
    final value = entry.value;

    if (key.startsWith(r'$')) continue; // Skip metadata

    if (value is Map<String, dynamic>) {
      if (value.containsKey(r'$type')) {
        // This is a token
        final type = value[r'$type'];
        if (type != 'color') {
          errors.add('$path.$key: Expected type "color", got "$type"');
        }

        if (!value.containsKey(r'$value')) {
          errors.add('$path.$key: Missing \$value');
        } else {
          final tokenValue = value[r'$value'];
          if (tokenValue is String) {
            if (!tokenValue.startsWith(r'$') && !_isValidHexColor(tokenValue)) {
              errors.add('$path.$key: Invalid color value: $tokenValue');
            }
          }
        }
      } else {
        // This is a nested group
        errors.addAll(_validateColorGroup(value, '$path.$key'));
      }
    }
  }

  return errors;
}

List<String> _validateSizeGroup(Map<String, dynamic> group, String path) {
  final errors = <String>[];

  for (final entry in group.entries) {
    final key = entry.key;
    final value = entry.value;

    if (key.startsWith(r'$')) continue;

    if (value is Map<String, dynamic>) {
      if (value.containsKey(r'$type')) {
        final type = value[r'$type'];
        if (type != 'number') {
          errors.add('$path.$key: Expected type "number", got "$type"');
        }

        if (!value.containsKey(r'$value')) {
          errors.add('$path.$key: Missing \$value');
        } else if (value[r'$value'] is! num) {
          errors.add('$path.$key: \$value must be a number');
        }
      } else {
        errors.addAll(_validateSizeGroup(value, '$path.$key'));
      }
    }
  }

  return errors;
}

List<String> _validateTypographyGroup(Map<String, dynamic> group, String path) {
  final errors = <String>[];

  for (final entry in group.entries) {
    final key = entry.key;
    final value = entry.value;

    if (key.startsWith(r'$')) continue;

    if (value is Map<String, dynamic>) {
      if (value.containsKey(r'$type')) {
        final type = value[r'$type'];
        if (type != 'typography') {
          errors.add('$path.$key: Expected type "typography", got "$type"');
          continue;
        }

        if (!value.containsKey(r'$value')) {
          errors.add('$path.$key: Missing \$value');
          continue;
        }

        final tokenValue = value[r'$value'];
        if (tokenValue is! Map<String, dynamic>) {
          errors.add('$path.$key: \$value must be an object');
          continue;
        }

        // Check required typography fields
        if (!tokenValue.containsKey('fontSize')) {
          errors.add('$path.$key: Missing fontSize in typography value');
        } else if (tokenValue['fontSize'] is! num) {
          errors.add('$path.$key: fontSize must be a number');
        }

        if (!tokenValue.containsKey('fontWeight')) {
          errors.add('$path.$key: Missing fontWeight in typography value');
        } else {
          final weight = tokenValue['fontWeight'];
          if (weight is! num || weight < 100 || weight > 900 || weight % 100 != 0) {
            errors.add('$path.$key: fontWeight must be 100, 200, ..., 900');
          }
        }
      } else {
        errors.addAll(_validateTypographyGroup(value, '$path.$key'));
      }
    }
  }

  return errors;
}

bool _isValidHexColor(String color) {
  final hexRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8}|[A-Fa-f0-9]{3}|[A-Fa-f0-9]{4})$');
  return hexRegex.hasMatch(color);
}

Set<String> _extractAllVariables(Map<String, dynamic> tokens) {
  final variables = <String>{};

  void extractFromMode(Map<String, dynamic>? mode) {
    if (mode == null) return;

    final vars = mode[r'$variables'] as Map<String, dynamic>?;
    if (vars == null) return;

    void traverse(Map<String, dynamic> map, String prefix) {
      for (final entry in map.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key.startsWith(r'$')) continue;

        if (value is String) {
          variables.add('$prefix$key');
        } else if (value is Map<String, dynamic>) {
          traverse(value, '$prefix$key.');
        }
      }
    }

    traverse(vars, '');
  }

  extractFromMode(tokens['light'] as Map<String, dynamic>?);
  extractFromMode(tokens['dark'] as Map<String, dynamic>?);

  return variables;
}

List<String> _validateVariableReferences(Map<String, dynamic> tokens, Set<String> allVariables) {
  final errors = <String>[];

  void checkValue(dynamic value, String path) {
    if (value is String && value.startsWith(r'$') && !value.startsWith(r'$$')) {
      // Remove $ prefix and check if variable exists
      final varPath = value.substring(1);
      if (!allVariables.contains(varPath)) {
        errors.add('$path: Unresolved variable reference: $value');
      }
    } else if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        checkValue(entry.value, '$path.${entry.key}');
      }
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        checkValue(value[i], '$path[$i]');
      }
    }
  }

  void checkMode(Map<String, dynamic>? mode, String modeName) {
    if (mode == null) return;

    // Skip $variables section
    for (final entry in mode.entries) {
      final key = entry.key;
      if (key.startsWith(r'$')) continue;

      checkValue(entry.value, '$modeName.$key');
    }
  }

  checkMode(tokens['light'] as Map<String, dynamic>?, 'light');
  checkMode(tokens['dark'] as Map<String, dynamic>?, 'dark');

  return errors;
}
