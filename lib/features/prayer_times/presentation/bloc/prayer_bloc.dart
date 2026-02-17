import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/governorate.dart';
import 'package:ramadan_project/features/prayer_times/domain/repositories/prayer_repository.dart';

// Events
abstract class PrayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrayerData extends PrayerEvent {}

class SelectGovernorate extends PrayerEvent {
  final Governorate governorate;
  SelectGovernorate(this.governorate);

  @override
  List<Object?> get props => [governorate];
}

class ToggleNotifications extends PrayerEvent {
  final bool enabled;
  ToggleNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateLeadTime extends PrayerEvent {
  final int minutes;
  UpdateLeadTime(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class RefreshPrayers extends PrayerEvent {}

// States
abstract class PrayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final List<Governorate> governorates;
  final Governorate selectedGovernorate;
  final List<PrayerTime> prayerTimes;
  final DateTime lastUpdated;
  final bool notificationsEnabled;
  final int leadTimeMinutes;

  PrayerLoaded({
    required this.governorates,
    required this.selectedGovernorate,
    required this.prayerTimes,
    required this.lastUpdated,
    this.notificationsEnabled = true,
    this.leadTimeMinutes = 5,
  });

  @override
  List<Object?> get props => [
    governorates,
    selectedGovernorate,
    prayerTimes,
    lastUpdated,
    notificationsEnabled,
    leadTimeMinutes,
  ];

  PrayerLoaded copyWith({
    List<Governorate>? governorates,
    Governorate? selectedGovernorate,
    List<PrayerTime>? prayerTimes,
    DateTime? lastUpdated,
    bool? notificationsEnabled,
    int? leadTimeMinutes,
  }) {
    return PrayerLoaded(
      governorates: governorates ?? this.governorates,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes,
    );
  }
}

class PrayerError extends PrayerState {
  final String message;
  PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repository;
  final SharedPreferences prefs;
  Timer? _refreshTimer;

  static const String _kGovernorateKey = 'selected_governorate';

  PrayerBloc({required this.repository, required this.prefs})
    : super(PrayerInitial()) {
    on<LoadPrayerData>(_onLoadPrayerData);
    on<SelectGovernorate>(_onSelectGovernorate);
    on<RefreshPrayers>(_onRefreshPrayers);

    // Refresh every minute to update "current prayer" highlighting
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      add(RefreshPrayers());
    });
  }

  Future<void> _onLoadPrayerData(
    LoadPrayerData event,
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoading());
    try {
      final governorates = repository.getGovernorates();

      // Load saved governorate or default to Cairo
      final savedGovName = prefs.getString(_kGovernorateKey);
      final initialGov = governorates.firstWhere(
        (g) => g.nameEnglish == savedGovName,
        orElse: () => governorates.first, // Default is Cairo
      );

      final prayerTimes = repository.getPrayerTimes(initialGov, DateTime.now());

      final newState = PrayerLoaded(
        governorates: governorates,
        selectedGovernorate: initialGov,
        prayerTimes: prayerTimes,
        lastUpdated: DateTime.now(),
      );

      emit(newState);
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }

  Future<void> _onSelectGovernorate(
    SelectGovernorate event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      try {
        // Persist selection
        await prefs.setString(_kGovernorateKey, event.governorate.nameEnglish);

        final prayerTimes = repository.getPrayerTimes(
          event.governorate,
          DateTime.now(),
        );
        final newState = currentState.copyWith(
          selectedGovernorate: event.governorate,
          prayerTimes: prayerTimes,
          lastUpdated: DateTime.now(),
        );
        emit(newState);
      } catch (e) {
        emit(PrayerError(e.toString()));
      }
    }
  }

  void _onRefreshPrayers(RefreshPrayers event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final prayerTimes = repository.getPrayerTimes(
        currentState.selectedGovernorate,
        DateTime.now(),
      );
      emit(
        currentState.copyWith(
          prayerTimes: prayerTimes,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
