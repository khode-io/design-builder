---
title: Examples
description: Common usage examples for Design Builder Flutter.
---

This page provides practical examples of common Design Builder Flutter usage patterns.

## Basic Theme Setup

### Complete App Setup

```dart
import 'package:flutter/material.dart';
import 'package:my_app/design_tokens/app_theme.dart';

void main() {
  runApp(
    AppThemeProvider(
      notifier: AppThemeNotifier(initialMode: AppThemeMode.light),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomeScreen(),
    );
  }
}
```

## Widget Examples

### Styled Container

```dart
class StyledCard extends StatelessWidget {
  final Widget child;

  const StyledCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background.card,
        borderRadius: BorderRadius.circular(theme.dimensions.radius.medium),
        boxShadow: [
          BoxShadow(
            color: theme.colors.shadow.light,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(theme.dimensions.spacing.md),
      child: child,
    );
  }
}
```

### Typography Usage

```dart
class TypographyExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heading', style: theme.typography.heading.large),
        SizedBox(height: theme.dimensions.spacing.sm),
        Text('Body text', style: theme.typography.body.medium),
        Text('Caption', style: theme.typography.caption.small),
      ],
    );
  }
}
```

## Theme Switching

### Manual Theme Toggle

```dart
class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.brightness_6),
      onPressed: () {
        context.themeNotifier.toggleMode();
      },
    );
  }
}
```

### Theme Mode Display

```dart
class CurrentThemeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: context.themeNotifier,
      builder: (context, mode, child) {
        return Text('Current mode: ${mode.name}');
      },
    );
  }
}
```

## Advanced Patterns

### Responsive Spacing

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use different spacing based on screen size
    final horizontalPadding = screenWidth > 600 
      ? theme.dimensions.spacing.xl 
      : theme.dimensions.spacing.md;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: const Column(
        children: [
          // Your content here
        ],
      ),
    );
  }
}
```

### Dynamic Theme Overrides

```dart
class DynamicThemeExample extends StatefulWidget {
  @override
  State<DynamicThemeExample> createState() => _DynamicThemeExampleState();
}

class _DynamicThemeExampleState extends State<DynamicThemeExample> {
  @override
  void initState() {
    super.initState();
    _loadServerOverrides();
  }

  Future<void> _loadServerOverrides() async {
    // Fetch overrides from server
    final response = await http.get(Uri.parse('/api/theme-overrides'));
    final overrides = jsonDecode(response.body);
    
    if (mounted) {
      context.theme.applyOverrides(overrides);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dynamic Theme Example')),
    );
  }
}
```
