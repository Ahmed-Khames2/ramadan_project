import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/prayer_time.dart';
import 'package:ramadan_project/features/prayer_times/domain/entities/governorate.dart';
import 'package:ramadan_project/features/prayer_times/domain/repositories/prayer_repository.dart';
import 'package:ramadan_project/core/services/location_service.dart';

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
  final LocationService _locationService = LocationService();
  Timer? _refreshTimer;

  static const String _kGovernorateKey = 'selected_governorate';

  PrayerBloc({required this.repository, required this.prefs})
    : super(_createInitialState(repository)) {
    on<LoadPrayerData>(_onLoadPrayerData);
    on<SelectGovernorate>(_onSelectGovernorate);
    on<RefreshPrayers>(_onRefreshPrayers);

    // Refresh every minute to update "current prayer" highlighting
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      add(RefreshPrayers());
    });
  }

  static PrayerState _createInitialState(PrayerRepository repository) {
    final governorates = repository.getGovernorates();
    final defaultGov = governorates.first; // Cairo
    final defaultPrayerTimes = repository.getPrayerTimes(
      defaultGov,
      DateTime.now(),
    );
    return PrayerLoaded(
      governorates: governorates,
      selectedGovernorate: defaultGov,
      prayerTimes: defaultPrayerTimes,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _onLoadPrayerData(
    LoadPrayerData event,
    Emitter<PrayerState> emit,
  ) async {
    // 1. Initial state is already PrayerLoaded with default data.
    // So we don't need to emit anything here to "start" the UI.
    // The UI will already be showing Cairo data.

    final governorates = repository.getGovernorates();
    final defaultGov = governorates.first; // Cairo

    // 2. Check for Saved City or Location in Background
    try {
      final savedGovName = prefs.getString(_kGovernorateKey);

      if (savedGovName != null && savedGovName != 'Current Location') {
        // User has manually selected a city before
        final selectedGov = governorates.firstWhere(
          (g) => g.nameEnglish == savedGovName,
          orElse: () => defaultGov,
        );

        if (selectedGov.nameEnglish != defaultGov.nameEnglish) {
          final prayerTimes = repository.getPrayerTimes(
            selectedGov,
            DateTime.now(),
          );
          emit(
            (state as PrayerLoaded).copyWith(
              selectedGovernorate: selectedGov,
              prayerTimes: prayerTimes,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      } else {
        // No saved city, try to get location
        final position = await _locationService.determinePosition();

        if (position != null) {
          // Location found! Use coordinates
          final prayerTimes = repository.getPrayerTimesByCoordinates(
            position.latitude,
            position.longitude,
            DateTime.now(),
          );

          final cityName = await _locationService.getCityFromCoordinates(
            position.latitude,
            position.longitude,
          );

          final locationGov = Governorate(
            nameArabic: cityName ?? 'موقعي الحالي',
            nameEnglish: 'Current Location',
            latitude: position.latitude,
            longitude: position.longitude,
          );

          emit(
            (state as PrayerLoaded).copyWith(
              selectedGovernorate: locationGov,
              prayerTimes: prayerTimes,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      // Silent error - keep showing default data
    }
  }

  Future<void> _onSelectGovernorate(
    SelectGovernorate event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      try {
        // Check if "Current Location" is selected
        if (event.governorate.nameEnglish == 'Current Location') {
          // Trigger location update logic similar to _onLoadPrayerData
          // We can't reuse _onLoadPrayerData directly easily without refactoring,
          // so I'll extract logic or duplicate for now safely.
          // Actually, better to just emit Loading or keep current state and then update.

          // Persist "Current Location" selection
          await prefs.setString(_kGovernorateKey, 'Current Location');

          final position = await _locationService.determinePosition();

          if (position != null) {
            final prayerTimes = repository.getPrayerTimesByCoordinates(
              position.latitude,
              position.longitude,
              DateTime.now(),
            );

            final cityName = await _locationService.getCityFromCoordinates(
              position.latitude,
              position.longitude,
            );

            final locationGov = Governorate(
              nameArabic: cityName ?? 'موقعي الحالي',
              nameEnglish: 'Current Location',
              latitude: position.latitude,
              longitude: position.longitude,
            );

            emit(
              currentState.copyWith(
                selectedGovernorate: locationGov,
                prayerTimes: prayerTimes,
                lastUpdated: DateTime.now(),
              ),
            );
          } else {
            // If location fails, stick with Cairo (default) but maybe update name?
            // Or just error? Let's fallback to Cairo but keep selection?
            // For now, let's just do nothing or show error.
          }
        } else {
          // Normal city selection
          // Persist selection
          await prefs.setString(
            _kGovernorateKey,
            event.governorate.nameEnglish,
          );

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
        }
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
