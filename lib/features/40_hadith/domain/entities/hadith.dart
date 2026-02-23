class Hadith {
  final String title;
  final String content;
  final String description;
  final int index;

  Hadith({
    required this.title,
    required this.content,
    required this.description,
    required this.index,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hadith &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content &&
          description == other.description &&
          index == other.index;

  @override
  int get hashCode =>
      title.hashCode ^ content.hashCode ^ description.hashCode ^ index.hashCode;
}
