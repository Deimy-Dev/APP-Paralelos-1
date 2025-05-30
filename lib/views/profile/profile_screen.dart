import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart'; // Ajusta según tu estructura

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: user == null
          ? Text("No hay usuario registrado")
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 100, color: Colors.grey),
                SizedBox(height: 20),
                Text("Email: ${user!.email}", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("UID: ${user!.uid}", style: TextStyle(fontSize: 14)),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: Icon(Icons.logout),
                  label: Text("Cerrar sesión"),
                ),
              ],
            ),
    );
  }
}
