/* 
Description : 선생님 채팅 페이지 구성 및 개선
  - 문의 목록 UI 재구성 및 새로고침 동작 정리
  - 채팅 상세 화면 스타일/입력바 개선
  - 하단 스크롤 고정 및 최신 메시지 표시 흐름 조정
  - Firebase 채팅 데이터 스트림 연동
Date : 2026-1-22
Author : 이상현
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teacher/app_keys.dart';
import 'package:teacher/vm/sanghyun/chatting_provider.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/util/message.dart';

// --- [Providers] ---

String _readableText(dynamic value, String fallback) {
  final String s = (value ?? '').toString().trim();
  return s.isEmpty ? fallback : s;
}

// 1. MySQL 가디언/학생/카테고리 목록 로더
final chatTargetProvider = FutureProvider<List<dynamic>>((ref) async {
  final String host = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  final String url = 'http://$host:8000/sanghyun/chat_list';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('MySQL 서버 연결 확인 필요: $e');
  }
});

// 1-1. 카테고리 목록 로더 (MySQL)
final categoryProvider = FutureProvider<Map<int, String>>((ref) async {
  final String host = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  final String url = 'http://$host:8000/sanghyun/categories';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    final Map<int, String> map = {};
    for (final item in data) {
      final id = item['category_id'];
      final title = item['category_title'];
      if (id is int && title is String) {
        map[id] = title;
      } else if (id != null && title != null) {
        map[int.parse(id.toString())] = title.toString();
      }
    }
    return map;
  } catch (e) {
    throw Exception('카테고리 로드 실패: $e');
  }
});

// 2-1. guardian_id 기준 최신 채팅의 category_id 로더 (Firebase)
final latestCategoryIdProvider = StreamProvider.family<int?, int>((ref, guardianId) {
  final col = ref.watch(chattingCollectionProvider);
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: true)
      .limit(1)
      .snapshots()
      .map((snap) {
        if (snap.docs.isEmpty) return null;
        final data = snap.docs.first.data() as Map<String, dynamic>;
        final id = data['category_id'];
        if (id is int) return id;
        if (id == null) return null;
        return int.tryParse(id.toString());
      });
});

// 3. 현재 선택된 문의 대상 정보
final selectedInquiryProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// 4. 실시간 채팅 스트림 (Firebase)
final chatStreamProvider = StreamProvider.autoDispose((ref) {
  final inquiry = ref.watch(selectedInquiryProvider);
  if (inquiry == null) return Stream.value([]);
  
  final col = ref.watch(chattingCollectionProvider);
  final int? guardianId = int.tryParse(inquiry['guardian_id'].toString());
  if (guardianId == null) return Stream.value([]);
  
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            DateTime date = (d['chatting_date'] is Timestamp) 
                ? (d['chatting_date'] as Timestamp).toDate() 
                : DateTime.now();
            final String contents =
                (d['chatting_contents'] ?? d['chatting_content'] ?? '').toString();
            final String imageUrl = (d['chatting_image'] ?? '').toString();
            return {
              'docId': doc.id,
              'contents': contents,
              'imageUrl': imageUrl,
              'isTeacher': d['teacher_id'] != null,
              'date': date,
            };
          }).toList());
});

// --- [Main View] ---

final Color _kTeacherMuted =
    Acolor.appBarBackgroundColor.withOpacity(0.55);

class TeacherChatting extends ConsumerWidget {
  const TeacherChatting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Acolor.baseBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(width: 360, child: _buildSidebar(ref)),
              const SizedBox(width: 16),
              const Expanded(child: _ChatDetailView()),
            ],
          ),
        ),
      ),
    );
  }

  // 문의 목록 사이드바 UI.
  Widget _buildSidebar(WidgetRef ref) {
    final listAsync = ref.watch(chatTargetProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final selectedInquiry = ref.watch(selectedInquiryProvider);

    return Container(
      decoration: BoxDecoration(
        color: Acolor.onPrimaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Acolor.appBarBackgroundColor.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Acolor.onPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Acolor.secondaryBackgroundColor),
                  ),
                  child: Icon(Icons.forum, color: Acolor.appBarBackgroundColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '문의 내역',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        color: Acolor.appBarBackgroundColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '최근 문의를 빠르게 확인하세요',
                        style: TextStyle(fontSize: 12, color: _kTeacherMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                  color: Acolor.onPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Acolor.secondaryBackgroundColor),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ref.invalidate(chatTargetProvider);
                      ref.invalidate(categoryProvider);
                      ref.invalidate(selectedInquiryProvider);
                      ref.invalidate(chatStreamProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: '새로고침',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              data: (items) => categoriesAsync.when(
                data: (categoryMap) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    final bool isSelected =
                        selectedInquiry?['guardian_id'] == item['guardian_id'];
                    final int? guardianId =
                        int.tryParse(item['guardian_id'].toString());
                    final String studentName = _readableText(
                      item['student_name'] ?? item['guardian_name'],
                      '이름 없음',
                    );
                    final categoryIdAsync = guardianId == null
                        ? const AsyncValue<int?>.data(null)
                        : ref.watch(latestCategoryIdProvider(guardianId));
                    Uint8List? img;
                    if (item['student_image'] != null) {
                      img = base64Decode(item['student_image']);
                    }

                    return InkWell(
                      onTap: () => ref
                          .read(selectedInquiryProvider.notifier)
                          .state = item,
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Acolor.onPrimaryColor
                              : Acolor.baseBackgroundColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Acolor.primaryColor
                                : Acolor.secondaryBackgroundColor,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Acolor.appBarBackgroundColor
                                        .withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: img != null ? MemoryImage(img) : null,
                              backgroundColor: Acolor.secondaryBackgroundColor,
                              child: img == null
                                  ? Icon(Icons.person,
                                      color: Acolor.appBarBackgroundColor)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$studentName 학부모님',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Acolor.appBarBackgroundColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  categoryIdAsync.when(
                                    data: (categoryId) {
                                      final String categoryTitle = _readableText(
                                        categoryId == null
                                            ? null
                                            : categoryMap[categoryId],
                                        '제목 없음',
                                      );
                                      return Text(
                                        '문의 · $categoryTitle',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _kTeacherMuted,
                                        ),
                                      );
                                    },
                                    loading: () => Text(
                                      '문의 · 불러오는 중...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _kTeacherMuted,
                                      ),
                                    ),
                                    error: (e, s) => Text(
                                      '문의 · 제목 없음',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _kTeacherMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: _kTeacherMuted),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('카테고리 로드 실패: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('데이터 로드 실패: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatDetailView extends ConsumerStatefulWidget {
  const _ChatDetailView();
  @override
  ConsumerState<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends ConsumerState<_ChatDetailView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxSendAttempts = 3;
  int? _lastGuardianId;
  bool _didInitialScroll = false;
  bool _wasCurrentRoute = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  // 전역 스낵바 표시.
  void _showSnack(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 텍스트 메시지 전송.
  void _send() async {
    final inquiry = ref.read(selectedInquiryProvider);
    final text = _textController.text.trim();
    if (inquiry == null) {
      debugPrint("⚠️ 전송 실패: 문의 대상이 선택되지 않았습니다.");
      _showSnack('전송 실패: 문의 대상을 선택해주세요.');
      return;
    }
    if (text.isEmpty) {
      debugPrint("⚠️ 전송 실패: 메시지가 비어 있습니다.");
      _showSnack('전송 실패: 메시지를 입력해주세요.');
      return;
    }

    // 1. 전송 누르면 즉시 텍스트 필드 비우기
    _textController.clear();
    final col = ref.read(chattingCollectionProvider);

    try {
      debugPrint("➡️ 전송 시도: guardian_id=${inquiry['guardian_id']}, student_id=${inquiry['student_id']}");
      _showSnack('전송 중...');
      await _retrySend(col: col, inquiry: inquiry, text: text);
      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Firebase 저장 에러: $e");
      _showSnack('전송 실패: $e');
    }
  }

  // 이미지 선택 후 전송.
  Future<void> _pickAndSendImage() async {
    final inquiry = ref.read(selectedInquiryProvider);
    if (inquiry == null) {
      _showSnack('전송 실패: 문의 대상을 선택해주세요.');
      return;
    }

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      _showSnack('이미지 업로드 중...');
      final file = File(picked.path);
      final storage = FirebaseStorage.instanceFor(app: Firebase.app());
      final String fileName =
          '${inquiry['guardian_id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = storage.ref().child('chatting_images').child(fileName);
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      await _retrySend(
        col: ref.read(chattingCollectionProvider),
        inquiry: inquiry,
        imageUrl: url,
      );
      _scrollToBottom();
      _showSnack('이미지 전송 완료');
    } catch (e) {
      debugPrint('❌ 이미지 업로드/전송 실패: $e');
      _showSnack('이미지 전송 실패: $e');
    }
  }

  // Firebase 메시지 전송 재시도 처리.
  Future<void> _retrySend(
    {
    required CollectionReference col,
    required Map<String, dynamic> inquiry,
    String? text,
    String? imageUrl,
  }
  ) async {
    final String safeText = (text ?? '').trim();
    final String safeImageUrl = (imageUrl ?? '').trim();
    for (int attempt = 1; attempt <= _maxSendAttempts; attempt++) {
      try {
        await col.limit(1).get(const GetOptions(source: Source.server)).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint("❌ Firebase 읽기 타임아웃(5초)");
            throw TimeoutException("Firebase read timed out");
          },
        );
        debugPrint("✅ Firebase 읽기 성공");
        final value = await col.add({
          'category_id': inquiry['category_id'] ?? 1,
          'chatting_contents': safeText,
          'chatting_content': safeText,
          'chatting_date': FieldValue.serverTimestamp(), // 서버 시간 고정 저장
          'guardian_id': int.tryParse(inquiry['guardian_id'].toString()) ??
              inquiry['guardian_id'],
          'student_id': inquiry['student_id'] ?? 1,
          'teacher_id': 1,
          'chatting_image': safeImageUrl,
          'chatting_read_date': null,
        }).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint("❌ Firebase 저장 타임아웃(5초)");
            throw TimeoutException("Firebase write timed out");
          },
        );
        debugPrint("✅ Firebase 저장 성공: ${value.id}");
        _showSnack('전송 성공');
        return;
      } on FirebaseException catch (e) {
        final bool shouldRetry =
            e.code == 'unavailable' || e.code == 'deadline-exceeded';
        if (!shouldRetry || attempt == _maxSendAttempts) rethrow;
        final delay = Duration(seconds: 1 << (attempt - 1));
        debugPrint("⏳ 재시도 대기 ${delay.inSeconds}s (attempt $attempt)");
        await Future.delayed(delay);
      } on TimeoutException {
        if (attempt == _maxSendAttempts) rethrow;
        final delay = Duration(seconds: 1 << (attempt - 1));
        debugPrint("⏳ 타임아웃 재시도 대기 ${delay.inSeconds}s (attempt $attempt)");
        await Future.delayed(delay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inquiry = ref.watch(selectedInquiryProvider);
    final chatData = ref.watch(chatStreamProvider);

    if (inquiry == null) return const Center(child: Text('문의를 선택해주세요.'));
    final int? guardianId = int.tryParse(inquiry['guardian_id'].toString());
    if (guardianId != null && guardianId != _lastGuardianId) {
      _lastGuardianId = guardianId;
      _didInitialScroll = false;
      _scrollToBottom();
    }
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute && !_wasCurrentRoute) {
      _wasCurrentRoute = true;
      _didInitialScroll = false;
      _scrollToBottom();
    } else if (!isCurrentRoute && _wasCurrentRoute) {
      _wasCurrentRoute = false;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Acolor.primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Acolor.onPrimaryColor,
                child: Icon(Icons.school,
                    color: Acolor.appBarBackgroundColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${inquiry['student_name']} 학부모님',
                      style: TextStyle(
                        color: Acolor.appBarBackgroundColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '실시간 상담 중',
                      style: TextStyle(
                        color: Acolor.appBarBackgroundColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Acolor.onPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ONLINE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Acolor.appBarBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: chatData.when(
            data: (msgs) {
              if (!_didInitialScroll && msgs.isNotEmpty) {
                _didInitialScroll = true;
                _scrollToBottom();
              }
              final reversedMsgs = msgs.reversed.toList();
              return Container(
                color: Acolor.onPrimaryColor,
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(24),
                  itemCount: reversedMsgs.length,
                  itemBuilder: (ctx, idx) {
                    final m = reversedMsgs[idx];
                    return _buildBubble(
                      context,
                      m['docId'],
                      m['contents'],
                      m['imageUrl'],
                      m['date'],
                      m['isTeacher'],
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('에러: $e')),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Acolor.onPrimaryColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(child: _buildInputBar()),
        ),
      ],
    );
  }

  // 채팅 버블 UI.
  Widget _buildBubble(
    BuildContext context,
    String? docId,
    String contents,
    String? imageUrl,
    DateTime date,
    bool isMe,
  ) {
    final String? url = (imageUrl ?? '').trim().isEmpty ? null : imageUrl;
    final bool isMine = isMe;
    final TextStyle messageStyle = TextStyle(
      color: Acolor.appBarBackgroundColor,
      fontSize: 16,
    );
    return GestureDetector(
      onLongPress: (!isMine || docId == null)
          ? null
          : () async {
              final result = await Message.confirm(
                context,
                '메세지 삭제',
                '메세지를 삭제 하시겠습니까?',
                Acolor.onPrimaryColor,
              );
              if (result == true) {
                await ref.read(chattingCollectionProvider).doc(docId).delete();
              }
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              Text(
                DateFormat('a h:mm').format(date),
                style: TextStyle(fontSize: 10, color: _kTeacherMuted),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? Acolor.primaryColor : Acolor.onPrimaryColor,
                borderRadius: BorderRadius.circular(18),
                border: isMine
                    ? null
                    : Border.all(color: Acolor.secondaryBackgroundColor),
                boxShadow: [
                  BoxShadow(
                    color: Acolor.appBarBackgroundColor.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return const Icon(Icons.broken_image, size: 40);
                        },
                      ),
                    ),
                  if (contents.trim().isNotEmpty) ...[
                    if (url != null) const SizedBox(height: 8),
                    Text(contents, style: messageStyle),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isMe)
              Text(
                DateFormat('a h:mm').format(date),
                style: TextStyle(fontSize: 10, color: _kTeacherMuted),
              ),
          ],
        ),
      ),
    );
  }

  // 메시지 입력/전송 바 UI.
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Acolor.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: _pickAndSendImage,
              icon: Icon(Icons.add,
                  color: Acolor.appBarBackgroundColor, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                filled: true,
                fillColor: Acolor.onPrimaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Acolor.secondaryBackgroundColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Acolor.secondaryBackgroundColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Acolor.primaryColor, width: 1.2),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Acolor.appBarBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: _send,
              icon: Icon(Icons.send,
                  color: Acolor.appBarForegroundColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
