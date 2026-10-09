import 'package:hive/hive.dart';

/// Local installation preferences, deliberately independent of financial data.
class TutorialProgress {
  TutorialProgress(this.box);
  final Box<dynamic> box;
  static const storageKey = 'tutoriales_v1';

  bool isPending(String group) => !states.containsKey(group);

  Map<String, String> get states {
    final stored = box.get(storageKey);
    if (stored is! Map) return {};
    return {
      for (final entry in stored.entries)
        if (entry.key is String &&
            (entry.value == 'completado' || entry.value == 'omitido'))
          entry.key as String: entry.value as String,
    };
  }

  Future<void> finish(String group, {required bool skipped}) async {
    await box.put(storageKey, {
      ...states,
      group: skipped ? 'omitido' : 'completado',
    });
  }

  Future<void> reset() => box.delete(storageKey);
}
