// مفضّلة المقامات. مخزّنة بالقرص لا بالذاكرة: قلبٌ ينسى اختياره عند إعادة
// التشغيل ميزةٌ ناقصة لا ميزة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/bootstrap.dart';

const String _kKey = 'maqam_favorites';

class MaqamFavoritesNotifier extends StateNotifier<Set<int>> {
  MaqamFavoritesNotifier()
      : super({
          for (final s in sharedPrefs.getStringList(_kKey) ?? const <String>[])
            if (int.tryParse(s) != null) int.parse(s),
        });

  bool contains(int id) => state.contains(id);

  Future<void> toggle(int id) async {
    final next = {...state};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
    await sharedPrefs.setStringList(
      _kKey,
      [for (final id in next) '$id'],
    );
  }
}

final maqamFavoritesProvider =
    StateNotifierProvider<MaqamFavoritesNotifier, Set<int>>(
  (ref) => MaqamFavoritesNotifier(),
);
