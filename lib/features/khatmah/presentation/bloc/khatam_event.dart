part of 'khatam_bloc.dart';

abstract class KhatamEvent extends Equatable {
  const KhatamEvent();

  @override
  List<Object> get props => [];
}

class CreateKhatamPlan extends KhatamEvent {
  final int targetDays;
  final DateTime startDate;

  const CreateKhatamPlan(this.targetDays, this.startDate);

  @override
  List<Object> get props => [targetDays, startDate];
}

class UpdateProgress extends KhatamEvent {
  final int currentPage;
  final int currentAyah;

  const UpdateProgress(this.currentPage, this.currentAyah);

  @override
  List<Object> get props => [currentPage, currentAyah];
}

class LoadKhatamData extends KhatamEvent {}

class ToggleReadingMode extends KhatamEvent {}

class CreateAdvancedKhatmahPlan extends KhatamEvent {
  final int targetDays;
  final DateTime startDate;
  final bool restDaysEnabled;
  final List<int> restDays;
  final String title;

  const CreateAdvancedKhatmahPlan({
    required this.targetDays,
    required this.startDate,
    this.restDaysEnabled = false,
    this.restDays = const [],
    this.title = 'ختمة جديدة',
  });

  @override
  List<Object> get props => [
    targetDays,
    startDate,
    restDaysEnabled,
    restDays,
    title,
  ];
}

class UpdateKhatmahProgress extends KhatamEvent {
  final int page;

  const UpdateKhatmahProgress(this.page);

  @override
  List<Object> get props => [page];
}
