import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MushafReadingMode { white, beige, dark, navy }

class QuranSettingsState extends Equatable {
  final double fontScale;
  final MushafReadingMode readingMode;

  const QuranSettingsState({
    this.fontScale = 1.0,
    this.readingMode = MushafReadingMode.white,
  });

  QuranSettingsState copyWith({
    double? fontScale,
    MushafReadingMode? readingMode,
  }) {
    return QuranSettingsState(
      fontScale: fontScale ?? this.fontScale,
      readingMode: readingMode ?? this.readingMode,
    );
  }

  @override
  List<Object?> get props => [fontScale, readingMode];
}

class QuranSettingsCubit extends Cubit<QuranSettingsState> {
  final SharedPreferences _prefs;
  static const String _fontScaleKey = 'mushaf_font_scale';
  static const String _readingModeKey = 'mushaf_reading_mode';

  QuranSettingsCubit(this._prefs) : super(const QuranSettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final fontScale = _prefs.getDouble(_fontScaleKey) ?? 1.0;
    final readingModeIndex = _prefs.getInt(_readingModeKey) ?? 0;
    final readingMode = MushafReadingMode.values[readingModeIndex];

    emit(state.copyWith(fontScale: fontScale, readingMode: readingMode));
  }

  Future<void> updateFontScale(double scale) async {
    final clampedScale = scale.clamp(0.5, 2.0);
    emit(state.copyWith(fontScale: clampedScale));
    await _prefs.setDouble(_fontScaleKey, clampedScale);
  }

  void cycleReadingMode(bool isAppDark) {
    MushafReadingMode nextMode;
    if (isAppDark) {
      nextMode = (state.readingMode == MushafReadingMode.dark)
          ? MushafReadingMode.navy
          : MushafReadingMode.dark;
    } else {
      nextMode = (state.readingMode == MushafReadingMode.white)
          ? MushafReadingMode.beige
          : MushafReadingMode.white;
    }
    setReadingMode(nextMode);
  }

  Future<void> setReadingMode(MushafReadingMode mode) async {
    emit(state.copyWith(readingMode: mode));
    await _prefs.setInt(_readingModeKey, mode.index);
  }

  void updateForAppBrightness(bool isAppDark) {
    if (isAppDark &&
        (state.readingMode == MushafReadingMode.white ||
            state.readingMode == MushafReadingMode.beige)) {
      setReadingMode(MushafReadingMode.dark);
    } else if (!isAppDark &&
        (state.readingMode == MushafReadingMode.dark ||
            state.readingMode == MushafReadingMode.navy)) {
      setReadingMode(MushafReadingMode.white);
    }
  }
}
