/// Configuration from build.yaml or theme_config.yaml
class ThemeConfig {
  ThemeConfig({
    this.constConstructors = true,
    this.generateJsonMethods = false,
    this.outputPath = 'design_tokens',
    this.outputFileName = 'app_theme',
    this.inputGlob = 'lib/**.tokens.json',
    this.specPath,
    this.className = 'AppTheme',
  });

  factory ThemeConfig.fromBuilderOptions(Map<String, dynamic> options) {
    return ThemeConfig(
      constConstructors: options['const_constructors'] as bool? ?? true,
      generateJsonMethods: options['generate_json_methods'] as bool? ?? true,
      outputPath: options['output_path'] as String? ?? 'design_tokens',
      outputFileName: options['output_file_name'] as String? ?? 'app_theme',
      inputGlob: options['input_glob'] as String? ?? 'lib/**.tokens.json',
      specPath: options['spec_path'] as String?,
      className: options['class_name'] as String? ?? 'AppTheme',
    );
  }

  /// Whether to generate const constructors
  final bool constConstructors;

  /// Whether to generate fromJson/toJson
  final bool generateJsonMethods;

  /// Output directory path relative to lib/ (e.g., "design_tokens", "theme")
  final String outputPath;

  /// Output file name without extension (e.g., "app_theme", "theme_tokens")
  final String outputFileName;

  /// Glob pattern for input token files (e.g., "lib/**.tokens.json")
  final String inputGlob;

  /// Path to JSON schema file for token spec (e.g., "spec/theme-spec.schema.json")
  /// If null, uses fallback hardcoded structure
  final String? specPath;

  /// The main class name for the generated theme (e.g., "AppTheme", "MyTheme")
  /// Default: "AppTheme"
  final String className;

  /// Get the full output file path (e.g., "design_tokens/app_theme.g.dart")
  String get outputFilePath => '$outputPath/$outputFileName.g.dart';

  /// Get the build extension output path
  String get buildExtensionOutput => '$outputPath/\$outputFileName.g.dart';
}
