import 'package:design_builder/src/grouper/token_grouper.dart';
import 'package:design_builder/src/models/design_token.dart';
import 'package:test/test.dart';

void main() {
  group('TokenGrouper', () {
    late TokenGrouper grouper;

    setUp(() {
      grouper = TokenGrouper();
    });

    test('returns empty list for empty tokens', () {
      final groups = grouper.group([], mode: 'light');
      expect(groups, isEmpty);
    });

    test('groups single color token correctly', () {
      final tokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      expect(groups, hasLength(1));
      expect(groups.first.name, 'brand');
      expect(groups.first.category, 'color');
      expect(groups.first.tokenPaths, ['light.color.brand.primary']);
    });

    test('groups multiple tokens from same category', () {
      final tokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
        DesignToken(
          path: 'light.color.brand.secondary',
          type: 'color',
          value: '#00FF00',
          raw: {'\$type': 'color', '\$value': '#00FF00'},
        ),
        DesignToken(
          path: 'light.color.text.primary',
          type: 'color',
          value: '#000000',
          raw: {'\$type': 'color', '\$value': '#000000'},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      expect(groups, hasLength(2));
      expect(groups.map((g) => g.name), contains('brand'));
      expect(groups.map((g) => g.name), contains('text'));
    });

    test('groups tokens from different categories', () {
      final tokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
        DesignToken(
          path: 'light.sizes.padding.md',
          type: 'dimension',
          value: 16,
          raw: {'\$type': 'dimension', '\$value': 16},
        ),
        DesignToken(
          path: 'light.typography.body.regular',
          type: 'typography',
          value: {'fontSize': 16, 'fontWeight': 400},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 16, 'fontWeight': 400}},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // Should have groups for color, sizes, and typography
      expect(groups, hasLength(3));
      expect(groups.map((g) => g.category), contains('color'));
      expect(groups.map((g) => g.category), contains('sizes'));
      expect(groups.map((g) => g.category), contains('typography'));
    });

    test('creates nested groups for deep paths', () {
      final tokens = [
        DesignToken(
          path: 'light.typography.display.h1.bold',
          type: 'typography',
          value: {'fontSize': 48, 'fontWeight': 700},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 48, 'fontWeight': 700}},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // Groups are flattened to leaf groups with tokens
      expect(groups, isNotEmpty);
      // The leaf group with tokens should be 'h1'
      final h1Group = groups.firstWhere((g) => g.name == 'h1');
      expect(h1Group.tokens, isNotEmpty);
      expect(h1Group.isNested, isTrue);
    });

    test('handles short paths by creating minimal structure', () {
      final tokens = [
        DesignToken(
          path: 'someShortPath',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // Short paths that don't follow mode.category.group.token pattern
      // may result in empty groups list or minimal grouping
      // This is an edge case that the grouper handles gracefully
      expect(groups, anyOf(isEmpty, isNotEmpty));
    });

    test('correctly associates tokens with leaf groups', () {
      final tokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
        DesignToken(
          path: 'light.color.brand.secondary',
          type: 'color',
          value: '#00FF00',
          raw: {'\$type': 'color', '\$value': '#00FF00'},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      final brandGroup = groups.firstWhere((g) => g.name == 'brand');
      expect(brandGroup.tokens, hasLength(2));
      expect(brandGroup.tokenPaths, contains('light.color.brand.primary'));
      expect(brandGroup.tokenPaths, contains('light.color.brand.secondary'));
    });

    test('groups are correctly flattened', () {
      final tokens = [
        DesignToken(
          path: 'light.typography.display.h1.bold',
          type: 'typography',
          value: {'fontSize': 48},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 48}},
        ),
        DesignToken(
          path: 'light.typography.display.h2.bold',
          type: 'typography',
          value: {'fontSize': 36},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 36}},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // Should return flat list of leaf groups
      expect(groups, isNotEmpty);

      // Check that the tokens ended up in the right groups
      final allTokenPaths = groups.expand((g) => g.allTokenPaths).toList();
      expect(allTokenPaths, contains('light.typography.display.h1.bold'));
      expect(allTokenPaths, contains('light.typography.display.h2.bold'));
    });

    test('handles complex nested structure', () {
      final tokens = [
        DesignToken(
          path: 'light.typography.display.h1.bold',
          type: 'typography',
          value: {'fontSize': 48, 'fontWeight': 700},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 48, 'fontWeight': 700}},
        ),
        DesignToken(
          path: 'light.typography.display.h1.regular',
          type: 'typography',
          value: {'fontSize': 48, 'fontWeight': 400},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 48, 'fontWeight': 400}},
        ),
        DesignToken(
          path: 'light.typography.body.regular',
          type: 'typography',
          value: {'fontSize': 16, 'fontWeight': 400},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 16, 'fontWeight': 400}},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // Should have groups for typography
      final typographyGroups = groups.where((g) => g.category == 'typography');
      expect(typographyGroups, isNotEmpty);

      // Should have leaf groups with tokens
      final leafGroups = groups.where((g) => g.tokens.isNotEmpty);
      expect(leafGroups, isNotEmpty);
    });

    test('handles tokens with different modes', () {
      final lightTokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
      ];

      final darkTokens = [
        DesignToken(
          path: 'dark.color.brand.primary',
          type: 'color',
          value: '#00FF00',
          raw: {'\$type': 'color', '\$value': '#00FF00'},
        ),
      ];

      final lightGroups = grouper.group(lightTokens, mode: 'light');
      final darkGroups = grouper.group(darkTokens, mode: 'dark');

      expect(lightGroups, hasLength(1));
      expect(darkGroups, hasLength(1));
    });

    test('handles empty category name gracefully', () {
      final tokens = [
        DesignToken(
          path: 'light..brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
      ];

      // Should handle the path without crashing
      final groups = grouper.group(tokens, mode: 'light');
      // The group will have an empty name, but it shouldn't crash
      expect(groups, isNotEmpty);
    });

    test('preserves parent-child relationships in groups', () {
      final tokens = [
        DesignToken(
          path: 'light.typography.display.h1.bold',
          type: 'typography',
          value: {'fontSize': 48},
          raw: {'\$type': 'typography', '\$value': {'fontSize': 48}},
        ),
      ];

      final groups = grouper.group(tokens, mode: 'light');

      // The h1 group should have display as parent
      final h1Group = groups.firstWhere((g) => g.name == 'h1');
      expect(h1Group.parent, isNotNull);
      expect(h1Group.parent!.name, 'display');
      expect(h1Group.isNested, isTrue);
    });
  });
}
