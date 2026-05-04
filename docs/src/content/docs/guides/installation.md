---
title: Installation
description: How to install Design Builder Flutter in your project.
---

Design Builder Flutter is a build runner tool that generates type-safe Flutter theme code from W3C Design Tokens.

## Requirements

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

## Installing via pub.dev

### 1. Add to pubspec.yaml

Add `design_builder` to your `dev_dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  design_builder: ^1.0.1
```

### 2. Install dependencies

Run the following command to install the package:

```bash
dart pub get
```

## Verifying Installation

After installation, verify that `design_builder` is available:

```bash
dart pub deps | grep design_builder
```

You should see output indicating the package is installed.

## Next Steps

Once installed, proceed to the [Quick Start Guide](/design_builder/guides/getting-started/) to configure and use Design Builder in your project.
