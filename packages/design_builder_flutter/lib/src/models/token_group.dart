import 'package:design_builder/src/models/design_token.dart';

/// Represents a hierarchical group of design tokens
class TokenGroup {
  TokenGroup({
    required this.name,
    required this.category,
    this.parent,
    this.description,
    List<TokenGroup>? children,
    List<String>? tokenPaths,
    List<DesignToken>? tokens,
  }) : children = children ?? <TokenGroup>[],
       tokenPaths = tokenPaths ?? <String>[],
       tokens = tokens ?? <DesignToken>[];

  /// Group name (e.g., "ButtonTheme")
  final String name;

  /// Group category (e.g., "Colors", "Typography")
  final String category;

  /// Group description from $description field
  final String? description;

  /// Parent group for building full paths (null for category roots)
  final TokenGroup? parent;

  /// Child groups
  final List<TokenGroup> children;

  /// Token paths in this group (for leaf groups with actual tokens)
  final List<String> tokenPaths;

  /// Design tokens in this group
  final List<DesignToken> tokens;

  /// Get the full path from category to this group
  /// e.g., for "h1" under "display" under "typography", returns "display.h1"
  String get fullGroupPath {
    if (parent == null || parent!.parent == null) {
      return name;
    }
    return '${parent!.fullGroupPath}.$name';
  }

  /// Get all token paths recursively
  List<String> get allTokenPaths {
    final result = <String>[...tokenPaths];
    for (final child in children) {
      result.addAll(child.allTokenPaths);
    }
    return result;
  }

  /// Check if this is a nested group (has a parent that is not a category root)
  bool get isNested => parent != null && parent!.parent != null;

  @override
  String toString() =>
      'TokenGroup($name, path: $fullGroupPath, tokens: ${tokenPaths.length})';
}
