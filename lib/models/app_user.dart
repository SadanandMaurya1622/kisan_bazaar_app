class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  final String uid;
  final String email;
  final String role;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'buyer',
    );
  }
}
