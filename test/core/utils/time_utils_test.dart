import 'package:control_financiero/core/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('horas respetan 12/24 horas incluso con es_EC', (tester) async {
    Future<void> showTimes(bool use24Hours) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'EC'),
          supportedLocales: const [Locale('es', 'EC')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: MediaQuery(
            data: MediaQueryData(alwaysUse24HourFormat: use24Hours),
            child: Builder(
              builder: (context) => Column(
                children: [
                  for (final hour in [0, 12, 14, 23])
                    Text(
                      formatDeviceTime(
                        context,
                        TimeOfDay(hour: hour, minute: 5),
                      ),
                    ),
                  Text(
                    formatTimeFromDateTime(
                      context,
                      DateTime(2026, 10, 12, 14, 5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await showTimes(false);
    expect(find.text('12:05 AM'), findsOneWidget);
    expect(find.text('12:05 PM'), findsOneWidget);
    expect(find.text('2:05 PM'), findsNWidgets(2));
    expect(find.text('11:05 PM'), findsOneWidget);

    await showTimes(true);
    expect(find.text('00:05'), findsOneWidget);
    expect(find.text('12:05'), findsOneWidget);
    expect(find.text('14:05'), findsNWidgets(2));
    expect(find.text('23:05'), findsOneWidget);
    expect(find.text('2:05 PM'), findsNothing);
  });
}
