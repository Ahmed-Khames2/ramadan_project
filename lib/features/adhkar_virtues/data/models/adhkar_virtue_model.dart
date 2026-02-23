import '../../domain/entities/adhkar_virtue.dart';

class AdhkarVirtueModel extends AdhkarVirtue {
  const AdhkarVirtueModel({
    required super.order,
    required super.content,
    required super.count,
    required super.countDescription,
    required super.fadl,
    required super.source,
    required super.type,
    required super.hadithText,
    required super.vocabularyExplanation,
  });

  factory AdhkarVirtueModel.fromJson(Map<String, dynamic> json) {
    return AdhkarVirtueModel(
      order: json['order'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      count: json['count'] as int? ?? 1,
      countDescription: json['count_description'] as String? ?? '',
      fadl: json['fadl'] as String? ?? '',
      source: json['source'] as String? ?? '',
      type: json['type'] as int? ?? 0,
      hadithText: json['hadith_text'] as String? ?? '',
      vocabularyExplanation:
          json['explanation_of_hadith_vocabulary'] as String? ?? '',
    );
  }
}
