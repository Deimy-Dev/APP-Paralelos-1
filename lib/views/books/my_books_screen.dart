import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_form_screen.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  String selectedFilter = "Todos";

  Future<void> _deleteBook(String docId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('read_books')
        .doc(docId)
        .delete();
  }

  _editBook(BuildContext context, String docId, Map<String, dynamic> bookData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookFormScreen(
          existingBook: bookData,
          docId: docId, // pasa docId por separado
        ),
      ),
    );
  }


  void _goToAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookFormScreen()),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = selectedFilter == label;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("No se ha iniciado sesión."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis libros"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _goToAddBook,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('read_books')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error al cargar libros'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          final filteredDocs = selectedFilter == "Todos"
              ? allDocs
              : allDocs.where((doc) => (doc['status'] ?? '') == selectedFilter).toList();

          return Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton("Todos"),
                  _buildFilterButton("Por leer"),
                  _buildFilterButton("Leyendo"),
                  _buildFilterButton("Terminados"),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: allDocs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("No tienes libros guardados."),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _goToAddBook,
                              child: const Text("Agregar libro"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Sin título';
                          final author = data['author'] ?? 'Autor desconocido';
                          final imageUrl = data['img'] ?? '';

                          return ListTile(
                            leading: imageUrl.isNotEmpty
                                ? Image.network(imageUrl, width: 50, fit: BoxFit.cover)
                                : const Icon(Icons.book),
                            title: Text(title),
                            subtitle: Text(author),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editBook(context, doc.id, data);
                                } else if (value == 'delete') {
                                  _deleteBook(doc.id);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Editar')),
                                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
