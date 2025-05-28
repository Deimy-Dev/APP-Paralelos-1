import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/auth_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';

void main() {
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'BookWise',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? HomeScreen() : LoginScreen();
          },
        ),
      ),
    );
  }
}