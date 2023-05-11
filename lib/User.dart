class User {
  String firstName;
  String lastName;
  //String image; // New property for user image

  User({
    required this.firstName,
    required this.lastName,
    // required this.image, // Include the image property in the constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      // 'image': image,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String firstname = json['firstName'] ?? '';
    String lastname = json['lastName'] ?? '';
    String image = json['image'] ?? ''; // Parse the image property from JSON

    return User(
      firstName: firstname,
      lastName: lastname,
      //image: image, // Pass the image property to the constructor
    );
  }
}
