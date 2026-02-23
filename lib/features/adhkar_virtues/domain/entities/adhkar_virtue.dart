import 'package:equatable/equatable.dart';

class AdhkarVirtue extends Equatable {
  final int order;
  final String content;
  final int count;
  final String countDescription;
  final String fadl;
  final String source;
  final int type; // 0: General, 1: Morning, 2: Evening
  final String hadithText;
  final String vocabularyExplanation;

  const AdhkarVirtue({
    required this.order,
    required this.content,
    required this.count,
    required this.countDescription,
    required this.fadl,
    required this.source,
    required this.type,
    required this.hadithText,
    required this.vocabularyExplanation,
  });

  @override
  List<Object?> get props => [
    order,
    content,
    count,
    countDescription,
    fadl,
    source,
    type,
    hadithText,
    vocabularyExplanation,
  ];
}
