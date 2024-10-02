class User {
  String? uid;
  String? name;
  String? email;
  String? phoneNumber;
  String? avatarUrl;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a User instance from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a User instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Method to update user details
  void updateUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String avatarUrl,
  }) {
    this.name = name;
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.avatarUrl = avatarUrl;
    this.updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'User{uid: $uid, name: $name, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
