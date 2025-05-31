class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String thumbnail;
  final int pages;
  final List<String> categories;
  final String language;
  final String format;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnail = '',
    this.pages = 0,
    this.categories = const [],
    this.language = '',
    this.format = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
      pages: json['pages'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      language: json['language'] ?? '',
      format: json['format'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Book && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
