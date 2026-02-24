import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeCubit extends Cubit<AppThemeMode> {
  static const String _kThemeModeKey =
      'theme_mode_v2'; // Changed key for the new enum
  final SharedPreferences _prefs;

  ThemeModeCubit(this._prefs) : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = _prefs.getString(_kThemeModeKey);
    if (savedMode == 'light') {
      emit(AppThemeMode.light);
    } else if (savedMode == 'dark' || savedMode == 'navy') {
      emit(AppThemeMode.dark); // Redirect navy users to dark
    } else {
      emit(AppThemeMode.system);
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case AppThemeMode.light:
        modeStr = 'light';
        break;
      case AppThemeMode.dark:
        modeStr = 'dark';
        break;
      case AppThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _prefs.setString(_kThemeModeKey, modeStr);
    emit(mode);
  }
}
