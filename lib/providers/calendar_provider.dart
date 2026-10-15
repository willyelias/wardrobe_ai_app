import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_log.dart';
import '../models/outfit.dart';
import '../services/database_service.dart';

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<CalendarLog> allLogs;
  final bool isLoading;
  final String? error;

  CalendarState({
    DateTime? focusedDay,
    DateTime? selectedDay,
    this.allLogs = const [],
    this.isLoading = false,
    this.error,
  })  : focusedDay = focusedDay ?? DateTime.now(),
        selectedDay = selectedDay ?? CalendarLog.normalizeDate(DateTime.now());

  List<CalendarLog> get selectedDayLogs {
    final norm = CalendarLog.normalizeDate(selectedDay);
    return allLogs.where((l) => CalendarLog.normalizeDate(l.date) == norm).toList();
  }

  bool hasLogsOnDay(DateTime day) {
    final norm = CalendarLog.normalizeDate(day);
    return allLogs.any((l) => CalendarLog.normalizeDate(l.date) == norm);
  }

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<CalendarLog>? allLogs,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      allLogs: allLogs ?? this.allLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(CalendarState()) {
    loadLogs();
  }

  final DatabaseService _db = DatabaseService.instance;

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _db.getCalendarLogs();
      state = state.copyWith(allLogs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar calendário: $e');
    }
  }

  void selectDay(DateTime selected, DateTime focused) {
    state = state.copyWith(
      selectedDay: CalendarLog.normalizeDate(selected),
      focusedDay: focused,
    );
  }

  Future<void> linkOutfitToDate({
    required DateTime date,
    required Outfit outfit,
    String? notes,
  }) async {
    try {
      final newLog = CalendarLog(
        id: const Uuid().v4(),
        date: CalendarLog.normalizeDate(date),
        outfitId: outfit.id,
        outfit: outfit,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _db.insertCalendarLog(newLog);
      final updated = [newLog, ...state.allLogs];
      state = state.copyWith(allLogs: updated);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao agendar look: $e');
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await _db.deleteCalendarLog(id);
      final updated = state.allLogs.where((l) => l.id != id).toList();
      state = state.copyWith(allLogs: updated);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao remover agendamento: $e');
    }
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});
