/* 
Description : EditState Notifier (수정 시 이미지 등록용)
Date : 2026-1-21
Author : 황민욱
*/


import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditState {
  final bool initialized;
  final List<String> existingUrls;
  final List<String> removedUrls;

  const EditState({
    this.initialized = false,
    this.existingUrls = const [],
    this.removedUrls = const [],
  });

  EditState copyWith({
    bool? initialized,
    List<String>? existingUrls,
    List<String>? removedUrls,
  }) {
    return EditState(
      initialized: initialized ?? this.initialized,
      existingUrls: existingUrls ?? this.existingUrls,
      removedUrls: removedUrls ?? this.removedUrls,
    );
  }
}

class EditNotifier extends Notifier<EditState> {
  @override
  EditState build() => const EditState();

  void initOnce(List<String> urls) {
    if (state.initialized) return;
    state = state.copyWith(
      initialized: true,
      existingUrls: List<String>.from(urls),
      removedUrls: const [],
    );
  }

  void removeExistingAt(int index) {
    final next = [...state.existingUrls];
    if (index < 0 || index >= next.length) return;

    final removed = next.removeAt(index);
    state = state.copyWith(
      existingUrls: next,
      removedUrls: [...state.removedUrls, removed],
    );
  }

  void clearRemoved() {
    state = state.copyWith(removedUrls: const []);
  }

  void reset() {
    state = const EditState();
  }
}

final editProvider = NotifierProvider.autoDispose.family<EditNotifier, EditState, String>(
  (arg) => EditNotifier(),
);