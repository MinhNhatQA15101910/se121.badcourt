class UserDto {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final String role;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    try {
      return UserDto(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        photoUrl: json['photoUrl']?.toString(),
        role: json['role']?.toString() ?? '',
      );
    } catch (e) {
      print('[UserDto] Error parsing from JSON: $e');
      print('[UserDto] JSON data: $json');
      
      return UserDto(
        id: json['id']?.toString() ?? 'unknown',
        username: json['username']?.toString() ?? 'Unknown User',
        email: json['email']?.toString() ?? 'unknown@example.com',
        photoUrl: null,
        role: json['role']?.toString() ?? 'Unknown',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
  
  @override
  String toString() {
    return 'UserDto{id: $id, username: $username, email: $email, role: $role}';
  }
}