/* 
Description : ImageNotifier
Date : 2026-1-20
Author : 황민욱
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageState {
  final List<XFile> files;

  ImageState({this.files = const []});

  ImageState copyWith({List<XFile>? files}) => ImageState(files: files ?? this.files);
}

class ImageNotifier extends Notifier<ImageState> {
  final ImagePicker picker = ImagePicker();

  @override
  ImageState build() => ImageState();

  // 이미지 여러 장 업로드
  Future<void> pickImagesFromGallery() async {
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    state = state.copyWith(files: [...state.files, ...picked]);
  }

  // 이미지 한 장 업로드
  Future<void> pickSingleImageFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    state = state.copyWith(files: [picked]);
  }

  void removeAt(int index) {
    final list = [...state.files]..removeAt(index);
    state = state.copyWith(files: list);
  }

  void clear() {
    state = ImageState();
  }
}

final imageNotifierProvider = NotifierProvider<ImageNotifier, ImageState>(
  ImageNotifier.new,
);
