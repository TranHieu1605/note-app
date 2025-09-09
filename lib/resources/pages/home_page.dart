import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/controllers/home_controller.dart';
import 'package:flutter_app/app/models/note.dart';
import 'package:flutter_app/resources/pages/write_note_page.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());
  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {

  final List<Note> _notes = [
    Note(
      title: 'Đi xem A80',
      content: 'Mac áo cờ đỏ sao vang',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Note(
      title: 'Học tieng anh',
      content: 'Thi ielts',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Note(
      title: 'Tán gái',
      content: 'Phong bat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isGrid = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    String two(int n) => n < 10 ? '0$n' : '$n';
    final d = two(dt.day), m = two(dt.month), h = two(dt.hour), mm = two(dt.minute);
    return '$d/$m $h:$mm';
  }

  // hien thi cap nhat neu thoi gian co thay doi, k thi da tao
  String _timeLabel(Note n) {
    if (n.updatedAt != null && n.createdAt != null && n.updatedAt!.isAfter(n.createdAt!)) {
      return 'Cập nhật: ${_fmt(n.updatedAt)}';
    }
    return 'Đã tạo: ${_fmt(n.createdAt)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WriteNotePage()),
          );
          if (result is Map && result['action'] == 'create' && result['note'] is Note) {
            setState(() => _notes.insert(0, result['note'] as Note));
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo ghi chú mới',
      ),
    );
  }

  Widget _buildBody() {
    final q = _query.trim().toLowerCase();
    final data = q.isEmpty
        ? _notes
        : _notes.where((n) {
      final t = n.title.toLowerCase();
      final c = n.content.toLowerCase();
      return t.contains(q) || c.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Tìm theo tiêu đề / nội dung',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(child: _buildListView(data)),
      ],
    );
  }

  Widget _buildListView(List<Note> data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.note_alt, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có ghi chú nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    // Grid
    if (_isGrid) {
      return GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 2,
        children: List.generate(data.length, (index) {
          final note = data[index];
          return _NoteCard(
            note: note,
            // [THÊM 5.3] Truyền text thời gian xuống Card để hiển thị
            timeText: _timeLabel(note),
            onTap: () => _openEdit(note, index),
          );
        }),
      );
    }

    // List
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final note = data[index];

        return ListTile(
          title: Text(note.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                _timeLabel(note),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openEdit(note, index),
        );
      },
    );
  }

  Future<void> _openEdit(Note note, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WriteNotePage(note: note, index: index)),
    );

    if (result is Map) {
      final action = result['action'];
      if (action == 'update' && result['note'] is Note && result['index'] is int) {
        setState(() => _notes[result['index'] as int] = result['note'] as Note);
      } else if (action == 'delete' && result['index'] is int) {
        setState(() => _notes.removeAt(result['index'] as int));
      }
    }
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final String timeText;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.timeText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 6),
              // them dong thoi gian
              Text(
                timeText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
