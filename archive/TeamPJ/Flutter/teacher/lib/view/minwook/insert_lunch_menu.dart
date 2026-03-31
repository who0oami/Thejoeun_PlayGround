/* 
Description : Insert LunchMenu Page (name + category + single image)
Date : 2026-1-22
Author : 황민욱
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/lunch_menu.dart';
import 'package:teacher/vm/minwook/lunch_provider.dart';
import 'package:teacher/vm/minwook/image_provider.dart';

final lunchMenuCategoryProvider = StateProvider<String>((ref) => '밥');

class InsertLunchMenu extends ConsumerStatefulWidget {
  const InsertLunchMenu({super.key});

  @override
  ConsumerState<InsertLunchMenu> createState() => _InsertLunchMenuState();
}

class _InsertLunchMenuState extends ConsumerState<InsertLunchMenu> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static const List<String> _categories = ['밥', '국', '반찬', '디저트', '기타'];

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(lunchMenuCategoryProvider);
    final imgState = ref.watch(imageNotifierProvider);

    final pickedFile = imgState.files.isEmpty ? null : File(imgState.files.first.path);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('메뉴 추가'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            _buildImagePicker(context, pickedFile),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(lunchMenuCategoryProvider.notifier).state = v;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '메뉴 이름',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: double.infinity),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('메뉴 이름은 필수임')),
                      );
                      return;
                    }

                    try {
                      final menu = LunchMenu(
                        lunch_menu_id: '',
                        lunch_menu_name: name,
                        lunch_menu_category: category,
                        lunch_menu_image: '', // imageFile 있으면 provider가 업로드 후 채움
                      );

                      await ref.read(lunchActionProvider.notifier).addMenuWithImage(
                            menu: menu,
                            imageFile: pickedFile,
                          );

                      ref.read(imageNotifierProvider.notifier).clear();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메뉴 추가됨')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('추가 실패: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('추가'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, File? pickedFile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '이미지(선택)',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  image: pickedFile == null
                      ? null
                      : DecorationImage(image: FileImage(pickedFile), fit: BoxFit.cover),
                ),
                child: pickedFile == null
                    ? Center(
                        child: Text(
                          '이미지 없음',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(imageNotifierProvider.notifier).pickSingleImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리'),
                  ),
                ),
                if (pickedFile != null) ...[
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(imageNotifierProvider.notifier).clear();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('삭제'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
