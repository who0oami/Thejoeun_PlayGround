/* 
Description : Lunch Insert Page (Monthly Grid + Detail + Category Menu Pick)
Date : 2026-1-22
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/lunch.dart';
import 'package:teacher/model/lunch_menu.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/lunch_provider.dart';
import 'package:teacher/view/minwook/insert_lunch_menu.dart';

// ======================= Providers =======================
final lunchFocusedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final lunchSelectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final _tempSelectedMenuIdsProvider =
    StateProvider.autoDispose<List<String>?>((ref) => null);

// Util
DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

String _yyyyMmDd(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

int _daysInMonth(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final next = DateTime(first.year, first.month + 1, 1);
  return next.subtract(const Duration(days: 1)).day;
}

// month cells (월~금)
List<DateTime?> _buildMonthCellsMonFri(DateTime month) {
  final totalDays = _daysInMonth(month);
  final first = DateTime(month.year, month.month, 1);
  final firstDow = first.weekday - 1; // Mon=0..Sun=6
  final cells = <DateTime?>[];

  final leadingNulls = (firstDow <= 4) ? firstDow : 5;
  for (int i = 0; i < leadingNulls; i++) {
    cells.add(null);
  }

  for (int day = 1; day <= totalDays; day++) {
    final d = DateTime(month.year, month.month, day);
    final dow = d.weekday - 1;
    if (dow <= 4) cells.add(d);
  }

  while (cells.length % 5 != 0) {
    cells.add(null);
  }

  return cells;
}

// 데이터 리스트
const List<String> _dow = ['월', '화', '수', '목', '금'];
const List<String> _categories = ['밥', '국', '반찬', '디저트', '기타'];
const List<String> _previewOrder = ['기타', '밥', '국', '반찬', '디저트'];

// InsertLunch
class InsertLunch extends ConsumerWidget {
  const InsertLunch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMonth = ref.watch(lunchFocusedMonthProvider);
    final selectedDay = ref.watch(lunchSelectedDayProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('급식'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsertLunchMenu()),
              );
            },
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
      drawer: AppDrawer(currentPage: this),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildMonthHeader(ref, focusedMonth),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        for (final d in _dow)
                          Expanded(
                            child: Container(
                              height: 22,
                              alignment: Alignment.center,
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildMonthGrid(
                  context: context,
                  ref: ref,
                  month: focusedMonth,
                  selectedDay: selectedDay,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  Widget _buildMonthHeader(WidgetRef ref, DateTime month) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            final prev = DateTime(month.year, month.month - 1, 1);
            ref.read(lunchFocusedMonthProvider.notifier).state = prev;
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              '${month.year}.${month.month.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final next = DateTime(month.year, month.month + 1, 1);
            ref.read(lunchFocusedMonthProvider.notifier).state = next;
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  } // _buildMonthHeader

  String _cellMenuPreview({
    required Lunch? lunch,
    required Map<String, LunchMenu> menuById,
  }) {
    if (lunch == null) return '';

    final lines = <String>[];

    for (final c in _previewOrder) {
      final ids = lunch.lunch_contents[c] ?? const <String>[];
      if (ids.isEmpty) continue;

      final names = <String>[];
      for (final id in ids) {
        final m = menuById[id];
        if (m == null) continue;
        final name = m.lunch_menu_name.trim();
        if (name.isEmpty) continue;
        names.add(name);
      }

      if (names.isEmpty) continue;
      lines.add(names.join('\n'));
    }
    return lines.join('\n');
  } //  _cellMenuPreview

  Widget _buildMonthGrid({
    required BuildContext context,
    required WidgetRef ref,
    required DateTime month,
    required DateTime selectedDay,
  }) {
    final menuAsync = ref.watch(lunchMenuListProvider);

    return menuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (menus) {
        final menuById = {for (final m in menus) m.lunch_menu_id: m};
        final monthCells = _buildMonthCellsMonFri(month);

        final dayCells = <Widget>[
          for (final date in monthCells)
            if (date == null)
              const SizedBox.shrink()
            else
              _DayCell(
                date: date,
                selectedDay: selectedDay,
                onOpen: () async {
                  ref.read(lunchSelectedDayProvider.notifier).state = _onlyDate(date);
                  await _openLunchDetailSheet(context, ref, _onlyDate(date));
                },
                previewBuilder: (lunch) => _cellMenuPreview(lunch: lunch, menuById: menuById),
              ),
        ];

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(8),
              child: GridView.count(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.62,
                children: dayCells,
              ),
            ),
          ),
        );
      },
    );
  } // _buildMonthGrid

  Future<void> _openLunchDetailSheet(BuildContext context, WidgetRef ref, DateTime day) async {
    await ref.read(lunchActionProvider.notifier).ensureLunch(day);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _LunchDetailSheet(day: day),
    );
  } // _openLunchDetailSheet
} // class InsertLunch

// ======================= Day Cell =======================
class _DayCell extends ConsumerWidget {
  final DateTime date;
  final DateTime selectedDay;
  final Future<void> Function() onOpen;
  final String Function(Lunch? lunch) previewBuilder;

  const _DayCell({
    required this.date,
    required this.selectedDay,
    required this.onOpen,
    required this.previewBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = _onlyDate(date) == _onlyDate(selectedDay);
    final lunchAsync = ref.watch(lunchByDateProvider(date));

    return InkWell(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.12) : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isSelected ? Colors.green.shade800 : Colors.black87,
              ),
            ),
            lunchAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 6),
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.error_outline, size: 14),
              ),
              data: (lunch) {
                final preview = previewBuilder(lunch);

                if (preview.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '비어있음',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SingleChildScrollView(
                        primary: false,
                        child: Text(
                          preview,
                          style: const TextStyle(
                            fontSize: 12.8,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  } // build
} // class _DayCell

// ======================= Detail Sheet =======================
class _LunchDetailSheet extends ConsumerWidget {
  final DateTime day;
  const _LunchDetailSheet({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lunchAsync = ref.watch(lunchByDateProvider(day));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: lunchAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(child: Text('Error: $e')),
        ),
        data: (lunch) {
          if (lunch == null) {
            return const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: Text('급식표 데이터가 없음')),
            );
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _yyyyMmDd(day),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildCategoryList(context, ref, lunch),
                ),
              ],
            ),
          );
        },
      ),
    );
  } // build

  Widget _buildCategoryList(BuildContext context, WidgetRef ref, Lunch lunch) {
    final menuAsync = ref.watch(lunchMenuListProvider);

    return menuAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (menus) {
        final byId = {for (final m in menus) m.lunch_menu_id: m};

        return Column(
          children: [
            for (final c in _categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              await _openCategoryPickSheet(context, ref, lunch, c);
                            },
                            child: const Text('메뉴 선택'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _selectedMenuChips(
                          menuIds: lunch.lunch_contents[c] ?? const <String>[],
                          byId: byId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  } // _buildCategoryList

  Widget _selectedMenuChips({
    required List<String> menuIds,
    required Map<String, LunchMenu> byId,
  }) {
    if (menuIds.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text('선택된 메뉴 없음', style: TextStyle(color: Colors.grey.shade400)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in menuIds)
          Builder(builder: (_) {
            final m = byId[id];
            final name = m?.lunch_menu_name ?? '(삭제된 메뉴)';
            final img = m?.lunch_menu_image ?? '';

            return Chip(
              avatar: img.isEmpty
                  ? const Icon(Icons.fastfood, size: 18)
                  : CircleAvatar(backgroundImage: NetworkImage(img)),
              label: Text(name),
            );
          }),
      ],
    );
  } // _selectedMenuChips

  Future<void> _openCategoryPickSheet(
    BuildContext context,
    WidgetRef ref,
    Lunch lunch,
    String category,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _CategoryMenuPickSheet(
        day: lunch.lunch_date,
        category: category,
        initiallySelectedIds: List<String>.from(lunch.lunch_contents[category] ?? const <String>[]),
      ),
    );
  } // _openCategoryPickSheet
} // class _LunchDetailSheet

// ======================= Category Pick Sheet =======================
class _CategoryMenuPickSheet extends ConsumerWidget {
  final DateTime day;
  final String category;
  final List<String> initiallySelectedIds;

  const _CategoryMenuPickSheet({
    required this.day,
    required this.category,
    required this.initiallySelectedIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIdsNullable = ref.watch(_tempSelectedMenuIdsProvider);
    final selectedIds = selectedIdsNullable ?? const <String>[];

    if (selectedIdsNullable == null) {
      Future(() {
        ref.read(_tempSelectedMenuIdsProvider.notifier).state =
            List<String>.from(initiallySelectedIds);
      });
    }

    final menuAsync = ref.watch(lunchMenuByCategoryProvider(category));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$category 메뉴 선택',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(_tempSelectedMenuIdsProvider.notifier).state = <String>[];
                },
                child: const Text('전체 해제'),
              ),

              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InsertLunchMenu()),
                  );
                },
                child: const Text('새 메뉴 추가'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: menuAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (menus) {
                if (menus.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(child: Text('해당 카테고리 메뉴가 없음')),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: menus.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final m = menus[i];
                      final checked = selectedIds.contains(m.lunch_menu_id);

                      return ListTile(
                        leading: m.lunch_menu_image.isEmpty
                            ? const CircleAvatar(child: Icon(Icons.fastfood))
                            : CircleAvatar(backgroundImage: NetworkImage(m.lunch_menu_image)),
                        title: Text(m.lunch_menu_name),
                        trailing: Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked),
                        onTap: () {
                          final next = [...selectedIds];
                          if (checked) {
                            next.remove(m.lunch_menu_id);
                          } else {
                            next.add(m.lunch_menu_id);
                          }
                          ref.read(_tempSelectedMenuIdsProvider.notifier).state = next;
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(lunchActionProvider.notifier).setCategoryMenus(
                              day: day,
                              category: category,
                              menuIds: selectedIds,
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('저장'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } // build
} // class _CategoryMenuPickSheet
