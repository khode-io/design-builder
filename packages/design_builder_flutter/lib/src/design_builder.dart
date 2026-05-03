import 'dart:async';

import 'package:build/build.dart';
import 'package:design_builder/src/generators/theme_generator.dart';
import 'package:design_builder/src/grouper/token_grouper.dart';
import 'package:design_builder/src/models/models.dart';
import 'package:design_builder/src/parsers/schema_loader.dart';
import 'package:design_builder/src/parsers/token_parser.dart';
import 'package:design_builder/src/resolvers/alias_resolver.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// Builder that generates Flutter theme code from design tokens.
///
/// Reads token files (JSON with light/dark modes), resolves aliases,
/// groups tokens by category, and generates Dart code with const maps
/// for fast lookup and server override support.
///
/// Configuration (via build.yaml):
/// ```yaml
/// targets:
///   $default:
///     builders:
///       design_builder|design_builder:
///         enabled: true
///         options:
///           spec_path: "lib/schema/theme-spec.schema.json"
///           input_glob: "lib/**.tokens.json"
///           output_path: "design_tokens"
///           output_file_name: "app_theme"
///           const_constructors: true
///           generate_json_methods: true
///           class_name: "AppTheme"
/// ```
///
/// Workflow:
/// 1. Loads configuration from build.yaml (required)
/// 2. Loads JSON schema (required)
/// 3. Discovers .tokens.json files
/// 4. Parses tokens from light/dark sections
/// 5. Resolves alias references
/// 6. Groups tokens by category
/// 7. Generates unified Dart code
/// 8. Writes to configured output path
class DesignBuilder implements Builder {
  DesignBuilder(BuilderOptions options) : config = _loadConfig(options);
  final ThemeConfig config;
  final Logger _logger = Logger('DesignBuilder');

  /// Loads configuration from build.yaml options
  static ThemeConfig _loadConfig(BuilderOptions options) {
    return ThemeConfig.fromBuilderOptions(options.config);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': [config.outputFilePath],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    _logger.info('Starting theme generation...');

    // Load schema (REQUIRED - throws if not found)
    final schemaLoader = await _loadSchema(buildStep);
    if (schemaLoader == null) {
      throw Exception(
        'Schema is required but not found at: ${config.specPath ?? "(not configured)"}. '
        'Please configure spec_path in build.yaml pointing to your JSON schema file.',
      );
    }
    _logger.info('Using schema from: ${config.specPath}');

    // Find all .tokens.json files using configured glob pattern
    final glob = Glob(config.inputGlob);
    final files = await buildStep.findAssets(glob).toList();

    if (files.isEmpty) {
      _logger.warning('No files found matching: ${config.inputGlob}');
      return;
    }

    _logger.info(
      'Found ${files.length} token file(s): ${files.map((f) => f.path).join(', ')}',
    );

    // Process the first file (single file format with light/dark)
    // If multiple files exist, process each separately
    for (final inputId in files) {
      final content = await buildStep.readAsString(inputId);
      final fileName = path.basename(inputId.path);

      try {
        final result = await _processThemeFile(content, fileName, schemaLoader);
        if (result == null) continue;

        // Generate unified code
        final generator = ThemeGenerator(config);
        final code = generator.generateUnified(
          result.modeGroups,
          result.modeTokens,
          result.modes,
          result.groupDescriptions,
          result.rootDescription,
        );

        // Write output to configured path
        final outputId = AssetId(
          buildStep.inputId.package,
          'lib/${config.outputFilePath}',
        );
        await buildStep.writeAsString(outputId, code);

        _logger.info(
          'Generated ${outputId.path} with modes: ${result.modes.join(', ')}',
        );
      } catch (e, stack) {
        _logger.severe('Error processing ${inputId.path}: $e');
        _logger.severe(stack.toString());
      }
    }
  }

  /// Load JSON schema from configured path (REQUIRED)
  Future<SchemaLoader?> _loadSchema(BuildStep buildStep) async {
    if (config.specPath == null) {
      _logger.severe(
        'No schema configured. spec_path is required in build.yaml',
      );
      return null;
    }

    try {
      final schemaId = AssetId(buildStep.inputId.package, config.specPath!);
      if (!await buildStep.canRead(schemaId)) {
        _logger.severe('Schema file not found: ${config.specPath}');
        return null;
      }

      final content = await buildStep.readAsString(schemaId);
      return SchemaLoader.parse(content);
    } catch (e) {
      _logger.severe('Failed to load schema: $e');
      return null;
    }
  }

  /// Process a single theme file and return processed data
  Future<_ProcessResult?> _processThemeFile(
    String content,
    String fileName,
    SchemaLoader schemaLoader,
  ) async {
    final parser = TokenParser(schemaLoader: schemaLoader);
    final parseResult = parser.parseModes(content);
    final modeTokens = parseResult.tokens;

    if (modeTokens.isEmpty) {
      _logger.warning('No tokens found in $fileName');
      return null;
    }

    final modes = modeTokens.keys.toList()..sort();
    _logger.info('Found modes in $fileName: ${modes.join(', ')}');

    final allModeGroups = <String, List<TokenGroup>>{};
    final allModeTokens = <String, List<DesignToken>>{};

    for (final mode in modes) {
      final tokens = modeTokens[mode]!;

      // Resolve aliases within this mode
      final resolver = AliasResolver();
      final resolvedTokens = resolver.resolve(tokens);

      // Group tokens
      final grouper = TokenGrouper();
      final groups = grouper.group(resolvedTokens, mode: mode);

      allModeTokens[mode] = resolvedTokens;
      allModeGroups[mode] = groups;

      _logger.info(
        'Processed $mode: ${tokens.length} tokens, ${groups.length} groups',
      );
    }

    return _ProcessResult(
      modeGroups: allModeGroups,
      modeTokens: allModeTokens,
      modes: modes,
      groupDescriptions: parseResult.groupDescriptions,
      rootDescription: parseResult.rootDescription,
    );
  }
}

/// Result of processing a theme file
class _ProcessResult {
  _ProcessResult({
    required this.modeGroups,
    required this.modeTokens,
    required this.modes,
    required this.groupDescriptions,
    this.rootDescription,
  });
  final Map<String, List<TokenGroup>> modeGroups;
  final Map<String, List<DesignToken>> modeTokens;
  final List<String> modes;
  final Map<String, String> groupDescriptions;
  final String? rootDescription;
}
