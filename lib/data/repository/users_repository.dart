import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UsersRepository {
  static const boxName = 'usersBox';
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final url = 'https://reqres.in/api/users?page=1&per_page=1';
    final header = {
      "accept": "application/json",
      "x-api-key": "reqres-free-v1",
    };
    final response = await http.get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      final box = await Hive.openBox(boxName);
      await box.put('users', data);
      return List<Map<String, dynamic>>.from(data);
    } else {
      final box = await Hive.openBox(boxName);
      return List<Map<String, dynamic>>.from(
        box.get('users', defaultValue: []),
      );
    }
  }
}
