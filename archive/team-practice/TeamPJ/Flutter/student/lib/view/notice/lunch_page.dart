/* 
Description : homework page 
Date : 2026-1-21
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:student/model/lunch_menu.dart';
import 'package:student/vm/sion/meal_riverpod.dart';

/// ✅ 선택 날짜(오늘 기준 offset: -1이면 어제, +1이면 내일)
final lunchDayOffsetProvider = StateProvider<int>((ref) => 0);

/// ✅ 이전 급식 캐시(끊김 완화)
final lastLunchCacheProvider =
    StateProvider<Map<String, List<LunchMenu>>?>((ref) => null);

class LunchPage extends ConsumerStatefulWidget {
  const LunchPage({super.key});

  @override
  ConsumerState<LunchPage> createState() => _LunchState();
}

class _LunchState extends ConsumerState<LunchPage> {
  @override
  Widget build(BuildContext context) {
    // 기존 코드 유지(현재 사용 안 해도 무방)
    final lunchtimeAsync = ref.watch(lunchMenuListProvider);

    // ✅ 일수(offset)로 날짜 변경
    final offset = ref.watch(lunchDayOffsetProvider);
    final selectedDate = DateTime.now().add(Duration(days: offset));

    // ✅ 조회 키
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    // ✅ 헤더에 보여줄 날짜 텍스트 (예: 1월 21일 (수))
    final headerDateText = DateFormat('M월 d일 (E)', 'ko_KR').format(selectedDate);

    // ✅ 날짜별 급식 조회
    final lunchAsync = ref.watch(lunchByDateProvider(dateKey));

    // ✅ 캐시
    final cached = ref.watch(lastLunchCacheProvider);

    // ✅ 새 데이터 오면 캐시에 저장
    ref.listen<AsyncValue<Map<String, List<LunchMenu>>>>(
      lunchByDateProvider(dateKey),
      (prev, next) {
        next.whenData((data) {
          ref.read(lastLunchCacheProvider.notifier).state = data;
        });
      },
    );

    // ✅ 표시할 데이터(우선순위: 현재값 > 캐시 > 빈값)
    final display = lunchAsync.value ?? cached ?? <String, List<LunchMenu>>{};

    // ✅ 카테고리 순서대로 합쳐서 Grid에 뿌릴 리스트 생성
    const order = ['밥', '국', '반찬', '기타', '디저트'];
    final lunchList = <LunchMenu>[];

    for (final k in order) {
      if (display.containsKey(k)) lunchList.addAll(display[k]!);
    }
    display.forEach((k, v) {
      if (!order.contains(k)) lunchList.addAll(v);
    });

    // ✅ 캐시가 있는데 새 요청 로딩 중이면 상단 얇은 로딩바만
    final showTopLoadingBar =
        lunchAsync.isLoading && cached != null && lunchAsync.value == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: Row(
              children: [
                const Text(
                  "이번주 급식",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 15),

                // ✅ 날짜 표시(기존 자리 유지) + 일수 변경 버튼만 추가
                Expanded(
                  child: Row(
                    children: [
                      // 이전날
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18,
                        onPressed: () {
                          ref.read(lunchDayOffsetProvider.notifier).state--;
                        },
                        icon: Icon(Icons.chevron_left, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 6),

                      Text(
                        headerDateText,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),

                      const SizedBox(width: 6),
                      // 다음날
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18,
                        onPressed: () {
                          ref.read(lunchDayOffsetProvider.notifier).state++;
                        },
                        icon: Icon(Icons.chevron_right, color: Colors.grey.shade500),
                      ),

                      const Spacer(),

                      // 오늘로 돌아가기(선택: 있으면 편해서 넣음. 원치 않으면 빼도 됨)
                      if (offset != 0)
                        TextButton(
                          onPressed: () {
                            ref.read(lunchDayOffsetProvider.notifier).state = 0;
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "오늘",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 급식 리스트 (Grid 형태) - 디자인 유지
          Expanded(
            child: Stack(
              children: [
                // ✅ 캐시가 없고 로딩이면 기존처럼 로딩 인디케이터
                if (lunchAsync.isLoading && cached == null)
                  const Center(child: CircularProgressIndicator())
                else if (lunchList.isEmpty)
                  const Center(child: Text('등록된 식단이 없습니다.'))
                else
                  GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: lunchList.length,
                    itemBuilder: (context, index) {
                      final menu = lunchList[index];
                      return _buildLunchItem(
                        menu.lunch_menu_name,
                        menu.lunch_menu_image,
                      );
                    },
                  ),

                if (showTopLoadingBar)
                  const Positioned(
                    left: 20,
                    right: 20,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),

                // ✅ 에러는 기존처럼 텍스트 표시
                if (lunchAsync.hasError)
                  Positioned.fill(
                    child: Center(
                      child: Text('Error: ${lunchAsync.error}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 개별 급식 아이템 위젯 (시안 디자인 구현) - ✅ 그대로 유지
  Widget _buildLunchItem(String name, String imageUrl) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F), // 시안의 노란색 배경
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037), // 시안의 갈색 텍스트 컬러 느낌
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
