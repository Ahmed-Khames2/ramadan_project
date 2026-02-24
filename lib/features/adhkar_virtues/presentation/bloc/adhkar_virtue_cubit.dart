import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/adhkar_virtue.dart';
import '../../domain/repositories/adhkar_virtue_repository.dart';

// States
abstract class AdhkarVirtueState extends Equatable {
  const AdhkarVirtueState();
  @override
  List<Object?> get props => [];
}

class AdhkarVirtueInitial extends AdhkarVirtueState {}

class AdhkarVirtueLoading extends AdhkarVirtueState {}

class AdhkarVirtueLoaded extends AdhkarVirtueState {
  final List<AdhkarVirtue> adhkar;
  final List<AdhkarVirtue> filteredAdhkar;
  final int activeCategory; // 0: All, 1: Morning, 2: Evening
  final Map<int, bool> readStatuses;
  final List<int> customOrder;

  const AdhkarVirtueLoaded({
    required this.adhkar,
    required this.filteredAdhkar,
    this.activeCategory = 0,
    required this.readStatuses,
    required this.customOrder,
  });

  @override
  List<Object?> get props => [
    adhkar,
    filteredAdhkar,
    activeCategory,
    readStatuses,
    customOrder,
  ];

  AdhkarVirtueLoaded copyWith({
    List<AdhkarVirtue>? adhkar,
    List<AdhkarVirtue>? filteredAdhkar,
    int? activeCategory,
    Map<int, bool>? readStatuses,
    List<int>? customOrder,
  }) {
    return AdhkarVirtueLoaded(
      adhkar: adhkar ?? this.adhkar,
      filteredAdhkar: filteredAdhkar ?? this.filteredAdhkar,
      activeCategory: activeCategory ?? this.activeCategory,
      readStatuses: readStatuses ?? this.readStatuses,
      customOrder: customOrder ?? this.customOrder,
    );
  }
}

class AdhkarVirtueError extends AdhkarVirtueState {
  final String message;
  const AdhkarVirtueError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AdhkarVirtueCubit extends Cubit<AdhkarVirtueState> {
  final AdhkarVirtueRepository repository;
  final SharedPreferences prefs;

  static const String _kReadStatusKey = 'adhkar_read_statuses';
  static const String _kCustomOrderKey = 'adhkar_custom_order';

  List<AdhkarVirtue> _allAdhkar = [];

  AdhkarVirtueCubit({required this.repository, required this.prefs})
    : super(AdhkarVirtueInitial());

  Future<void> loadAdhkar() async {
    emit(AdhkarVirtueLoading());
    try {
      _allAdhkar = await repository.getAdhkarVirtues();

      // Load read statuses
      final savedStatuses = prefs.getStringList(_kReadStatusKey) ?? [];
      final readStatuses = {
        for (var idStr in savedStatuses) int.parse(idStr): true,
      };

      // Load custom order
      final savedOrder = prefs.getStringList(_kCustomOrderKey) ?? [];
      final customOrderIndices = savedOrder.map(int.parse).toList();

      if (customOrderIndices.isNotEmpty &&
          customOrderIndices.length == _allAdhkar.length) {
        _applyCustomOrder(customOrderIndices);
      } else {
        // Initialize order if not present or mismatch
        _allAdhkar.sort((a, b) => a.order.compareTo(b.order));
      }

      emit(
        AdhkarVirtueLoaded(
          adhkar: _allAdhkar,
          filteredAdhkar: _allAdhkar,
          readStatuses: readStatuses,
          customOrder: _allAdhkar.map((e) => e.order).toList(),
        ),
      );
    } catch (e) {
      emit(AdhkarVirtueError('فشل تحميل الأذكار: $e'));
    }
  }

  void toggleReadStatus(int order) {
    if (state is AdhkarVirtueLoaded) {
      final currentState = state as AdhkarVirtueLoaded;
      final newStatuses = Map<int, bool>.from(currentState.readStatuses);

      if (newStatuses[order] == true) {
        newStatuses.remove(order);
      } else {
        newStatuses[order] = true;
      }

      // Persist
      prefs.setStringList(
        _kReadStatusKey,
        newStatuses.keys.map((e) => e.toString()).toList(),
      );

      emit(currentState.copyWith(readStatuses: newStatuses));
    }
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (state is AdhkarVirtueLoaded) {
      final currentState = state as AdhkarVirtueLoaded;

      // Only reorder if we are in "All" category, because reordering in filtered lists is complex
      if (currentState.activeCategory != 0) return;

      final List<AdhkarVirtue> newAllAdhkar = List.from(_allAdhkar);

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = newAllAdhkar.removeAt(oldIndex);
      newAllAdhkar.insert(newIndex, item);

      _allAdhkar = newAllAdhkar;

      final newOrder = _allAdhkar.map((e) => e.order).toList();

      // Persist
      prefs.setStringList(
        _kCustomOrderKey,
        newOrder.map((e) => e.toString()).toList(),
      );

      emit(
        currentState.copyWith(
          adhkar: _allAdhkar,
          filteredAdhkar: _allAdhkar,
          customOrder: newOrder,
        ),
      );
    }
  }

  void _applyCustomOrder(List<int> customOrder) {
    final Map<int, AdhkarVirtue> lookup = {
      for (var item in _allAdhkar) item.order: item,
    };

    final List<AdhkarVirtue> ordered = [];
    for (var order in customOrder) {
      if (lookup.containsKey(order)) {
        ordered.add(lookup[order]!);
      }
    }

    // Add any missing items (in case JSON changed)
    for (var item in _allAdhkar) {
      if (!customOrder.contains(item.order)) {
        ordered.add(item);
      }
    }

    _allAdhkar = ordered;
  }

  void filterByCategory(int categoryIndex) {
    if (state is AdhkarVirtueLoaded) {
      final currentState = state as AdhkarVirtueLoaded;
      List<AdhkarVirtue> filtered;

      if (categoryIndex == 0) {
        filtered = _allAdhkar;
      } else {
        filtered = _allAdhkar.where((a) => a.type == categoryIndex).toList();
      }

      emit(
        currentState.copyWith(
          filteredAdhkar: filtered,
          activeCategory: categoryIndex,
        ),
      );
    }
  }

  void searchAdhkar(String query) {
    if (state is AdhkarVirtueLoaded) {
      final currentState = state as AdhkarVirtueLoaded;
      final filtered = _allAdhkar.where((a) {
        final matchesQuery =
            a.content.contains(query) || a.fadl.contains(query);
        final matchesCategory =
            currentState.activeCategory == 0 ||
            a.type == currentState.activeCategory;
        return matchesQuery && matchesCategory;
      }).toList();

      emit(currentState.copyWith(filteredAdhkar: filtered));
    }
  }
}
