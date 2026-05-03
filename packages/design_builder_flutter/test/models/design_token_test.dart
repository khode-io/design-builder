import 'package:design_builder/src/models/design_token.dart';
import 'package:test/test.dart';

void main() {
  group('DesignToken', () {
    test('creates token with required fields', () {
      final token = DesignToken(
        path: 'light.colors.primary.main',
        type: 'color',
        value: '#FF5733',
        raw: {'\$type': 'color', '\$value': '#FF5733'},
      );

      expect(token.path, 'light.colors.primary.main');
      expect(token.type, 'color');
      expect(token.value, '#FF5733');
      expect(token.raw, {'\$type': 'color', '\$value': '#FF5733'});
      expect(token.description, isNull);
      expect(token.extensions, isNull);
    });

    test('creates token with all fields', () {
      final token = DesignToken(
        path: 'light.colors.primary.main',
        type: 'color',
        value: '#FF5733',
        description: 'Primary brand color',
        extensions: {'figmaId': '12345'},
        raw: {
          '\$type': 'color',
          '\$value': '#FF5733',
          '\$description': 'Primary brand color',
          '\$extensions': {'figmaId': '12345'},
        },
      );

      expect(token.path, 'light.colors.primary.main');
      expect(token.type, 'color');
      expect(token.value, '#FF5733');
      expect(token.description, 'Primary brand color');
      expect(token.extensions, {'figmaId': '12345'});
    });

    test('toString returns expected format', () {
      final token = DesignToken(
        path: 'light.colors.primary.main',
        type: 'color',
        value: '#FF5733',
        raw: {'\$type': 'color', '\$value': '#FF5733'},
      );

      expect(
        token.toString(),
        'DesignToken(light.colors.primary.main: color = #FF5733)',
      );
    });

    group('alias detection', () {
      test('detects curly braces as alias', () {
        final token = DesignToken(
          path: 'light.colors.primary.alias',
          type: 'color',
          value: '{light.colors.secondary.main}',
          raw: {'\$type': 'color', '\$value': '{light.colors.secondary.main}'},
        );

        // W3C Design Tokens format supports both $ and {...} syntax
        expect(token.isAlias, isTrue);
        expect(token.aliasPath, 'light.colors.secondary.main');
      });

      test('detects alias reference starting with dollar sign', () {
        final token = DesignToken(
          path: 'light.colors.primary.alias',
          type: 'color',
          value: '\$light.colors.secondary.main',
          raw: {'\$type': 'color', '\$value': '\$light.colors.secondary.main'},
        );

        expect(token.isAlias, isTrue);
        expect(token.aliasPath, 'light.colors.secondary.main');
      });

      test('non-alias value returns false for isAlias', () {
        final token = DesignToken(
          path: 'light.colors.primary.main',
          type: 'color',
          value: '#FF5733',
          raw: {'\$type': 'color', '\$value': '#FF5733'},
        );

        expect(token.isAlias, isFalse);
        expect(token.aliasPath, isNull);
      });

      test('numeric value is not an alias', () {
        final token = DesignToken(
          path: 'light.sizes.padding.md',
          type: 'dimension',
          value: 16,
          raw: {'\$type': 'dimension', '\$value': 16},
        );

        expect(token.isAlias, isFalse);
        expect(token.aliasPath, isNull);
      });

      test('empty string is not an alias', () {
        final token = DesignToken(
          path: 'light.colors.empty',
          type: 'color',
          value: '',
          raw: {'\$type': 'color', '\$value': ''},
        );

        expect(token.isAlias, isFalse);
        expect(token.aliasPath, isNull);
      });

      test(
        'string starting with { but without closing } is NOT detected as alias',
        () {
          final token = DesignToken(
            path: 'light.colors.invalid',
            type: 'color',
            value: '{light.colors.secondary.main',
            raw: {'\$type': 'color', '\$value': '{light.colors.secondary.main'},
          );

          // Curly brace aliases must have both opening and closing braces
          expect(token.isAlias, isFalse);
          expect(token.aliasPath, isNull);
        },
      );
    });

    group('edge cases', () {
      test('handles empty path', () {
        final token = DesignToken(
          path: '',
          type: 'color',
          value: '#FF5733',
          raw: {'\$type': 'color', '\$value': '#FF5733'},
        );

        expect(token.path, '');
        expect(token.isAlias, isFalse);
      });

      test('handles complex nested value', () {
        final complexValue = {
          'fontSize': 16.0,
          'fontWeight': 400,
          'height': 1.5,
        };

        final token = DesignToken(
          path: 'light.typography.body.regular',
          type: 'typography',
          value: complexValue,
          raw: {'\$type': 'typography', '\$value': complexValue},
        );

        expect(token.value, complexValue);
        expect(token.isAlias, isFalse);
      });

      test('handles list value', () {
        final token = DesignToken(
          path: 'light.colors.palette',
          type: 'color',
          value: ['#FF0000', '#00FF00', '#0000FF'],
          raw: {
            '\$type': 'color',
            '\$value': ['#FF0000', '#00FF00', '#0000FF'],
          },
        );

        expect(token.value, isA<List>());
        expect(token.isAlias, isFalse);
      });
    });
  });
}
