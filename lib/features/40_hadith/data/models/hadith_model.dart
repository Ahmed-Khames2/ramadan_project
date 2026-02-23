import '../../domain/entities/hadith.dart';

class HadithModel extends Hadith {
  HadithModel({
    required super.title,
    required super.content,
    required super.description,
    required super.index,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json, int index) {
    final rawHadith = json['hadith'] as String;
    final parts = rawHadith.split('\n\n');

    String title = 'الحديث ${index + 1}';
    String content = rawHadith;

    if (parts.length >= 2) {
      title = parts[0].trim();
      content = parts.sublist(1).join('\n\n').trim();
    }

    return HadithModel(
      title: title,
      content: content,
      description: json['description'] as String,
      index: index,
    );
  }

  Map<String, dynamic> toJson() {
    return {'hadith': '$title\n\n$content', 'description': description};
  }
}
