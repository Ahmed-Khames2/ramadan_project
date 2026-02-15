part of 'khatam_bloc.dart';

abstract class KhatamState extends Equatable {
  const KhatamState();

  @override
  List<Object?> get props => [];
}

class KhatamInitial extends KhatamState {}

class KhatamLoading extends KhatamState {}

class KhatamLoaded extends KhatamState {
  final KhatamPlan? plan;
  final UserProgressModel progress;
  final KhatmahPlan? khatmahPlan;

  const KhatamLoaded({this.plan, required this.progress, this.khatmahPlan});

  @override
  List<Object?> get props => [plan, progress, khatmahPlan];
}

class KhatamError extends KhatamState {
  final String message;

  const KhatamError(this.message);

  @override
  List<Object> get props => [message];
}
