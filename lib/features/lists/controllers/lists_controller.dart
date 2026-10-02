import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_block_list.dart';

class ListsState {
  final List<AppBlockList> lists;
  final String activeListId;
  final bool isLoading;
  final String? errorMessage;

  const ListsState({
    this.lists = const [],
    this.activeListId = '',
    this.isLoading = false,
    this.errorMessage,
  });

  AppBlockList? get activeList {
    if (lists.isEmpty) return null;
    return lists.firstWhere(
      (l) => l.id == activeListId,
      orElse: () => lists.first,
    );
  }

  ListsState copyWith({
    List<AppBlockList>? lists,
    String? activeListId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ListsState(
      lists: lists ?? this.lists,
      activeListId: activeListId ?? this.activeListId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ListsController extends StateNotifier<ListsState> {
  static const String _storageKeyLists = 'saved_block_lists_v2';
  static const String _storageKeyActiveId = 'active_block_list_id_v2';
  static const Uuid _uuid = Uuid();

  Future<void>? _loadFuture;

  ListsController() : super(const ListsState(isLoading: true)) {
    loadLists();
  }

  Future<void> loadLists() {
    return _loadFuture ??= _loadListsInternal();
  }

  Future<void> _loadListsInternal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear any legacy placeholder lists from previous runs
      await prefs.remove('saved_block_lists_v1');
      await prefs.remove('active_block_list_id_v1');

      final jsonString = prefs.getString(_storageKeyLists);
      final savedActiveId = prefs.getString(_storageKeyActiveId);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        final loaded = decoded
            .map((e) => AppBlockList.fromJson(e as Map<String, dynamic>))
            .where((l) => !l.id.startsWith('seed-') && !l.isDefault)
            .toList();

        if (loaded.isNotEmpty) {
          final activeId = (savedActiveId != null &&
                  loaded.any((l) => l.id == savedActiveId))
              ? savedActiveId
              : loaded.first.id;

          state = state.copyWith(
            lists: loaded,
            activeListId: activeId,
            isLoading: false,
            clearError: true,
          );
          return;
        }
      }

      // First boot: completely empty lists - users set them up first
      state = state.copyWith(
        lists: const [],
        activeListId: '',
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        lists: const [],
        activeListId: '',
        isLoading: false,
        clearError: true,
      );
    }
  }

  /// Sets the active block list.
  /// Strictly rejected if timer is active.
  bool setActiveList(String listId, {required bool isTimerActive}) {
    if (isTimerActive) {
      state = state.copyWith(
        errorMessage: 'Lists cannot be changed while the timer is active.',
      );
      return false;
    }

    if (!state.lists.any((l) => l.id == listId)) {
      return false;
    }

    state = state.copyWith(
      activeListId: listId,
      clearError: true,
    );
    _persistActiveId(listId);
    return true;
  }

  /// Creates a new block list.
  /// Strictly rejected if timer is active.
  bool createList({
    required String name,
    required List<String> appNames,
    required bool isTimerActive,
  }) {
    if (isTimerActive) {
      state = state.copyWith(
        errorMessage: 'Lists cannot be created or edited while the timer is active.',
      );
      return false;
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(
        errorMessage: 'List name cannot be empty.',
      );
      return false;
    }

    final newList = AppBlockList(
      id: _uuid.v4(),
      name: trimmedName,
      appNames: List.unmodifiable(appNames.toSet().toList()),
      createdAt: DateTime.now(),
      isDefault: false,
    );

    final updated = [...state.lists, newList];
    state = state.copyWith(
      lists: updated,
      activeListId: newList.id,
      clearError: true,
    );

    _persistToPrefs(updated, newList.id);
    return true;
  }

  /// Updates an existing block list.
  /// Strictly rejected if timer is active.
  bool updateList(AppBlockList updatedList, {required bool isTimerActive}) {
    if (isTimerActive) {
      state = state.copyWith(
        errorMessage: 'Lists cannot be edited while the timer is active.',
      );
      return false;
    }

    final trimmedName = updatedList.name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(
        errorMessage: 'List name cannot be empty.',
      );
      return false;
    }

    final sanitized = updatedList.copyWith(
      name: trimmedName,
      appNames: List.unmodifiable(updatedList.appNames.toSet().toList()),
    );

    final updated = state.lists.map((l) {
      if (l.id == sanitized.id) {
        return sanitized;
      }
      return l;
    }).toList();

    state = state.copyWith(
      lists: updated,
      clearError: true,
    );

    _persistToPrefs(updated, state.activeListId);
    return true;
  }

  /// Deletes a block list.
  /// Strictly rejected if timer is active.
  bool deleteList(String listId, {required bool isTimerActive}) {
    if (isTimerActive) {
      state = state.copyWith(
        errorMessage: 'Lists cannot be deleted while the timer is active.',
      );
      return false;
    }

    if (state.lists.isEmpty) {
      return false;
    }

    final updated = state.lists.where((l) => l.id != listId).toList();
    var nextActiveId = state.activeListId;
    if (nextActiveId == listId) {
      nextActiveId = updated.isNotEmpty ? updated.first.id : '';
    }

    state = state.copyWith(
      lists: updated,
      activeListId: nextActiveId,
      clearError: true,
    );

    _persistToPrefs(updated, nextActiveId);
    return true;
  }

  void clearErrorMessage() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _persistToPrefs(List<AppBlockList> lists, String activeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(lists.map((l) => l.toJson()).toList());
      await prefs.setString(_storageKeyLists, jsonString);
      await prefs.setString(_storageKeyActiveId, activeId);
    } catch (_) {}
  }

  Future<void> _persistActiveId(String activeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKeyActiveId, activeId);
    } catch (_) {}
  }
}

final listsControllerProvider =
    StateNotifierProvider<ListsController, ListsState>((ref) {
  return ListsController();
});
