import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferencesScreen extends StatefulWidget {
  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  TextEditingController authorsController = TextEditingController();
  TextEditingController categoriesController = TextEditingController();
  TextEditingController languagesController = TextEditingController();
  TextEditingController formatController = TextEditingController();

  RangeValues pageRange = RangeValues(100, 500);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  void dispose() {
    authorsController.dispose();
    categoriesController.dispose();
    languagesController.dispose();
    formatController.dispose();
    super.dispose();
  }

  Future<void> loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc(user.uid);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        authorsController.text = (data['authors'] as List<dynamic>?)
                ?.join(', ') ??
            '';
        categoriesController.text = (data['categories'] as List<dynamic>?)
                ?.join(', ') ??
            '';
        languagesController.text = (data['languages'] as List<dynamic>?)
                ?.join(', ') ??
            '';
        formatController.text = data['format'] ?? '';

        final pageData = data['pageRange'];
        if (pageData != null) {
          pageRange = RangeValues(
            (pageData['min'] ?? 100).toDouble(),
            (pageData['max'] ?? 500).toDouble(),
          );
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Editar preferencias')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Editar preferencias')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Autores favoritos'),
              TextField(
                controller: authorsController,
                decoration: InputDecoration(
                  hintText: 'Autores separados por coma',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),

              Text('Categorías'),
              TextField(
                controller: categoriesController,
                decoration: InputDecoration(
                  hintText: 'Categorías separadas por coma',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),

              Text('Idiomas'),
              TextField(
                controller: languagesController,
                decoration: InputDecoration(
                  hintText: 'Idiomas separados por coma',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 16),

              Text('Formato'),
              TextField(
                controller: formatController,
                decoration: InputDecoration(
                  hintText: 'Formato preferido',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              Text('Rango de páginas'),
              RangeSlider(
                values: pageRange,
                min: 0,
                max: 1000,
                divisions: 20,
                labels: RangeLabels(
                  pageRange.start.round().toString(),
                  pageRange.end.round().toString(),
                ),
                onChanged: (newRange) {
                  setState(() {
                    pageRange = newRange;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
