import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'pyq_bookmarks_v1';

class _BookmarkNotifier extends StateNotifier<Set<String>> {
  _BookmarkNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? [];
    state = Set<String>.from(list);
  }

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kKey, next.toList());
  }

  bool isBookmarked(String id) => state.contains(id);
}

final bookmarkProvider =
    StateNotifierProvider<_BookmarkNotifier, Set<String>>(
        (_) => _BookmarkNotifier());
