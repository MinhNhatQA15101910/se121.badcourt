import 'package:frontend/models/photo.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String token;
  final List<String> roles;
  final List<Photo> photos;
  final DateTime? lastOnlineAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl = '',
    this.token = '',
    this.roles = const [],
    this.photos = const [],
    this.lastOnlineAt,
  });

  String get role {
    if (roles.isNotEmpty) {
      return roles[0];
    }
    return 'User';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      List<String> rolesList = [];
      final rolesJson = json['roles'];
      if (rolesJson != null) {
        if (rolesJson is List) {
          rolesList = rolesJson.map((role) => role.toString()).toList();
        } else if (rolesJson is String) {
          rolesList = [rolesJson];
        }
      }

      List<Photo> photoList = [];
      final photosJson = json['photos'];
      if (photosJson != null && photosJson is List) {
        photoList = photosJson.map((p) => Photo.fromJson(p)).toList();
      }

      return User(
        id: json['id'] as String? ?? '',
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
        token: json['token'] as String? ?? '',
        roles: rolesList,
        photos: photoList,
        lastOnlineAt: json['lastOnlineAt'] != null
            ? DateTime.tryParse(json['lastOnlineAt'])
            : null,
      );
    } catch (e, stackTrace) {
      print('[User] Error parsing JSON: $e');
      print('[User] Stack trace: $stackTrace');
      print('[User] JSON data: $json');

      return User(
        id: json['id'] as String? ?? 'unknown',
        username: json['username'] as String? ?? 'Unknown User',
        email: json['email'] as String? ?? 'unknown@example.com',
        photoUrl: '',
        token: '',
        roles: const ['User'],
        photos: const [],
        lastOnlineAt: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'token': token,
      'roles': roles,
      'photos': photos.map((p) => p.toJson()).toList(),
      'lastOnlineAt': lastOnlineAt?.toIso8601String(), // <-- serialize
    };
  }

  factory User.empty() {
    return User(
      id: '',
      username: '',
      email: '',
      photoUrl: '',
      roles: [],
      token: '',
      photos: [],
      lastOnlineAt: null,
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    String? token,
    List<String>? roles,
    List<Photo>? photos,
    DateTime? lastOnlineAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
      roles: roles ?? this.roles,
      photos: photos ?? this.photos,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, photoUrl: $photoUrl, token: $token, roles: $roles, photos: $photos, lastOnlineAt: $lastOnlineAt)';
  }
}
