import 'outfit.dart';

/// Registro de look agendado ou vestido em uma data no calendário
class CalendarLog {
  final String id;
  final DateTime date;
  final String outfitId;
  final Outfit? outfit;
  final String? notes;
  final DateTime createdAt;

  const CalendarLog({
    required this.id,
    required this.date,
    required this.outfitId,
    this.outfit,
    this.notes,
    required this.createdAt,
  });

  /// Retorna a data normalizada apenas com Ano-Mês-Dia (sem horário)
  static DateTime normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  CalendarLog copyWith({
    String? id,
    DateTime? date,
    String? outfitId,
    Outfit? outfit,
    String? notes,
    DateTime? createdAt,
  }) {
    return CalendarLog(
      id: id ?? this.id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      outfit: outfit ?? this.outfit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final norm = normalizeDate(date);
    return {
      'id': id,
      'date': norm.toIso8601String().split('T').first, // YYYY-MM-DD
      'outfitId': outfitId,
      'notes': notes ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalendarLog.fromMap(Map<String, dynamic> map, {Outfit? outfit}) {
    final dateStr = map['date'] as String;
    final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    return CalendarLog(
      id: map['id'] as String,
      date: normalizeDate(parsedDate),
      outfitId: map['outfitId'] as String,
      outfit: outfit,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
