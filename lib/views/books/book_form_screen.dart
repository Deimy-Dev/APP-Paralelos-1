import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class BookFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingBook;
  final String? docId;

  BookFormScreen({this.existingBook, this.docId});

  @override
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _author;
  int? _totalPages;
  int? _currentPage;
  double _rating = 0.0;
  String _status = 'Por leer';
  String _category = 'Sin categoría';
  String? _comment;
  File? _imageFile;
  String _addedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final List<String> _categories = ['Ficción', 'Educación', 'Ciencia', 'Autoayuda', 'Sin categoría'];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingBook != null) {
      final book = widget.existingBook!;
      _title = book['title'];
      _author = book['author'];
      _totalPages = book['totalPages'];
      _currentPage = book['currentPage'];
      _rating = (book['rating'] as num).toDouble();
      _status = book['status'];
      _category = book['category'];
      _comment = book['comment'];
      _addedDate = book['dateRead'] ?? _addedDate;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('book_covers/$userId/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    final bookData = {
      'img': imageUrl ?? widget.existingBook?['img'] ?? '',
      'title': _title!,
      'author': _author ?? '',
      'totalPages': _totalPages ?? 0,
      'currentPage': _currentPage ?? 0,
      'rating': _rating,
      'status': _status,
      'category': _category,
      'comment': _comment ?? '',
      'dateRead': _addedDate,
    };

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('read_books');

    if (widget.existingBook != null && widget.docId != null) {
      await collection.doc(widget.docId).update(bookData);
    } else {
      await collection.add(bookData);
    }

    Navigator.pop(context);
  }

  void _addNewCategory() {
    showDialog(
      context: context,
      builder: (context) {
        String newCategory = '';
        return AlertDialog(
          title: Text("Nueva categoría"),
          content: TextField(
            autofocus: true,
            onChanged: (value) => newCategory = value,
            decoration: InputDecoration(hintText: 'Nombre de la categoría'),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Agregar"),
              onPressed: () {
                if (newCategory.trim().isNotEmpty) {
                  setState(() {
                    _categories.add(newCategory);
                    _category = newCategory;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => setState(() => _rating = index + 1.0),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingBook == null ? 'Agregar libro' : 'Editar libro'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : (widget.existingBook != null && widget.existingBook!['img'] != '')
                        ? Image.network(widget.existingBook!['img'], height: 150)
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Center(child: Text("Seleccionar imagen")),
                          ),
              ),
              SizedBox(height: 16),

              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Título *'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                onSaved: (value) => _title = value,
              ),

              TextFormField(
                initialValue: _author,
                decoration: InputDecoration(labelText: 'Autor'),
                onSaved: (value) => _author = value,
              ),

              TextFormField(
                initialValue: _totalPages?.toString(),
                decoration: InputDecoration(labelText: 'Total de páginas'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _totalPages = int.tryParse(value ?? '0'),
              ),

              TextFormField(
                initialValue: _currentPage?.toString(),
                decoration: InputDecoration(labelText: 'Página actual'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _currentPage = int.tryParse(value ?? '0'),
              ),

              SizedBox(height: 12),
              Row(
                children: [
                  Text('Puntuación:'),
                  _buildRatingStars(),
                ],
              ),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Estatus'),
                items: ['Por leer', 'Leyendo', 'Terminado'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(labelText: 'Categoría'),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addNewCategory,
                    tooltip: 'Agregar nueva categoría',
                  ),
                ],
              ),

              TextFormField(
                initialValue: _comment,
                decoration: InputDecoration(labelText: 'Comentarios'),
                maxLines: 3,
                onSaved: (value) => _comment = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
