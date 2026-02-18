import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ramadan_project/presentation/blocs/search_bloc.dart';
import 'package:ramadan_project/data/models/user_progress_model.dart';
import 'package:ramadan_project/core/navigation/navigation_routes.dart';
import 'package:ramadan_project/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:ramadan_project/features/audio/presentation/bloc/audio_bloc.dart';
import 'package:ramadan_project/features/khatmah/presentation/bloc/khatam_bloc.dart';
import 'package:ramadan_project/features/favorites/domain/entities/favorite_ayah.dart';
import 'package:ramadan_project/features/azkar/data/repositories/azkar_repository.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/features/prayer_times/presentation/bloc/prayer_bloc.dart';
import 'package:ramadan_project/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ramadan_project/features/home/presentation/pages/main_navigation_page.dart';
import 'package:ramadan_project/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:ramadan_project/features/quran/data/datasources/quran_local_datasource.dart';
import 'package:ramadan_project/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:ramadan_project/features/khatmah/domain/repositories/khatmah_repository.dart';
import 'package:ramadan_project/features/khatmah/domain/usecases/calculate_khatam_target.dart';
import 'package:ramadan_project/features/audio/data/repositories/reciter_repository_impl.dart';
import 'package:ramadan_project/features/favorites/data/repositories/favorites_repository.dart';
import 'package:ramadan_project/features/khatmah/data/repositories/khatmah_repository_impl.dart';
import 'package:ramadan_project/features/khatmah/data/datasources/khatmah_local_datasource.dart';
import 'package:ramadan_project/features/prayer_times/data/repositories/prayer_repository_impl.dart'
    as prayer_repo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ramadan_project/features/splash/presentation/pages/splash_page.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/worship_task_model.dart';
import 'package:ramadan_project/features/ramadan_worship/data/models/day_progress_model.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/worship_local_datasource.dart';
import 'package:ramadan_project/features/ramadan_worship/data/repositories/worship_repository_impl.dart';
import 'package:ramadan_project/features/ramadan_worship/domain/repositories/worship_repository.dart';
import 'package:ramadan_project/features/ramadan_worship/presentation/cubit/worship_cubit.dart';
import 'package:ramadan_project/features/ramadan_worship/data/datasources/custom_tasks_datasource.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Disable runtime font fetching - use locally bundled fonts only
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize essential services
  await Future.wait([initializeDateFormatting('ar', null), Hive.initFlutter()]);

  final prefs = await SharedPreferences.getInstance();

  // Register Hive Adapters
  _registerHiveAdapters();

  // Open Hive Boxes
  await Future.wait([Hive.openBox('tasbih'), Hive.openBox('azkar_progress')]);

  // Initialize DataSources & Repositories
  final quranDataSource = QuranLocalDataSource();
  await quranDataSource.init();

  final khatmahDataSource = KhatmahLocalDataSource();
  await khatmahDataSource.init();

  final quranRepository = QuranRepositoryImpl(localDataSource: quranDataSource);
  await quranRepository.init();

  final khatmahRepository = KhatmahRepositoryImpl(
    localDataSource: khatmahDataSource,
    quranLocalDataSource: quranDataSource,
  );

  final favoritesRepository = FavoritesRepository();
  await favoritesRepository.init();

  final worshipDataSource = WorshipLocalDataSourceImpl();
  await worshipDataSource.init();

  final customTasksDataSource = CustomTasksDataSourceImpl();
  await customTasksDataSource.init();

  final worshipRepository = WorshipRepositoryImpl(
    localDataSource: worshipDataSource,
    customTasksDataSource: customTasksDataSource,
  );

  // Initialization complete - remove splash screen
  FlutterNativeSplash.remove();

  runApp(
    MyApp(
      quranRepository: quranRepository,
      khatmahRepository: khatmahRepository,
      favoritesRepository: favoritesRepository,
      worshipRepository: worshipRepository,
      prefs: prefs,
    ),
  );
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0))
    Hive.registerAdapter(UserProgressModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FavoriteAyahAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(KhatmahPlanAdapter());
  if (!Hive.isAdapterRegistered(3))
    Hive.registerAdapter(KhatmahHistoryEntryAdapter());
  if (!Hive.isAdapterRegistered(4))
    Hive.registerAdapter(KhatmahMilestoneAdapter());
  if (!Hive.isAdapterRegistered(5))
    Hive.registerAdapter(WorshipTaskModelAdapter());
  if (!Hive.isAdapterRegistered(6))
    Hive.registerAdapter(DayProgressModelAdapter());
}

class MyApp extends StatelessWidget {
  final QuranRepository quranRepository;
  final KhatmahRepository khatmahRepository;
  final FavoritesRepository favoritesRepository;
  final WorshipRepository worshipRepository;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.quranRepository,
    required this.khatmahRepository,
    required this.favoritesRepository,
    required this.worshipRepository,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: quranRepository),
        RepositoryProvider.value(value: khatmahRepository),
        RepositoryProvider.value(value: favoritesRepository),
        RepositoryProvider.value(value: worshipRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // ... (other blocs)
          BlocProvider(
            create: (context) => KhatamBloc(
              quranRepository: quranRepository,
              khatmahRepository: khatmahRepository,
              calculateKhatamTarget: CalculateKhatamTarget(),
            )..add(LoadKhatamData()),
          ),
          BlocProvider(
            create: (context) =>
                FavoritesBloc(repository: quranRepository)
                  ..add(LoadFavorites()),
          ),
          BlocProvider(
            create: (context) =>
                AzkarBloc(AzkarRepository())..add(LoadAllAzkar()),
          ),
          BlocProvider(
            create: (context) => AudioBloc(
              audioRepository: AudioRepositoryImpl(),
              reciterRepository: ReciterRepositoryImpl(),
            )..add(const AudioStarted()),
          ),
          BlocProvider(
            create: (context) => PrayerBloc(
              repository: prayer_repo.PrayerRepositoryImpl(),
              prefs: prefs,
            )..add(LoadPrayerData()),
          ),
          BlocProvider(
            create: (context) => SearchBloc(repository: quranRepository),
          ),
          BlocProvider(
            create: (context) =>
                WorshipCubit(worshipRepository)..loadDailyProgress(),
          ),
        ],
        child: MaterialApp(
          title: 'زاد',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationRoutes.navigatorKey,
          theme: AppTheme.lightTheme,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
        ),
      ),
    );
  }
}
