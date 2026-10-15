import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../services/background_removal_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_chip.dart';

/// Modal bottom sheet para cadastrar nova peça fotografada ou importada
class AddItemSheet extends ConsumerStatefulWidget {
  final File initialImageFile;

  const AddItemSheet({super.key, required this.initialImageFile});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _colorController;

  late File _currentImageFile;
  bool _removeBackground = true;
  bool _isProcessingBackground = false;
  ClothingCategory _selectedCategory = ClothingCategory.top;
  final Set<String> _selectedOccasions = {'Casual', 'Trabalho'};
  String _selectedSeason = 'Todas';
  bool _isSaving = false;

  final List<String> _allOccasions = [
    'Trabalho',
    'Casual',
    'Balada',
    'Frio',
    'Encontro',
    'Esporte',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _colorController = TextEditingController(text: 'Neutro');
    _currentImageFile = widget.initialImageFile;

    // Inicia a remoção de fundo automaticamente ao abrir se a flag estiver ativa
    if (_removeBackground) {
      _applyBackgroundRemoval();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _applyBackgroundRemoval() async {
    setState(() => _isProcessingBackground = true);
    try {
      final processed = await BackgroundRemovalService.instance.removeBackground(_currentImageFile);
      if (mounted) {
        setState(() {
          _currentImageFile = processed;
          _isProcessingBackground = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao remover fundo: $e');
      if (mounted) {
        setState(() => _isProcessingBackground = false);
      }
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Salva imagem no armazenamento permanente local do app
      final savedPath = await StorageService.instance.saveImagePermanently(_currentImageFile);

      final newItem = ClothingItem(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        color: _colorController.text.trim(),
        imagePath: savedPath,
        occasions: _selectedOccasions.toList(),
        season: _selectedSeason,
        createdAt: DateTime.now(),
      );

      await ref.read(wardrobeProvider.notifier).addItem(newItem);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peça adicionada ao seu closet com sucesso!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar peça: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 16),

              const Text(
                'Nova Peça',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Preview da Foto com indicação de IA
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _currentImageFile,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (_isProcessingBackground)
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(color: Colors.white, radius: 14),
                            SizedBox(height: 8),
                            Text(
                              'Removendo Fundo...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Switch de Remoção de Fundo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.wand_stars, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Remoção de Fundo Automática (IA)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _removeBackground,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _removeBackground = val);
                        if (val) {
                          _applyBackgroundRemoval();
                        } else {
                          setState(() => _currentImageFile = widget.initialImageFile);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo Nome
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome da Peça',
                  hintText: 'Ex: Camisa Linho Branca',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome da peça';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Categoria Segmented Picker
              const Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
              const SizedBox(height: 16),

              // Cor e Estação
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Cor Predominante',
                        hintText: 'Ex: Azul Marinho',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSeason,
                      decoration: const InputDecoration(labelText: 'Estação'),
                      items: const [
                        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                        DropdownMenuItem(value: 'Verão', child: Text('Verão')),
                        DropdownMenuItem(value: 'Inverno', child: Text('Inverno')),
                        DropdownMenuItem(value: 'Meia Estação', child: Text('Meia Estação')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSeason = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ocasiões
              const Text(
                'Ocasiões de Uso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allOccasions.map((occ) {
                  final isSel = _selectedOccasions.contains(occ);
                  return CustomChip(
                    label: occ,
                    isSelected: isSel,
                    onTap: () {
                      setState(() {
                        if (isSel) {
                          _selectedOccasions.remove(occ);
                        } else {
                          _selectedOccasions.add(occ);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                child: _isSaving
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text('Salvar no Closet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
