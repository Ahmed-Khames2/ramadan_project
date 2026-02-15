import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final String id;
  final String name;
  final String arabicName;
  final String? imagePath;

  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, name, arabicName, imagePath];
}
