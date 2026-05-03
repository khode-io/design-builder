#!/usr/bin/env dart

import 'dart:io';

/// Quick theme generation script for design_builder_flutter.
///
/// Usage: dart run generate_theme.dart
///
/// Runs build_runner with common options and proper error handling.

void main(List<String> args) async {
  print('🏗️  Generating theme code with build_runner...\n');

  // Determine which command to run
  final deleteConflicting = args.contains('--delete-conflicting') || args.contains('-d');
  final watch = args.contains('--watch') || args.contains('-w');

  final executable = 'dart';
  final arguments = <String>[
    'run',
    'build_runner',
    if (watch) 'watch' else 'build',
    if (deleteConflicting || !watch) '--delete-conflicting-outputs',
  ];

  print('Running: $executable ${arguments.join(' ')}\n');

  // Run build_runner
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;

  if (exitCode == 0) {
    print('\n✅ Theme code generated successfully!');
    print('');
    print('Next steps:');
    print('  1. Import the generated theme in your Dart files');
    print('  2. Wrap your app with AppThemeProvider');
    print('  3. Access theme values via context.theme');
  } else {
    print('\n❌ Theme generation failed with exit code: $exitCode');
    print('');
    print('Troubleshooting:');
    print('  - Ensure build.yaml is configured correctly');
    print('  - Check that your token files are valid JSON');
    print('  - Verify the schema path in build.yaml exists');
    print('  - Run with --delete-conflicting if you have stale outputs');
  }

  exit(exitCode);
}
