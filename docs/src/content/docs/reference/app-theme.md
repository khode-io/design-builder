---
title: AppTheme API
description: API reference for the generated AppTheme classes.
---

The `AppTheme` API provides access to your generated theme tokens in Flutter widgets.

## AppThemeProvider

A widget that provides theme access to the widget tree.

### Constructor

```dart
AppThemeProvider({
  required AppThemeNotifier notifier,
  required Widget child,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `notifier` | `AppThemeNotifier` | Manages theme mode state |
| `child` | `Widget` | Child widget to render |

### Usage

```dart
void main() {
  runApp(
    AppThemeProvider(
      notifier: AppThemeNotifier(initialMode: AppThemeMode.light),
      child: MyApp(),
    ),
  );
}
```

## AppThemeNotifier

Manages the current theme mode and notifies listeners of changes.

### Constructor

```dart
AppThemeNotifier({
  required AppThemeMode initialMode,
})
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `setMode(AppThemeMode mode)` | `void` | Switches to the specified theme mode |
| `toggleMode()` | `void` | Toggles between light and dark modes |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentMode` | `AppThemeMode` | The currently active theme mode |
| `currentTheme` | `AppTheme` | The theme data for the current mode |

## AppThemeMode

Enumeration of available theme modes.

```dart
enum AppThemeMode {
  light,
  dark,
}
```

## AppTheme

The main generated theme class containing all your tokens.

### Accessing Theme Data

Use the extension method on `BuildContext`:

```dart
final theme = context.theme;
```

### Properties

The available properties depend on your token structure. Common categories include:

| Property | Type | Description |
|----------|------|-------------|
| `colors` | `AppThemeColors` | Color tokens |
| `typography` | `AppThemeTypography` | Text style tokens |
| `dimensions` | `AppThemeDimensions` | Spacing and sizing tokens |

### Example

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Container(
      color: theme.colors.brand.primary,
      padding: EdgeInsets.all(theme.dimensions.spacing.md),
      child: Text(
        'Hello World',
        style: theme.typography.heading.large,
      ),
    );
  }
}
```

## Runtime Overrides

Apply server-side token overrides dynamically.

### Methods

| Method | Description |
|--------|-------------|
| `applyOverrides(Map<String, dynamic> overrides)` | Apply token overrides at runtime |
| `clearOverrides()` | Remove all applied overrides |

### Example

```dart
// Apply overrides from server response
context.theme.applyOverrides({
  'colors.brand.primary': '#FF0000',
});
```
