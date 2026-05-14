import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../view_models/dashboard_view_model.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dashboardController = Get.find<DashboardViewModel>();
    final query = FirebaseFirestore.instance.collection('notices');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final header = _NoticeHeader(
          onAdd: () => _NoticeEditorDialog.show(context: context),
        );

        if (snapshot.hasError) {
          return _NoticeStateMessage(
            title: '\uACF5\uC9C0\uC0AC\uD56D\uC744 \uBD88\uB7EC\uC624\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.',
            message: snapshot.error.toString(),
            header: header,
          );
        }

        final notices = snapshot.data?.docs
                .map((doc) => NoticeItem.fromFirestore(doc.reference, doc.data()))
                .toList(growable: true) ??
            <NoticeItem>[];
        notices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filteredNotices = _filterNotices(
          notices: notices,
          query: dashboardController.noticeSearchQuery.value,
        );

        if (filteredNotices.isEmpty) {
          return _NoticeStateMessage(
            title: notices.isEmpty
                ? '\uB4F1\uB85D\uB41C \uACF5\uC9C0\uC0AC\uD56D\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.'
                : '\uAC80\uC0C9 \uACB0\uACFC\uAC00 \uC5C6\uC2B5\uB2C8\uB2E4.',
            message: notices.isEmpty
                ? 'Firebase notices collection is empty.'
                : '\uC785\uB825\uD55C \uAC80\uC0C9\uC5B4\uB85C \uACF5\uC9C0\uC0AC\uD56D\uC744 \uCC3E\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.',
            header: header,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 18),
            ...filteredNotices.map(
              (notice) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _NoticeCard(
                  notice: notice,
                  onEdit: () => _NoticeEditorDialog.show(
                    context: context,
                    notice: notice,
                  ),
                  onDelete: () => _NoticeDeleteDialog.show(
                    context: context,
                    notice: notice,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

List<NoticeItem> _filterNotices({
  required List<NoticeItem> notices,
  required String query,
}) {
  final normalized = _normalizeQuery(query);
  if (normalized.isEmpty) {
    return notices;
  }

  return notices.where((notice) {
    final title = _normalizeQuery(notice.title);
    return title.contains(normalized);
  }).toList(growable: false);
}

String _normalizeQuery(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

class NoticeItem {
  const NoticeItem({
    required this.reference,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.createdAtLabel,
    required this.isImportant,
    required this.isVisible,
  });

  final DocumentReference<Map<String, dynamic>> reference;
  final String title;
  final String content;
  final DateTime createdAt;
  final String createdAtLabel;
  final bool isImportant;
  final bool isVisible;

  factory NoticeItem.fromFirestore(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
  ) {
    final createdAt = _readCreatedAt(data['createdAt']);
    return NoticeItem(
      reference: reference,
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      createdAt: createdAt,
      createdAtLabel: _formatCreatedAt(createdAt),
      isImportant: data['isImportant'] == true,
      isVisible: data['isVisible'] == true,
    );
  }

  static DateTime _readCreatedAt(dynamic value) {
    final dateTime = switch (value) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      String raw => DateTime.tryParse(raw),
      _ => null,
    };
    return dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatCreatedAt(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return '';
    }

    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute';
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.onEdit,
    required this.onDelete,
  });

  final NoticeItem notice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notice.title.isEmpty ? '\uC81C\uBAA9 \uC5C6\uC74C' : notice.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: palette.primaryText,
                        ),
                  ),
                ),
                if (notice.isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: palette.accentRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '\uC911\uC694',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.accentRed,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                if (notice.isImportant && !notice.isVisible) const SizedBox(width: 6),
                if (!notice.isVisible)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: palette.mutedText.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '\uC228\uAE40',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.mutedText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                const SizedBox(width: 8),
                _NoticeActionButton(
                  icon: Icons.edit_rounded,
                  label: '\uC218\uC815',
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                _NoticeActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: '\uC0AD\uC81C',
                  onTap: onDelete,
                ),
              ],
            ),
            if (notice.createdAtLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                notice.createdAtLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.mutedText,
                    ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              notice.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                    height: 1.55,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeStateMessage extends StatelessWidget {
  const _NoticeStateMessage({
    required this.title,
    required this.message,
    required this.header,
  });

  final String title;
  final String message;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\uACF5\uC9C0\uC0AC\uD56D',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: palette.primaryText,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '\uC6B4\uC601 \uC2DC\uAC04\uACFC \uC8FC\uCC28\uC7A5 \uC548\uB0B4\uB97C \uD655\uC778\uD558\uC138\uC694.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.mutedText,
                    ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('\uACF5\uC9C0 \uCD94\uAC00'),
        ),
      ],
    );
  }
}

class _NoticeActionButton extends StatelessWidget {
  const _NoticeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: palette.accentBlue),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.accentBlue,
              fontWeight: FontWeight.w700,
            ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _NoticeEditorDialog extends StatefulWidget {
  const _NoticeEditorDialog({this.notice});

  final NoticeItem? notice;

  static Future<void> show({
    required BuildContext context,
    NoticeItem? notice,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _NoticeEditorDialog(notice: notice),
    );
  }

  @override
  State<_NoticeEditorDialog> createState() => _NoticeEditorDialogState();
}

class _NoticeEditorDialogState extends State<_NoticeEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isImportant = false;
  bool _isVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final notice = widget.notice;
    _titleController = TextEditingController(text: notice?.title ?? '');
    _contentController = TextEditingController(text: notice?.content ?? '');
    _isImportant = notice?.isImportant ?? false;
    _isVisible = notice?.isVisible ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final payload = <String, dynamic>{
      'title': title,
      'content': content,
      'isImportant': _isImportant,
      'isVisible': _isVisible,
    };

    try {
      if (widget.notice == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('notices').add(payload);
      } else {
        await widget.notice!.reference.update(payload);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.notice == null ? '\uACF5\uC9C0 \uCD94\uAC00' : '\uACF5\uC9C0 \uC218\uC815'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '\uC81C\uBAA9'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: '\uB0B4\uC6A9'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile.adaptive(
                    value: _isImportant,
                    title: const Text('\uC911\uC694 \uACF5\uC9C0'),
                    onChanged: (value) => setState(() => _isImportant = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SwitchListTile.adaptive(
                    value: _isVisible,
                    title: const Text('\uC5F0\uB3D9 \uD45C\uC2DC'),
                    onChanged: (value) => setState(() => _isVisible = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('\uCDE8\uC18C'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? '\uC800\uC7A5 \uC911...' : '\uC800\uC7A5'),
        ),
      ],
    );
  }
}

class _NoticeDeleteDialog extends StatelessWidget {
  const _NoticeDeleteDialog({required this.notice});

  final NoticeItem notice;

  static Future<void> show({
    required BuildContext context,
    required NoticeItem notice,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _NoticeDeleteDialog(notice: notice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('\uACF5\uC9C0 \uC0AD\uC81C'),
      content: Text('\u201C${notice.title} \u201D \uACF5\uC9C0\uB97C \uC0AD\uC81C\uD560\uAE4C\uC694?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('\uCDE8\uC18C'),
        ),
        FilledButton(
          onPressed: () async {
            await notice.reference.delete();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('\uC0AD\uC81C'),
        ),
      ],
    );
  }
}
