import 'dart:convert';

import 'package:design_builder/src/models/design_token.dart';
import 'package:design_builder/src/parsers/schema_loader.dart';

/// Result of parsing design tokens including tokens and group descriptions
class TokenParseResult {
  TokenParseResult({
    required this.tokens,
    required this.groupDescriptions,
    this.rootDescription,
  });

  /// Map of mode name to list of tokens
  final Map<String, List<DesignToken>> tokens;

  /// Map of group path to description (e.g., 'light.color.action' -> 'Colors for buttons...')
  final Map<String, String> groupDescriptions;

  /// Root-level description of the theme from the token file
  final String? rootDescription;
}

/// Parses W3C Design Tokens JSON format into DesignToken objects
///
/// The parser requires a SchemaLoader to discover token structure dynamically.
/// No fallback is provided - users must specify a schema in build.yaml.
///
/// The format has:
/// - Metadata: $schemaVersion, $id, $version, $name
/// - light and dark sections containing:
///   - colors: dynamic color groups discovered from schema
///   - sizes: dynamic size categories discovered from schema
///   - typography: dynamic text styles discovered from schema
class TokenParser {
  /// Create parser with required schema loader for dynamic structure
  TokenParser({required SchemaLoader schemaLoader})
    : _schemaLoader = schemaLoader;
  final SchemaLoader _schemaLoader;

  final Map<String, String> _groupDescriptions = {};

  /// Stores variables defined in $variables section for value substitution
  final Map<String, dynamic> _variables = {};

  /// Parse JSON content into tokens for each mode
  /// Returns a [TokenParseResult] containing both tokens and group descriptions
  TokenParseResult parseModes(String jsonContent) {
    _groupDescriptions.clear();
    _variables.clear();
    final Map<String, dynamic> json = jsonDecode(jsonContent);
    final result = <String, List<DesignToken>>{};

    // Extract root-level variables if present
    if (json['\$variables'] is Map<String, dynamic>) {
      _extractVariables(json['\$variables'] as Map<String, dynamic>, '');
    }

    // Parse light mode
    if (json['light'] is Map<String, dynamic>) {
      final lightTokens = <DesignToken>[];
      _parseAppearance(
        json['light'] as Map<String, dynamic>,
        'light',
        lightTokens,
      );
      result['light'] = lightTokens;
    }

    // Parse dark mode
    if (json['dark'] is Map<String, dynamic>) {
      final darkTokens = <DesignToken>[];
      _parseAppearance(
        json['dark'] as Map<String, dynamic>,
        'dark',
        darkTokens,
      );
      result['dark'] = darkTokens;
    }

    // Extract root-level description if present
    final rootDesc = json['\$description'] as String?;

    return TokenParseResult(
      tokens: result,
      groupDescriptions: Map.unmodifiable(_groupDescriptions),
      rootDescription: rootDesc,
    );
  }

  /// Parse appearance section (light or dark)
  void _parseAppearance(
    Map<String, dynamic> appearance,
    String mode,
    List<DesignToken> tokens,
  ) {
    // Extract mode-level variables if present
    if (appearance['\$variables'] is Map<String, dynamic>) {
      _extractVariables(appearance['\$variables'] as Map<String, dynamic>, '');
    }

    // Parse color section (schema uses 'color' singular)
    if (appearance['color'] is Map<String, dynamic>) {
      _parseColors(appearance['color'] as Map<String, dynamic>, mode, tokens);
    }

    // Parse sizes section
    if (appearance['sizes'] is Map<String, dynamic>) {
      _parseSizes(appearance['sizes'] as Map<String, dynamic>, mode, tokens);
    }

    // Parse typography section
    if (appearance['typography'] is Map<String, dynamic>) {
      _parseTypography(
        appearance['typography'] as Map<String, dynamic>,
        mode,
        tokens,
      );
    }
  }

  /// Parse color section with dynamic color groups from schema
  void _parseColors(
    Map<String, dynamic> color,
    String mode,
    List<DesignToken> tokens,
  ) {
    // Get color groups from schema
    final colorGroups = _schemaLoader.getColorGroupNames();

    for (final groupName in colorGroups) {
      final group = color[groupName];
      if (group is Map<String, dynamic>) {
        final groupPath = '$mode.color.$groupName';
        // Extract group-level description if present
        final groupDesc = group['\$description'] as String?;
        if (groupDesc != null && groupDesc.isNotEmpty) {
          _groupDescriptions[groupPath] = groupDesc;
        }
        _parseColorGroup(group, groupPath, tokens);
      }
    }
  }

  /// Parse a single color group
  void _parseColorGroup(
    Map<String, dynamic> group,
    String basePath,
    List<DesignToken> tokens,
  ) {
    group.forEach((key, value) {
      // Skip $description key itself
      if (key == '\$description') return;

      final newPath = '$basePath.$key';

      if (value is Map<String, dynamic>) {
        // Check if this is a nested group or a color token
        final tokenType = _schemaLoader.getTokenType(value);

        if (tokenType == 'color' && value.containsKey('\$value')) {
          final token = _createColorToken(newPath, value);
          if (token != null) {
            tokens.add(token);
          }
        }
      }
    });
  }

  /// Create a color token from the spec format (hex string)
  DesignToken? _createColorToken(String path, Map<String, dynamic> data) {
    final raw = Map<String, dynamic>.from(data);
    final value = data['\$value'];
    final description = data['\$description'] as String?;

    // Resolve variable references
    final resolvedValue = _resolveValue(value);

    // Handle hex color value (string format)
    String? hexValue;
    if (resolvedValue is String) {
      hexValue = resolvedValue;
    }

    if (hexValue == null) return null;

    return DesignToken(
      path: path,
      type: 'color',
      value: hexValue,
      description: description,
      extensions: _extractExtensions(data),
      raw: raw,
    );
  }

  /// Parse sizes section with dynamic categories from schema
  void _parseSizes(
    Map<String, dynamic> sizes,
    String mode,
    List<DesignToken> tokens,
  ) {
    // Get size categories from schema
    final sizeCategories = _schemaLoader.getSizeCategoryNames();

    // Extract sizes parent group description if present
    final sizesDesc = sizes['\$description'] as String?;
    if (sizesDesc != null && sizesDesc.isNotEmpty) {
      _groupDescriptions['$mode.sizes'] = sizesDesc;
    }

    for (final category in sizeCategories) {
      final scale = sizes[category];
      if (scale is Map<String, dynamic>) {
        final groupPath = '$mode.sizes.$category';
        // Extract group-level description if present
        final groupDesc = scale['\$description'] as String?;
        if (groupDesc != null && groupDesc.isNotEmpty) {
          _groupDescriptions[groupPath] = groupDesc;
        }
        _parseScale(scale, groupPath, tokens);
      }
    }
  }

  /// Parse a size scale (e.g., padding: {xs, sm, md, ...})
  void _parseScale(
    Map<String, dynamic> scale,
    String basePath,
    List<DesignToken> tokens,
  ) {
    scale.forEach((key, value) {
      // Skip $description key itself
      if (key == '\$description') return;

      if (value is Map<String, dynamic>) {
        // Check if this is a dimension token using schema
        final tokenType = _schemaLoader.getTokenType(value);

        if (value.containsKey('\$value') &&
            (tokenType == 'number' || tokenType == 'dimension')) {
          // Resolve variable references
          final resolvedValue = _resolveValue(value['\$value']);
          tokens.add(
            DesignToken(
              path: '$basePath.$key',
              type: 'dimension',
              value: resolvedValue,
              description: value['\$description'] as String?,
              extensions: _extractExtensions(value),
              raw: Map<String, dynamic>.from(value),
            ),
          );
        }
      }
    });
  }

  /// Parse typography section with dynamic styles from schema
  void _parseTypography(
    Map<String, dynamic> typography,
    String mode,
    List<DesignToken> tokens,
  ) {
    // Get typography style names from schema (e.g., 'display', 'headline', etc.)
    final textStyles = _schemaLoader.getTypographyStyleNames();

    // Extract typography parent group description if present
    final typographyDesc = typography['\$description'] as String?;
    if (typographyDesc != null && typographyDesc.isNotEmpty) {
      _groupDescriptions['$mode.typography'] = typographyDesc;
    }

    for (final styleName in textStyles) {
      final style = typography[styleName];
      if (style is Map<String, dynamic>) {
        final groupPath = '$mode.typography.$styleName';
        // Extract group-level description if present
        final groupDesc = style['\$description'] as String?;
        if (groupDesc != null && groupDesc.isNotEmpty) {
          _groupDescriptions[groupPath] = groupDesc;
        }

        // Check if this is a flat structure (direct weights) or nested (size variants)
        if (_isFlatTypographyStyle(style)) {
          // Flat structure: display.black
          _parseTypographyWeightGroup(
            style,
            groupPath,
            tokens,
          );
        } else {
          // Nested structure: display.h1.black
          _parseNestedTypographyStyle(
            style,
            groupPath,
            tokens,
          );
        }
      }
    }
  }

  /// Check if the typography style is flat (contains weights directly)
  bool _isFlatTypographyStyle(Map<String, dynamic> style) {
    for (final value in style.values) {
      if (value is Map<String, dynamic>) {
        final tokenType = _schemaLoader.getTokenType(value);
        if (tokenType == 'typography') {
          return true; // Contains typography tokens directly - flat
        }
      }
    }
    return false; // No typography tokens directly - must be nested
  }

  /// Parse nested typography style (e.g., display.h1.black)
  void _parseNestedTypographyStyle(
    Map<String, dynamic> style,
    String basePath,
    List<DesignToken> tokens,
  ) {
    // style is like: {h1: {black: {...}, bold: {...}}, h2: {...}}
    for (final sizeVariant in style.keys) {
      final sizeData = style[sizeVariant];
      if (sizeData is Map<String, dynamic>) {
        _parseTypographyWeightGroup(sizeData, '$basePath.$sizeVariant', tokens);
      }
    }
  }

  /// Parse typography weight group (black, extraBold, bold, semiBold, medium, regular, light, extraLight, thin)
  void _parseTypographyWeightGroup(
    Map<String, dynamic> weightGroup,
    String basePath,
    List<DesignToken> tokens,
  ) {
    // Get weight variant names from schema
    final weightNames = _schemaLoader.getTypographyWeightNames();

    for (final weight in weightNames) {
      final style = weightGroup[weight];
      if (style is Map<String, dynamic>) {
        // Check if this is a typography token using schema
        final tokenType = _schemaLoader.getTokenType(style);

        final value = style['\$value'];
        if (tokenType == 'typography' && value is Map<String, dynamic>) {
          // Resolve variable references within the typography value
          final resolvedValue = _resolveValue(value);
          tokens.add(
            DesignToken(
              path: '$basePath.$weight',
              type: 'typography',
              value: resolvedValue,
              description: style['\$description'] as String?,
              extensions: _extractExtensions(style),
              raw: Map<String, dynamic>.from(style),
            ),
          );
        }
      }
    }
  }

  /// Extract extensions from token data
  Map<String, dynamic>? _extractExtensions(Map<String, dynamic> data) {
    final extensions = data['\$extensions'];
    if (extensions is Map<String, dynamic>) {
      return extensions;
    }
    return null;
  }

  /// Legacy parse method for backward compatibility
  List<DesignToken> parse(String jsonContent) {
    final result = parseModes(jsonContent);
    // Combine all tokens for backward compatibility
    return result.tokens.values.expand((list) => list).toList();
  }

  /// Parse a dimension value like "4px", "1rem", "1.5em" into a numeric value
  static double? parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'(px|rem|em|%|pt|dp)$'), '');
      return double.tryParse(clean);
    }
    return null;
  }

  /// Parse a color hex string into an integer color value
  static int? parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      var hex = value;
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      if (hex.length == 6) {
        return int.tryParse('FF$hex', radix: 16);
      } else if (hex.length == 8) {
        return int.tryParse(hex, radix: 16);
      }
    }
    return null;
  }

  /// Recursively extracts variables from the $variables section
  /// Keys are stored as dot-separated paths (e.g., "color.brand.primary")
  void _extractVariables(Map<String, dynamic> variables, String prefix) {
    variables.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _extractVariables(value, fullKey);
      } else {
        _variables[fullKey] = value;
      }
    });
  }

  /// Resolves a value that may contain variable references
  /// Variable references use $ prefix (e.g., "$color.brand.primary")
  /// Also recursively resolves references within Map structures
  /// Returns the resolved value or the original if no reference found
  dynamic _resolveValue(dynamic value) {
    // Handle Map structures recursively (e.g., typography values)
    if (value is Map<String, dynamic>) {
      final resolved = <String, dynamic>{};
      for (final entry in value.entries) {
        resolved[entry.key] = _resolveValue(entry.value);
      }
      return resolved;
    }

    // Handle List structures recursively
    if (value is List) {
      return value.map((item) => _resolveValue(item)).toList();
    }

    // Handle string variable references with $ prefix
    if (value is String && value.startsWith('\$')) {
      // Remove the leading $ and look up in variables
      final varPath = value.substring(1);
      if (_variables.containsKey(varPath)) {
        return _variables[varPath];
      }
    }

    return value;
  }
}
