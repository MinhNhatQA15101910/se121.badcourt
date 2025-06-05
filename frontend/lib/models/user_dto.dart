class UserDto {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final String? token;
  final List<String> roles; // Thay đổi từ String role thành List<String> roles

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    this.token,
    this.roles = const [], // Default empty list
  });

  // Getter để lấy role đầu tiên từ mảng roles
  String get role {
    if (roles.isNotEmpty) {
      return roles[0]; // Lấy phần tử đầu tiên
    }
    return 'User'; // Default role nếu không có
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    try {
      // Parse roles list
      List<String> rolesList = [];
      final rolesJson = json['roles'];
      if (rolesJson != null) {
        if (rolesJson is List) {
          rolesList = rolesJson.map((role) => role.toString()).toList();
        } else if (rolesJson is String) {
          rolesList = [rolesJson]; // Nếu là string đơn, chuyển thành list
        }
      }

      return UserDto(
        id: json['id'] as String? ?? '',
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        token: json['token'] as String?,
        roles: rolesList,
      );
    } catch (e, stackTrace) {
      print('[UserDto] Error parsing JSON: $e');
      print('[UserDto] Stack trace: $stackTrace');
      print('[UserDto] JSON data: $json');
      
      // Return default UserDto on error
      return UserDto(
        id: json['id'] as String? ?? 'unknown',
        username: json['username'] as String? ?? 'Unknown User',
        email: json['email'] as String? ?? 'unknown@example.com',
        photoUrl: null,
        token: null,
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

  UserDto copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    String? token,
    List<String>? roles,
  }) {
    return UserDto(
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
    return 'UserDto(id: $id, username: $username, email: $email, photoUrl: $photoUrl, roles: $roles)';
  }
}
