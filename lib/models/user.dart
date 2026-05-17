class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
  });

  // Parse a user from a DummyJSON /users response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Serialize for POST/PUT request bodies
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }

  // Helper to get the full display name
  String get fullName => '$firstName $lastName';

  // Used when editing — copy with changed fields only
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? image,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }

  // Legacy getters to keep existing UI stable
  String get avatar => image;
  String? get job => phone.isNotEmpty ? phone : null;
  String? get createdAt => null;
  String? get updatedAt => null;

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}