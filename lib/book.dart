class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnail;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      authors: List<String>.from(json['authors'] ?? []),
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
