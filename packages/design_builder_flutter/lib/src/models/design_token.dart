/// Represents a W3C Design Token
class DesignToken {
  DesignToken({
    required this.path,
    required this.type,
    required this.value,
    required this.raw,
    this.description,
    this.extensions,
  });

  /// Token identifier path (e.g., "Colors.Button.primary")
  final String path;

  /// Token type (color, dimension, fontFamily, etc.)
  final String type;

  /// Token value (can be primitive or reference)
  final dynamic value;

  /// Token description
  final String? description;

  /// Token extensions (Figma metadata, etc.)
  final Map<String, dynamic>? extensions;

  /// Raw JSON data for this token
  final Map<String, dynamic> raw;

  /// Whether this token is an alias reference
  bool get isAlias =>
      value is String &&
      (value.toString().startsWith('\$') ||
          (value.toString().startsWith('{') &&
              value.toString().endsWith('}')));

  /// If this is an alias, returns the referenced path
  String? get aliasPath {
    if (!isAlias) return null;
    final str = value.toString();
    if (str.startsWith('\$')) {
      return str.substring(1);
    } else if (str.startsWith('{') && str.endsWith('}')) {
      return str.substring(1, str.length - 1);
    }
    return null;
  }

  @override
  String toString() => 'DesignToken($path: $type = $value)';
}
