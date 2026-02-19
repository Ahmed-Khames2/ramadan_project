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
  static const String _kLastLatKey = 'last_latitude';
  static const String _kLastLngKey = 'last_longitude';
  static const String _kLastCityKey = 'last_city_name';

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
    // Explicitly use Cairo as the default
    final defaultGov = governorates.firstWhere(
      (g) => g.nameEnglish == 'Cairo',
      orElse: () => governorates.first,
    );
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
    final governorates = repository.getGovernorates();
    final defaultGov = governorates.firstWhere(
      (g) => g.nameEnglish == 'Cairo',
      orElse: () => governorates.first,
    );

    try {
      final savedGovName = prefs.getString(_kGovernorateKey);

      if (savedGovName != null && savedGovName != 'Current Location') {
        // 1. User has manually selected a city
        final selectedGov = governorates.firstWhere(
          (g) => g.nameEnglish == savedGovName,
          orElse: () => defaultGov,
        );

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
      } else {
        // 2. No saved city or "Current Location" is preferred
        // Try to get fresh location, but don't block too long
        final position = await _locationService.determinePosition();

        if (position != null) {
          await _updateLocationState(
            position.latitude,
            position.longitude,
            emit,
          );
        } else {
          // 3. Fallback to Last Known Cached Location
          final lastLat = prefs.getDouble(_kLastLatKey);
          final lastLng = prefs.getDouble(_kLastLngKey);
          final lastCity = prefs.getString(_kLastCityKey);

          if (lastLat != null && lastLng != null) {
            final prayerTimes = repository.getPrayerTimesByCoordinates(
              lastLat,
              lastLng,
              DateTime.now(),
            );
            final locationGov = Governorate(
              nameArabic: lastCity ?? 'موقعي السابق',
              nameEnglish: 'Current Location',
              latitude: lastLat,
              longitude: lastLng,
            );
            emit(
              (state as PrayerLoaded).copyWith(
                selectedGovernorate: locationGov,
                prayerTimes: prayerTimes,
                lastUpdated: DateTime.now(),
              ),
            );
          } else {
            // 4. Ultimate Fallback to Cairo
            final prayerTimes = repository.getPrayerTimes(
              defaultGov,
              DateTime.now(),
            );
            emit(
              (state as PrayerLoaded).copyWith(
                selectedGovernorate: defaultGov,
                prayerTimes: prayerTimes,
                lastUpdated: DateTime.now(),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Silent fallback
    }
  }

  Future<void> _updateLocationState(
    double lat,
    double lng,
    Emitter<PrayerState> emit,
  ) async {
    final prayerTimes = repository.getPrayerTimesByCoordinates(
      lat,
      lng,
      DateTime.now(),
    );
    final cityName = await _locationService.getCityFromCoordinates(lat, lng);

    // Save to cache
    await prefs.setDouble(_kLastLatKey, lat);
    await prefs.setDouble(_kLastLngKey, lng);
    if (cityName != null) await prefs.setString(_kLastCityKey, cityName);

    final locationGov = Governorate(
      nameArabic: cityName ?? 'موقعي الحالي',
      nameEnglish: 'Current Location',
      latitude: lat,
      longitude: lng,
    );

    if (state is PrayerLoaded) {
      emit(
        (state as PrayerLoaded).copyWith(
          selectedGovernorate: locationGov,
          prayerTimes: prayerTimes,
          lastUpdated: DateTime.now(),
        ),
      );
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
            await _updateLocationState(
              position.latitude,
              position.longitude,
              emit,
            );
          } else {
            // Handle failure or denial
            final lastLat = prefs.getDouble(_kLastLatKey);
            final lastLng = prefs.getDouble(_kLastLngKey);

            if (lastLat != null && lastLng != null) {
              await _updateLocationState(lastLat, lastLng, emit);
            } else {
              // Redirect to Cairo if absolutely nothing works
              final cairo = currentState.governorates.firstWhere(
                (g) => g.nameEnglish == 'Cairo',
                orElse: () => currentState.governorates.first,
              );
              final prayerTimes = repository.getPrayerTimes(
                cairo,
                DateTime.now(),
              );
              emit(
                currentState.copyWith(
                  selectedGovernorate: cairo,
                  prayerTimes: prayerTimes,
                  lastUpdated: DateTime.now(),
                ),
              );
            }
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
