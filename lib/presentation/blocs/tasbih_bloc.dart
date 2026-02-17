import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Events
abstract class TasbihEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class IncrementCount extends TasbihEvent {}

class ResetTasbih extends TasbihEvent {}

class UpdateBeadSettings extends TasbihEvent {
  final int totalBeads;
  final String material;
  UpdateBeadSettings({required this.totalBeads, required this.material});
  @override
  List<Object?> get props => [totalBeads, material];
}

// State
class TasbihState extends Equatable {
  final int count;
  final int rounds;
  final int targetCount;
  final String material;
  final bool soundEnabled;
  final bool hapticEnabled;

  const TasbihState({
    this.count = 0,
    this.rounds = 0,
    this.targetCount = 33,
    this.material = 'emerald',
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  TasbihState copyWith({
    int? count,
    int? rounds,
    int? targetCount,
    String? material,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return TasbihState(
      count: count ?? this.count,
      rounds: rounds ?? this.rounds,
      targetCount: targetCount ?? this.targetCount,
      material: material ?? this.material,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  @override
  List<Object?> get props => [
    count,
    rounds,
    targetCount,
    material,
    soundEnabled,
    hapticEnabled,
  ];

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'rounds': rounds,
      'targetCount': targetCount,
      'material': material,
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
    };
  }

  factory TasbihState.fromJson(Map<dynamic, dynamic> json) {
    return TasbihState(
      count: json['count'] ?? 0,
      rounds: json['rounds'] ?? 0,
      targetCount: json['targetCount'] ?? 33,
      material: json['material'] ?? 'emerald',
      soundEnabled: json['soundEnabled'] ?? true,
      hapticEnabled: json['hapticEnabled'] ?? true,
    );
  }
}

// Bloc
class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final Box _box = Hive.box('tasbih');

  TasbihBloc() : super(_getInitialState()) {
    on<IncrementCount>((event, emit) {
      int nextCount = state.count + 1;
      int nextRounds = state.rounds;

      if (nextCount >= state.targetCount) {
        nextCount = 0;
        nextRounds++;
      }

      final newState = state.copyWith(count: nextCount, rounds: nextRounds);
      _saveState(newState);
      emit(newState);
    });

    on<ResetTasbih>((event, emit) {
      final newState = state.copyWith(count: 0, rounds: 0);
      _saveState(newState);
      emit(newState);
    });

    on<UpdateBeadSettings>((event, emit) {
      final newState = state.copyWith(
        targetCount: event.totalBeads,
        material: event.material,
        // Preserve current count and rounds as requested
        count: state.count,
        rounds: state.rounds,
      );
      _saveState(newState);
      emit(newState);
    });
  }

  static TasbihState _getInitialState() {
    try {
      final box = Hive.box('tasbih');
      final savedData = box.get('session');
      if (savedData != null) {
        return TasbihState.fromJson(Map<dynamic, dynamic>.from(savedData));
      }
    } catch (_) {}
    return const TasbihState();
  }

  void _saveState(TasbihState state) {
    _box.put('session', state.toJson());
  }
}
