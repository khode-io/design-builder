import 'package:design_builder/src/parsers/schema_loader.dart';
import 'package:design_builder/src/parsers/token_parser.dart';
import 'package:test/test.dart';

void main() {
  group('TokenParser', () {
    late SchemaLoader schemaLoader;

    const schemaJson = '''
    {
      "definitions": {
        "color": {
          "properties": {
            "brand": {},
            "text": {}
          }
        },
        "appearance": {
          "properties": {
            "sizes": {
              "properties": {
                "padding": {},
                "spacing": {}
              }
            }
          }
        },
        "typography": {
          "properties": {
            "display": {},
            "body": {}
          }
        },
        "typographyWeight": {
          "properties": {
            "bold": {},
            "regular": {}
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
        "textStyleToken": {
          "properties": {
            "\$type": {"const": "typography"}
          }
        }
      }
    }
    ''';

    setUp(() {
      schemaLoader = SchemaLoader.parse(schemaJson);
    });

    group('parseModes', () {
      test('parses simple light mode with color', () {
        const json = '''
        {
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#FF0000"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        expect(result.tokens.keys, contains('light'));
        expect(result.tokens['light'], hasLength(1));
        expect(result.tokens['light']!.first.path, 'light.color.brand.primary');
        expect(result.tokens['light']!.first.value, '#FF0000');
      });

      test('parses both light and dark modes', () {
        const json = '''
        {
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#FF0000"
                }
              }
            }
          },
          "dark": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#00FF00"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        expect(result.tokens.keys, contains('light'));
        expect(result.tokens.keys, contains('dark'));
        expect(result.tokens['light']!.first.value, '#FF0000');
        expect(result.tokens['dark']!.first.value, '#00FF00');
      });

      test('parses size tokens', () {
        const json = '''
        {
          "light": {
            "sizes": {
              "padding": {
                "md": {
                  "\$type": "dimension",
                  "\$value": 16
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.path, 'light.sizes.padding.md');
        expect(token.type, 'dimension');
        expect(token.value, 16);
      });

      test('parses typography tokens', () {
        const json = '''
        {
          "light": {
            "typography": {
              "display": {
                "bold": {
                  "\$type": "typography",
                  "\$value": {
                    "fontSize": 24,
                    "fontWeight": 700
                  }
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.path, 'light.typography.display.bold');
        expect(token.type, 'typography');
        expect(token.value, {'fontSize': 24, 'fontWeight': 700});
      });

      test('returns empty result for empty JSON', () {
        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes('{}');

        expect(result.tokens, isEmpty);
        expect(result.groupDescriptions, isEmpty);
      });

      test('extracts root description', () {
        const json = '''
        {
          "\$description": "My theme",
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#FF0000"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        expect(result.rootDescription, 'My theme');
      });

      test('extracts group descriptions', () {
        const json = '''
        {
          "light": {
            "color": {
              "brand": {
                "\$description": "Brand colors",
                "primary": {
                  "\$type": "color",
                  "\$value": "#FF0000",
                  "\$description": "Primary color"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        expect(result.groupDescriptions['light.color.brand'], 'Brand colors');
      });
    });

    group('parse (legacy method)', () {
      test('combines all mode tokens', () {
        const json = '''
        {
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#FF0000"
                }
              }
            }
          },
          "dark": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "#00FF00"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final tokens = parser.parse(json);

        expect(tokens, hasLength(2));
      });
    });

    group('variable resolution', () {
      test('resolves root-level variables', () {
        const json = '''
        {
          "\$variables": {
            "brand": {
              "primary": "#FF0000"
            }
          },
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "\$brand.primary"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.value, '#FF0000');
      });

      test('resolves nested variables', () {
        const json = '''
        {
          "\$variables": {
            "colors": {
              "base": {
                "red": "#FF0000"
              }
            }
          },
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "\$colors.base.red"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.value, '#FF0000');
      });

      test('keeps original value when variable not found', () {
        const json = '''
        {
          "light": {
            "color": {
              "brand": {
                "primary": {
                  "\$type": "color",
                  "\$value": "\$unknown.variable"
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.value, '\$unknown.variable');
      });

      test('resolves variables in typography values', () {
        const json = '''
        {
          "\$variables": {
            "fontSize": {
              "base": 16
            }
          },
          "light": {
            "typography": {
              "body": {
                "regular": {
                  "\$type": "typography",
                  "\$value": {
                    "fontSize": "\$fontSize.base",
                    "fontWeight": 400
                  }
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        final token = result.tokens['light']!.first;
        expect(token.value, {'fontSize': 16, 'fontWeight': 400});
      });
    });

    group('static helper methods', () {
      group('parseDimension', () {
        test('parses numeric value', () {
          expect(TokenParser.parseDimension(16), 16.0);
          expect(TokenParser.parseDimension(16.5), 16.5);
        });

        test('parses string with px suffix', () {
          expect(TokenParser.parseDimension('16px'), 16.0);
        });

        test('parses string with rem suffix', () {
          expect(TokenParser.parseDimension('1.5rem'), 1.5);
        });

        test('parses string with em suffix', () {
          expect(TokenParser.parseDimension('1em'), 1.0);
        });

        test('parses string with percentage suffix', () {
          expect(TokenParser.parseDimension('50%'), 50.0);
        });

        test('returns null for invalid value', () {
          expect(TokenParser.parseDimension(null), isNull);
          expect(TokenParser.parseDimension('invalid'), isNull);
          expect(TokenParser.parseDimension({}), isNull);
        });
      });

      group('parseColor', () {
        test('parses 6-character hex with hash', () {
          expect(TokenParser.parseColor('#FF0000'), 0xFFFF0000);
        });

        test('parses 6-character hex without hash', () {
          expect(TokenParser.parseColor('FF0000'), 0xFFFF0000);
        });

        test('parses 8-character hex with alpha', () {
          expect(TokenParser.parseColor('#80FF0000'), 0x80FF0000);
        });

        test('returns null for invalid color', () {
          expect(TokenParser.parseColor(null), isNull);
          expect(TokenParser.parseColor(''), isNull);
          expect(TokenParser.parseColor('invalid'), isNull);
          expect(TokenParser.parseColor('#GGG'), isNull);
        });
      });
    });

    group('nested typography parsing', () {
      test('parses flat typography structure', () {
        const json = '''
        {
          "light": {
            "typography": {
              "display": {
                "bold": {
                  "\$type": "typography",
                  "\$value": {
                    "fontSize": 32,
                    "fontWeight": 700
                  }
                }
              }
            }
          }
        }
        ''';

        final parser = TokenParser(schemaLoader: schemaLoader);
        final result = parser.parseModes(json);

        expect(result.tokens['light'], hasLength(1));
        expect(
          result.tokens['light']!.first.path,
          'light.typography.display.bold',
        );
      });

      test('parses deeply nested typography structure', () {
        // Update schema to support h1 nested structure
        const deepSchema = '''
        {
          "definitions": {
            "typography": {
              "properties": {
                "display": {}
              }
            },
            "typographyWeight": {
              "properties": {
                "bold": {}
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

        const json = '''
        {
          "light": {
            "typography": {
              "display": {
                "h1": {
                  "bold": {
                    "\$type": "typography",
                    "\$value": {
                      "fontSize": 48,
                      "fontWeight": 700
                    }
                  }
                }
              }
            }
          }
        }
        ''';

        final customSchema = SchemaLoader.parse(deepSchema);
        final parser = TokenParser(schemaLoader: customSchema);
        final result = parser.parseModes(json);

        // Should parse the nested structure
        expect(result.tokens['light'], isNotEmpty);
      });
    });
  });
}
