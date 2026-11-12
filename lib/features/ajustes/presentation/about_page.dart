import 'package:control_financiero/core/constants/app_strings.dart'
    as app_strings;
import 'package:control_financiero/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:control_financiero/features/actualizaciones/update_dialog.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre la aplicación')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Image.asset(
                  'assets/icons/app_prod_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              app_strings.appName,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión ${app_strings.appVersion}',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (supportsAppUpdates) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => showUpdateDialog(context),
                icon: const Icon(Icons.system_update),
                label: const Text('Buscar actualizaciones'),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '© ${currentDateTime.year} Alejo\nDesarrollado con ❤️ usando Flutter',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
