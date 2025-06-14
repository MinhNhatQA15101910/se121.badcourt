import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String imageUrl;
  final String role;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.token,
  });

  /// Dùng khi bạn cần map để lưu hoặc serialize
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'role': role,
      'token': token,
    };
  }

  /// ✅ Chuyển từ Map -> User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
    );
  }

  /// Dùng khi decode từ json string
  factory User.fromJsonString(String source) =>
      User.fromJson(json.decode(source));

  /// Dùng khi encode sang json string
  String toJsonString() => json.encode(toMap());

  /// ✅ Tạo user rỗng
  factory User.empty() {
    return const User(
      id: '',
      username: '',
      email: '',
      imageUrl: '',
      role: '',
      token: '',
    );
  }

  /// Optional: hỗ trợ copy để chỉnh sửa từng phần
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? imageUrl,
    String? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
