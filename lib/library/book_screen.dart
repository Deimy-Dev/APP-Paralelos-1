import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app1_paralelos/book.dart';
import 'package:app1_paralelos/services/api_service.dart';
import 'package:app1_paralelos/models/user_preferences.dart';

class BooksScreen extends StatefulWidget {
  final List<String> authors;
  final List<String> categories;
  final List<String> languages;
  final String format;
  final RangeValues pageRange;

  const BooksScreen({
    Key? key,
    required this.authors,
    required this.categories,
    required this.languages,
    required this.format,
    required this.pageRange,
  }) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late ApiService apiService;
  List<Book> books = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Inicializar el servicio con el endpoint correcto
    apiService = ApiService(baseUrl: 'http://192.168.22.1:3000/api');

    print("📚 Preferencias recibidas:");
    print("Autores: ${widget.authors}");
    print("Categorías: ${widget.categories}");
    print("Idiomas: ${widget.languages}");
    print("Formato: ${widget.format}");
    print("Rango de páginas: ${widget.pageRange.start}-${widget.pageRange.end}");

    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedBooks = await apiService.searchBooksMulti(
        authors: widget.authors,
        categories: widget.categories,
        languages: widget.languages,
        formats: [widget.format], // Se espera una lista
        minPages: widget.pageRange.start.round(),
        maxPages: widget.pageRange.end.round(),
      );

      setState(() {
        books = fetchedBooks;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar libros: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros recomendados')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : books.isEmpty
                  ? const Center(child: Text('No se encontraron libros'))
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return ListTile(
                          leading: book.thumbnail != null && book.thumbnail.isNotEmpty
                              ? Image.network(book.thumbnail, width: 50, fit: BoxFit.cover)
                              : const Icon(Icons.book, size: 50),
                          title: Text(book.title),
                          subtitle: Text(book.authors.join(', ')),
                        );
                      },
                    ),
    );
  }
}
