import 'package:design_builder/src/models/token_group.dart';

/// Helper class to represent a node in the token group tree.
class TokenGroupNode {
  TokenGroupNode({
    required this.name,
    required this.fullPath,
    required this.group,
    required this.children,
  });

  final String name;
  final String fullPath;
  final TokenGroup group;
  final List<TokenGroupNode> children;
}
