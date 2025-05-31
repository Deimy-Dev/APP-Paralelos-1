 import 'package:app1_paralelos/library/book_screen.dart';
import 'package:app1_paralelos/views/profile/EditProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1_paralelos/views/user_preferences_screen.dart';
import 'package:app1_paralelos/views/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullName;
  String? email;
  bool loading = true;

  List<String> authors = [];
  List<String> categories = [];
  List<String> languages = [];
  String format = 'Digital';
  RangeValues pageRange = RangeValues(100, 500);

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _loadPreferences());
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
    setState(() {
      email = user.email;
      fullName = doc.data()?['fullName'] ?? 'Nombre no disponible';
      loading = false;
    });
    print('📄 Datos de preferencias: ${doc.data()}');

  }
  

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        authors = List<String>.from(data['authors'] ?? []);
        categories = List<String>.from(data['categories'] ?? []);
        languages = List<String>.from(data['languages'] ?? []);
        format = data['format'] ?? 'Digital';
        final pageData = data['pageRange'];
        if (pageData != null) {
          pageRange = RangeValues(
            (pageData['min'] ?? 100).toDouble(),
            (pageData['max'] ?? 500).toDouble(),
          );
        }
      });
    }
  }

  Future<void> _resetPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('preferences')
        .doc('main')
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferencias reseteadas')),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.email).delete();
    await user.delete();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mi perfil')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            fullName ?? '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            email ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Divider(),

          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar perfil'),
            onTap: () async {
              final newName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
              if (newName != null) {
                setState(() => fullName = newName);
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Editar preferencias'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserPreferencesScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Mis estadísticas'),
            onTap: () {
              // Ir a StatsScreen
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Resetear preferencias'),
            onTap: _resetPreferences,
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false,
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Eliminar cuenta'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('¿Eliminar cuenta?'),
                  content: Text('Esta acción eliminará todos tus datos.'),
                  actions: [
                    TextButton(child: Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
                    TextButton(child: Text('Eliminar'), onPressed: () => Navigator.pop(context, true)),
                  ],
                ),
              );
              if (confirm == true) {
                await _deleteAccount();
              }
            },
          ),

          Divider(),

          Text("🎯 Tus preferencias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("📚 Autores: ${authors.isNotEmpty ? authors.join(', ') : 'No definidos'}"),
          Text("📂 Categorías: ${categories.isNotEmpty ? categories.join(', ') : 'No definidas'}"),
          Text("🌐 Idiomas: ${languages.isNotEmpty ? languages.join(', ') : 'No definidos'}"),
          Text("📦 Formato: $format"),
          Text("📄 Rango de páginas: ${pageRange.start.round()} - ${pageRange.end.round()} páginas"),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BooksScreen(
                    authors: authors,
                    categories: categories,
                    languages: languages,
                    format: format,
                    pageRange: pageRange,
                  ),
                ),
              );
            },
            icon: Icon(Icons.book),
            label: Text('Ver libros sugeridos'),
          ),
        ],
      ),
    );
  }
}













/*import 'package:app1_paralelos/library/book_screen.dart';
import 'package:app1_paralelos/views/profile/EditProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1_paralelos/views/user_preferences_screen.dart';
import 'package:app1_paralelos/views/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullName;
  String? email;
  bool loading = true;

  List<String> authors = [];
  List<String> categories = [];
  List<String> languages = [];
  String format = 'Digital';
  RangeValues pageRange = RangeValues(100, 500);

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _loadPreferences());
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
    setState(() {
      email = user.email;
      fullName = doc.data()?['fullName'] ?? 'Nombre no disponible';
      loading = false;
    });
    print('📄 Datos de preferencias: ${doc.data()}');
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email) // <- Asegúrate que sea `email`, no `uid`, por consistencia
        .collection('preferences')
        .doc('main')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        authors = List<String>.from(data['authors'] ?? []);
        categories = List<String>.from(data['categories'] ?? []);
        languages = List<String>.from(data['languages'] ?? []);
        format = data['format'] ?? 'Digital';
        final pageData = data['pageRange'];
        if (pageData != null) {
          pageRange = RangeValues(
            (pageData['min'] ?? 100).toDouble(),
            (pageData['max'] ?? 500).toDouble(),
          );
        }
      });
    }
  }

  Future<void> _resetPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('preferences')
        .doc('main')
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferencias reseteadas')),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.email).delete();
    await user.delete();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mi perfil')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            fullName ?? '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            email ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Divider(),

          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Editar perfil'),
            onTap: () async {
              final newName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
              if (newName != null) {
                setState(() => fullName = newName);
              }
            },
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Editar preferencias'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserPreferencesScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Mis estadísticas'),
            onTap: () {
              // Ir a StatsScreen
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Resetear preferencias'),
            onTap: _resetPreferences,
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false,
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Eliminar cuenta'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('¿Eliminar cuenta?'),
                  content: Text('Esta acción eliminará todos tus datos.'),
                  actions: [
                    TextButton(child: Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
                    TextButton(child: Text('Eliminar'), onPressed: () => Navigator.pop(context, true)),
                  ],
                ),
              );
              if (confirm == true) {
                await _deleteAccount();
              }
            },
          ),

          Divider(),

          Text("🎯 Tus preferencias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("📚 Autores: ${authors.isNotEmpty ? authors.join(', ') : 'No definidos'}"),
          Text("📂 Categorías: ${categories.isNotEmpty ? categories.join(', ') : 'No definidas'}"),
          Text("🌐 Idiomas: ${languages.isNotEmpty ? languages.join(', ') : 'No definidos'}"),
          Text("📦 Formato: $format"),
          Text("📄 Rango de páginas: ${pageRange.start.round()} - ${pageRange.end.round()} páginas"),

          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BooksScreen(
                    authors: authors,
                    categories: categories,
                    languages: languages,
                    format: format,
                    pageRange: pageRange,
                  ),
                ),
              );
            },
            icon: Icon(Icons.book),
            label: Text('Ver libros sugeridos'),
          ),
        ],
      ),
    );
  }
}


*/