import 'package:flutter/material.dart';

import 'screens/root_tabs.dart';
import 'theme.dart';

void main() => runApp(const NextwatchApp());

class NextwatchApp extends StatelessWidget {
  const NextwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nextwatch',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const RootTabs(),
    );
  }
}
