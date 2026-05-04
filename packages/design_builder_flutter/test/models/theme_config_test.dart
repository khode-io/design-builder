import 'package:design_builder/src/models/theme_config.dart';
import 'package:test/test.dart';

void main() {
  group('ThemeConfig', () {
    test('uses default values when created with no arguments', () {
      final config = ThemeConfig();

      expect(config.constConstructors, isTrue);
      expect(config.generateJsonMethods, isFalse);
      expect(config.outputPath, 'design_tokens');
      expect(config.outputFileName, 'app_theme');
      expect(config.inputGlob, 'lib/**.tokens.json');
      expect(config.specPath, isNull);
      expect(config.className, 'AppTheme');
    });

    test('uses provided values when specified', () {
      final config = ThemeConfig(
        constConstructors: false,
        generateJsonMethods: true,
        outputPath: 'custom_theme',
        outputFileName: 'my_theme',
        inputGlob: 'lib/**.design.json',
        specPath: 'lib/schema.json',
        className: 'CustomTheme',
      );

      expect(config.constConstructors, isFalse);
      expect(config.generateJsonMethods, isTrue);
      expect(config.outputPath, 'custom_theme');
      expect(config.outputFileName, 'my_theme');
      expect(config.inputGlob, 'lib/**.design.json');
      expect(config.specPath, 'lib/schema.json');
      expect(config.className, 'CustomTheme');
    });

    test('calculates output file path correctly', () {
      final config = ThemeConfig(
        outputPath: 'theme',
        outputFileName: 'generated',
      );

      expect(config.outputFilePath, 'theme/generated.g.dart');
    });

    test('calculates build extension output correctly', () {
      final config = ThemeConfig(
        outputPath: 'design_tokens',
        outputFileName: 'app_theme',
      );

      expect(
        config.buildExtensionOutput,
        'design_tokens/\$outputFileName.g.dart',
      );
    });

    group('fromBuilderOptions', () {
      test('parses options from build.yaml format', () {
        final options = {
          'const_constructors': false,
          'generate_json_methods': true,
          'output_path': 'generated',
          'output_file_name': 'theme_data',
          'input_glob': 'lib/**.tokens.json',
          'spec_path': 'lib/schema/schema.json',
          'class_name': 'MyTheme',
        };

        final config = ThemeConfig.fromBuilderOptions(options);

        expect(config.constConstructors, isFalse);
        expect(config.generateJsonMethods, isTrue);
        expect(config.outputPath, 'generated');
        expect(config.outputFileName, 'theme_data');
        expect(config.inputGlob, 'lib/**.tokens.json');
        expect(config.specPath, 'lib/schema/schema.json');
        expect(config.className, 'MyTheme');
      });

      test('uses defaults when options are missing', () {
        final options = <String, dynamic>{};

        final config = ThemeConfig.fromBuilderOptions(options);

        expect(config.constConstructors, isTrue);
        expect(config.generateJsonMethods, isTrue);
        expect(config.outputPath, 'design_tokens');
        expect(config.outputFileName, 'app_theme');
        expect(config.inputGlob, 'lib/**.tokens.json');
        expect(config.specPath, isNull);
        expect(config.className, 'AppTheme');
      });

      test('uses defaults when options are null', () {
        final options = {
          'const_constructors': null,
          'generate_json_methods': null,
          'output_path': null,
          'output_file_name': null,
          'input_glob': null,
          'spec_path': null,
          'class_name': null,
        };

        final config = ThemeConfig.fromBuilderOptions(options);

        expect(config.constConstructors, isTrue);
        expect(config.generateJsonMethods, isTrue);
        expect(config.outputPath, 'design_tokens');
        expect(config.outputFileName, 'app_theme');
        expect(config.inputGlob, 'lib/**.tokens.json');
        expect(config.specPath, isNull);
        expect(config.className, 'AppTheme');
      });

      test('handles partial options', () {
        final options = {
          'output_path': 'custom_output',
          'class_name': 'PartialTheme',
        };

        final config = ThemeConfig.fromBuilderOptions(options);

        expect(config.constConstructors, isTrue);
        expect(config.generateJsonMethods, isTrue);
        expect(config.outputPath, 'custom_output');
        expect(config.outputFileName, 'app_theme');
        expect(config.inputGlob, 'lib/**.tokens.json');
        expect(config.specPath, isNull);
        expect(config.className, 'PartialTheme');
      });
    });

    group('edge cases', () {
      test('handles empty string values', () {
        final config = ThemeConfig(
          outputPath: '',
          outputFileName: '',
          className: '',
        );

        expect(config.outputFilePath, '/.g.dart');
        expect(config.className, '');
      });

      test('handles special characters in paths', () {
        final config = ThemeConfig(
          outputPath: 'lib/generated/themes',
          outputFileName: 'app_theme_v2',
        );

        expect(
          config.outputFilePath,
          'lib/generated/themes/app_theme_v2.g.dart',
        );
      });
    });
  });
}
