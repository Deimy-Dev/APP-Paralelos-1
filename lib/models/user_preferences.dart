import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferences {
  final List<String> authors;
  final List<String> categories;
  final List<String> languages;
  final List<String> formats;

  UserPreferences({
    required this.authors,
    required this.categories,
    required this.languages,
    required this.formats,
  });

  factory UserPreferences.fromFirestore(Map<String, dynamic> data) {
    return UserPreferences(
      authors: List<String>.from(data['authors'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      formats: List<String>.from(data['formats'] ?? []),
    );
  }
}

Future<UserPreferences> fetchUserPreferences(String userId) async {
  final firestore = FirebaseFirestore.instance;

  final docSnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('preferences')
      .doc(userId)
      .get();

  if (!docSnapshot.exists) {
    return UserPreferences(authors: [], categories: [], languages: [], formats: []);
  }

  return UserPreferences.fromFirestore(docSnapshot.data()!);
}
