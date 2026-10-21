import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../services/smart_packing_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/clothing_image_view.dart';

class SmartPackingDialog extends ConsumerStatefulWidget {
  const SmartPackingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SmartPackingDialog(),
    );
  }

  @override
  ConsumerState<SmartPackingDialog> createState() => _SmartPackingDialogState();
}

class _SmartPackingDialogState extends ConsumerState<SmartPackingDialog> {
  final _destinationCtrl = TextEditingController(text: 'Rio de Janeiro');
  int _days = 4;
  String _theme = 'Lazer';
  TravelCapsule? _capsule;
  final Set<String> _checkedItems = {};

  final List<String> _themes = const ['Lazer', 'Trabalho', 'Praia', 'Inverno'];

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  void _generateCapsule(List<ClothingItem> allClothes) {
    final dest = _destinationCtrl.text.trim().isEmpty ? 'Viagem' : _destinationCtrl.text.trim();
    final capsule = SmartPackingService.instance.generateCapsule(
      destination: dest,
      days: _days,
      tripTheme: _theme,
      allClothes: allClothes,
    );
    setState(() => _capsule = capsule);
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.luggage_outlined, size: 18, color: AppColors.primaryBlack),
                          const SizedBox(width: 8),
                          Text(
                            'ASSISTENTE DE VIAGEM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mala de Viagem Cápsula',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                if (_capsule == null) ...[
                  // Trip settings form
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Destino da Viagem',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _destinationCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ex: Gramado, Paris, Florianópolis...',
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Days counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Duração:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: _days > 1 ? () => setState(() => _days--) : null,
                                ),
                                Text(
                                  '$_days dias',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: _days < 14 ? () => setState(() => _days++) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Theme selector
                        const Text(
                          'Estilo / Clima Predominante:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _themes.map((t) {
                            final isSel = _theme == t;
                            return ChoiceChip(
                              label: Text(t),
                              selected: isSel,
                              onSelected: (_) => setState(() => _theme = t),
                              selectedColor: AppColors.primaryBlack,
                              backgroundColor: AppColors.cardBackground,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.primaryBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _generateCapsule(wardrobe.allClothes),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text(
                              'Calcular Mala Cápsula',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlack,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Results Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.amber, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_capsule!.days} dias em ${_capsule!.destination}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                'Apenas ${_capsule!.packedClothes.length} peças geram ${_capsule!.generatedTripOutfits.length} looks completos!',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _capsule = null),
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Capsule clothes section
                  const Text(
                    'Peças para Colocar na Mala:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _capsule!.packedClothes.length,
                      itemBuilder: (context, index) {
                        final item = _capsule!.packedClothes[index];
                        return Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  child: ClothingImageView(imagePath: item.imagePath, fit: BoxFit.contain),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Checklist Section
                  const Text(
                    'Checklist de Bagagem & Itens Essenciais:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ..._capsule!.travelEssentialsChecklist.map((essential) {
                    final isChecked = _checkedItems.contains(essential);
                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _checkedItems.add(essential);
                          } else {
                            _checkedItems.remove(essential);
                          }
                        });
                      },
                      title: Text(
                        essential,
                        style: TextStyle(
                          fontSize: 13,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? Colors.grey : AppColors.primaryBlack,
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
