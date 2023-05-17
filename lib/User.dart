class User {
  String firstName;
  String lastName;
  String id;
  //String image; // New property for user image

  User({required this.firstName, required this.lastName, required this.id
      // required this.image, // Include the image property in the constructor
      });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'id': id
      // 'image': image,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String firstname = json['firstName'] ?? '';
    String lastname = json['lastName'] ?? '';
    String id = json['id'].toString();

    return User(
      firstName: firstname,
      lastName: lastname,
      id: id,
      //image: image, // Pass the image property to the constructor
    );
  }
}
