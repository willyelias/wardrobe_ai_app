import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quota_provider.dart';
import '../../services/ad_manager.dart';
import '../../theme/app_colors.dart';

/// Modal exibido quando o usuário atinge o limite diário de 3 gerações de IA
class RewardedAdDialog extends ConsumerStatefulWidget {
  final VoidCallback onRewardSuccess;

  const RewardedAdDialog({super.key, required this.onRewardSuccess});

  @override
  ConsumerState<RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends ConsumerState<RewardedAdDialog> {
  bool _isLoadingAd = false;

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);

    await AdManager.instance.showRewardedAd(
      onUserEarnedReward: () async {
        // Concede +1 geração bônus
        await ref.read(quotaProvider.notifier).grantBonus();
        if (mounted) {
          Navigator.pop(context);
          widget.onRewardSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('+1 Geração de IA desbloqueada!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      onAdDismissed: () {
        if (mounted) {
          setState(() => _isLoadingAd = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.play_circle_fill,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Liberar Geração de IA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Você utilizou suas 3 gerações gratuitas de hoje.\nAssista a um vídeo rápido patrocinado para liberar a IA para este look!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoadingAd ? null : _watchAd,
              icon: _isLoadingAd
                  ? const CupertinoActivityIndicator(color: Colors.white, radius: 10)
                  : const Icon(CupertinoIcons.film, size: 18),
              label: Text(_isLoadingAd ? 'Carregando vídeo...' : 'Assistir Vídeo (Liberar Look)'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Voltar amanhã',
                style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
