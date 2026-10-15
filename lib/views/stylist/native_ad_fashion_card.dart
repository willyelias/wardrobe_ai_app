import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_manager.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';

/// Cartão de Anúncio Nativo elegante camuflado como Dica de Moda / Compre Peças Parecidas
class NativeAdFashionCard extends StatefulWidget {
  const NativeAdFashionCard({super.key});

  @override
  State<NativeAdFashionCard> createState() => _NativeAdFashionCardState();
}

class _NativeAdFashionCardState extends State<NativeAdFashionCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      _nativeAd = AdManager.instance.createNativeAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Falha ao carregar anúncio nativo: $error. Exibindo cartão institucional.');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Erro ao inicializar NativeAd: $e');
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se o Native Ad oficial do Google estiver renderizado com sucesso:
    if (_isAdLoaded && _nativeAd != null) {
      return AppleCard(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge('PARCERIA RECOMENDADA'),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        ),
      );
    }

    // Design System Nativo Minimalista Apple: Dica de Moda & Inspiração
    return AppleCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge('DICA DO STYLIST • PARCERIA'),
              const Icon(CupertinoIcons.sparkles, size: 16, color: AppColors.goldAccent),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Compre Peças Semelhantes em Linho & Algodão Nobre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Peças atemporais de marcas sustentáveis com caimento impecável e paleta neutra para compor combinações versáteis.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Redirecionando para a curadoria de peças selecionadas...'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    side: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explorar Curadoria',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 6),
                      Icon(CupertinoIcons.arrow_up_right, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
