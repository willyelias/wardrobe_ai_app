import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../main_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      badge: 'CLOSET DIGITAL',
      title: 'Seu guarda-roupa\nna palma da mão',
      subtitle:
          'Fotografe suas peças reais. A inteligência artificial remove o fundo instantaneamente e cataloga tudo com elegância.',
      icon: Icons.checkroom_rounded,
    ),
    OnboardingSlide(
      badge: 'PROVADOR VIRTUAL',
      title: 'Seu avatar real\ncom as suas roupas',
      subtitle:
          'Tire uma foto de corpo inteiro. Monte e prove combinações no seu próprio corpo sem precisar trocar de roupa.',
      icon: Icons.accessibility_new_rounded,
    ),
    OnboardingSlide(
      badge: 'IA STYLIST & LOJAS',
      title: 'Looks infinitos &\nonde comprar',
      subtitle:
          'Gerações ilimitadas para qualquer ocasião, análise cromática e busca direta de peças similares em lojas online.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const MainScaffold(),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Top Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 20),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'Pular',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Icon Container
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.pureWhite,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  slide.icon,
                                  size: 64,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                slide.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                height: 1.2,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators and Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primaryBlack
                                  : AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1
                                ? 'Começar Minha Experiência'
                                : 'Continuar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;

  const OnboardingSlide({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
