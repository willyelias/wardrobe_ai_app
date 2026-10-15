import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_log.dart';
import '../../models/outfit.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_colors.dart';

/// Modal para agendar um look em uma data do calendário com notas opcionais
class ScheduleLookDialog extends ConsumerStatefulWidget {
  final Outfit outfit;
  final DateTime? initialDate;

  const ScheduleLookDialog({
    super.key,
    required this.outfit,
    this.initialDate,
  });

  @override
  ConsumerState<ScheduleLookDialog> createState() => _ScheduleLookDialogState();
}

class _ScheduleLookDialogState extends ConsumerState<ScheduleLookDialog> {
  late DateTime _selectedDate;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = CalendarLog.normalizeDate(widget.initialDate ?? DateTime.now());
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = CalendarLog.normalizeDate(picked));
    }
  }

  Future<void> _onConfirm() async {
    setState(() => _isSaving = true);

    try {
      await ref.read(calendarProvider.notifier).linkOutfitToDate(
            date: _selectedDate,
            outfit: widget.outfit,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Look agendado para ${DateFormat('dd/MM/yyyy').format(_selectedDate)}!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao agendar: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(dt);
    } catch (_) {
      return DateFormat.yMMMMEEEEd().format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = _formatDate(_selectedDate);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de arraste
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
          const SizedBox(height: 20),

          const Text(
            'Agendar Look',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.outfit.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Seletor de Data
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.calendar, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data do Planejamento',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Notas / Ocasião do dia
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notas / Compromisso do Dia (Opcional)',
              hintText: 'Ex: Reunião com clientes ou Jantar executivo',
            ),
          ),
          const SizedBox(height: 24),

          // Botão Confirmar
          ElevatedButton(
            onPressed: _isSaving ? null : _onConfirm,
            child: _isSaving
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text('Confirmar Agendamento'),
          ),
        ],
      ),
    );
  }
}
