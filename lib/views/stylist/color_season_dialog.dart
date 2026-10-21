import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/color_season_provider.dart';
import '../../services/color_season_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';

class ColorSeasonDialog extends ConsumerStatefulWidget {
  const ColorSeasonDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ColorSeasonDialog(),
    );
  }

  @override
  ConsumerState<ColorSeasonDialog> createState() => _ColorSeasonDialogState();
}

class _ColorSeasonDialogState extends ConsumerState<ColorSeasonDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Foto e estado de análise
  File? _selfieFile;
  bool _isProcessing = false;
  ColorAnalysisResult? _analysisResult;

  // Draping interativo selecionado
  Color _activeDrapeColor = const Color(0xFFC0392B); // Inicia com Terracota
  String _activeDrapeLabel = 'Outono Quente (Terracota)';

  // Quiz manual
  int _selectedUndertone = 1;
  int _selectedIntensity = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Carrega resultado prévio se existir no provider
    final state = ref.read(colorSeasonProvider);
    if (state.lastAnalysis != null) {
      _analysisResult = state.lastAnalysis;
      _selfieFile = state.selfieFile;
      _activeDrapeColor = state.currentSeason.sampleColors.first;
      _activeDrapeLabel = '${state.currentSeason.name} (${state.currentSeason.bestColorNames.first})';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );

      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _selfieFile = file;
          _isProcessing = true;
        });

        final result = await ref.read(colorSeasonProvider.notifier).runPhotoAnalysis(file);

        if (mounted) {
          setState(() {
            _analysisResult = result;
            _isProcessing = false;
            _activeDrapeColor = result.season.sampleColors.first;
            _activeDrapeLabel = '${result.season.name} (${result.season.bestColorNames.first})';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar foto: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _applyDrape(Color color, String label) {
    setState(() {
      _activeDrapeColor = color;
      _activeDrapeLabel = label;
    });
  }

  Widget _buildOptionTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryBlack : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonState = ref.watch(colorSeasonProvider);
    final activeSeason = seasonState.currentSeason;

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
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
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, size: 18, color: AppColors.accentBronze),
                          const SizedBox(width: 8),
                          Text(
                            'COLORAÇÃO PESSOAL IA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Descubra sua Cartela de Cores',
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

          // Tab Bar Superior Apple-style
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: '📸 Selfie / IA'),
                Tab(text: '🎨 Cartelas'),
                Tab(text: '📝 Quiz'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Análise Facial por Selfie (Draping Virtual)
                _buildSelfieAnalysisTab(context),

                // Aba 2: Todas as Cartelas
                _buildAllSeasonsTab(context, activeSeason),

                // Aba 3: Quiz de Subtom
                _buildQuizTab(context, activeSeason),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ABA 1: ANÁLISE POR SELFIE + DRAPING VIRTUAL
  // ==========================================
  Widget _buildSelfieAnalysisTab(BuildContext context) {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(radius: 20),
            const SizedBox(height: 18),
            const Text(
              'Escaneando Subtom Facial...',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
            ),
            const SizedBox(height: 6),
            Text(
              'Avaliando temperatura da pele, contraste natural e luminosidade.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_selfieFile == null) {
      // Estado Inicial: Instruções e botões de câmera
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.face_retouching_natural_rounded, color: Colors.amber.shade900, size: 26),
                    const SizedBox(width: 10),
                    const Text(
                      'Análise Facial com Câmera (IA)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Descubra sua cartela sazonal com o método científico de consultoria de imagem. Nossa IA extrai os pigmentos da pele e testa os tecidos virtuais (drapes) no seu rosto.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF92400E), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dicas para melhor resultado
          const Text(
            'Recomendações para a foto perfeita:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildTipItem(Icons.wb_sunny_outlined, 'Luz natural indireta (em frente a uma janela de dia).'),
          _buildTipItem(Icons.face_outlined, 'Rosto limpo, sem maquiagem pesada ou filtros artificiais.'),
          _buildTipItem(Icons.crop_original_outlined, 'Enquadre o rosto dos ombros até o topo da cabeça.'),
          const SizedBox(height: 24),

          // Botões de captura
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(CupertinoIcons.camera_fill, size: 20),
            label: const Text('Tirar Selfie com a Câmera', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            onPressed: () => _pickPhoto(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(CupertinoIcons.photo, size: 20),
            label: const Text('Escolher Foto da Galeria', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            onPressed: () => _pickPhoto(ImageSource.gallery),
          ),
        ],
      );
    }

    // Foto Capturada + Drapeamento Virtual Interativo + Dossiê
    final res = _analysisResult;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Viewport com a foto do usuário e Tecido Virtual (Drape) em volta do queixo
        Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Foto com moldura
              Container(
                width: 200,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _activeDrapeColor, width: 4),
                  boxShadow: [
                    BoxShadow(color: _activeDrapeColor.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_selfieFile!, fit: BoxFit.cover),
                ),
              ),

              // Tecido Virtual (Drape) simulado sob o rosto
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: _activeDrapeColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Text(
                  _activeDrapeLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botão para refazer foto
        Center(
          child: TextButton.icon(
            onPressed: () => _pickPhoto(ImageSource.camera),
            icon: const Icon(CupertinoIcons.camera, size: 16),
            label: const Text('Tirar Outra Foto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),

        // Seletor de Drapeamento Virtual (Tecidos)
        AppleCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.theater_comedy_outlined, size: 18, color: AppColors.accentBronze),
                  SizedBox(width: 8),
                  Text(
                    'Teste de Drapeamento Virtual (Tecidos)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Toque nos tecidos abaixo para alternar a cor da gola na sua foto e comparar:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Metais: Ouro vs Prata
              const Text('1. Teste de Metais (Temperatura):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        side: BorderSide(color: _activeDrapeLabel.contains('Ouro') ? Colors.black : Colors.transparent, width: 2),
                      ),
                      onPressed: () => _applyDrape(const Color(0xFFD4AF37), 'Drape Ouro Amarelo (Quente)'),
                      child: const Text('🟡 Ouro (Quente)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0C0C0),
                        foregroundColor: Colors.black,
                        side: BorderSide(color: _activeDrapeLabel.contains('Prata') ? Colors.black : Colors.transparent, width: 2),
                      ),
                      onPressed: () => _applyDrape(const Color(0xFFC0C0C0), 'Drape Prata 925 (Frio)'),
                      child: const Text('⚪ Prata (Frio)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Estações
              const Text('2. Teste das 4 Estações Sazonais:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ColorSeasonService.allSeasons.map((s) {
                    final isSel = _activeDrapeLabel.startsWith(s.name);
                    final color = s.sampleColors.first;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selectedColor: color.withValues(alpha: 0.2),
                        avatar: Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        label: Text(s.name, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                        selected: isSel,
                        onSelected: (_) => _applyDrape(color, '${s.name} (${s.bestColorNames.first})'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Dossiê Diagnóstico
        if (res != null) ...[
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Colors.amber, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Veredito da Análise Facial', style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                          Text(res.season.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBlack, letterSpacing: -0.3)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Subtom e Contraste
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Subtom de Pele', style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(res.undertone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contraste Facial', style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(res.contrast, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(res.explanation, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 14),

                // Metais
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.ring_volume_rounded, size: 16, color: AppColors.accentBronze),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                          children: [
                            const TextSpan(text: 'Metais & Acessórios: ', style: TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: res.metalsRecommendation),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Maquiagem
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.brush_rounded, size: 16, color: AppColors.accentBronze),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                          children: [
                            const TextSpan(text: 'Dica de Beleza: ', style: TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: res.makeupAndHairAdvice),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paleta de Cores
                const Text('Cores que mais valorizam você:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: res.season.bestColorNames.map((name) {
                    return Chip(
                      label: Text(name, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.surfaceSubtle,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Cores a evitar
                const Text('Cores a evitar próximas ao rosto:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFC65500))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: res.season.avoidColorNames.map((name) {
                    return Chip(
                      label: Text(name, style: const TextStyle(fontSize: 11, color: Color(0xFFC65500))),
                      backgroundColor: const Color(0xFFFFF3E0),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Salvar "${res.season.name}" como Minha Cartela',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      ref.read(colorSeasonProvider.notifier).selectSeason(res.season.name);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cartela "${res.season.name}" salva com sucesso!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentBronze),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  // ==========================================
  // ABA 2: TODAS AS CARTELAS
  // ==========================================
  Widget _buildAllSeasonsTab(BuildContext context, ColorSeason activeSeason) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        const Text(
          'Explore ou selecione manualmente sua cartela:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        ...ColorSeasonService.allSeasons.map((season) {
          final isSelected = season.name == activeSeason.name;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                ref.read(colorSeasonProvider.notifier).selectSeason(season.name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cartela alterada para "${season.name}"'), duration: const Duration(seconds: 2)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber.shade50.withValues(alpha: 0.6) : AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? Colors.amber.shade700 : AppColors.cardBorder,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          season.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 15,
                            color: isSelected ? Colors.amber.shade900 : AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Ativa', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(season.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    const SizedBox(height: 10),

                    // Círculos de cores da cartela
                    Row(
                      children: season.sampleColors.map((c) {
                        return Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Combina com: ${season.bestColorNames.take(4).join(', ')}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // ABA 3: QUIZ DE SUBTOM
  // ==========================================
  Widget _buildQuizTab(BuildContext context, ColorSeason activeSeason) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Suas veias no pulso e sua reação ao sol:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                title: 'Veias esverdeadas / Pego bronzeado com facilidade (Quente)',
                isSelected: _selectedUndertone == 1,
                onTap: () {
                  setState(() => _selectedUndertone = 1);
                  _updateCalculatedSeason();
                },
              ),
              _buildOptionTile(
                title: 'Veias azuladas ou arroxeadas / Queimo antes de bronzear (Frio)',
                isSelected: _selectedUndertone == 0,
                onTap: () {
                  setState(() => _selectedUndertone = 0);
                  _updateCalculatedSeason();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '2. O contraste entre sua pele, olhos e cabelos:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                title: 'Contraste suave / Tons que se mesclam com naturalidade (Suave)',
                isSelected: _selectedIntensity == 0,
                onTap: () {
                  setState(() => _selectedIntensity = 0);
                  _updateCalculatedSeason();
                },
              ),
              _buildOptionTile(
                title: 'Contraste marcante / Olhos e cabelos bem definidos (Intenso/Brilhante)',
                isSelected: _selectedIntensity == 1,
                onTap: () {
                  setState(() => _selectedIntensity = 1);
                  _updateCalculatedSeason();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlack,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _updateCalculatedSeason,
          child: const Text('Calcular e Salvar Cartela'),
        ),
      ],
    );
  }

  void _updateCalculatedSeason() {
    final calculated = ColorSeasonService.instance.determineSeason(
      undertoneScore: _selectedUndertone,
      intensityScore: _selectedIntensity,
    );
    ref.read(colorSeasonProvider.notifier).selectSeason(calculated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cartela diagnosticada: "$calculated"!'), duration: const Duration(seconds: 2)),
    );
  }
}
