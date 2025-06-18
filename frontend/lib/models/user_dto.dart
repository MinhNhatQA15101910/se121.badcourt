class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl; // <- không nullable
  final String token;    // <- không nullable
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl = '',  // <- mặc định là chuỗi rỗng
    this.token = '',     // <- mặc định là chuỗi rỗng
    this.roles = const [],
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

      return User(
        id: json['id'] as String? ?? '',
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '', // fallback nếu null
        token: json['token'] as String? ?? '',       // fallback nếu null
        roles: rolesList,
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
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    String? token,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
      roles: roles ?? this.roles,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, photoUrl: $photoUrl, token: $token, roles: $roles)';
  }
}
