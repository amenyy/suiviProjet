import 'package:suiviprojet/User.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const API_URL = 'http://localhost:3000/users';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(API_URL));

    if (response.statusCode == 200) {
      final users = json.decode(response.body) as List<dynamic>;

      return users.map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
