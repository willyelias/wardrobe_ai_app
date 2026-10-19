import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';

class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSheet(),
    );
  }

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isEmailMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = user.isLoggedIn;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                      Text(
                        isLoggedIn ? 'MINHA CONTA & NUVEM' : 'SINCRONIZAÇÃO EM NUVEM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoggedIn ? 'Perfil e Backup' : 'Conecte sua Conta',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
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
                if (!isLoggedIn) ...[
                  _buildGuestBanner(),
                  const SizedBox(height: 24),

                  if (!_isEmailMode) ...[
                    // Google Sign In Button
                    _buildGoogleButton(),
                    const SizedBox(height: 14),

                    // Email Option Switch
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _isEmailMode = true),
                      icon: const Icon(Icons.email_outlined, color: AppColors.primaryBlack),
                      label: const Text(
                        'Entrar com E-mail',
                        style: TextStyle(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Email Form
                    _buildEmailForm(),
                  ],
                ] else ...[
                  // Logged in User Card
                  _buildLoggedInCard(user),
                  const SizedBox(height: 24),

                  // Cloud Sync Section
                  _buildSyncControls(authState),
                  const SizedBox(height: 24),

                  // Logout button
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Container(
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_sync_rounded, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Salve suas roupas na nuvem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ao conectar sua conta, todas as suas peças, fotos, looks do estilista e seu avatar serão salvos automaticamente. Você poderá acessar tudo em qualquer outro smartphone ou tablet.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          final success = await ref.read(authProvider.notifier).signInWithGoogle();
          if (success && mounted) {
            ref.read(wardrobeProvider.notifier).loadClothes();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.g_mobiledata_rounded,
                size: 24,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continuar com o Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Container(
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
            'Entrar com seu E-mail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Seu melhor e-mail',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (_emailCtrl.text.trim().isEmpty) return;
                await ref.read(authProvider.notifier).signInWithEmail(
                      email: _emailCtrl.text.trim(),
                      name: _nameCtrl.text.trim(),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Entrar e Sincronizar'),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isEmailMode = false),
            child: const Center(
              child: Text(
                'Voltar para opções',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInCard(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.cardBackground,
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 16, color: Colors.blue),
                  ],
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Conta Ativa • Conectado via ${user.authMethod == AuthMethod.google ? "Google" : "E-mail"}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncControls(AuthState authState) {
    final user = authState.user;
    final lastSync = user.lastSyncAt;
    final dateStr = lastSync != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(lastSync)
        : 'Ainda não sincronizado';

    return Container(
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
              Icon(Icons.cloud_done_rounded, color: Colors.green.shade700, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Status da Nuvem',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Última sincronização: $dateStr',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (authState.syncMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              authState.syncMessage!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: authState.isSyncing
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).syncToCloud();
                        },
                  icon: authState.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Sincronizar Agora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: authState.isSyncing
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).restoreFromCloud();
                          ref.read(wardrobeProvider.notifier).loadClothes();
                        },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Restaurar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlack,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
