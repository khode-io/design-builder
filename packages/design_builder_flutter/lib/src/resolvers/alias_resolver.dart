import 'package:design_builder/src/models/design_token.dart';

/// Resolves {path.to.token} alias references
class AliasResolver {
  /// Resolve all aliases in a list of tokens
  List<DesignToken> resolve(List<DesignToken> tokens) {
    final tokenMap = {for (final t in tokens) t.path: t};
    final resolved = <DesignToken>[];

    for (final token in tokens) {
      if (token.isAlias) {
        final resolvedToken = _resolveAlias(token, tokenMap);
        resolved.add(resolvedToken);
      } else {
        resolved.add(token);
      }
    }

    return resolved;
  }

  DesignToken _resolveAlias(
    DesignToken alias,
    Map<String, DesignToken> tokenMap,
  ) {
    final targetPath = alias.aliasPath;
    if (targetPath == null) {
      return alias; // Cannot resolve
    }

    final target = tokenMap[targetPath];
    if (target == null) {
      // Unresolved alias - keep as-is
      return alias;
    }

    // Resolve recursively if target is also an alias
    final resolvedValue = target.isAlias
        ? _resolveAlias(target, tokenMap).value
        : target.value;

    return DesignToken(
      path: alias.path,
      type: target.type,
      value: resolvedValue,
      description: alias.description ?? target.description,
      extensions: alias.extensions ?? target.extensions,
      raw: {...alias.raw, 'resolved': true, 'resolvedFrom': targetPath},
    );
  }
}
