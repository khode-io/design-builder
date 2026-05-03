import 'package:design_builder/src/models/design_token.dart';
import 'package:design_builder/src/resolvers/alias_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('AliasResolver', () {
    late AliasResolver resolver;

    setUp(() {
      resolver = AliasResolver();
    });

    test('returns empty list for empty tokens', () {
      final resolved = resolver.resolve([]);
      expect(resolved, isEmpty);
    });

    test('returns non-alias tokens unchanged', () {
      final tokens = [
        DesignToken(
          path: 'light.color.brand.primary',
          type: 'color',
          value: '#FF0000',
          raw: {'\$type': 'color', '\$value': '#FF0000'},
        ),
      ];

      final resolved = resolver.resolve(tokens);

      expect(resolved, hasLength(1));
      expect(resolved.first.value, '#FF0000');
      expect(resolved.first.isAlias, isFalse);
    });

    test('resolves simple alias with dollar sign prefix', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        raw: {'\$type': 'color', '\$value': '#FF0000'},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '\$light.color.brand.primary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved, hasLength(2));
      expect(resolved[1].value, '#FF0000');
      expect(resolved[1].type, 'color');
      expect(resolved[1].isAlias, isFalse);
      expect(resolved[1].raw['resolved'], isTrue);
      expect(resolved[1].raw['resolvedFrom'], 'light.color.brand.primary');
    });

    test('resolves simple alias with dollar sign', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        raw: {'\$type': 'color', '\$value': '#FF0000'},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '\$light.color.brand.primary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved[1].value, '#FF0000');
    });

    test('resolves chain of aliases', () {
      final primary = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        raw: {'\$type': 'color', '\$value': '#FF0000'},
      );

      final secondary = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '\$light.color.brand.primary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
      );

      final tertiary = DesignToken(
        path: 'light.color.brand.tertiary',
        type: 'color',
        value: '\$light.color.brand.secondary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.secondary'},
      );

      final resolved = resolver.resolve([primary, secondary, tertiary]);

      expect(resolved[2].value, '#FF0000');
      expect(resolved[2].type, 'color');
    });

    test('keeps alias unchanged when target not found', () {
      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '\$light.color.brand.nonexistent',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.nonexistent'},
      );

      final resolved = resolver.resolve([alias]);

      expect(resolved[0].value, '\$light.color.brand.nonexistent');
      expect(resolved[0].isAlias, isTrue);
    });

    test('preserves description from alias if present', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        description: 'Target description',
        raw: {'\$type': 'color', '\$value': '#FF0000', '\$description': 'Target description'},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '{light.color.brand.primary}',
        description: 'Alias description',
        raw: {'\$type': 'color', '\$value': '{light.color.brand.primary}', '\$description': 'Alias description'},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved[1].description, 'Alias description');
    });

    test('uses target description when alias has none', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        description: 'Target description',
        raw: {'\$type': 'color', '\$value': '#FF0000', '\$description': 'Target description'},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '{light.color.brand.primary}',
        raw: {'\$type': 'color', '\$value': '{light.color.brand.primary}'},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved[1].description, 'Target description');
    });

    test('preserves extensions from alias if present', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        extensions: {'targetId': '123'},
        raw: {'\$type': 'color', '\$value': '#FF0000', '\$extensions': {'targetId': '123'}},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '{light.color.brand.primary}',
        extensions: {'aliasId': '456'},
        raw: {'\$type': 'color', '\$value': '{light.color.brand.primary}', '\$extensions': {'aliasId': '456'}},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved[1].extensions, {'aliasId': '456'});
    });

    test('uses target extensions when alias has none', () {
      final target = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        extensions: {'targetId': '123'},
        raw: {'\$type': 'color', '\$value': '#FF0000', '\$extensions': {'targetId': '123'}},
      );

      final alias = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '{light.color.brand.primary}',
        raw: {'\$type': 'color', '\$value': '{light.color.brand.primary}'},
      );

      final resolved = resolver.resolve([target, alias]);

      expect(resolved[1].extensions, {'targetId': '123'});
    });

    test('circular references cause stack overflow (known limitation)', () {
      final token1 = DesignToken(
        path: 'light.color.a',
        type: 'color',
        value: '\$light.color.b',
        raw: {'\$type': 'color', '\$value': '\$light.color.b'},
      );

      final token2 = DesignToken(
        path: 'light.color.b',
        type: 'color',
        value: '\$light.color.a',
        raw: {'\$type': 'color', '\$value': '\$light.color.a'},
      );

      // NOTE: This is a known limitation - circular references cause
      // infinite recursion in the current implementation
      // This test documents the current behavior
      expect(
        () => resolver.resolve([token1, token2]),
        throwsA(isA<StackOverflowError>()),
      );
    });

    test('self-referential alias causes stack overflow (known limitation)', () {
      final token = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '\$light.color.brand.primary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
      );

      // NOTE: This is a known limitation - self-referential aliases cause
      // infinite recursion in the current implementation
      // This test documents the current behavior
      expect(
        () => resolver.resolve([token]),
        throwsA(isA<StackOverflowError>()),
      );
    });

    test('handles mixed aliases and non-aliases', () {
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
          path: 'light.color.brand.tertiary',
          type: 'color',
          value: '\$light.color.brand.primary',
          raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
        ),
      ];

      final resolved = resolver.resolve(tokens);

      expect(resolved, hasLength(3));
      expect(resolved[0].isAlias, isFalse);
      expect(resolved[1].isAlias, isFalse);
      expect(resolved[2].isAlias, isFalse);
      expect(resolved[2].value, '#FF0000');
    });

    test('resolves multiple independent aliases', () {
      final primary = DesignToken(
        path: 'light.color.brand.primary',
        type: 'color',
        value: '#FF0000',
        raw: {'\$type': 'color', '\$value': '#FF0000'},
      );

      final background = DesignToken(
        path: 'light.color.background.main',
        type: 'color',
        value: '#FFFFFF',
        raw: {'\$type': 'color', '\$value': '#FFFFFF'},
      );

      final alias1 = DesignToken(
        path: 'light.color.brand.secondary',
        type: 'color',
        value: '\$light.color.brand.primary',
        raw: {'\$type': 'color', '\$value': '\$light.color.brand.primary'},
      );

      final alias2 = DesignToken(
        path: 'light.color.surface.main',
        type: 'color',
        value: '\$light.color.background.main',
        raw: {'\$type': 'color', '\$value': '\$light.color.background.main'},
      );

      final resolved = resolver.resolve([primary, background, alias1, alias2]);

      expect(resolved[2].value, '#FF0000');
      expect(resolved[3].value, '#FFFFFF');
    });
  });
}
