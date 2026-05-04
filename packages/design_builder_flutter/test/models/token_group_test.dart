import 'package:design_builder/src/models/design_token.dart';
import 'package:design_builder/src/models/token_group.dart';
import 'package:test/test.dart';

void main() {
  group('TokenGroup', () {
    test('creates root group with default values', () {
      final group = TokenGroup(name: 'Colors', category: 'color');

      expect(group.name, 'Colors');
      expect(group.category, 'color');
      expect(group.parent, isNull);
      expect(group.description, isNull);
      expect(group.children, isEmpty);
      expect(group.tokenPaths, isEmpty);
      expect(group.tokens, isEmpty);
    });

    test('creates group with all values', () {
      final token = DesignToken(
        path: 'light.color.primary.main',
        type: 'color',
        value: '#FF0000',
        raw: {'\$type': 'color', '\$value': '#FF0000'},
      );

      final childGroup = TokenGroup(name: 'primary', category: 'color');

      final parentGroup = TokenGroup(name: 'color', category: 'color');

      final group = TokenGroup(
        name: 'brand',
        category: 'color',
        parent: parentGroup,
        description: 'Brand colors',
        children: [childGroup],
        tokenPaths: ['light.color.brand.main'],
        tokens: [token],
      );

      expect(group.name, 'brand');
      expect(group.category, 'color');
      expect(group.parent, parentGroup);
      expect(group.description, 'Brand colors');
      expect(group.children, [childGroup]);
      expect(group.tokenPaths, ['light.color.brand.main']);
      expect(group.tokens, [token]);
    });

    group('fullGroupPath', () {
      test('returns name for root group', () {
        final group = TokenGroup(name: 'Colors', category: 'color');

        expect(group.fullGroupPath, 'Colors');
      });

      test('returns name for category root (parent is category)', () {
        final categoryRoot = TokenGroup(name: 'color', category: 'color');

        final child = TokenGroup(
          name: 'brand',
          category: 'color',
          parent: categoryRoot,
        );

        expect(child.fullGroupPath, 'brand');
      });

      test('builds full path for nested group', () {
        final categoryRoot = TokenGroup(name: 'color', category: 'color');

        final brandGroup = TokenGroup(
          name: 'brand',
          category: 'color',
          parent: categoryRoot,
        );

        final primaryGroup = TokenGroup(
          name: 'primary',
          category: 'color',
          parent: brandGroup,
        );

        expect(primaryGroup.fullGroupPath, 'brand.primary');
      });

      test('handles deeply nested path', () {
        final root = TokenGroup(name: 'color', category: 'color');
        final typography = TokenGroup(
          name: 'typography',
          category: 'typography',
          parent: root,
        );
        final display = TokenGroup(
          name: 'display',
          category: 'typography',
          parent: typography,
        );
        final h1 = TokenGroup(
          name: 'h1',
          category: 'typography',
          parent: display,
        );

        expect(h1.fullGroupPath, 'typography.display.h1');
      });
    });

    group('allTokenPaths', () {
      test('returns empty list when no tokens', () {
        final group = TokenGroup(name: 'Colors', category: 'color');

        expect(group.allTokenPaths, isEmpty);
      });

      test('returns direct token paths', () {
        final group = TokenGroup(
          name: 'brand',
          category: 'color',
          tokenPaths: ['light.color.brand.main', 'light.color.brand.surface'],
        );

        expect(group.allTokenPaths, [
          'light.color.brand.main',
          'light.color.brand.surface',
        ]);
      });

      test('recursively collects token paths from children', () {
        final child1 = TokenGroup(
          name: 'primary',
          category: 'color',
          tokenPaths: ['light.color.brand.primary.main'],
        );

        final child2 = TokenGroup(
          name: 'secondary',
          category: 'color',
          tokenPaths: ['light.color.brand.secondary.main'],
        );

        final parent = TokenGroup(
          name: 'brand',
          category: 'color',
          children: [child1, child2],
        );

        expect(parent.allTokenPaths, [
          'light.color.brand.primary.main',
          'light.color.brand.secondary.main',
        ]);
      });

      test('combines own tokens with children tokens', () {
        final child = TokenGroup(
          name: 'primary',
          category: 'color',
          tokenPaths: ['light.color.brand.primary.surface'],
        );

        final parent = TokenGroup(
          name: 'brand',
          category: 'color',
          tokenPaths: ['light.color.brand.main'],
          children: [child],
        );

        expect(parent.allTokenPaths, [
          'light.color.brand.main',
          'light.color.brand.primary.surface',
        ]);
      });
    });

    group('isNested', () {
      test('returns false for category root', () {
        final root = TokenGroup(name: 'color', category: 'color');

        expect(root.isNested, isFalse);
      });

      test('returns false for group with category root as parent', () {
        final categoryRoot = TokenGroup(name: 'color', category: 'color');

        final child = TokenGroup(
          name: 'brand',
          category: 'color',
          parent: categoryRoot,
        );

        // This is the first level after category root, so it's not nested
        expect(child.isNested, isFalse);
      });

      test('returns true for deeply nested group', () {
        final categoryRoot = TokenGroup(name: 'color', category: 'color');

        final brand = TokenGroup(
          name: 'brand',
          category: 'color',
          parent: categoryRoot,
        );

        final primary = TokenGroup(
          name: 'primary',
          category: 'color',
          parent: brand,
        );

        expect(primary.isNested, isTrue);
      });

      test('returns false for group with null parent', () {
        final group = TokenGroup(name: 'Colors', category: 'color');

        expect(group.isNested, isFalse);
      });
    });

    group('toString', () {
      test('returns expected format', () {
        final group = TokenGroup(
          name: 'brand',
          category: 'color',
          tokenPaths: ['light.color.brand.main', 'light.color.brand.surface'],
        );

        expect(group.toString(), 'TokenGroup(brand, path: brand, tokens: 2)');
      });

      test('returns format with full path for nested group', () {
        final categoryRoot = TokenGroup(name: 'color', category: 'color');
        final brand = TokenGroup(
          name: 'brand',
          category: 'color',
          parent: categoryRoot,
        );

        expect(brand.toString(), 'TokenGroup(brand, path: brand, tokens: 0)');
      });
    });

    group('mutability', () {
      test('can add children dynamically', () {
        final parent = TokenGroup(name: 'brand', category: 'color');

        final child = TokenGroup(name: 'primary', category: 'color');

        parent.children.add(child);

        expect(parent.children, [child]);
      });

      test('can add token paths dynamically', () {
        final group = TokenGroup(name: 'brand', category: 'color');

        group.tokenPaths.add('light.color.brand.main');

        expect(group.tokenPaths, ['light.color.brand.main']);
      });

      test('can add tokens dynamically', () {
        final group = TokenGroup(name: 'brand', category: 'color');

        final token = DesignToken(
          path: 'light.color.brand.main',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        );

        group.tokens.add(token);

        expect(group.tokens, [token]);
      });
    });
  });
}
