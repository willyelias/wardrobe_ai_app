import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/calendar_log.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/clothing_image_view.dart';
import '../../widgets/empty_state.dart';
import 'schedule_look_dialog.dart';
import 'smart_packing_dialog.dart';

/// Aba 3: Calendário de Histórico e Planejamento de Looks
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  String _formatSelectedDate(DateTime dt) {
    try {
      return DateFormat('d \'de\' MMMM', 'pt_BR').format(dt);
    } catch (_) {
      return DateFormat.yMMMMd().format(dt);
    }
  }

  void _showPickOutfitForDateSheet(BuildContext context, DateTime targetDate) {
    final savedOutfits = ref.read(stylistProvider).savedOutfits;

    if (savedOutfits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum look salvo ainda! Gere looks na aba IA Stylist primeiro.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escolher Look para Vincular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: savedOutfits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final outfit = savedOutfits[index];
                  return AppleCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ScheduleLookDialog(
                          outfit: outfit,
                          initialDate: targetDate,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.sparkles, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                outfit.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${outfit.occasion} • ${outfit.itemIds.length} peças',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.textTertiary),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final selectedDate = calendarState.selectedDay;
    final dayLogs = calendarState.selectedDayLogs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bag),
            tooltip: 'Mala de Viagem Inteligente',
            onPressed: () => SmartPackingDialog.show(context),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.today),
            tooltip: 'Ir para Hoje',
            onPressed: () {
              final now = DateTime.now();
              ref.read(calendarProvider.notifier).selectDay(now, now);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de Acesso Rápido à Mala Inteligente
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AppleCard(
                padding: const EdgeInsets.all(14),
                onTap: () => SmartPackingDialog.show(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.bag_fill, color: AppColors.primaryBlack, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mala de Viagem Inteligente',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Método cápsula 5-4-3-2-1 com checklist interativo.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),

            // Widget de Calendário Estilo Apple
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppleCard(
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: calendarState.focusedDay,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => isSameDay(calendarState.selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    ref.read(calendarProvider.notifier).selectDay(selectedDay, focusedDay);
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  eventLoader: (day) {
                    return calendarState.hasLogsOnDay(day) ? ['has_outfit'] : [];
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    leftChevronIcon: Icon(CupertinoIcons.chevron_left, size: 18),
                    rightChevronIcon: Icon(CupertinoIcons.chevron_right, size: 18),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    weekendTextStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    markerSize: 6,
                    markerMargin: const EdgeInsets.only(top: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cabeçalho dos Looks do Dia Selecionado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatSelectedDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showPickOutfitForDateSheet(context, selectedDate),
                    icon: const Icon(CupertinoIcons.plus, size: 16),
                    label: const Text(
                      'Vincular Look',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Lista de Looks do Dia
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: dayLogs.isEmpty
                  ? EmptyState(
                      icon: CupertinoIcons.calendar_today,
                      title: 'Nenhum look para este dia',
                      description: 'Planeje sua roupa com antecedência ou registre o look que vestiu.',
                      actionLabel: 'Atrelar Look Salvo',
                      onAction: () => _showPickOutfitForDateSheet(context, selectedDate),
                    )
                  : Column(
                      children: dayLogs.map((log) => _buildDayLogCard(context, log)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLogCard(BuildContext context, CalendarLog log) {
    final outfit = log.outfit;
    if (outfit == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppleCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    outfit.occasion.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.trash, size: 16, color: AppColors.textTertiary),
                  onPressed: () => ref.read(calendarProvider.notifier).deleteLog(log.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              outfit.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Nota: ${log.notes}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Miniaturas das peças do look
            if (outfit.items.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: outfit.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final piece = outfit.items[i];
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClothingImageView(item: piece, borderRadius: 10),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
