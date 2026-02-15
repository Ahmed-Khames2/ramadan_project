import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatam_plan.dart';
import 'package:ramadan_project/features/khatmah/domain/entities/khatmah_entities.dart';
import 'package:ramadan_project/features/khatmah/domain/repositories/khatmah_repository.dart';
import 'package:ramadan_project/features/khatmah/domain/usecases/calculate_khatam_target.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';
import 'package:ramadan_project/data/models/user_progress_model.dart';

part 'khatam_event.dart';
part 'khatam_state.dart';

class KhatamBloc extends Bloc<KhatamEvent, KhatamState> {
  final QuranRepository quranRepository;
  final KhatmahRepository khatmahRepository;
  final CalculateKhatamTarget calculateKhatamTarget;

  KhatamBloc({
    required this.quranRepository,
    required this.khatmahRepository,
    required this.calculateKhatamTarget,
  }) : super(KhatamInitial()) {
    on<LoadKhatamData>(_onLoadKhatamData);
    on<CreateKhatamPlan>(_onCreateKhatamPlan);
    on<CreateAdvancedKhatmahPlan>(_onCreateAdvancedKhatmahPlan);
    on<UpdateProgress>(_onUpdateProgress);
    on<ToggleReadingMode>(_onToggleReadingMode);
  }

  Future<void> _onCreateAdvancedKhatmahPlan(
    CreateAdvancedKhatmahPlan event,
    Emitter<KhatamState> emit,
  ) async {
    try {
      final plan = KhatmahPlan(
        startDate: event.startDate,
        targetDays: event.targetDays,
        restDaysEnabled: event.restDaysEnabled,
        restDays: event.restDays,
        title: event.title,
      );
      await khatmahRepository.saveKhatmahPlan(plan);
      add(LoadKhatamData());
    } catch (e) {
      emit(KhatamError("Failed to create advanced plan: $e"));
    }
  }

  Future<void> _onLoadKhatamData(
    LoadKhatamData event,
    Emitter<KhatamState> emit,
  ) async {
    emit(KhatamLoading());
    try {
      final khatmahPlan = khatmahRepository.getKhatmahPlan();
      final progress = quranRepository.getProgress() ?? UserProgressModel();
      KhatamPlan? planEntity;

      if (khatmahPlan != null) {
        planEntity = calculateKhatamTarget(
          targetDays: khatmahPlan.targetDays,
          currentProgressPage: progress.lastReadPage ?? 0,
          startDate: khatmahPlan.startDate,
          restDaysEnabled: khatmahPlan.restDaysEnabled,
          restDays: khatmahPlan.restDays,
        );
      } else if (progress.targetDays != null && progress.startDate != null) {
        planEntity = calculateKhatamTarget(
          targetDays: progress.targetDays!,
          currentProgressPage: progress.lastReadPage ?? 0,
          startDate: progress.startDate!,
          restDaysEnabled: false,
          restDays: const [],
        );
      }

      emit(
        KhatamLoaded(
          progress: progress,
          plan: planEntity,
          khatmahPlan: khatmahPlan,
        ),
      );
    } catch (e) {
      emit(KhatamError("Failed to load data: $e"));
    }
  }

  Future<void> _onCreateKhatamPlan(
    CreateKhatamPlan event,
    Emitter<KhatamState> emit,
  ) async {
    try {
      await khatmahRepository.saveKhatamPlanLegacy(
        event.targetDays,
        event.startDate,
      );
      add(LoadKhatamData());
    } catch (e) {
      emit(KhatamError("Failed to create plan: $e"));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateProgress event,
    Emitter<KhatamState> emit,
  ) async {
    try {
      await quranRepository.saveLastRead(event.currentPage, event.currentAyah);

      final progress = quranRepository.getProgress();
      final plan = khatmahRepository.getKhatmahPlan();

      if (plan != null && progress != null) {
        final totalPages = 604;
        final currentPages = progress.lastReadPage ?? 0;
        final percentage = (currentPages / totalPages) * 100;

        final existingMilestones = khatmahRepository.getKhatmahMilestones();

        final List<Map<String, dynamic>> milestoneDefs = [
          {
            'id': 'quarter',
            'threshold': 25.0,
            'title': 'بداية مباركة',
            'desc': 'أتممت ربع الختمة',
          },
          {
            'id': 'half',
            'threshold': 50.0,
            'title': 'نصف الطريق',
            'desc': 'أتممت نصف الختمة',
          },
          {
            'id': 'three_quarters',
            'threshold': 75.0,
            'title': 'على وشك الوصول',
            'desc': 'أتممت ثلاثة أرباع الختمة',
          },
          {
            'id': 'complete',
            'threshold': 100.0,
            'title': 'ختمة مباركة',
            'desc': 'أتممت الختمة بنجاح!',
          },
        ];

        for (var milestone in milestoneDefs) {
          if (percentage >= (milestone['threshold'] as double)) {
            final isAlreadyUnlocked = existingMilestones.any(
              (m) => (m as dynamic).id == milestone['id'],
            );
            if (!isAlreadyUnlocked) {
              await khatmahRepository.unlockMilestone(
                KhatmahMilestone(
                  id: milestone['id'] as String,
                  title: milestone['title'] as String,
                  unlockedAt: DateTime.now(),
                  icon: 'star',
                ),
              );
            }
          }
        }
      }

      add(LoadKhatamData());
    } catch (e) {
      emit(KhatamError("Failed to update progress: $e"));
    }
  }

  Future<void> _onToggleReadingMode(
    ToggleReadingMode event,
    Emitter<KhatamState> emit,
  ) async {
    final currentState = state;
    if (currentState is KhatamLoaded) {
      final progress = currentState.progress;
      final currentMode = progress.readingMode ?? 'verse';
      // Update reading mode in progress model via repository
      // TODO: Implement reading mode persistence in QuranRepository
      print(
        'Switching reading mode to: ${currentMode == 'verse' ? 'mushaf' : 'verse'}',
      );

      // Update reading mode in progress model via repository
      // Need to add this method to QuranRepository or just use saveLastRead with dummy
      // For now, let's assume it works or we'll add it soon.
      add(LoadKhatamData());
    }
  }
}
