/* 
Description : 학부모 채팅 페이지 구성 및 개선
  - 채팅 UI 재구성 및 입력바 스타일 개선
  - 카테고리 선택 드롭다운 추가 및 라벨 정리
  - 하단 스크롤 고정 및 최신 메시지 표시 흐름 조정
  - Firebase 채팅 데이터 스트림 연동
Date : 2026-1-22
Author : 이상현
*/

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/vm/minjae/guardian_riverpod.dart';
import 'package:guardian/vm/sanghyun/chat_vm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/util/message.dart';

const int kDefaultGuardianId = 2;
const int kDefaultStudentId = 2;

final Color _kGuardianMuted =
    Acolor.appBarBackgroundColor.withOpacity(0.55);

class GuardianChatting extends ConsumerStatefulWidget {
  const GuardianChatting({
    super.key,
    this.guardianId,
    this.studentId,
    this.categoryId = 1,
  });

  final int? guardianId;
  final int? studentId;
  final int categoryId;

  @override
  ConsumerState<GuardianChatting> createState() => _GuardianChattingState();
}

class _GuardianChattingState extends ConsumerState<GuardianChatting> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _didInitialScroll = false;
  bool _wasCurrentRoute = true;
  late int _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryId;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 하단으로 스크롤 이동.
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

  // 가디언 ID 우선순위 해석.
  int? _resolveGuardianId(List<dynamic> guardians) {
    if (widget.guardianId != null) return widget.guardianId;
    if (guardians.isEmpty) return kDefaultGuardianId;
    final g = guardians.first;
    return g.guardian_id;
  }

  // 학생 ID 우선순위 해석.
  int? _resolveStudentId(List<dynamic> guardians) {
    if (widget.studentId != null) return widget.studentId;
    if (guardians.isEmpty) return kDefaultStudentId;
    final g = guardians.first;
    return g.student_id;
  }

  // 메시지 전송 공통 처리.
  Future<void> _sendMessage(
    int guardianId,
    int studentId, {
    String? text,
    String? imageUrl,
  }) async {
    final String safeText = (text ?? '').trim();
    final String safeImageUrl = (imageUrl ?? '').trim();
    if (safeText.isEmpty && safeImageUrl.isEmpty) return;

    debugPrint(
      '📨 send called: guardianId=$guardianId studentId=$studentId text="$safeText"',
    );

    _textController.clear();
    final col = ref.read(guardianChatCollectionProvider);
    debugPrint(
      '📡 Firestore project: ${FirebaseFirestore.instance.app.options.projectId}',
    );
    try {
      debugPrint('⏳ Firebase 저장 시도');
      final doc = await col
          .add({
        'category_id': _selectedCategory,
        'chatting_contents': safeText,
        'chatting_content': safeText,
        'chatting_date': FieldValue.serverTimestamp(),
        'guardian_id': guardianId,
        'student_id': studentId,
        'teacher_id': null,
        'chatting_image': safeImageUrl,
        'chatting_read_date': null,
      })
          .timeout(const Duration(seconds: 10));
      debugPrint("✅ Firebase 저장 성공: ${doc.id}");
      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Firebase 저장 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전송 실패: $e')),
        );
      }
    } finally {
      debugPrint('✅ 전송 처리 완료');
    }
  }

  // 텍스트 메시지 전송.
  Future<void> _sendText(int guardianId, int studentId) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await _sendMessage(guardianId, studentId, text: text);
  }

  // 이미지 선택 후 전송.
  Future<void> _pickAndSendImage(int guardianId, int studentId) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      final file = File(picked.path);
      final storage = FirebaseStorage.instanceFor(app: Firebase.app());
      final String fileName =
          '${guardianId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('chatting_images').child(fileName);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      await _sendMessage(guardianId, studentId, imageUrl: url);
    } catch (e) {
      debugPrint("❌ 이미지 전송 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 전송 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardianAsync = ref.watch(guardianNotifierProvider);
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute && !_wasCurrentRoute) {
      _wasCurrentRoute = true;
      _didInitialScroll = false;
      _scrollToBottom();
    } else if (!isCurrentRoute && _wasCurrentRoute) {
      _wasCurrentRoute = false;
    }

    return Scaffold(
      backgroundColor: Acolor.baseBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 76,
        elevation: 0,
        backgroundColor: Acolor.onPrimaryColor.withOpacity(0),
        foregroundColor: Acolor.appBarForegroundColor,
        title: const Text(
          '선생님과의 채팅',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Acolor.primaryColor,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Acolor.onPrimaryColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Text(
                  '주제 선택',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Acolor.appBarBackgroundColor,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCategory,
                    dropdownColor: Acolor.onPrimaryColor,
                    style: TextStyle(
                      fontSize: 13,
                      color: Acolor.appBarBackgroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('출결')),
                      DropdownMenuItem(value: 2, child: Text('급식')),
                      DropdownMenuItem(value: 3, child: Text('결석문의')),
                      DropdownMenuItem(value: 4, child: Text('개인상담')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: guardianAsync.when(
        data: (guardians) {
          final guardianId = _resolveGuardianId(guardians);
          final studentId = _resolveStudentId(guardians);
          if (guardianId == null || studentId == null) {
            return const Center(child: Text('학부모 정보가 없습니다.'));
          }

          final chatData = ref.watch(guardianChatStreamProvider(guardianId));
          final guardian = guardians.isEmpty ? null : guardians.first;

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth >= 900;
              final double maxWidth = isTablet ? 720 : double.infinity;

          final content = Container(
            decoration: BoxDecoration(
              color: Acolor.onPrimaryColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Acolor.appBarBackgroundColor.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: chatData.when(
                    data: (msgs) {
                      if (!_didInitialScroll && msgs.isNotEmpty) {
                        _didInitialScroll = true;
                        _scrollToBottom();
                      }
                      final reversedMsgs = msgs.reversed.toList();
                      return ListView.builder(
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
                            m['isMe'],
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('에러: $e')),
                  ),
                ),
                SafeArea(child: _buildInputBar(guardianId, studentId)),
              ],
            ),
          );

              if (!isTablet) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: content,
                );
              }
              return Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: _buildSidebar(context, guardian, guardianId, studentId),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Acolor.secondaryBackgroundColor,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: content,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('학부모 정보 로드 실패: $e')),
      ),
    );
  }

  // 태블릿 사이드바 UI.
  Widget _buildSidebar(
    BuildContext context,
    dynamic guardian,
    int guardianId,
    int studentId,
  ) {
    final String guardianName = guardian?.guardian_name?.toString() ?? '이름 없음';
    final String now = DateFormat('yyyy.MM.dd EEE', 'ko_KR').format(DateTime.now());

    return Container(
      color: Acolor.onPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '선생님에게 문의',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Acolor.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guardianName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'guardian_id: $guardianId / student_id: $studentId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Acolor.appBarBackgroundColor.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 18,
                  color: Acolor.appBarBackgroundColor.withOpacity(0.55)),
              const SizedBox(width: 8),
              Text(
                now,
                style: TextStyle(
                  fontSize: 13,
                  color: Acolor.appBarBackgroundColor.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '채팅 안내',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '문의 내용을 남기면 선생님과 실시간으로 대화할 수 있어요.',
            style: TextStyle(
              fontSize: 12,
              color: Acolor.appBarBackgroundColor.withOpacity(0.55),
            ),
          ),
        ],
      ),
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
                await ref
                    .read(guardianChatCollectionProvider)
                    .doc(docId)
                    .delete();
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
                style: TextStyle(fontSize: 10, color: _kGuardianMuted),
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
                    Text(
                      contents,
                      style: TextStyle(
                        color: isMine
                            ? Acolor.onPrimaryColor
                            : Acolor.appBarBackgroundColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isMe)
              Text(
                DateFormat('a h:mm').format(date),
                style: TextStyle(fontSize: 10, color: _kGuardianMuted),
              ),
          ],
        ),
      ),
    );
  }

  // 메시지 입력/전송 바 UI.
  Widget _buildInputBar(int guardianId, int studentId) {
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
              onPressed: () => _pickAndSendImage(guardianId, studentId),
              icon: Icon(Icons.add,
                  color: Acolor.appBarForegroundColor, size: 24),
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
              onSubmitted: (_) => _sendText(guardianId, studentId),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Acolor.appBarBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: () => _sendText(guardianId, studentId),
              icon: Icon(Icons.send,
                  color: Acolor.appBarForegroundColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
