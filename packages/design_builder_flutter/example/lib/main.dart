import 'package:flutter/material.dart';

import 'theme/app_theme.g.dart';

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
      title: 'Design Builder Demo',
      debugShowCheckedModeBanner: false,
      // Use themeData from notifier
      theme: AppThemeProvider.of(context).themeData,
      home: const MyHomePage(title: 'Design Builder Theme Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleTheme() {
    // Access the notifier via context extension or provider
    final notifier = context.themeNotifier;
    notifier.toggleMode();
  }

  @override
  Widget build(BuildContext context) {
    // Access theme via context.theme
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.canvas.primary,
      appBar: AppBar(
        backgroundColor: theme.colors.brand.primary,
        foregroundColor: theme.colors.foreground.inverse,
        title: Text(
          widget.title,
          style: theme.typography.title.regular.copyWith(
            color: theme.colors.foreground.inverse,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
              theme.colors.canvas.primary.computeLuminance() > 0.5
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: theme.colors.foreground.inverse,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(theme.sizes.padding.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Showcase
            Text('Typography', style: theme.typography.headline.medium),
            SizedBox(height: theme.sizes.spacing.md),
            Text('Display Large', style: theme.typography.display.regular),
            Text('Display Medium', style: theme.typography.display.medium),
            Text('Display Small', style: theme.typography.display.semiBold),
            SizedBox(height: theme.sizes.spacing.sm),
            Text('Headline Large', style: theme.typography.headline.regular),
            Text('Headline Medium', style: theme.typography.headline.medium),
            Text('Headline Small', style: theme.typography.headline.semiBold),
            SizedBox(height: theme.sizes.spacing.sm),
            Text('Title Large', style: theme.typography.title.regular),
            Text('Title Medium', style: theme.typography.title.medium),
            Text('Title Small', style: theme.typography.title.semiBold),
            SizedBox(height: theme.sizes.spacing.sm),
            Text('Body Large', style: theme.typography.body.regular),
            Text('Body Medium', style: theme.typography.body.medium),
            Text('Body Small', style: theme.typography.caption.regular),
            SizedBox(height: theme.sizes.spacing.sm),
            Text('Label Large', style: theme.typography.label.regular),
            Text('Label Medium', style: theme.typography.label.medium),
            Text('Label Small', style: theme.typography.label.semiBold),

            SizedBox(height: theme.sizes.spacing.xl),

            // Colors Showcase
            Text('Design Tokens', style: theme.typography.headline.medium),
            SizedBox(height: theme.sizes.spacing.md),

            // Color swatches
            _buildColorSwatch('Brand Primary', theme.colors.brand.primary),
            _buildColorSwatch('Brand Container', theme.colors.brand.container),
            _buildColorSwatch(
              'Foreground Primary',
              theme.colors.foreground.primary,
            ),
            _buildColorSwatch(
              'Foreground Subtle',
              theme.colors.foreground.subtle,
            ),
            _buildColorSwatch('Canvas Primary', theme.colors.canvas.primary),
            _buildColorSwatch('Surface Card', theme.colors.surface.card),
            _buildColorSwatch(
              'Action Filled',
              theme.colors.action.filledPrimary,
            ),
            _buildColorSwatch(
              'Feedback Success',
              theme.colors.feedback.success,
            ),
            _buildColorSwatch(
              'Feedback Warning',
              theme.colors.feedback.warning,
            ),
            _buildColorSwatch('Feedback Danger', theme.colors.feedback.danger),
            _buildColorSwatch('Feedback Info', theme.colors.feedback.info),

            SizedBox(height: theme.sizes.spacing.xl),

            // Spacing Showcase
            Text('Spacing Tokens', style: theme.typography.headline.medium),
            SizedBox(height: theme.sizes.spacing.md),
            _buildSpacingShowcase(theme),

            SizedBox(height: theme.sizes.spacing.xl),

            // Counter Section
            Card(
              color: theme.colors.surface.card,
              child: Padding(
                padding: EdgeInsets.all(theme.sizes.padding.md),
                child: Column(
                  children: [
                    Text(
                      'Counter Example',
                      style: theme.typography.title.medium,
                    ),
                    SizedBox(height: theme.sizes.spacing.sm),
                    Text(
                      '$_counter',
                      style: theme.typography.display.medium.copyWith(
                        color: theme.colors.brand.primary,
                      ),
                    ),
                    SizedBox(height: theme.sizes.spacing.md),
                    ElevatedButton.icon(
                      onPressed: _incrementCounter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colors.action.filledPrimary,
                        foregroundColor: theme.colors.foreground.inverse,
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.sizes.padding.md,
                          vertical: theme.sizes.padding.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            theme.sizes.radius.md,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Increment'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: theme.colors.brand.primary,
        foregroundColor: theme.colors.foreground.inverse,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.theme.typography.body.regular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                  style: context.theme.typography.body.regular.copyWith(
                    fontFamily: 'monospace',
                    color: context.theme.colors.foreground.subtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingShowcase(AppTheme theme) {
    final sizes = theme.sizes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpacingBar('Padding XS', sizes.padding.xs, Colors.blue),
        _buildSpacingBar('Padding SM', sizes.padding.sm, Colors.blue.shade400),
        _buildSpacingBar('Padding MD', sizes.padding.md, Colors.blue.shade600),
        _buildSpacingBar('Padding LG', sizes.padding.lg, Colors.blue.shade800),
        SizedBox(height: sizes.spacing.md),
        _buildSpacingBar('Spacing XS', sizes.spacing.xs, Colors.green),
        _buildSpacingBar('Spacing SM', sizes.spacing.sm, Colors.green.shade400),
        _buildSpacingBar('Spacing MD', sizes.spacing.md, Colors.green.shade600),
        _buildSpacingBar('Spacing LG', sizes.spacing.lg, Colors.green.shade800),
        SizedBox(height: sizes.spacing.md),
        _buildSpacingBar('Radius XS', sizes.radius.xs, Colors.orange),
        _buildSpacingBar('Radius SM', sizes.radius.sm, Colors.orange.shade400),
        _buildSpacingBar('Radius MD', sizes.radius.md, Colors.orange.shade600),
        _buildSpacingBar('Radius LG', sizes.radius.lg, Colors.orange.shade800),
      ],
    );
  }

  Widget _buildSpacingBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: value,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ${value.toStringAsFixed(0)}px',
            style: context.theme.typography.body.regular.copyWith(
              color: context.theme.colors.foreground.subtle,
            ),
          ),
        ],
      ),
    );
  }
}
