/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para compute()
import 'package:http/http.dart' as http;

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  bool _loading = false;

  void _searchBooks() async {
    setState(() => _loading = true);
    final query = _searchController.text.trim();
    final books = await fetchBooksInBackground(query);
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(labelText: 'Buscar libro...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: _searchBooks,
              )
            ],
          ),
        ),
        _loading
            ? CircularProgressIndicator()
            : Expanded(
                child: ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return ListTile(
                      leading: book.thumbnail != null
                          ? Image.network(book.thumbnail!)
                          : null,
                      title: Text(book.title),
                      subtitle: Text(book.authors.join(', ')),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

/// Modelo de libro
class Book {
  final String title;
  final List<String> authors;
  final String? thumbnail;

  Book({required this.title, required this.authors, this.thumbnail});

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    return Book(
      title: volumeInfo['title'] ?? 'Sin título',
      authors: List<String>.from(volumeInfo['authors'] ?? ['Desconocido']),
      thumbnail: volumeInfo['imageLinks'] != null
          ? volumeInfo['imageLinks']['thumbnail']
          : null,
    );
  }
}

/// Llamada a compute para no bloquear el hilo principal
Future<List<Book>> fetchBooksInBackground(String query) async {
  return compute(fetchBooks, query);
}

Future<List<Book>> fetchBooks(String query) async {
  final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>?;
    if (items == null) return [];
    return items.map((item) => Book.fromJson(item)).toList();
  } else {
    throw Exception('Error al buscar libros');
  }
}
*/