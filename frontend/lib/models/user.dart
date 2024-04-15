import 'dart:convert';

class User {
  final String id;
  final String username;
  final String phoneNumber;
  final String email;
  final String password;
  final String role;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.role,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'role': role,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? username,
    String? phoneNumber,
    String? email,
    String? password,
    String? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
