import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../providers/color_season_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../services/purchase_validator_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/clothing_image_view.dart';
import '../../widgets/custom_chip.dart';

class PurchaseValidatorDialog extends ConsumerStatefulWidget {
  const PurchaseValidatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PurchaseValidatorDialog(),
    );
  }

  @override
  ConsumerState<PurchaseValidatorDialog> createState() => _PurchaseValidatorDialogState();
}

class _PurchaseValidatorDialogState extends ConsumerState<PurchaseValidatorDialog> {
  final _nameCtrl = TextEditingController(text: 'Blazer Estruturado');
  final _colorCtrl = TextEditingController(text: 'Caramelo');
  final _priceCtrl = TextEditingController(text: '199.90');
  ClothingCategory _selectedCategory = ClothingCategory.outerwear;
  PurchaseAnalysisResult? _analysis;

  final List<String> _suggestedColors = [
    'Caramelo',
    'Preto',
    'Off-White',
    'Azul Marinho',
    'Terracota',
    'Verde Oliva',
    'Bordô',
    'Bege',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _runAnalysis() {
    final wardrobe = ref.read(wardrobeProvider).allClothes;
    final colorSeason = ref.read(colorSeasonProvider).currentSeason.name;
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.').trim());

    final result = PurchaseValidatorService.instance.analyzeCandidate(
      name: _nameCtrl.text.trim().isEmpty ? 'Nova Peça' : _nameCtrl.text.trim(),
      category: _selectedCategory,
      color: _colorCtrl.text.trim().isEmpty ? 'Neutro' : _colorCtrl.text.trim(),
      price: price,
      allClothes: wardrobe,
      userPalette: colorSeason,
    );

    setState(() => _analysis = result);
  }

  @override
  Widget build(BuildContext context) {
    final colorSeason = ref.watch(colorSeasonProvider).currentSeason;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
                          const Icon(Icons.verified_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'COMPRAS CONSCIENTES',
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
                        'Devo Comprar? (Validador)',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Explicação
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: Colors.amber.shade900, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Está na loja física ou online? Digite os dados da peça para saber se ela multiplica seus looks ou se é uma compra redundante.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.brown.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Formulário da Peça
                AppleCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'O que você está pensando em comprar?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nome
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nome ou Descrição da Peça',
                          hintText: 'Ex: Camisa Linho, Calça Alfaiataria',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Categoria
                      const Text(
                        'Categoria:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ClothingCategory.values.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CustomChip(
                                label: cat.displayName,
                                icon: cat.icon,
                                isSelected: isSel,
                                onTap: () => setState(() => _selectedCategory = cat),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Cor
                      TextField(
                        controller: _colorCtrl,
                        decoration: InputDecoration(
                          labelText: 'Cor da Peça',
                          hintText: 'Ex: Caramelo, Azul Claro, Preto',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _suggestedColors.map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(c, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.surfaceSubtle,
                                side: BorderSide.none,
                                onPressed: () {
                                  setState(() => _colorCtrl.text = c);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Preço (R$)
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Preço na Etiqueta (R\$)',
                          hintText: '199.90',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Botão Analisar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _runAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(CupertinoIcons.sparkles, size: 18),
                          label: const Text(
                            'Analisar Compatibilidade no Guarda-Roupa',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Resultados da Análise
                if (_analysis != null) ...[
                  _buildAnalysisSection(context, _analysis!, colorSeason.name),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, PurchaseAnalysisResult res, String paletteName) {
    Color verdictBg;
    Color verdictText;
    IconData verdictIcon;

    switch (res.verdict) {
      case PurchaseVerdict.recommended:
        verdictBg = const Color(0xFFE8F8EE);
        verdictText = const Color(0xFF1B7A3D);
        verdictIcon = Icons.check_circle_rounded;
        break;
      case PurchaseVerdict.redundant:
        verdictBg = const Color(0xFFFFF3E0);
        verdictText = const Color(0xFFC65500);
        verdictIcon = Icons.warning_amber_rounded;
        break;
      case PurchaseVerdict.niche:
        verdictBg = const Color(0xFFEDF4FF);
        verdictText = const Color(0xFF1565C0);
        verdictIcon = Icons.info_outline_rounded;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card do Veredito
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: verdictBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: verdictText.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(verdictIcon, color: verdictText, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      res.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: verdictText,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                res.headline,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: verdictText.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                res.detailedAdvice,
                style: TextStyle(
                  fontSize: 12.5,
                  color: verdictText.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Análise de Coloração Pessoal
        AppleCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.palette_outlined, size: 18, color: AppColors.accentBronze),
                  const SizedBox(width: 8),
                  Text(
                    'Coloração Pessoal ($paletteName)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: res.colorEvaluation.isDirectMatch
                      ? const Color(0xFFE8F8EE)
                      : (res.colorEvaluation.isUniversal ? const Color(0xFFF0F4F8) : const Color(0xFFFFF7ED)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  res.colorEvaluation.isDirectMatch
                      ? '✓ Harmonia Perfeita na sua cartela'
                      : (res.colorEvaluation.isUniversal
                          ? '✓ Cor Neutra / Universal'
                          : '⚠️ Fora da sua cartela principal'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: res.colorEvaluation.isDirectMatch
                        ? const Color(0xFF1B7A3D)
                        : (res.colorEvaluation.isUniversal ? const Color(0xFF334E68) : const Color(0xFFB45309)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                res.colorEvaluation.explanation,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Custo por Uso Projetado (CPW)
        if (res.estimatedCostPerWear != null) ...[
          AppleCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.price_check_rounded, color: AppColors.primaryBlack, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custo por Uso Projetado',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'R\$ ${res.estimatedCostPerWear!.toStringAsFixed(2)} / uso',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlack,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Baseado em estimativa realista de 15 usos no ano.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Peças Semelhantes já Possuídas (se houver)
        if (res.similarPiecesAlreadyOwned.isNotEmpty) ...[
          const Text(
            'Peças semelhantes que você já tem:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: res.similarPiecesAlreadyOwned.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final item = res.similarPiecesAlreadyOwned[idx];
                return Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClothingImageView(item: item, borderRadius: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
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
          const SizedBox(height: 16),
        ],

        // Peças Compatíveis do seu Armário
        if (res.compatiblePieces.isNotEmpty) ...[
          Text(
            'Combina com estas peças do seu closet (${res.matchingPiecesCount}):',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: res.compatiblePieces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final item = res.compatiblePieces[idx];
                return Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClothingImageView(item: item, borderRadius: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
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
        ],
      ],
    );
  }
}
