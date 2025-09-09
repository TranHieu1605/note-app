

class Note { // lớp đại diện 1 ghi chú đơn giản
  final String id; // mã ghi chú (tạo tự động nếu không truyền vào)
  String title; // tiêu đề ghi chú (ngắn gọn)
  String content; // nội dung ghi chú (dài)
  DateTime createdAt; // thời điểm tạo
  DateTime updatedAt; // thời điểm cập nhật gần nhất

  Note({ // constructor để tạo đối tượng Note mới
    String? id, // cho phép null để mình tự sinh nếu không truyền
    required this.title, // bắt buộc có title
    required this.content, // bắt buộc có content
    DateTime? createdAt, // cho phép null, sẽ gán mặc định
    DateTime? updatedAt, // cho phép null, sẽ gán mặc định
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(), // nếu id null -> tự sinh từ thời gian
        createdAt = createdAt ?? DateTime.now(), // nếu createdAt null -> lấy thời điểm hiện tại
        updatedAt = updatedAt ?? DateTime.now(); // nếu updatedAt null -> lấy thời điểm hiện tại

  void touch() { // hàm nhỏ để cập nhật mốc thời gian mỗi khi sửa
    updatedAt = DateTime.now(); // gán lại updatedAt = bây giờ
  }
  Map<String, dynamic> toMap() { // hàm chuyển Note thành Map (kiểu key:value)
    return { // trả về một cái Map
      'id': id, // lưu id
      'title': title, // lưu tiêu đề
      'content': content, // lưu nội dung
      'createdAt': createdAt.toIso8601String(), // chuyển DateTime thành String ISO
      'updatedAt': updatedAt.toIso8601String(), // tương tự cho updatedAt
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) { // factory constructor: tạo Note từ Map
    return Note( // trả về đối tượng Note mới
      id: map['id'], // lấy id từ map
      title: map['title'] ?? '', // lấy title, nếu null thì gán rỗng
      content: map['content'] ?? '', // lấy content, nếu null thì gán rỗng
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(), // parse String thành DateTime, nếu lỗi thì lấy now
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(), // tương tự cho updatedAt
    );
  }

}