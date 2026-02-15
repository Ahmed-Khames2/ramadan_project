import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ramadan_project/features/azkar/data/models/azkar_model.dart';
import 'package:ramadan_project/features/azkar/data/repositories/azkar_repository.dart';

// Events
abstract class AzkarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllAzkar extends AzkarEvent {}

class TapZekr extends AzkarEvent {
  final String zekrId;
  final int maxRepeat;
  TapZekr({required this.zekrId, required this.maxRepeat});

  @override
  List<Object?> get props => [zekrId, maxRepeat];
}

class ResetCategoryProgress extends AzkarEvent {
  final List<ZekrModel> azkarTexts;
  ResetCategoryProgress(this.azkarTexts);

  @override
  List<Object?> get props => [azkarTexts];
}

// State
class AzkarState extends Equatable {
  final List<AzkarItem> allAzkar;
  final Map<String, int> progress; // uniqueZekrId -> currentCount
  final bool isLoading;
  final String? error;

  const AzkarState({
    this.allAzkar = const [],
    this.progress = const {},
    this.isLoading = false,
    this.error,
  });

  AzkarState copyWith({
    List<AzkarItem>? allAzkar,
    Map<String, int>? progress,
    bool? isLoading,
    String? error,
  }) {
    return AzkarState(
      allAzkar: allAzkar ?? this.allAzkar,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [allAzkar, progress, isLoading, error];
}

// Bloc
class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final AzkarRepository _repository;
  final Box _progressBox = Hive.box('azkar_progress');

  AzkarBloc(this._repository) : super(const AzkarState()) {
    on<LoadAllAzkar>(_onLoadAllAzkar);
    on<TapZekr>(_onTapZekr);
    on<ResetCategoryProgress>(_onResetCategoryProgress);
  }

  Future<void> _onLoadAllAzkar(
    LoadAllAzkar event,
    Emitter<AzkarState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final azkar = await _repository.getAllAzkar();

      final Map<String, int> initialProgress = {};
      for (var item in azkar) {
        for (var zekr in item.azkarTexts) {
          initialProgress[zekr.id] = _progressBox.get(zekr.id, defaultValue: 0);
        }
      }

      emit(
        state.copyWith(
          allAzkar: azkar,
          progress: initialProgress,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onTapZekr(TapZekr event, Emitter<AzkarState> emit) {
    final currentCount = state.progress[event.zekrId] ?? 0;
    if (currentCount < event.maxRepeat) {
      final newCount = currentCount + 1;
      final newProgress = Map<String, int>.from(state.progress);
      newProgress[event.zekrId] = newCount;

      _progressBox.put(event.zekrId, newCount);
      emit(state.copyWith(progress: newProgress));
    }
  }

  void _onResetCategoryProgress(
    ResetCategoryProgress event,
    Emitter<AzkarState> emit,
  ) {
    final newProgress = Map<String, int>.from(state.progress);
    for (var zekr in event.azkarTexts) {
      newProgress[zekr.id] = 0;
      _progressBox.put(zekr.id, 0);
    }
    emit(state.copyWith(progress: newProgress));
  }
}
