import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String imageUrl;
  final String role;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.imageUrl,
    required this.role,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
      'role': role,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
