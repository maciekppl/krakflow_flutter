import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';

class TaskApiService {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<Task>> fetchTasks() async {
    final response = await http
        .get(Uri.parse('$baseUrl/todos'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Blad pobierania danych');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final todos = data['todos'] as List<dynamic>;

    return todos.map((todo) {
      final todoMap = todo as Map<String, dynamic>;

      return Task(
        id: (todoMap['id'] as num).toInt(),
        title: todoMap['todo']?.toString() ?? '',
        deadline: 'brak',
        done: todoMap['completed'] == true,
        priority: 'sredni',
      );
    }).toList();
  }
}
