import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gerenciador centralizado de Monetização e Anúncios do Google AdMob.
/// Responsável pelo ciclo de vida, carregamento e exibição de Rewarded Ads e Native Ads.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  bool _isInitialized = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  /// Inicializa o SDK do Google Mobile Ads caso esteja em dispositivo móvel
  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('AdMob ignorado: Plataforma atual não suportada nativamente para anúncios mobile.');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('Google Mobile Ads SDK inicializado com sucesso.');
      loadRewardedAd();
    } catch (e) {
      debugPrint('Falha ao inicializar Google Mobile Ads: $e');
    }
  }

  // ==================== IDs DE TESTE OFICIAIS DO GOOGLE ====================

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return (dotenv.isInitialized ? dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_ANDROID'] : null) ??
          'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return (dotenv.isInitialized ? dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_IOS'] : null) ??
          'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return (dotenv.isInitialized ? dotenv.env['ADMOB_NATIVE_AD_UNIT_ID_ANDROID'] : null) ??
          'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return (dotenv.isInitialized ? dotenv.env['ADMOB_NATIVE_AD_UNIT_ID_IOS'] : null) ??
          'ca-app-pub-3940256099942544/3986624511';
    }
    return '';
  }

  // ==================== REWARDED ADS (ANÚNCIOS RECOMPENSADOS) ====================

  /// Pré-carrega o anúncio de recompensa na memória para exibição instantânea
  void loadRewardedAd() {
    if (!_isInitialized || _isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    debugPrint('Carregando Rewarded Ad (ID: $rewardedAdUnitId)...');

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          debugPrint('Rewarded Ad carregado com sucesso!');

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd(); // Pré-carrega o próximo
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Falha ao exibir Rewarded Ad: $error');
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          _rewardedAd = null;
          debugPrint('Falha no carregamento do Rewarded Ad: $error');
        },
      ),
    );
  }

  /// Exibe o anúncio de recompensa para o usuário e executa o callback ao ser concluído
  Future<void> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) async {
    // Se não estiver em ambiente Android/iOS ou se estiver em emulador sem anúncio carregado:
    if (!_isInitialized || _rewardedAd == null) {
      debugPrint('Modo de Simulação / Fallback de Anúncio Ativado.');
      // Simula a recompensa para permitir testes em qualquer ambiente ou quando sem rede
      onUserEarnedReward();
      onAdDismissed?.call();
      loadRewardedAd();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (adWithoutView, reward) {
        debugPrint('Usuário assistiu ao anúncio e recebeu recompensa: ${reward.amount} ${reward.type}');
        onUserEarnedReward();
      },
    );
  }

  // ==================== NATIVE ADS (ANÚNCIOS NATIVOS) ====================

  /// Cria e carrega uma instância de NativeAd integrada à interface
  NativeAd? createNativeAd({
    required void Function(NativeAd ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    if (!_isInitialized || nativeAdUnitId.isEmpty) return null;

    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile', // ou factory customizada
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as NativeAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );

    nativeAd.load();
    return nativeAd;
  }
}
