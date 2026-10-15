import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quota_service.dart';

class QuotaState {
  final int remaining;
  final int usedToday;
  final int bonusToday;
  final int maxDaily;
  final bool isLoading;

  const QuotaState({
    this.remaining = 3,
    this.usedToday = 0,
    this.bonusToday = 0,
    this.maxDaily = 3,
    this.isLoading = false,
  });

  bool get canGenerate => remaining > 0;

  QuotaState copyWith({
    int? remaining,
    int? usedToday,
    int? bonusToday,
    int? maxDaily,
    bool? isLoading,
  }) {
    return QuotaState(
      remaining: remaining ?? this.remaining,
      usedToday: usedToday ?? this.usedToday,
      bonusToday: bonusToday ?? this.bonusToday,
      maxDaily: maxDaily ?? this.maxDaily,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuotaNotifier extends StateNotifier<QuotaState> {
  QuotaNotifier() : super(const QuotaState()) {
    refresh();
  }

  final QuotaService _service = QuotaService.instance;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final remaining = await _service.getRemainingGenerationsToday();
    final used = await _service.getUsedGenerationsToday();
    final bonus = await _service.getBonusGenerationsToday();
    final max = _service.maxDailyFreeGenerations;

    state = state.copyWith(
      remaining: remaining,
      usedToday: used,
      bonusToday: bonus,
      maxDaily: max,
      isLoading: false,
    );
  }

  Future<void> consume() async {
    await _service.consumeGeneration();
    await refresh();
  }

  Future<void> grantBonus() async {
    await _service.grantBonusGeneration();
    await refresh();
  }
}

final quotaProvider = StateNotifierProvider<QuotaNotifier, QuotaState>((ref) {
  return QuotaNotifier();
});
