import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:control_financiero/core/constants/app_strings.dart';
import 'package:control_financiero/core/theme/app_theme.dart';
import 'app_state.dart';
import 'app_scaffold.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: AppTheme.light,
        home: const AppScaffold(),
      ),
    );
  }
}