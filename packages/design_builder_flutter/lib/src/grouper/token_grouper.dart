import 'package:design_builder/src/models/design_token.dart';
import 'package:design_builder/src/models/token_group.dart';

/// Groups tokens from design tokens format into hierarchical TokenGroups with recursive nesting support.
///
/// The format supports arbitrary depth paths like:
/// - light.colors.brand.primary (mode.category.group.token)
/// - light.sizes.padding.xs (mode.category.group.token)
/// - light.typography.display.h1.black (mode.category.group.subgroup.token)
/// - light.typography.display.h1.bold (mode.category.group.subgroup.token)
/// - dark.colors.background.page.surface (mode.category.group.subgroup.subtoken)
///
/// This grouper recursively builds the hierarchy to any depth.
class TokenGrouper {
  /// Group tokens by category and recursive nested structure
  List<TokenGroup> group(List<DesignToken> tokens, {String? mode}) {
    final root = TokenGroup(
      name: 'Root',
      category: 'root',
      children: <TokenGroup>[],
      tokenPaths: <String>[],
      tokens: <DesignToken>[],
    );

    for (final token in tokens) {
      _addTokenToGroup(root, token, mode);
    }

    // Convert to list of groups (flatten category level only)
    final groups = <TokenGroup>[];
    for (final child in root.children) {
      // For each category (colors, sizes, typography), add all nested groups
      groups.addAll(_flattenToLeafGroups(child));
    }

    return groups;
  }

  void _addTokenToGroup(
    TokenGroup root,
    DesignToken token,
    String? explicitMode,
  ) {
    final parts = token.path.split('.');
    if (parts.length < 3) {
      // Direct token at root level
      root.tokenPaths.add(token.path);
      root.tokens.add(token);
      return;
    }

    // Path format: mode.category.[subgroup...].tokenName
    // e.g., light.colors.brand.primary or light.typography.display.h1.black
    final category = parts[1]; // colors, sizes, typography

    // Create or find category group
    var categoryGroup = root.children.firstWhere(
      (g) => g.name == category && g.category == category,
      orElse: () {
        final newGroup = TokenGroup(
          name: category,
          category: category,
          children: [],
          tokenPaths: [],
          tokens: [],
        );
        root.children.add(newGroup);
        return newGroup;
      },
    );

    // Recursively build the nested structure for remaining parts
    // parts[2+] are the group path: brand.primary or display.h1.black
    _buildNestedGroup(categoryGroup, token, parts.sublist(2));
  }

  void _buildNestedGroup(
    TokenGroup parent,
    DesignToken token,
    List<String> pathParts,
  ) {
    if (pathParts.isEmpty) return;

    if (pathParts.length == 1) {
      // Leaf node - this is the actual token name
      parent.tokenPaths.add(token.path);
      parent.tokens.add(token);
      return;
    }

    // More levels to go - create/find intermediate group
    final groupName = pathParts.first;
    var childGroup = parent.children.firstWhere(
      (g) => g.name == groupName,
      orElse: () {
        final newGroup = TokenGroup(
          name: groupName,
          category: parent.category,
          parent: parent,
          children: [],
          tokenPaths: [],
          tokens: [],
        );
        parent.children.add(newGroup);
        return newGroup;
      },
    );

    // Recurse with remaining path parts
    _buildNestedGroup(childGroup, token, pathParts.sublist(1));
  }

  /// Flatten the tree to get all leaf groups (groups that contain tokens)
  /// while preserving the full path information for nested groups.
  List<TokenGroup> _flattenToLeafGroups(TokenGroup group) {
    final result = <TokenGroup>[];

    // If this group has tokens, it's a leaf - add it with full path context
    if (group.tokenPaths.isNotEmpty) {
      result.add(group);
    }

    // Recursively process children
    for (final child in group.children) {
      result.addAll(_flattenToLeafGroups(child));
    }

    return result;
  }
}
