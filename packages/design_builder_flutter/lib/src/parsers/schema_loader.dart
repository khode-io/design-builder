import 'dart:convert';

/// Loads and parses JSON schema to discover token structure dynamically.
/// This allows the parser to adapt to spec changes without code modifications.
class SchemaLoader {
  SchemaLoader._(this._schema);

  /// Parse schema from JSON string
  factory SchemaLoader.parse(String jsonContent) {
    final schema = jsonDecode(jsonContent) as Map<String, dynamic>;
    return SchemaLoader._(schema);
  }
  final Map<String, dynamic> _schema;

  /// Get definitions section from schema
  Map<String, dynamic> get _definitions {
    return _schema['definitions'] as Map<String, dynamic>? ?? {};
  }

  /// Get color group names from schema (e.g., ['brand', 'foreground', 'icon', ...])
  List<String> getColorGroupNames() {
    final color = _definitions['color'] as Map<String, dynamic>?;
    if (color == null) return [];

    final properties = color['properties'] as Map<String, dynamic>?;
    if (properties == null) return [];

    return properties.keys.toList();
  }

  /// Get size category names from schema (e.g., ['padding', 'spacing', 'radius', ...])
  List<String> getSizeCategoryNames() {
    final appearance = _definitions['appearance'] as Map<String, dynamic>?;
    if (appearance == null) return [];

    final properties = appearance['properties'] as Map<String, dynamic>?;
    if (properties == null) return [];

    final sizes = properties['sizes'] as Map<String, dynamic>?;
    if (sizes == null) return [];

    final sizeProperties = sizes['properties'] as Map<String, dynamic>?;
    if (sizeProperties == null) return [];

    return sizeProperties.keys.toList();
  }

  /// Get typography style names from schema (e.g., ['display', 'headline', 'title', ...])
  List<String> getTypographyStyleNames() {
    final typography = _definitions['typography'] as Map<String, dynamic>?;
    if (typography == null) return [];

    final properties = typography['properties'] as Map<String, dynamic>?;
    if (properties == null) return [];

    return properties.keys.toList();
  }

  /// Get typography weight variant names from schema
  /// (e.g., ['black', 'extraBold', 'bold', 'semiBold', 'medium', 'regular', 'light', 'extraLight', 'thin'])
  List<String> getTypographyWeightNames() {
    final typographyWeight =
        _definitions['typographyWeight'] as Map<String, dynamic>?;
    if (typographyWeight == null) return [];

    final properties = typographyWeight['properties'] as Map<String, dynamic>?;
    if (properties == null) return [];

    return properties.keys.toList();
  }

  /// Get the expected properties for a color group (e.g., 'brand' -> ['primary', 'container'])
  List<String> getColorGroupProperties(String groupName) {
    final color = _definitions['color'] as Map<String, dynamic>?;
    if (color == null) return [];

    final properties = color['properties'] as Map<String, dynamic>?;
    if (properties == null) return [];

    final group = properties[groupName] as Map<String, dynamic>?;
    if (group == null) return [];

    final groupProperties = group['properties'] as Map<String, dynamic>?;
    if (groupProperties == null) return [];

    return groupProperties.keys.toList();
  }

  /// Get token type definition by $type value
  /// Returns the definition name (e.g., 'colorToken', 'numberToken', 'textStyleToken')
  String? getTokenTypeDefinition(String type) {
    final definitions = _definitions;

    for (final entry in definitions.entries) {
      final def = entry.value as Map<String, dynamic>;
      final defProperties = def['properties'] as Map<String, dynamic>?;
      if (defProperties == null) continue;

      final typeProperty = defProperties['\$type'] as Map<String, dynamic>?;
      if (typeProperty == null) continue;

      // Check const match
      final constValue = typeProperty['const'] as String?;
      if (constValue == type) {
        return entry.key;
      }

      // Check enum match
      final enumValues = typeProperty['enum'] as List<dynamic>?;
      if (enumValues != null && enumValues.contains(type)) {
        return entry.key;
      }
    }

    return null;
  }

  /// Determine the internal token type from schema definition
  /// Maps to: 'color', 'dimension', 'typography', 'string', etc.
  String? getTokenType(Map<String, dynamic> tokenData) {
    final type = tokenData['\$type'] as String?;
    if (type == null) return null;

    final defName = getTokenTypeDefinition(type);
    if (defName == null) return null;

    // Map definition name to internal type
    if (defName == 'colorToken') return 'color';
    if (defName == 'numberToken') return 'dimension';
    if (defName == 'stringToken') return 'string';
    if (defName == 'textStyleToken') return 'typography';

    return type; // Fallback to $type value
  }

  /// Check if data matches a token definition (has $type and $value)
  bool isToken(Map<String, dynamic> data) {
    return data.containsKey('\$type') && data.containsKey('\$value');
  }

  /// Get all token types defined in schema
  Map<String, String> getTokenTypeMap() {
    final result = <String, String>{};
    final definitions = _definitions;

    for (final entry in definitions.entries) {
      final defName = entry.key;
      final def = entry.value as Map<String, dynamic>;
      final defProperties = def['properties'] as Map<String, dynamic>?;
      if (defProperties == null) continue;

      final typeProperty = defProperties['\$type'] as Map<String, dynamic>?;
      if (typeProperty == null) continue;

      // Handle const
      final constValue = typeProperty['const'] as String?;
      if (constValue != null) {
        result[constValue] = defName;
      }

      // Handle enum
      final enumValues = typeProperty['enum'] as List<dynamic>?;
      if (enumValues != null) {
        for (final value in enumValues) {
          result[value.toString()] = defName;
        }
      }
    }

    return result;
  }
}
