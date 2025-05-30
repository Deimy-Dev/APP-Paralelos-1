import 'package:flutter/material.dart';
import 'books/my_books_screen.dart';
import 'package:app1_paralelos/library/library_screen.dart';
import 'summaries/summary_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MyBooksScreen(),        // Pantalla principal
    //LibraryScreen(),     // Librería (con API en el futuro)
    SummaryScreen(),      // Resumen de lectura mensual
    ProfileScreen(),     // Perfil y logout
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Mis libros'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Librería'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
