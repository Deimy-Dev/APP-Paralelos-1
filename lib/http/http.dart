import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app1_paralelos/book.dart';

class BookService {
  static const String _baseUrl = 'http://localhost:3000/api/books';

  static Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar libros');
    }
  }
}
