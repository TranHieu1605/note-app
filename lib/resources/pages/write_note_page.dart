import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/note.dart';

class WriteNotePage extends StatefulWidget {

  final Note? note;
  final int? index;

  const WriteNotePage({super.key, this.note, this.index});

  @override
  State<WriteNotePage> createState() => _WriteNotePageState();
}

class _WriteNotePageState extends State<WriteNotePage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _titleCtrl.text = widget.note!.title;
      _contentCtrl.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }


  void _save({bool isAuto = false}) {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    // title BẮT BUỘC + tối đa 120 ký tự
    if (title.isEmpty || title.length > 120) {
      if (!isAuto) {

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Không hợp lệ'),
            content: const Text('Tiêu đề bắt buộc và tối đa 120 ký tự.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
      return; // không lưu
    }

    final now = DateTime.now();

    if (isEditing) {
      // cập nhật note
      final updated = Note(
        id: widget.note!.id,
        title: title,
        content: content,
        createdAt: widget.note!.createdAt,
        updatedAt: now,
      );
      Navigator.pop(context, {'action': 'update', 'note': updated, 'index': widget.index});
    } else {
      // tạo mới note
      final created = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      Navigator.pop(context, {'action': 'create', 'note': created});
    }
  }

  //  Xóa
  void _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: const Text('Bạn chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (yes == true) {
      Navigator.pop(context, {'action': 'delete', 'index': widget.index});
    }
  }

  @override
  Widget build(BuildContext context) {
    //  Tự động LƯU
    return WillPopScope(
      onWillPop: () async {
        _save(isAuto: true); // tự lưu nếu hợp lệ
        return true; // cho phép thoát trang
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Sửa ghi chú' : 'Viết ghi chú mới'),
          centerTitle: true,
          actions: [
            if (isEditing)
              IconButton(
                onPressed: _delete, //  nút xóa khi sửa
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa',
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề (bat buoc, toi da 120)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
