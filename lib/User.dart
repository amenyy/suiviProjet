class User {
  int id;
  String firstName;
  String lastName;
  String image;
  String email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'image': image,
      'email': email,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      image: json['image'],
      email: json['email'],
    );
  }
}
