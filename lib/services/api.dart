import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../models/todo.dart';

class TodoPage {
  final List<Todo> todos;
  final bool hasNext;
  TodoPage(this.todos, this.hasNext);
}

class Api {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    headers: {'Accept': 'application/json'},
  ));

  Api() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }

  // ---------- auth ----------
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> login(String email, String password) async {
    final r = await _dio.post('/login', data: {'email': email, 'password': password});
    await _saveToken(r.data['token']);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  Future<String> fetchUserName() async {
    final r = await _dio.get('/user');
    return r.data['name'] as String;
  }

  // ---------- todos ----------
  Future<TodoPage> fetchTodos({int page = 1, bool? completed, int? categoryId}) async {
    final r = await _dio.get('/todos', queryParameters: {
      'page': page,
      if (completed != null) 'completed': completed ? 1 : 0,
      if (categoryId != null) 'category_id': categoryId,
    });
    return TodoPage(
      (r.data['data'] as List).map((e) => Todo.fromJson(e)).toList(),
      r.data['links']['next'] != null,
    );
  }

  Future<void> createTodo(Map<String, dynamic> data) => _dio.post('/todos', data: data);

  Future<void> updateTodo(int id, Map<String, dynamic> data) =>
      _dio.put('/todos/$id', data: data);

  Future<void> deleteTodo(int id) => _dio.delete('/todos/$id');

  // ---------- categories ----------
  Future<List<Category>> fetchCategories() async {
    final r = await _dio.get('/categories');
    return (r.data['data'] as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<void> createCategory(String name) => _dio.post('/categories', data: {'name': name});

  Future<void> deleteCategory(int id) => _dio.delete('/categories/$id');

  // ---------- tags ----------
  Future<List<Tag>> fetchTags() async {
    final r = await _dio.get('/tags');
    return (r.data['data'] as List).map((e) => Tag.fromJson(e)).toList();
  }

  Future<Tag> createTag(String name) async {
    final r = await _dio.post('/tags', data: {'name': name});
    return Tag.fromJson(r.data['data']);
  }

  /// Turns a Dio error into a readable message.
  static String errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return (errors.values.first as List).first.toString();
        }
        if (data['message'] != null) return data['message'].toString();
      }
      return 'Cannot reach the server. Is "php artisan serve" running?';
    }
    return e.toString();
  }
}