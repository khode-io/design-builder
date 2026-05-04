import 'package:design_builder/src/parsers/schema_loader.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaLoader', () {
    const simpleSchema = '''
    {
      "definitions": {
        "color": {
          "properties": {
            "brand": {},
            "foreground": {},
            "background": {}
          }
        },
        "appearance": {
          "properties": {
            "sizes": {
              "properties": {
                "padding": {},
                "spacing": {},
                "radius": {}
              }
            }
          }
        },
        "typography": {
          "properties": {
            "display": {},
            "headline": {},
            "body": {}
          }
        },
        "typographyWeight": {
          "properties": {
            "bold": {},
            "regular": {},
            "light": {}
          }
        },
        "colorToken": {
          "properties": {
            "\$type": {"const": "color"}
          }
        },
        "numberToken": {
          "properties": {
            "\$type": {"enum": ["number", "dimension"]}
          }
        },
        "stringToken": {
          "properties": {
            "\$type": {"const": "string"}
          }
        },
        "textStyleToken": {
          "properties": {
            "\$type": {"const": "typography"}
          }
        }
      }
    }
    ''';

    test('parses schema from JSON string', () {
      final loader = SchemaLoader.parse(simpleSchema);
      expect(loader, isNotNull);
    });

    test('throws when given invalid JSON', () {
      expect(() => SchemaLoader.parse('invalid json'), throwsFormatException);
    });

    test('handles empty schema', () {
      final loader = SchemaLoader.parse('{"definitions": {}}');
      expect(loader.getColorGroupNames(), isEmpty);
      expect(loader.getSizeCategoryNames(), isEmpty);
      expect(loader.getTypographyStyleNames(), isEmpty);
    });

    group('getColorGroupNames', () {
      test('returns color group names from schema', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final groups = loader.getColorGroupNames();

        expect(groups, contains('brand'));
        expect(groups, contains('foreground'));
        expect(groups, contains('background'));
        expect(groups.length, 3);
      });

      test('returns empty list when color definition is missing', () {
        const schemaWithoutColor = '{"definitions": {}}';
        final loader = SchemaLoader.parse(schemaWithoutColor);

        expect(loader.getColorGroupNames(), isEmpty);
      });

      test('returns empty list when color has no properties', () {
        const schema = '''
        {
          "definitions": {
            "color": {}
          }
        }
        ''';
        final loader = SchemaLoader.parse(schema);

        expect(loader.getColorGroupNames(), isEmpty);
      });
    });

    group('getSizeCategoryNames', () {
      test('returns size category names from schema', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final categories = loader.getSizeCategoryNames();

        expect(categories, contains('padding'));
        expect(categories, contains('spacing'));
        expect(categories, contains('radius'));
        expect(categories.length, 3);
      });

      test('returns empty list when appearance definition is missing', () {
        const schema = '{"definitions": {}}';
        final loader = SchemaLoader.parse(schema);

        expect(loader.getSizeCategoryNames(), isEmpty);
      });

      test('returns empty list when sizes is missing', () {
        const schema = '''
        {
          "definitions": {
            "appearance": {
              "properties": {}
            }
          }
        }
        ''';
        final loader = SchemaLoader.parse(schema);

        expect(loader.getSizeCategoryNames(), isEmpty);
      });
    });

    group('getTypographyStyleNames', () {
      test('returns typography style names from schema', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final styles = loader.getTypographyStyleNames();

        expect(styles, contains('display'));
        expect(styles, contains('headline'));
        expect(styles, contains('body'));
        expect(styles.length, 3);
      });

      test('returns empty list when typography definition is missing', () {
        const schema = '{"definitions": {}}';
        final loader = SchemaLoader.parse(schema);

        expect(loader.getTypographyStyleNames(), isEmpty);
      });
    });

    group('getTypographyWeightNames', () {
      test('returns typography weight names from schema', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final weights = loader.getTypographyWeightNames();

        expect(weights, contains('bold'));
        expect(weights, contains('regular'));
        expect(weights, contains('light'));
        expect(weights.length, 3);
      });

      test(
        'returns empty list when typographyWeight definition is missing',
        () {
          const schema = '{"definitions": {}}';
          final loader = SchemaLoader.parse(schema);

          expect(loader.getTypographyWeightNames(), isEmpty);
        },
      );
    });

    group('getColorGroupProperties', () {
      const schemaWithColorProperties = '''
      {
        "definitions": {
          "color": {
            "properties": {
              "brand": {
                "properties": {
                  "primary": {},
                  "secondary": {}
                }
              }
            }
          }
        }
      }
      ''';

      test('returns properties for a color group', () {
        final loader = SchemaLoader.parse(schemaWithColorProperties);
        final properties = loader.getColorGroupProperties('brand');

        expect(properties, contains('primary'));
        expect(properties, contains('secondary'));
      });

      test('returns empty list for non-existent group', () {
        final loader = SchemaLoader.parse(schemaWithColorProperties);
        final properties = loader.getColorGroupProperties('nonexistent');

        expect(properties, isEmpty);
      });
    });

    group('getTokenTypeDefinition', () {
      test('finds color token definition', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('color');

        expect(def, 'colorToken');
      });

      test('finds number token definition', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('number');

        expect(def, 'numberToken');
      });

      test('finds dimension token definition', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('dimension');

        expect(def, 'numberToken');
      });

      test('finds string token definition', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('string');

        expect(def, 'stringToken');
      });

      test('finds typography token definition', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('typography');

        expect(def, 'textStyleToken');
      });

      test('returns null for unknown type', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final def = loader.getTokenTypeDefinition('unknown');

        expect(def, isNull);
      });
    });

    group('getTokenType', () {
      test('detects color token', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({
          '\$type': 'color',
          '\$value': '#FF0000',
        });

        expect(type, 'color');
      });

      test('detects dimension token', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({
          '\$type': 'dimension',
          '\$value': 16,
        });

        expect(type, 'dimension');
      });

      test('detects number token', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({'\$type': 'number', '\$value': 42});

        expect(type, 'dimension');
      });

      test('detects typography token', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({
          '\$type': 'typography',
          '\$value': {'fontSize': 16},
        });

        expect(type, 'typography');
      });

      test('detects string token', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({
          '\$type': 'string',
          '\$value': 'Hello',
        });

        expect(type, 'string');
      });

      test('returns null when \$type is missing', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final type = loader.getTokenType({'\$value': '#FF0000'});

        expect(type, isNull);
      });

      test('returns null when definition not found', () {
        const schema = '''
        {
          "definitions": {
            "customToken": {
              "properties": {
                "\$type": {"const": "custom"}
              }
            }
          }
        }
        ''';
        final loader = SchemaLoader.parse(schema);
        final type = loader.getTokenType({
          '\$type': 'unknown',
          '\$value': 'something',
        });

        // When definition is not found, returns null
        expect(type, isNull);
      });
    });

    group('isToken', () {
      test('returns true for valid token data', () {
        final loader = SchemaLoader.parse(simpleSchema);

        expect(
          loader.isToken({'\$type': 'color', '\$value': '#FF0000'}),
          isTrue,
        );
      });

      test('returns false when \$type is missing', () {
        final loader = SchemaLoader.parse(simpleSchema);

        expect(loader.isToken({'\$value': '#FF0000'}), isFalse);
      });

      test('returns false when \$value is missing', () {
        final loader = SchemaLoader.parse(simpleSchema);

        expect(loader.isToken({'\$type': 'color'}), isFalse);
      });

      test('returns false for empty map', () {
        final loader = SchemaLoader.parse(simpleSchema);

        expect(loader.isToken({}), isFalse);
      });
    });

    group('getTokenTypeMap', () {
      test('returns map of token types to definitions', () {
        final loader = SchemaLoader.parse(simpleSchema);
        final typeMap = loader.getTokenTypeMap();

        expect(typeMap['color'], 'colorToken');
        expect(typeMap['number'], 'numberToken');
        expect(typeMap['dimension'], 'numberToken');
        expect(typeMap['string'], 'stringToken');
        expect(typeMap['typography'], 'textStyleToken');
      });

      test('returns empty map when schema has no definitions', () {
        final loader = SchemaLoader.parse('{"definitions": {}}');
        final typeMap = loader.getTokenTypeMap();

        expect(typeMap, isEmpty);
      });
    });
  });
}
