import 'package:app1_paralelos/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferencesScreen extends StatefulWidget {
  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final TextEditingController _authorController = TextEditingController();
  List<String> authors = [];
  List<String> selectedCategories = [];
  List<String> selectedLanguages = [];
  String format = 'Digital';
  RangeValues pageRange = RangeValues(100, 500);

  final List<String> allCategories = [
    'Fantasía', 'Ciencia Ficción', 'Romance', 'Terror', 'Historia'
  ];
  final List<String> allLanguages = ['es', 'en', 'fr', 'de', 'it'];

  void _addAuthor() {
    final author = _authorController.text.trim();
    if (author.isNotEmpty && !authors.contains(author)) {
      setState(() {
        authors.add(author);
        _authorController.clear();
      });
    }
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final preferencesData = {
      'authors': authors,
      'categories': selectedCategories,
      'languages': selectedLanguages,
      'format': format,
      'pageRange': {
        'min': pageRange.start.round(),
        'max': pageRange.end.round(),
      }
    };

    // 🔄 Guarda las preferencias en users/{uid}/preferences/{uid}
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc(user.uid); // ✅ usar el uid como ID del documento también

    await docRef.set(preferencesData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferencias guardadas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preferencias de lectura')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Autores favoritos
            Text('Autores favoritos'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _authorController,
                    decoration: InputDecoration(hintText: 'Agregar autor'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addAuthor,
                )
              ],
            ),
            Wrap(
              spacing: 8.0,
              children: authors
                  .map((author) => Chip(
                        label: Text(author),
                        onDeleted: () {
                          setState(() {
                            authors.remove(author);
                          });
                        },
                      ))
                  .toList(),
            ),

            SizedBox(height: 20),

            // Categorías favoritas
            Text('Categorías favoritas'),
            ...allCategories.map((category) => CheckboxListTile(
                  title: Text(category),
                  value: selectedCategories.contains(category),
                  onChanged: (val) {
                    setState(() {
                      val!
                          ? selectedCategories.add(category)
                          : selectedCategories.remove(category);
                    });
                  },
                )),

            SizedBox(height: 20),

            // Idiomas preferidos
            Text('Idiomas preferidos'),
            ...allLanguages.map((lang) => CheckboxListTile(
                  title: Text(lang),
                  value: selectedLanguages.contains(lang),
                  onChanged: (val) {
                    setState(() {
                      val!
                          ? selectedLanguages.add(lang)
                          : selectedLanguages.remove(lang);
                    });
                  },
                )),

            SizedBox(height: 20),

            // Formato preferido
            Text('Formato preferido'),
            ...['Digital', 'Físico', 'Ambos'].map((f) => RadioListTile(
                  title: Text(f),
                  value: f,
                  groupValue: format,
                  onChanged: (val) {
                    setState(() {
                      format = val!;
                    });
                  },
                )),

            SizedBox(height: 20),

            // Rango de páginas
            Text(
                'Rango de páginas: ${pageRange.start.round()} - ${pageRange.end.round()}'),
            RangeSlider(
              values: pageRange,
              min: 50,
              max: 1000,
              divisions: 19,
              labels: RangeLabels(
                '${pageRange.start.round()}',
                '${pageRange.end.round()}',
              ),
              onChanged: (val) {
                setState(() {
                  pageRange = val;
                });
              },
            ),

            SizedBox(height: 30),

            // Botón guardar
            ElevatedButton(
              onPressed: () async {
                await _savePreferences();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: Text('Guardar preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
