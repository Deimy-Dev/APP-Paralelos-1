import 'dart:convert';
import 'package:app1_paralelos/book.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Book>> searchBooks({
    String? q,
    String? author,
    String? category,
    String? language,
    int? minPages,
    int? maxPages,
    String? format,
  }) async {
    final queryParameters = <String, String>{};
    if (q != null && q.isNotEmpty) queryParameters['q'] = q;
    if (author != null && author.isNotEmpty) queryParameters['author'] = author;
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;
    if (language != null && language.isNotEmpty) queryParameters['language'] = language;
    if (minPages != null) queryParameters['minPages'] = minPages.toString();
    if (maxPages != null) queryParameters['maxPages'] = maxPages.toString();
    if (format != null && format.isNotEmpty) queryParameters['format'] = format;

    final uri = Uri.parse('$baseUrl/books/search').replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((jsonItem) => Book.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Error al obtener libros: ${response.statusCode}');
    }
  }

  Future<List<Book>> searchBooksMulti({
    required List<String> authors,
    required List<String> categories,
    required List<String> languages,
    required List<String> formats,
    int? minPages,
    int? maxPages,
    String? q,
  }) async {
    final Set<Book> allBooks = {};
    final List<Future<List<Book>>> futures = [];

    final authorsList = authors.isEmpty ? [''] : authors;
    final categoriesList = categories.isEmpty ? [''] : categories;
    final languagesList = languages.isEmpty ? [''] : languages;
    final formatsList = formats.isEmpty ? [''] : formats;

    for (final author in authorsList) {
      for (final category in categoriesList) {
        for (final language in languagesList) {
          for (final format in formatsList) {
            futures.add(
              searchBooks(
                q: q,
                author: author,
                category: category,
                language: language,
                minPages: minPages,
                maxPages: maxPages,
                format: format,
              ),
            );
          }
        }
      }
    }

    final results = await Future.wait(futures);

    for (var books in results) {
      allBooks.addAll(books);
    }

    return allBooks.toList();
  }
}
